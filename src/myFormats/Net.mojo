from collections import Dict, List
from myUtil.Util import clearUpLines
from myFormats.Arch import Pin
"""
@file Net.mojo

Parser für das Net File Format vom VPR Tool

@author Marvin Wollbrück
"""

@value
struct Net:
    var isValid: Bool
    var nets: Dict[String, List[String]]
    var globalNets: Dict[String, List[String]]

    fn __init__(out self, path: String, sbblknum: Int8, pins: List[Pin]):
        self.nets = Dict[String, List[String]]()
        self.globalNets = Dict[String, List[String]]()
        self.isValid = False
        self.isValid = self.parse(path, sbblknum, pins)


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
                if words[0] == ".input":
                    var name = words[1]
                    line = lines.pop(0)
                    words = line.split()
                    if words[0] != "pinlist:":
                        return False
                    var net = words[1]
                    self.addToNets(net, name)
                elif words[0] == ".output":
                    var name = words[1]
                    line = lines.pop(0)
                    words = line.split()
                    if words[0] != "pinlist:":
                        return True
                    var net = words[1]
                    self.addToNets(net, name)
                elif words[0] == ".global":
                    var name = words[1]
                    self.addToGlobalNets(name, name)
                elif words[0] == ".clb":
                    var name = words[1]
                    line = lines.pop(0)
                    words = line.split()
                    if words[0] != "pinlist:":
                        return False
                    for i in range(1, len(pins)):
                        var net = words[i]
                        if net != "open":
                            if pins[i].isGlobal:
                                self.addToGlobalNets(net, name, pins[i].isInpin)
                            else:
                                self.addToNets(net, name, pins[i].isInpin)
                    for i in range(sbblknum):
                        line = lines.pop(0)
                        words = line.split()
                        if words[0] != "subblock:":
                            return False
                else:
                    return False
        except:
            return False
        return True

    fn addToNets(mut self, net: String, block: String, isInpin: Bool = False):
        if net in self.nets:
            try:
                if isInpin:
                    self.nets[net].append(block)
                else:
                    self.nets[net].insert(0, block)
            except:
                # Darf niemals ausgelöst werden
                print("NetError: ", net, " nicht gefunden") 
        else:
            self.nets[net] = List[String](block)
        
    fn addToGlobalNets(mut self, net: String, block: String, isInpin: Bool = False):
        if net in self.globalNets:
            try:
                if isInpin:
                    self.globalNets[net].append(block)
                else:
                    self.globalNets[net].insert(0, block)
            except:
                # Darf niemals ausgelöst werden
                print("NetError: ", net, " nicht gefunden")
        else:
            self.globalNets[net] = List[String](block)
