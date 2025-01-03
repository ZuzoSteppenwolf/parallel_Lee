from sys import argv
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
    if len(args) < 3 or args[1] == "-h" or args[1] == "--help":
        print_help()
        return

# Hilfsmethode um die Hilfe auszugeben
def print_help():
    print("Usage: mojo main.mojo <netlist> <placments> [OPTIONS]")
    print()
    print("netlist: Path to the netlist file")
    print("placments: Path to the placments file")
    print()
    print("Options:")
    print("  -h, --help: Print this help message")
    print("  ")