from sys import argv
from myUtil.Matrix import Matrix
from myFormats.Net import Net
from myFormats.Place import Place
from myFormats.Arch import Arch

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
var CHANNEL_WIDTH = STANDARD_CHANEL_WIDTH
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
            CHANNEL_WIDTH = atol(args[idx + 1])
        except:
            print("Invalid channel width: ", args[idx + 1])
            return
    
    
    
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
