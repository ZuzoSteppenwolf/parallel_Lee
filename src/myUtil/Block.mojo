from myUtil.Enum import Blocktype
from memory import UnsafePointer, Pointer, ArcPointer, Span
from collections import List, Deque
from os import os
from tempfile import NamedTemporaryFile
from sys.info import sizeof
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
    var preDelays: List[Float64]
    var coord: Tuple[Int, Int]
    var hasCritPath: Bool

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

    # Gibt die Verzögerung des Blocks zurück
    #
    # @return Die Verzögerung(en) des Blocks
    fn getDelay(mut self) -> List[Float64]:
        var delays: List[Float64] = List[Float64]()
        if len(self.preconnections) == 0:
            delays.append(self.delay)
        else:
            
            try:
                with NamedTemporaryFile("rw") as fPreDelays:
                    with NamedTemporaryFile("rw") as fIdxs:
                        var preDelays: Int = 0
                        var idxs: Int = 0
                        var blockFront: Deque[Self.SharedBlock] = Deque[Self.SharedBlock]()
                        @parameter
                        fn setPreDelays(value: Float64) raises:
                            _ = fPreDelays.seek((preDelays - 1) * sizeof[Float64](), os.SEEK_SET)
                            fPreDelays.write_bytes(value.as_bytes())

                        @parameter
                        fn setIdxs(value: Int64) raises:
                            _ = fIdxs.seek((idxs - 1) * sizeof[Int64](), os.SEEK_SET)
                            fIdxs.write_bytes(value.as_bytes())

                        @parameter
                        fn getPreDelays() raises -> Float64:
                            _ = fPreDelays.seek((preDelays - 1) * sizeof[Float64](), os.SEEK_SET)
                            var list = fPreDelays.read_bytes(sizeof[Float64]())
                            var ptr2UInt8 = list.steal_data() 
                            var ptr2Float64 = ptr2UInt8.bitcast[Float64]()
                            return ptr2Float64[]

                        @parameter
                        fn getIdxs() raises -> Int64:
                            _ = fIdxs.seek((idxs - 1) * sizeof[Int64](), os.SEEK_SET)
                            var list = fIdxs.read_bytes(sizeof[Int64]())
                            var ptr2UInt8 = list.steal_data() 
                            var ptr2Int64 = ptr2UInt8.bitcast[Int64]()
                            return ptr2Int64[]

                        for idx in range(len(self.preconnections)):                    
                            blockFront.append(self.preconnections[idx])
                            while blockFront:
                                var preDelay: Float64 = 0.0
                                if len(blockFront) < idxs:
                                    idxs -= 1
                                elif len(blockFront) > idxs:
                                    idxs += 1
                                    setIdxs(0)
                                if len(blockFront) < preDelays:
                                    var bufferDelay = getPreDelays()
                                    var bufferIdx = getIdxs()
                                    preDelay = bufferDelay + blockFront[-1][].delay + blockFront[-1][].preDelays[bufferIdx - 1]
                                    preDelays -= 1
                                elif len(blockFront) > preDelays:
                                    preDelays += 1
                                    setPreDelays(blockFront[-1][].delay)
                                    
                                var bufferDelay = getPreDelays()
                                if bufferDelay < preDelay:
                                    setPreDelays(preDelay)
                                
                                var bufferIdx = getIdxs()
                                if bufferIdx < len(blockFront[-1][].preconnections) and not blockFront[-1][].hasCritPath:
                                    blockFront.append(blockFront[-1][].preconnections[bufferIdx])
                                    setIdxs(bufferIdx + 1)
                                else:
                                    blockFront[-1][].hasCritPath = True
                                    blockFront[-1][].delay = getPreDelays()
                                    _ = blockFront.pop()  
                            preDelays = 1   
                            var bufferDelay = getPreDelays()
                            delays.append(bufferDelay + self.delay + self.preDelays[idx])
                            preDelays = 0     
                            idxs = 0
                            blockFront = Deque[Self.SharedBlock]()

            except e:
                print("Error calculating delays: ", e)
            """
            for idx in range(len(self.preconnections)):
                var preDelays: List[Float64] = self.preconnections[idx][].getDelay()
                var maxDelay: Float64 = 0.0
                for d in preDelays:
                    if (d[] + self.preDelays[idx]) > maxDelay:
                        maxDelay = d[] + self.preDelays[idx]
                
                delays.append(maxDelay + self.delay)
            """
        return delays
