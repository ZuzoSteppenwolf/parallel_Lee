from myFormats.Place import *
from myUtil.Matrix import *
from myUtil.Enum import *
from myUtil.Util import *
from myUtil.Block import *
from myFormats.Arch import *
from collections import Dict, List, Set
from os import Atomic
from time import sleep
from algorithm import parallelize

"""
@file Lee.mojo
Erzeugt eine Verdrahtungsliste mit dem Lee-Algorithmus.
Die Netze werden in echtzeit parallel verarbeitet.

@author Marvin Wollbrück
"""

"""
Mutex-Struktur
"""
struct Mutex:
    
    var owner: Atomic[DType.int64]
    var visitor: Atomic[DType.int64]

    alias FREE = -1


    fn __init__(out self):
        self.owner = Atomic[DType.int64](self.FREE)
        self.visitor = Atomic[DType.int64](0)

    async fn lock(mut self, id: Int):
        var owner: SIMD[DType.int64, 1] = self.FREE
        while not self.owner.compare_exchange_weak(owner, id):
            owner = self.FREE
            sleep(0.1)
        while self.visitor.load() != 0:
            sleep(0.1)
    
    async fn unlock(mut self, id: Int):
        var owner: SIMD[DType.int64, 1] = id
        _ = self.owner.compare_exchange_weak(owner, self.FREE)

    async fn visit(mut self):
        while self.owner.load() != self.FREE:
            sleep(0.1)
        _ = self.visitor.fetch_add(1)

    async fn unvisit(mut self):
        _ = self.visitor.fetch_sub(1)
        
    
struct Route:
    var isValid: Bool
    var routeLists: List[List[Block.SharedBlock]]
    var chanMap: Matrix[Dict[String, List[Block.SharedBlock]]]
    var clbMap: Matrix[List[Block.SharedBlock]]
    var netKeys: List[String]
    var nets: Dict[String, List[String]]
    var mutex: Mutex
    var chanWidth: Int
    var chanDelay: Float64
    var pins: List[Pin]

    fn __init__(out self, nets: Dict[String, List[String]], clbMap: Matrix[List[Block.SharedBlock]], chanWidth: Int, chanDelay: Float64, pins: List[Pin]):
        self.routeLists = List[List[Block.SharedBlock]]()
        self.chanMap = Matrix[Dict[String, List[Block.SharedBlock]]](clbMap.cols, clbMap.rows)
        initMap(self.chanMap)
        self.clbMap = clbMap
        self.netKeys = List[String]()
        self.nets = nets
        self.mutex = Mutex()
        self.chanWidth = chanWidth
        self.chanDelay = chanDelay
        self.pins = pins
        self.isValid = True

        for net in nets:
            self.netKeys.append(net[])
        
        @parameter
        fn algo(id: Int):
            alias EMPTY = 0
            alias CONNECTED = 1
            alias START = 2
            var maze = Matrix[UInt](self.clbMap.cols, self.clbMap.rows)
            var routeList = List[Block.SharedBlock]()
            var net = self.netKeys[id]
            var routedClbs = Set[String]()
            try:
                routedClbs.add(self.nets[net][0])
            except e:
                print("Error: ", e)
                self.isValid = False
                return

            # Initialisiere das Labyrinth
            # 1 = verdrahteter Block/Kanal, 0 = Frei
            @parameter
            fn initMaze():
                for i in range(self.clbMap.cols):
                    for j in range(self.clbMap.rows):
                        await self.mutex.visit()
                        try:
                            if net in self.chanMap[i, j]:
                                maze[i, j] = CONNECTED
                            else:
                                if len(self.clbMap[i, j]) > 0:
                                    for block in self.clbMap[i, j]:
                                        if block[][].name in routedClbs:
                                            maze[i, j] = CONNECTED
                                            break
                            if maze[i, j] != CONNECTED:
                                maze[i, j] = EMPTY
                        except e:
                            print("Error: ", e)
                            self.isValid = False
                            return
                        finally:
                            await self.mutex.unvisit()

            initMaze()

            var isFinished = False
            while not isFinished:
                pass
            pass
            self.routeLists.append(routeList)

        parallelize[algo](len(self.netKeys), len(self.netKeys))
            