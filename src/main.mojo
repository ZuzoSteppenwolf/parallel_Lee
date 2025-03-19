from sys import argv
from myUtil.Matrix import Matrix
from myUtil.Block import Block
from myUtil.Enum import Blocktype
from myUtil.Util import initMap
from myFormats.Net import Net
from myFormats.Place import Place
from myFormats.Arch import Arch
from collections import Dict, List, Set
from myAlgorithm.Lee import Route

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
var maxIterations = DEFAULT_MAX_ITERATIONS
var channalWidth = STANDARD_CHANEL_WIDTH
var hasFixedChannelWidth = False

"""
Main-Methode der Applikation
"""
def main():
    args = List[String]()
    for arg in argv():
        args.append(String(arg))

    if len(args) < 4 or "-h" in args or "--help" in args:
        print_help()

    print("Read file ", args[1])
    placement = Place(args[1])
    if not placement.isValid:
        print("Invalid placement file")
        return

    print("Read file ", args[3])
    arch = Arch(args[3])
    if not arch.isValid:
        print("Invalid architecture file")
        return

    print("Read file ", args[2])
    netlist = Net(args[2], len(arch.subblocks), arch.pins)
    if not netlist.isValid:
        print("Invalid netlist file")
        return
    
    if "--route_chan_width" in args:
        idx = args.index("--route_chan_width")
        hasFixedChannelWidth = True
        try:
            channalWidth = atol(args[idx + 1])
        except:
            print("Invalid channel width: ", args[idx + 1])
            return

    if "--max_iterations" in args:
        idx = args.index("--max_iterations")
        try:
            maxIterations = atol(args[idx + 1])
        except:
            print("Invalid max iterations: ", args[idx + 1])
            return

    @parameter
    def compute(chanWidth: Int) -> Route:
        print("Compute")
        clbMap = Matrix[List[Block.SharedBlock]](placement.cols+2, placement.rows+2)
        initMap(clbMap)
        for clb in placement.archiv.keys():
            if clb[] in netlist.inpads:
                var block = Block.SharedBlock(Block(clb[], Blocktype.INPAD, arch.t_ipad))
                clbMap[placement.archiv[clb[]][0], placement.archiv[clb[]][1]].append(block)
            elif clb[] in netlist.outpads:
                var block = Block.SharedBlock(Block(clb[], Blocktype.OUTPAD, arch.t_opad))
                clbMap[placement.archiv[clb[]][0], placement.archiv[clb[]][1]].append(block)
            else:
                hasGlobalNet = False
                for net in netlist.globalNets.keys():
                    hasGlobalNet = clb[] in netlist.globalNets[net[]]
                    if hasGlobalNet:
                        break
                delay = 0.0
                if hasGlobalNet:
                    delay = arch.t_ipin_cblock + arch.subblocks[0].t_seq_in + arch.subblocks[0].t_seq_out
                else:
                    delay = arch.t_ipin_cblock + arch.subblocks[0].t_comb
                var block = Block.SharedBlock(Block(clb[], Blocktype.CLB, delay, len(arch.subblocks)))
                clbMap[placement.archiv[clb[]][0], placement.archiv[clb[]][1]].append(block)
        return Route(netlist.nets, clbMap, chanWidth, arch.switches[0].Tdel, arch.pins)
        
    
    if hasFixedChannelWidth:
        pass
    else:
        pass
    
    return

"""
Hilfsmethode um die Hilfe auszugeben
"""
def print_help():
    print("Usage: mojo main.mojo <placments> <netlist> <architecture> [OPTIONS]")
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
