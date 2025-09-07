from collections import Dict, List
from myUtil.Enum import Blocktype
from myUtil.Matrix import Matrix
from myUtil.Util import clearUpLines
from myUtil.Block import Block
from myUtil.Logger import Log
"""
@file Place.mojo
Parser für das Placement File Format vom VPR Tool

@author Marvin Wollbrück
"""

"""
Datenstruktur für die Platzierung von Blöcken in einer Matrix.
Enthält Informationen über die Netzliste, Architektur, Größe der Matrix,
"""
@fieldwise_init
struct Place(Copyable, Movable):

    var isValid: Bool
    var net: String
    var arch: String
    var archiv: Dict[String, Tuple[Int, Int]]
    var path: String
    var rows: Int
    var cols: Int
    var clbNums: Dict[String, Int]
    var clbSubblk: Dict[String, Int]
    var log: Optional[Log[True]]

    # Konstruktor
    # @arg path: Pfad zur Platzierungsdatei
    # @arg logDir: Verzeichnis, in dem die Logdatei gespeichert werden soll, standardmäßig im aktuellen Verzeichnis
    fn __init__(out self, path: String, logDir: String = ""):
        self.net = ""
        self.arch = ""
        self.isValid = False
        self.archiv = Dict[String, Tuple[Int, Int]]()
        self.path = path
        self.rows = 0
        self.cols = 0
        self.clbNums = Dict[String, Int]()
        self.clbSubblk = Dict[String, Int]()
        try:
            self.log = Log[True](logDir + "place.log")
        except:
            self.log = None
        self.isValid = self.parse(path)

    # Liest die Platzierungsdatei und speichert die Informationen in der Struktur
    # @arg path: Pfad zur Platzierungsdatei
    # @return: True, wenn die Datei erfolgreich gelesen wurde, sonst False
    fn parse(mut self, path: String) -> Bool:
        try:
            var lines: List[String] = List[String]()
            with open(path, "r") as file:
                var lineSlices = file.read().split("\n")
                for lineSlice in lineSlices:
                    lines.append(String(lineSlice))
            lines = clearUpLines(lines)
            if len(lines) == 0:
                return False
            var hasNet: Bool = False
            var hasArch: Bool = False
            var hasSize: Bool = False
            var blockNum: Int = 0
            for line in lines:
                if line and not line.startswith("#") and not line.isspace():
                    var words = List[String]()
                    var wordSlices = line.split()
                    for wordSlice in wordSlices:
                        words.append(String(wordSlice))
                    var counter: Int = 0
                    var col: Int = 0
                    var row: Int = 0
                    var name: String = ""
                    var isComment = False
                    for word in words:
                        if word and not word.isspace() and not isComment:
                            # Erste Zeile beinhaltet Netzliste- und Architektur-Pfad
                            if not hasNet:
                                if counter == 0 and word != "Netlist":
                                    if self.log:
                                        self.log.value().writeln("Error: 'Netlist' not found; ", word)
                                    return False
                                elif counter == 1 and word != "file:":
                                    if self.log:
                                        self.log.value().writeln("Error: 'file:' not found; ", word)
                                    return False
                                elif counter == 2:
                                    self.net = word
                                    hasNet = True
                                    if self.log:
                                        self.log.value().writeln("Netlist: ", self.net)
                                counter += 1
                            
                            elif not hasArch:
                                if counter == 3 and word != "Architecture":
                                    if self.log:
                                        self.log.value().writeln("Error: 'Architecture' not found; ", word)
                                    return False
                                elif counter == 4 and word != "file:":
                                    if self.log:
                                        self.log.value().writeln("Error: 'file:' not found; ", word)
                                    return False
                                elif counter == 5:
                                    self.arch = word
                                    hasArch = True
                                    if self.log:
                                        self.log.value().writeln("Architecture: ", self.arch)
                                counter += 1

                            # Zweite Zeile beinhaltet die Größe der Matrix
                            elif not hasSize:
                                if counter == 0 and word != "Array":
                                    if self.log:
                                        self.log.value().writeln("Error: 'Array' not found; ", word)
                                    return False
                                elif counter == 1 and word != "size:":
                                    if self.log:
                                        self.log.value().writeln("Error: 'size:' not found; ", word)
                                    return False
                                elif counter == 2:
                                    col = atol(word)
                                    if self.log:
                                        self.log.value().writeln("Columns: ", col)
                                elif counter == 3 and word != "x":
                                    if self.log:
                                        self.log.value().writeln("Error: 'x' not found; ", word)
                                    return False
                                elif counter == 4:
                                    row = atol(word)
                                    if self.log:
                                        self.log.value().writeln("Rows: ", row)
                                    self.cols = col
                                    self.rows = row
                                elif counter == 5 and word != "logic":
                                    if self.log:
                                        self.log.value().writeln("Error: 'logic' not found; ", word)
                                    return False
                                elif counter == 6:
                                    if word != "blocks":
                                        if self.log:
                                            self.log.value().writeln("Error: 'blocks' not found; ", word)
                                        return False
                                    else:
                                        hasSize = True
                                counter += 1

                            # Restliche Zeilen beinhalten die Platzierungen
                            else:
                                if word.startswith("#"):
                                    isComment = True
                                elif counter == 0:
                                    name = word
                                elif counter == 1:
                                    col = atol(word)
                                elif counter == 2:
                                    row = atol(word)
                                elif counter == 3:
                                    self.clbSubblk[name] = atol(word)
                                    self.archiv[name] = Tuple[Int, Int](col, row)
                                    self.clbNums[name] = blockNum
                                    blockNum += 1
                                    if self.log:
                                        self.log.value().writeln("Block: ", name, " Col: ", col, " Row: ", row, " Subblock: ", self.clbSubblk[name])
                                counter += 1
        except:
            return False
        return True

