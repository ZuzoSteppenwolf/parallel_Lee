import benchmark
from sys import argv
from myUtil.Matrix import Matrix, ListMatrix
from myUtil.Block import Block
from myUtil.Enum import Blocktype
from myUtil.Util import initMap
from myUtil.Logger import Log
from myFormats.Net import Net
from myFormats.Place import Place
from myFormats.Arch import Arch
from collections import Dict, List, Set
from myAlgorithm.Lee import Lee
from memory import ArcPointer
from time import perf_counter
from myFormats.Route import *

"""
@file Main.mojo
Die Applikation implementiert den Labyrinth/Lee-Algorithmus
um anhand einer Netzliste und Platzierungsliste
eine Vernetzungsliste zu erstellen.

Der Algorithmus wird durch echtzeit parallelisierung
erweitert um die Laufzeit zu optimieren. 

@author Marvin Wollbrück
"""
alias LOG_PATH = "log/main.log"
alias STANDARD_CHANEL_WIDTH = 12
alias DEFAULT_MAX_ITERATIONS = 30
var maxIterations = DEFAULT_MAX_ITERATIONS
var channelWidth = STANDARD_CHANEL_WIDTH
var hasFixedChannelWidth = False
var runParallel = True

"""
Main-Methode der Applikation
"""
def main():
    _ = perf_counter()
    args = List[String]()
    for arg in argv():
        args.append(String(arg))

    if len(args) < 5 or "-h" in args or "--help" in args:
        print_help()
        return

    print("Read file ", args[1])
    placement = Place(args[1])
    if not placement.isValid:
        print("Invalid placement file")
        print_duration()
        return

    print("Read file ", args[3])
    arch = Arch(args[3])
    if not arch.isValid:
        print("Invalid architecture file")
        print_duration()
        return

    print("Read file ", args[2])
    netlist = Net(args[2], len(arch.subblocks), arch.pins)
    if not netlist.isValid:
        print("Invalid netlist file")
        print_duration()
        return
    
    if "--route_chan_width" in args:
        idx = args.index("--route_chan_width")
        hasFixedChannelWidth = True
        try:
            channelWidth = atol(args[idx + 1])
        except:
            print("Invalid channel width: ", args[idx + 1])
            print_duration()
            return

    if "--max_iterations" in args:
        idx = args.index("--max_iterations")
        try:
            maxIterations = atol(args[idx + 1])
        except:
            print("Invalid max iterations: ", args[idx + 1])
            print_duration()
            return

    if "--single_thread" in args:
        runParallel = False

    @parameter
    fn compute(chanWidth: Int) -> Lee:
        var clbMap = ListMatrix[List[Block.SharedBlock]](placement.cols+2, placement.rows+2, List[Block.SharedBlock]())
        for clb in placement.archiv.keys():
            try:
                if clb[] in netlist.inpads:
                    var block = Block.SharedBlock(Block(clb[], Blocktype.INPAD, arch.t_ipad))
                    block[].coord = (placement.archiv[clb[]][0], placement.archiv[clb[]][1])
                    clbMap[placement.archiv[clb[]][0], placement.archiv[clb[]][1]].append(block)
                elif clb[] in netlist.outpads:
                    var block = Block.SharedBlock(Block(clb[], Blocktype.OUTPAD, arch.t_opad))
                    block[].coord = (placement.archiv[clb[]][0], placement.archiv[clb[]][1])
                    clbMap[placement.archiv[clb[]][0], placement.archiv[clb[]][1]].append(block)
                else:
                    hasGlobalNet = False
                    for net in netlist.globalNets.keys():
                        for block in netlist.globalNets[net[]]:
                            if block[][0] == clb[]:
                                hasGlobalNet = True
                                break
                        if hasGlobalNet:
                            break
                    delay = 0.0
                    if hasGlobalNet:
                        delay = arch.t_ipin_cblock + arch.subblocks[0].t_seq_in + arch.subblocks[0].t_seq_out
                    else:
                        delay = arch.t_ipin_cblock + arch.subblocks[0].t_comb
                    var block = Block.SharedBlock(Block(clb[], Blocktype.CLB, delay, len(arch.subblocks)))
                    block[].coord = (placement.archiv[clb[]][0], placement.archiv[clb[]][1])
                    clbMap[placement.archiv[clb[]][0], placement.archiv[clb[]][1]].append(block)
            except e:
                print("Error: ", e)
                return Lee()
        return Lee(netlist.nets, clbMap, placement.archiv, chanWidth, arch.switches[0].Tdel, arch.pins)
        
    
    var critPath: Float64 = 0.0
    var route: ArcPointer[Lee] = ArcPointer[Lee](Lee())
    @parameter
    fn calc():          
        for i in range(maxIterations):
            route = ArcPointer[Lee](compute(channelWidth))
            route[].run(runParallel)
            if route[].isValid:
                print("Success", i)
                critPath = route[].getCriticalPath(netlist.outpads)
                break
            else:
                print("Failure", i)

                
    if hasFixedChannelWidth:
        print()
        print("Start routing")
        print("Channel width: ", channelWidth)
        print("----------------")
        calc()
        print("----------------")
        print("Critical path: ", critPath)
        print()
        
    else:
        # binäre Suche für die minimalste Kanal-Breite
        var lowWidth = 0
        var highWidth = channelWidth
        var hasEnd = False
        var bestRoute: ArcPointer[Lee] = ArcPointer[Lee](Lee())
        var bestWidth = channelWidth
        var bestCritPath = critPath
        while not hasEnd:
            print()
            print("Start routing")
            print("Channel width: ", channelWidth)
            print("----------------")
            calc()
            print("----------------")
            print("Critical path: ", critPath)
            print()
            if route[].isValid:
                highWidth = channelWidth
                bestWidth = channelWidth
                bestRoute = route
                bestCritPath = critPath
                channelWidth = (lowWidth + highWidth) // 2
            else:
                lowWidth = channelWidth                
                if lowWidth == highWidth:
                    channelWidth = lowWidth + (highWidth // 2)
                else:
                    channelWidth = (lowWidth + highWidth) // 2
                highWidth = channelWidth
            if channelWidth == lowWidth:
                hasEnd = True
        
        route = bestRoute
        critPath = bestCritPath
        channelWidth = bestWidth

    print()
    if route[].isValid:
        print("Routing successful")
        print("Critical path: ", critPath)
        print("Channel width: ", channelWidth)
        print()
        var netPins: Dict[String, Dict[String, Int]] = Dict[String, Dict[String, Int]]()
        for net in netlist.nets:
            netPins[net[]] = Dict[String, Int]()
            for pin in netlist.nets[net[]]:
                netPins[net[]][pin[][0]] = pin[][1]
        if writeRouteFile(args[4], route[].routeLists, netlist.netList, arch.pins,
            route[].clbMap, placement.clbNums, netPins, netlist.globalNets, placement.archiv):
            print("Routing result written to file")
        else:
            print("Routing result not written to file")
        print()
    else:
        print("Routing failed")
        print()
   
    print()
    print("Routing finished")
    print()
    print_duration()
    return

"""
Hilfsmethode um die Hilfe auszugeben
"""
def print_help():
    print("Usage: ./PLee <placments> <netlist> <architecture> <route> [OPTIONS]")
    print()    
    print("placments: Path to the placments file")
    print("netlist: Path to the netlist file")
    print("architecture: Path to the architecture file")
    print()
    print("Options:")
    print("  -h, --help: Print this help message")
    print("  --route_chan_width <int>: Set the channel width for routing")
    print("    disabled binary search")
    print("  --max_iterations <int>: Set the maximum iterations for the routing")
    print("    disabled binary search")
    print("  --single_thread: Run the algorithm in single thread mode")

def print_duration():
    print("Programm Duration: ", perf_counter(), "ns")
    return