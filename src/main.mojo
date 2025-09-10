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
alias STANDARD_CHANEL_WIDTH = 12
alias DEFAULT_MAX_ITERATIONS = 30
alias LOG_DIRECTORY = "log/"
alias MAX_OPTIONAL_ARGS = 5


"""
Main-Methode der Applikation
"""
def main():
    var maxIterations = DEFAULT_MAX_ITERATIONS
    var channelWidth = STANDARD_CHANEL_WIDTH
    var hasFixedChannelWidth = False
    var runParallel = True
    var validArgs: Int = 0

    args = List[String]()
    for arg in argv():
        args.append(String(arg))

    # auf gültige Optionen prüfen
    if "--route_chan_width" in args:
        idx = args.index("--route_chan_width")
        hasFixedChannelWidth = True
        try:
            channelWidth = atol(args[idx + 1])
            validArgs += 2
        except:
            print("Invalid channel width: ", args[idx + 1])

    if "--max_iterations" in args:
        idx = args.index("--max_iterations")
        try:
            maxIterations = atol(args[idx + 1])
            validArgs += 2
        except:
            print("Invalid max iterations: ", args[idx + 1])

    if "--single_thread" in args:
        runParallel = False
        validArgs += 1

    if len(args) < MAX_OPTIONAL_ARGS or "-h" in args or "--help" in args or len(args) > (validArgs + MAX_OPTIONAL_ARGS):
        print_help()
        return

    # .place Datei auslesen
    print("Read file ", args[1])
    placement = Place(args[1], logDir=LOG_DIRECTORY)
    if not placement.isValid:
        print("Invalid placement file")
        return

    # auf Gültigkeit prüfen
    if not(args[3].split("/")[-1] == placement.arch.split("/")[-1]):
        print("Architecture file is different from placement file: ", args[3], " != ", placement.arch.split("/")[-1])
        return

    if not(args[2].split("/")[-1] == placement.net.split("/")[-1]):
        print("Netlist file is different from placement file: ", args[2], " != ", placement.net.split("/")[-1])
        return

    # .arch Datei auslesen
    print("Read file ", args[3])
    arch = Arch(args[3], logDir=LOG_DIRECTORY)
    if not arch.isValid:
        print("Invalid architecture file")
        return

    # auf Ausführbarkeit prüfen
    if arch.subblocks_per_clb > 1:
        print("Multiple subblocks in architecture file not supported")
        return

    if arch.chan_width_io < 1 or arch.chan_width_x.peak < 1 or arch.chan_width_y.peak < 1:
        print("Fractional channel width not supported, must be 1")
        return

    if arch.chan_width_x.type != ChanType.UNIFORM or arch.chan_width_y.type != ChanType.UNIFORM:
        print("Non-uniform channel width not supported")
        return

    if len(arch.segments) > 1:
        print("Multiple segments in architecture file not supported")
        return

    if len(arch.switches) > 1:
        print("Multiple switches in architecture file not supported")
        return

    if arch.segments[0].isLongline or arch.segments[0].length > 1:
        print("Longline segments or segments with length > 1 not supported")
        return
    
    if arch.segments[0].frac_cb < 1 or arch.segments[0].frac_sb < 1:
        print("Fractional switch/connection block not supported, must be 1")
        return

    if arch.switch_block_type != SwitchType.SUBSET:
        print("Only subset switch block type supported")
        return

    if arch.fc_type != FcType.FRACTIONAL:
        print("Only fractional connection between input, output, pad pins and channels supported")
        return

    if arch.fc_input != 1 or arch.fc_output != 1 or arch.fc_pad != 1:
        print("Only full connection between input, output, pad pins and channels supported")
        return

    # .net Datei auslesen
    print("Read file ", args[2])
    netlist = Net(args[2], len(arch.subblocks), arch.pins, logDir=LOG_DIRECTORY)
    if not netlist.isValid:
        print("Invalid netlist file")
        return

    print()
    print("In total ", len(netlist.netList), " nets")
    print(len(netlist.globalNets), " are global nets")
    print(len(netlist.nets), " to be routed")

    # Algorithmus Initialisieren
    # @arg chanWidth: Kanal-Breite
    # @return: Lee-Objekt
    @parameter
    fn compute(chanWidth: Int) -> Lee:
        var clbMap = ListMatrix[List[Block.SharedBlock]](placement.cols+2, placement.rows+2, List[Block.SharedBlock]())
        # Pads und CLBs in Array übertragen(erzeugen)
        for clb in placement.archiv.keys():
            try:
                if clb in netlist.inpads:
                    var block = Block.SharedBlock(Block(clb, Blocktype.INPAD, arch.t_ipad))
                    block[].coord = (placement.archiv[clb][0], placement.archiv[clb][1])
                    block[].subblk = placement.clbSubblk[clb]
                    clbMap[placement.archiv[clb][0], placement.archiv[clb][1]].append(block)

                elif clb in netlist.outpads:
                    var block = Block.SharedBlock(Block(clb, Blocktype.OUTPAD, arch.t_opad))
                    block[].coord = (placement.archiv[clb][0], placement.archiv[clb][1])
                    block[].subblk = placement.clbSubblk[clb]
                    clbMap[placement.archiv[clb][0], placement.archiv[clb][1]].append(block)
                
                else:
                    hasGlobalNet = False
                    for net in netlist.globalNets.keys():
                        for block in netlist.globalNets[net]:
                            if block[0] == clb:
                                hasGlobalNet = True
                                break
                        if hasGlobalNet:
                            break
                    delay = 0.0

                    if hasGlobalNet:
                        delay = arch.t_ipin_cblock
                    else:
                        delay = arch.t_ipin_cblock + arch.subblocks[0].t_comb
                    var block = Block.SharedBlock(Block(clb, Blocktype.CLB, delay, len(arch.subblocks)))
                    block[].coord = (placement.archiv[clb][0], placement.archiv[clb][1])
                    block[].subblk = placement.clbSubblk[clb]
                    if hasGlobalNet:
                        block[].hasGlobal = True
                    clbMap[placement.archiv[clb][0], placement.archiv[clb][1]].append(block)
            except e:
                print("Error: ", e)
                return Lee()
        return Lee(netlist.nets, clbMap, placement.archiv, chanWidth, arch.switches[0].Tdel, arch.pins, placement.clbNums, logDir=LOG_DIRECTORY)
        
    
    var critPath: Float64 = 0.0
    var route: ArcPointer[Lee] = ArcPointer[Lee](Lee())

    # Algorithmus ausführen für maxIterations
    @parameter
    fn calc():          
        for i in range(maxIterations):
            route = ArcPointer[Lee](compute(channelWidth))
            route[].run(runParallel)
            if route[].isValid:
                print("Success", i)
                critPath = route[].getCriticalPath(netlist.outpads, arch.subblocks[0].t_seq_in, arch.subblocks[0].t_seq_out)
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
        print("t_crit: ", critPath)
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
            critPath = 0.0
            print()
            print("Start routing")
            print("Channel width: ", channelWidth)
            print("----------------")           
            calc()
            print("----------------")
            print("t_crit: ", critPath)
            print()
            # Kanalbreite nach unten anpassen
            if route[].isValid:
                highWidth = channelWidth
                bestWidth = channelWidth
                bestRoute = route
                bestCritPath = critPath
                channelWidth = (lowWidth + highWidth) // 2

            # Kanalbreite nach oben anpassen, aber unterhalb einer erfolgreichen Breite
            else:
                lowWidth = channelWidth                
                if lowWidth == highWidth:
                    channelWidth = lowWidth + (highWidth // 2)
                    highWidth = channelWidth
                else:
                    channelWidth = (lowWidth + highWidth) // 2
                    
            if channelWidth == lowWidth:
                hasEnd = True
        
        route = bestRoute
        critPath = bestCritPath
        channelWidth = bestWidth

    print()
    if route[].isValid:
        print("Routing successful")
        print("Lowest Channel width: ", channelWidth)
        print("Critical path: ", critPath)
        print()

        if writeRouteFile(args[4], route[].routeLists, netlist.netList, arch.pins,
            (route[].clbMap.cols-2, route[].clbMap.rows-2), placement.clbNums, netlist.globalNets, placement.archiv):
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
    return

"""
Hilfsmethode um die Hilfe auszugeben
"""
def print_help():
    print("Usage: ./lee <placments> <netlist> <architecture> <route> [OPTIONS]")
    print()    
    print("placments: Path to the placments file")
    print("netlist: Path to the netlist file")
    print("architecture: Path to the architecture file")
    print("route: Path to the output route file")
    print()
    print("Options:")
    print("  -h, --help: Print this help message")
    print("  --route_chan_width <int>: Set the channel width for routing")
    print("    disabled binary search")
    print("  --max_iterations <int>: Set the maximum iterations for the routing")
    print("  --single_thread: Run the algorithm in single thread mode")
