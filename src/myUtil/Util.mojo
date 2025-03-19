"""
@file Util.mojo

Utility Funktionen für Mojo

@author Marvin Wollbrück
"""
from collections import Dict, List
from myUtil.Block import Block
from myUtil.Matrix import Matrix

"""
Bereinigt die übergebenen Zeilen von Kommentaren und Zeilenumbrüchen

@param lines: Liste von Zeilen
@return: Liste von bereinigten Zeilen
"""
fn clearUpLines(owned lines: List[String]) -> List[String]:
    var newLines = List[String]()
    var isContinued = False
    while len(lines) > 0:
        var line = lines.pop(0)
        if line == "" or line.isspace():
            continue
        var newLine = String(line.strip())
        if newLine.startswith("#"):
            continue
        var offset = newLine.find("#")
        if offset > -1:
            newLine = String(newLine[:offset].strip())
        offset = newLine.find("\\")
        if offset > -1:
            newLine = newLine[:offset]
            if isContinued:
                newLines[-1] += newLine
            else:
                isContinued = True
                newLines.append(newLine)
            continue
        if isContinued:
            isContinued = False
            newLines[-1] += newLine
        else:
            newLines.append(newLine)
        
    return newLines


fn initMap(mut map: Matrix[Dict[String, List[Block.SharedBlock]]]):
    for i in range(map.cols):
            for j in range(map.rows):
                map[i, j] = Dict[String, List[Block.SharedBlock]]()

fn initMap(mut map: Matrix[List[Block.SharedBlock]]):
    for i in range(map.cols):
            for j in range(map.rows):
                map[i, j] = List[Block.SharedBlock]()