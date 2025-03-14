from myUtil.Enum import Blocktype
from memory import ArcPointer
"""
@file Block.mojo
Repräsentiert einen Block in der Architektur.

@author Marvin Wollbrück
"""
@value
struct Block:
    var name: String
    var subblk: Int8
    var type: Blocktype
    var delay: Float64
    var preconnections: List[ArcPointer[Block]]

    fn __init__(out self, name: String, subblk: Int8 = 0,  type: Blocktype = Blocktype.NONE):
        self.name = name
        self.subblk = subblk
        self.type = type
        self.delay = 0.0
        self.preconnections = List[ArcPointer[Block]]()

    fn __eq__(self, other: Block) -> Bool:
        return self.name == other.name and self.subblk == other.subblk and self.type == other.type

    fn __ne__(self, other: Block) -> Bool:
        return not self.__eq__(other)

    fn __str__(self) -> String:
        return self.name.join(" ").join(self.subblk).join(" ") + self.type.__str__()

    # Gibt die Verzögerung des Blocks zurück
    #
    # @return Die Verzögerung(en) des Blocks
    fn getDelay(self) -> List[Float64]:
        if len(self.preconnections) == 0:
            return List[Float64](self.delay)
        else:
            var delays: List[Float64] = List[Float64]()
            for preconnection in self.preconnections:
                var preDelays = preconnection[][].getDelay()
                for i in range(len(preDelays)):
                    delays.append(preDelays[i] + self.delay)
            return delays