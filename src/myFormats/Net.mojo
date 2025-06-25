from collections import Dict, List, Set, Optional
from myUtil.Util import clearUpLines
from myUtil.Logger import Log
from myFormats.Arch import Pin
"""
@file Net.mojo

Parser für das Net File Format vom VPR Tool

@author Marvin Wollbrück
"""

"""
Datenstruktur für die Netliste eines FPGA-Designs.
"""
@value
struct Net:
    var isValid: Bool
    var nets: Dict[String, List[Tuple[String, Int]]]
    var globalNets: Dict[String, List[Tuple[String, Int]]]
    var inpads: Set[String]
    var outpads: Set[String]
    var clbs: Set[String]
    var netList: List[String]
    var log: Optional[Log[True]]

    # Konstruktor
    # @arg path: Pfad zur Netliste
    # @arg sbblknum: Anzahl der Subblöcke
    # @arg pins: Liste der Pins, die in der Netliste verwendet werden
    fn __init__(out self, path: String, sbblknum: Int8, pins: List[Pin]):
        self.nets = Dict[String, List[Tuple[String, Int]]]()
        self.globalNets = Dict[String, List[Tuple[String, Int]]]()
        self.isValid = False
        self.inpads = Set[String]()
        self.outpads = Set[String]()
        self.clbs = Set[String]()
        self.netList = List[String]()
        try:
            self.log = Log[True]("log/net.log")
        except:
            self.log = None
        self.isValid = self.parse(path, sbblknum, pins)
        
    # Copy-Konstruktor
    fn __copyinit__(out self, other: Net):
        self.nets = other.nets
        self.globalNets = other.globalNets
        self.isValid = other.isValid
        self.inpads = Set[String](other.inpads)
        self.outpads = Set[String](other.outpads)
        self.clbs = Set[String](other.clbs)
        self.netList = List[String](other.netList)
        self.log = other.log

    # Liest die Netliste und speichert die Informationen in der Struktur
    # @arg path: Pfad zur Netliste
    # @arg sbblknum: Anzahl der Subblöcke
    # @arg pins: Liste der Pins, die in der Netliste verwendet werden
    # @return: True, wenn die Datei erfolgreich gelesen wurde, sonst False
    fn parse(mut self, path: String, sbblknum: Int8, pins: List[Pin]) -> Bool:
        try:
            var lines: List[String]
            with open(path, "r") as file:
                lines = file.read().split("\n")
            lines = clearUpLines(lines)
            if len(lines) == 0:
                return False
            while len(lines) > 0:
                var line = lines.pop(0)
                var words = line.split()

                # Parser für Inpad
                if words[0] == ".input":
                    var name = words[1]
                    self.inpads.add(name)
                    line = lines.pop(0)
                    words = line.split()
                    if words[0] != "pinlist:":
                        if self.log:
                            self.log.value().writeln("Error: 'pinlist:' nicht gefunden; ", words[0])
                        return False
                    var net = words[1]
                    if net in self.globalNets:
                        self.addToGlobalNets(net, name, -1)
                    else:
                        self.addToNets(net, name, -1)
                    
                # Parser für Outpad
                elif words[0] == ".output":
                    var name = words[1]
                    self.outpads.add(name)
                    line = lines.pop(0)
                    words = line.split()
                    if words[0] != "pinlist:":
                        if self.log:
                            self.log.value().writeln("Error: 'pinlist:' nicht gefunden; ", words[0])
                        return False
                    var net = words[1]
                    if net in self.globalNets:
                        self.addToGlobalNets(net, name, -1, True)
                    else:
                        self.addToNets(net, name, -1, True)
                    
                # Parser für globale Netze
                # Setzt ein globales Netz, das nicht ein Block ist
                elif words[0] == ".global":
                    var name = words[1]
                    self.addToGlobalNets(name)

                # Parser für Logikblöcke
                elif words[0] == ".clb":
                    var name = words[1]
                    self.clbs.add(name)
                    line = lines.pop(0)
                    words = line.split()
                    if words[0] != "pinlist:":
                        if self.log:
                            self.log.value().writeln("Error: 'pinlist:' nicht gefunden; ", words[0])
                        return False
                    for i in range(1, len(pins)+1):
                        var net = words[i]
                        if net != "open":
                            if pins[i-1].isGlobal:
                                self.addToGlobalNets(net, name, i-1, pins[i-1].isInpin)
                            else:
                                self.addToNets(net, name, i-1, pins[i-1].isInpin)
                    for _ in range(sbblknum):
                        line = lines.pop(0)
                        words = line.split()
                        if words[0] != "subblock:":
                            if self.log:
                                self.log.value().writeln("Error: 'subblock:' nicht gefunden; ", words[0])
                            return False
                else:
                    if self.log:
                        self.log.value().writeln("Error: ", words[0], " nicht gefunden")
                    return False
        except e:
            if self.log:
                self.log.value().writeln("Error: ", e)
            return False
        return True

    # Hilfsfunktion, um ein Netz zu einer Liste hinzuzufügen
    # @arg net: Name des Netzes
    # @arg block: Name des Blocks, der dem Netz hinzugefügt werden soll
    # @arg pin: Pin-Idx des Blocks im Netz
    # @arg isInpin: True, wenn es sich um einen Eingangspin handelt, sonst False
    fn addToNets(mut self, net: String, block: String, pin: Int, isInpin: Bool = False):
        if net in self.nets:
            try:
                if len(self.nets[net]) == 0:
                    self.netList.append(net)
                if isInpin:
                    self.nets[net].append(Tuple[String, Int](block, pin))
                else:
                    self.nets[net].insert(0, Tuple[String, Int](block, pin))
            except:
                # Darf niemals ausgelöst werden
                if self.log != None:
                    self.log.value().writeln("Error: ", net, " nicht gefunden")
        else:
            self.nets[net] = List[Tuple[String, Int]](Tuple[String, Int](block, pin))
            self.netList.append(net)

        if self.log != None:
            self.log.value().writeln("Net: ", net, " ", block, " ", pin)
        
    # Hilfsfunktion, um ein globales Netz zu einer Liste hinzuzufügen
    # @arg net: Name des globalen Netzes
    # @arg block: Name des Blocks, der dem globalen Netz hinzugefügt werden soll
    # @arg pin: Pin-Idx des Blocks im globalen Netz
    # @arg isInpin: True, wenn es sich um einen Eingangspin handelt, sonst False
    fn addToGlobalNets(mut self, net: String, block: String, pin: Int, isInpin: Bool = False):
        if net in self.globalNets:           
            try:
                if len(self.globalNets[net]) == 0:
                    self.netList.append(net)
                if isInpin:
                    self.globalNets[net].append(Tuple[String, Int](block, pin))
                else:
                    self.globalNets[net].insert(0, Tuple[String, Int](block, pin))
            except:
                # Darf niemals ausgelöst werden
                if self.log != None:
                    self.log.value().writeln("Error: ", net, " nicht gefunden")
        else:
            self.globalNets[net] = List[Tuple[String, Int]](Tuple[String, Int](block, pin))
            self.netList.append(net)

        if self.log != None:
            self.log.value().writeln("GlobalNet: ", net, " ", block, " ", pin)

    # Hilfsfunktion, um ein globales Netz zu einer Liste hinzuzufügen
    # @arg net: Name des globalen Netzes
    fn addToGlobalNets(mut self, net: String):
            self.globalNets[net] = List[Tuple[String, Int]]()
            if self.log != None:
                self.log.value().writeln("GlobalNet: ", net)
