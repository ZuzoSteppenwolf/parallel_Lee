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

struct Place:

    var isValid: Bool
    var net: String
    var arch: String
    #var map: Matrix[Dict[String, List[Block]]]
    var archiv: Dict[String, Tuple[Int, Int]]
    var path: String
    var rows: Int
    var cols: Int
    var clbNums: Dict[String, Int]
    var log: Optional[Log[True]]

    fn __init__(out self, path: String):
        self.net = ""
        self.arch = ""
        #self.map = Matrix[Dict[String, List[Block]]](0, 0)
        self.isValid = False
        self.archiv = Dict[String, Tuple[Int, Int]]()
        self.path = path
        self.rows = 0
        self.cols = 0
        self.clbNums = Dict[String, Int]()
        try:
            self.log = Log[True]("log/place.log")
        except:
            self.log = None
        self.isValid = self.parse(path)



    fn parse(mut self, path: String) -> Bool:
        try:
            var lines: List[String]
            with open(path, "r") as file:
                lines = file.read().split("\n")
            lines = clearUpLines(lines)
            if len(lines) == 0:
                return False
            var hasNet: Bool = False
            var hasArch: Bool = False
            var hasSize: Bool = False
            var blockNum: Int = 0
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
                                    if self.log:
                                        self.log.value().writeln("Error: 'Netlist' not found; ", word[])
                                    return False
                                elif counter == 1 and word[] != "file:":
                                    if self.log:
                                        self.log.value().writeln("Error: 'file:' not found; ", word[])
                                    return False
                                elif counter == 2:
                                    self.net = word[]
                                    hasNet = True
                                    if self.log:
                                        self.log.value().writeln("Netlist: ", self.net)
                                counter += 1
                                
                            elif not hasArch:
                                if counter == 3 and word[] != "Architecture":
                                    if self.log:
                                        self.log.value().writeln("Error: 'Architecture' not found; ", word[])
                                    return False
                                elif counter == 4 and word[] != "file:":
                                    if self.log:
                                        self.log.value().writeln("Error: 'file:' not found; ", word[])
                                    return False
                                elif counter == 5:
                                    self.arch = word[]
                                    hasArch = True
                                    if self.log:
                                        self.log.value().writeln("Architecture: ", self.arch)
                                counter += 1

                            # Zweite Zeile beinhaltet die Größe der Matrix
                            elif not hasSize:
                                if counter == 0 and word[] != "Array":
                                    if self.log:
                                        self.log.value().writeln("Error: 'Array' not found; ", word[])
                                    return False
                                elif counter == 1 and word[] != "size:":
                                    if self.log:
                                        self.log.value().writeln("Error: 'size:' not found; ", word[])
                                    return False
                                elif counter == 2:
                                    col = atol(word[])
                                    if self.log:
                                        self.log.value().writeln("Columns: ", col)
                                elif counter == 3 and word[] != "x":
                                    if self.log:
                                        self.log.value().writeln("Error: 'x' not found; ", word[])
                                    return False
                                elif counter == 4:
                                    row = atol(word[])
                                    if self.log:
                                        self.log.value().writeln("Rows: ", row)
                                    #self.initMatrix(col+2, row+2)
                                    self.cols = col
                                    self.rows = row
                                elif counter == 5 and word[] != "logic":
                                    if self.log:
                                        self.log.value().writeln("Error: 'logic' not found; ", word[])
                                    return False
                                elif counter == 6:
                                    if word[] != "blocks":
                                        if self.log:
                                            self.log.value().writeln("Error: 'blocks' not found; ", word[])
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
                                    col = atol(word[])
                                elif counter == 2:
                                    row = atol(word[])
                                elif counter == 3:
                                    block = Block(name)
                                    block.subblk = atol(word[])
                                    #self.addToMap(block, col, row)
                                    self.archiv[name] = Tuple[Int, Int](col, row)
                                    self.clbNums[name] = blockNum
                                    blockNum += 1
                                    if self.log:
                                        self.log.value().writeln("Block: ", name, " Col: ", col, " Row: ", row, " Subblock: ", block.subblk)
                                counter += 1
        except:
            return False
        return True
    """ 
    fn addToMap(mut self, block: Block, col: Int, row: Int):
        try:
            if block.name in self.map[col, row]:
                self.map[col, row][block.name].append(block)
            else:
                self.map[col, row][block.name] = List[Block](block)
            self.archiv[block.name] = Tuple[Int, Int](col, row)
        except:
                print("Error: " + block.name + " ", col ," ", row)

    fn initMatrix(mut self, col: Int, row: Int):
        self.map = Matrix[Dict[String, List[Block]]](col, row)
        for i in range(col):
            for j in range(row):
                self.map[i, j] = Dict[String, List[Block]]()
    """

