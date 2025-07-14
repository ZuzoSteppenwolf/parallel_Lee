from myUtil.Enum import Blocktype
from memory import UnsafePointer, Pointer, ArcPointer
"""
@file Block.mojo
Repräsentiert einen Block in der Architektur.

@author Marvin Wollbrück
"""

"""
Repräsentiert einen Block in der Architektur.
Der Block enthält Informationen über seinen Namen, Typ, Verzögerung,
Subblock-Index, Verbindungen zu anderen Blöcken und Koordinaten.
"""
@value
struct Block:

    alias SharedBlock = ArcPointer[Block]

    var name: String
    var subblk: Int8
    var type: Blocktype
    var delay: Float64
    var preconnections: List[Self.SharedBlock]
    var coord: Tuple[Int, Int]

    # Konstruktor
    # @arg name: Name des Blocks
    # @arg type: Typ des Blocks (Standard: Blocktype.NONE)
    # @arg delay: Verzögerung des Blocks (Standard: 0.0)
    # @arg subblk: Subblock-Index (Standard: 0)
    fn __init__(out self, name: String,  type: Blocktype = Blocktype.NONE, delay: Float64 = 0.0, subblk: Int8 = 0):
        self.name = name
        self.subblk = subblk
        self.type = type
        self.delay = delay
        self.preconnections = List[Self.SharedBlock]()
        self.coord = (0, 0)


    fn __eq__(self, other: Block) -> Bool:
        return self.name == other.name and self.subblk == other.subblk and self.type == other.type and self.delay == other.delay
        
    fn __ne__(self, other: Block) -> Bool:
        return not self.__eq__(other)

    fn __str__(self) -> String:
        return self.name + " " + String(self.subblk) + " " + String(self.type) + " "+ String(self.delay) + " " + String(self.coord[0]) + ";" + String(self.coord[1])

    # Fügt eine Verbindung zu einem anderen Block hinzu
    #
    # @arg block Der Blockzeiger, zu dem die Verbindung hinzugefügt werden soll
    fn addPreconnection(mut self, block: Self.SharedBlock):
        self.preconnections.append(block)

    # Gibt die Verzögerung des Blocks zurück
    #
    # @return Die Verzögerung(en) des Blocks
    fn getDelay(self) -> List[Float64]:
        var delays: List[Float64] = List[Float64]()
        if len(self.preconnections) == 0:
            delays.append(self.delay)
        else:
            
            for preconnection in self.preconnections:
                var preDelays: List[Float64] = preconnection[][].getDelay()
                var maxDelay: Float64 = 0.0
                for d in preDelays:
                    if d[] > maxDelay:
                        maxDelay = d[]
                
                delays.append(maxDelay + self.delay)
        return delays
