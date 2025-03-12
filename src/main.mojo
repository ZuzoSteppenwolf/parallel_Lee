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

"""
Main-Methode der Applikation
"""
def main():
    args = argv()
    if len(args) < 4 or args[1] == "-h" or args[1] == "--help":
        print_help()

    #TODO
    print(len(args))
    #placements = Place(String(args[1]))
    placements = Place("test/.place/test_PlaceFormat.place")
    print(placements.isValid)
    
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
    print("  ")
