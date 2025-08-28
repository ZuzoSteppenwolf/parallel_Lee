"""
@file Util.mojo

Utility Funktionen für Mojo

@author Marvin Wollbrück
"""
from collections import Dict, List
from myUtil.Block import Block, BlockPair
from myUtil.Matrix import Matrix

"""
Bereinigt die übergebenen Zeilen von Kommentaren und Zeilenumbrüchen

@arg lines: Liste von Zeilen
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

"""
Initialisiert die Map mit leeren Werten
@arg map: Matrix, die initialisiert werden soll
"""
fn initMap(mut map: Matrix[Dict[String, List[Block.SharedBlock]]]):
    for idx in range(map.size):
        map.initMemSpace(idx, Dict[String, List[Block.SharedBlock]]())

"""
Initialisiert die Map mit leeren Werten
@arg map: Matrix, die initialisiert werden soll
"""
fn initMap(mut map: Matrix[Dict[Int, List[Block.SharedBlock]]]):
    for idx in range(map.size):
        map.initMemSpace(idx, Dict[Int, List[Block.SharedBlock]]())

"""
Initialisiert die Map mit leeren Werten
@arg map: Matrix, die initialisiert werden soll
"""
fn initMap(mut map: Matrix[List[Block.SharedBlock]]):
    for idx in range(map.size):
        map.initMemSpace(idx, List[Block.SharedBlock]())

"""
Initialisiert die Map mit leeren Werten
@arg map: Matrix, die initialisiert werden soll
@arg value: Wert, mit dem die Map initialisiert werden soll
"""
fn initMap(mut map: Matrix[Int], value: Int):
    for idx in range(map.size):
        map.initMemSpace(idx, value)

"""
Initialisiert die Map mit leeren Werten
@arg map: Matrix, die initialisiert werden soll
"""
fn initMap[T: Copyable & Movable & Hashable & EqualityComparable & Stringable](mut map: Matrix[List[BlockPair[T]]]):
    for idx in range(map.size):
        map.initMemSpace(idx, List[BlockPair[T]]())