from myUtil.Enum import Blocktype
from memory import UnsafePointer, Pointer, ArcPointer
from collections import List, Deque
from hashlib.hasher import Hasher
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
@fieldwise_init
struct Block(Copyable, Movable, EqualityComparable, Stringable):

    alias SharedBlock = ArcPointer[Block]

    var name: String
    var subblk: Int8
    var type: Blocktype
    var delay: Float64
    var preconnections: List[Self.SharedBlock]
    var preDelays: List[Float64]
    var coord: Tuple[Int, Int]
    var hasCritPath: Bool
    var visitCount: UInt8
    var hasGlobal: Bool

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
        self.preDelays = List[Float64]()
        self.coord = (0, 0)
        self.hasCritPath = False
        self.visitCount = 0
        self.hasGlobal = False


    fn __eq__(self, other: Block) -> Bool:
        return self.name == other.name and self.subblk == other.subblk and self.type == other.type and self.delay == other.delay
        
    fn __ne__(self, other: Block) -> Bool:
        return not self.__eq__(other)

    fn __str__(self) -> String:
        return self.name + " " + String(self.subblk) + " " + String(self.type) + " "+ String(self.delay) + " " + String(self.coord[0]) + ";" + String(self.coord[1])

    # Fügt eine Verbindung zu einem anderen Block hinzu
    #
    # @arg block Der Blockzeiger, zu dem die Verbindung hinzugefügt werden soll
    # @arg delay Die Verzögerung der Verbindung (Standard: 0.0)
    fn addPreconnection(mut self, block: Self.SharedBlock, delay: Float64 = 0.0):
        self.preconnections.append(block)
        self.preDelays.append(delay)

"""
Paart einen Block mit einem Wert.
"""
@fieldwise_init
struct BlockPair[type: Copyable & Movable & Hashable & EqualityComparable & Stringable](Copyable, Movable, Hashable, EqualityComparable):
    var block: Block.SharedBlock
    var value: type

    fn __eq__(self, other: Self) -> Bool:
        return self.block[] == other.block[] and self.value == other.value

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __hash__[H: Hasher](self, mut hasher: H):
        var hash: String = (self.block[].name + String(self.value))
        hasher.update(hash.as_string_slice())
