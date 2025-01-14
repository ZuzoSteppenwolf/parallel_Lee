from collections import Dict, List
from myUtil.Enum import Blocktype
from myUtil.Matrix import Matrix
from myUtil.Util import clearUpLines
"""
@file Place.mojo
Parser für das Placement File Format vom VPR Tool

@author Marvin Wollbrück
"""
@value
struct Block(Copyable):
    var name: String
    var subblk: Int8
    var type: Blocktype

    fn __init__(out self, name: String, subblk: Int8 = 0,  type: Blocktype = Blocktype.NONE):
        self.name = name
        self.subblk = subblk
        self.type = type

    fn __eq__(borrowed self, other: Block) -> Bool:
        return self.name == other.name and self.subblk == other.subblk and self.type == other.type

    fn __ne__(borrowed self, other: Block) -> Bool:
        return not self.__eq__(other)

    fn __str__(borrowed self) -> String:
        return self.name + " " + str(self.subblk) + " " + str(self.type)

@value
struct Place:
    var isValid: Bool
    var net: String
    var arch: String
    var map: Matrix[List[Block]]
    var archiv: Dict[String, Tuple[Int, Int]]
    var path: String

    fn __init__(out self, path: String):
        self.net = ""
        self.arch = ""
        self.map = Matrix[List[Block]](0, 0)
        self.isValid = False
        self.archiv = Dict[String, Tuple[Int, Int]]()
        self.path = path
        self.isValid = self.parse(path)



    fn parse(mut self, path: String) -> Bool:
        try:
            with open(path, "r") as file:
                var lines = file.read().split("\n")
                lines = clearUpLines(lines)
                if len(lines) == 0:
                    return False
                var hasNet: Bool = False
                var hasArch: Bool = False
                var hasSize: Bool = False
                for line in lines:
                    if line[] != "" and not line[].startswith("#") and not line[].isspace():                      
                        var words = line[].split()
                        var counter: Int = 0
                        var col: Int = 0
                        var row: Int = 0
                        var name: String = ""
                        var isComment = False
                        for word in words:
                            if word[] != "" and not word[].isspace() and not isComment:
                                # Erste Zeile beinhaltet Netzliste- und Architektur-Pfad
                                if not hasNet:
                                    if counter == 0 and word[] != "Netlist":
                                        return False
                                    elif counter == 1 and word[] != "file:":
                                        return False
                                    elif counter == 2:
                                        self.net = word[]
                                        hasNet = True
                                    counter += 1
                                elif not hasArch:
                                    if counter == 3 and word[] != "Architecture":
                                        return False
                                    elif counter == 4 and word[] != "file:":
                                        return False
                                    elif counter == 5:
                                        self.arch = word[]
                                        hasArch = True
                                    counter += 1

                                # Zweite Zeile beinhaltet die Größe der Matrix
                                elif not hasSize:
                                    if counter == 0 and word[] != "Array":
                                        return False
                                    elif counter == 1 and word[] != "size:":
                                        return False
                                    elif counter == 2:
                                        col = int(word[])
                                    elif counter == 3 and word[] != "x":
                                        return False
                                    elif counter == 4:
                                        row = int(word[])
                                        self.map = Matrix[List[Block]](col+2, row+2)
                                        #hasSize = True
                                    elif counter == 5 and word[] != "logic":
                                        return False
                                    elif counter == 6:
                                        if word[] != "blocks":
                                            return False
                                        else:
                                            hasSize = True
                                    counter += 1

                                # Restliche Zeilen beinhalten die Platzierungen
                                else:
                                    if word[].startswith("#"):
                                        isComment = True
                                    elif counter == 0:
                                        name = word[]
                                    elif counter == 1:
                                        col = int(word[])
                                    elif counter == 2:
                                        row = int(word[])
                                    elif counter == 3:
                                        block = Block(name)
                                        block.subblk = int(word[])
                                        self.map[col, row].append(block)
                                        self.archiv[name] = Tuple[Int, Int](col, row)
                                    counter += 1
        except IOError:
            return False
        return True
        
