from collections import Dict, List
from myUtil.Util import clearUpLines
"""
@file Net.mojo

Parser für das Net File Format vom VPR Tool

@author Marvin Wollbrück
"""

@value
struct Net:
    var nets: Dict[String, List[String]]

    fn __init__(out self, path: String):
        self.nets = Dict[String, List[String]]()


    fn parse(mut self, path: String) -> Bool:
        try:
            with open(path, "r") as file:
                var lines = file.read().split("\n")
                lines = clearUpLines(lines)
        except:
            return False
        return True