from sys import argv
import Matrix
# @file Main.mojo
# Die Applikation implementiert den Labyrinth/Lee-Algorithmus
# um anhand einer Netzliste und Platzierungsliste
# eine Vernetzungsliste zu erstellen.
#
# Der Algorithmus wird durch echtzeit parallelisierung
# erweitert um die Laufzeit zu optimieren. 
#
# @author Marvin Wollbrück

# Main-Methode der Applikation
def main():
    args = argv()
    #if len(args) < 4 or args[1] == "-h" or args[1] == "--help":
    #    print_help()
    #    return

    var mat = Matrix.Matrix[DType.int8, 5, 5]()
    mat[0, 0] = 1
    num = mat[0, 0]
    mat[0, 1] = num
    print(mat.__str__())
    return

# Hilfsmethode um die Hilfe auszugeben
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

