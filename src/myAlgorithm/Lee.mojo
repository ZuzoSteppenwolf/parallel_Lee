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

    fn __copyinit__(out self, other: Mutex):
        self.owner = Atomic[DType.int64](other.owner.load())
        self.visitor = Atomic[DType.int64](other.visitor.load())

    fn __moveinit__(out self, owned other: Mutex):
        self.owner = Atomic[DType.int64](other.owner.load())
        self.visitor = Atomic[DType.int64](other.visitor.load())

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

"""
Pair-Struktur
"""
struct Pair:
    var id: String
    var value: Int

    fn __init__(out self, id: String, value: Int):
        self.id = id
        self.value = value

    fn __copyinit__(out self, other: Pair):
        self.id = other.id
        self.value = other.value

    fn __moveinit__(out self, owned other: Pair):
        self.id = other.id
        self.value = other.value

    fn __eq__(self, other: Pair) -> Bool:
        return self.id == other.id and self.value == other.value

    fn __eq__(self, other: String) -> Bool:
        return self.id == other

    fn __ne__(self, other: Pair) -> Bool:
        return not self.__eq__(other)

    fn __str__(self) -> String:
        return self.id.join(" : ").join(self.value)

"""
Route-Struktur
"""       
struct Route:
    alias BLOCKED = -2
    alias EMPTY = -1
    var isValid: Bool
    var routeLists: Dict[String, Dict[Int, List[Block.SharedBlock]]]
    var chanMap: List[Matrix[Int]]#Matrix[Dict[String, List[Block.SharedBlock]]]
    var clbMap: Matrix[List[Block.SharedBlock]]
    var netKeys: List[String]
    var nets: Dict[String, List[Tuple[String, Int]]]
    var mutex: List[Mutex]
    var chanWidth: Int
    var chanDelay: Float64
    var pins: List[Pin]
    var archiv: Dict[String, Tuple[Int, Int]]

    fn __init__(out self, nets: Dict[String, List[Tuple[String, Int]]], clbMap: Matrix[List[Block.SharedBlock]], archiv: Dict[String, Tuple[Int, Int]], chanWidth: Int, chanDelay: Float64, pins: List[Pin]):
        self.routeLists = Dict[String, Dict[Int, List[Block.SharedBlock]]]()
        #self.chanMap = Matrix[Dict[String, List[Block.SharedBlock]]](clbMap.cols, clbMap.rows)
        #initMap(self.chanMap)
        self.chanMap = List[Matrix[Int]]()
        for i in range(chanWidth):
            self.chanMap.append(Matrix[Int]((clbMap.cols-2)*2+1, (clbMap.rows-2)*2+1))
            initMap(self.chanMap[i], Route.EMPTY)
        self.clbMap = clbMap
        self.netKeys = List[String]()
        self.nets = nets
        self.archiv = archiv
        #self.mutex = Mutex()
        self.mutex = List[Mutex]()
        for _ in range(len(self.netKeys)):
            self.mutex.append(Mutex())
        self.chanWidth = chanWidth
        self.chanDelay = chanDelay
        self.pins = pins
        self.isValid = True

        for net in nets:
            self.netKeys.append(net[])
        
        @parameter
        fn algo(id: Int):
            alias SINK = -3
            alias BLOCKED = Route.BLOCKED
            alias EMPTY = Route.EMPTY
            alias CONNECTED = 0
            alias START = 1
            
            var routeList = Dict[Int, List[Block.SharedBlock]]()
            for i in range(self.chanWidth):
                routeList[i] = List[Block.SharedBlock]()
                try:
                    var coord = archiv[self.nets[self.netKeys[id]][0][0]]
                    routeList[i].append(self.clbMap[coord[0], coord[1]][0])
                except e:
                    print("Error: ", e)
                    self.isValid = False
                    return
            var net = self.netKeys[id]
            var routedClbs = Set[String]()
            var track = 0
            var currentTrack = (id+track) % self.chanWidth
            var maze = Matrix[Int](self.chanMap[currentTrack].cols, self.chanMap[currentTrack].rows)
            initMap(maze, Route.EMPTY)
            try:
                routedClbs.add(self.nets[net][0][0])
            except e:
                print("Error: ", e)
                self.isValid = False
                return

            # Initialisiere das Labyrinth
            # 1 = verdrahteter Block/Kanal, 0 = Frei
            @parameter
            fn initMaze():
                for col in range(self.clbMap.cols):
                    for row in range(self.clbMap.rows):
                        await self.mutex[currentTrack].visit()
                        try:
                            maze[col*2-1, row*2-1] = BLOCKED
                        except e:
                            print("Error: ", e)
                            self.isValid = False
                            return
                        finally:
                            await self.mutex[currentTrack].unvisit()
                

            initMaze()

            var isFinished = False
            var pathfinder = START
            var pathcount = 0
            var sinkCoord: Tuple[Int, Int] = (0, 0)
            var sink: Block.SharedBlock = Block.SharedBlock(Block("Error"))
            while not isFinished:
                var foundSink = False
                pathcount = 0
                for col in range(self.clbMap.cols):
                    for row in range(self.clbMap.rows):
                        await self.mutex[currentTrack].visit()
                        try:
                            if maze[col, row] == EMPTY:
                                if len(self.chanMap[col, row]) == self.chanWidth and not(net in self.chanMap[col, row]):
                                    maze[col, row] = BLOCKED
                                elif col > 0 and maze[col-1, row] == pathfinder - 1:
                                    maze[col, row] = pathfinder
                                elif col < self.clbMap.cols - 1 and maze[col+1, row] == pathfinder - 1:
                                    maze[col, row] = pathfinder
                                elif row > 0 and maze[col, row-1] == pathfinder - 1:
                                    maze[col, row] = pathfinder
                                elif row < self.clbMap.rows - 1 and maze[col, row+1] == pathfinder - 1:
                                    maze[col, row] = pathfinder

                                if maze[col, row] != BLOCKED:
                                    for clb in self.clbMap[col, row]:
                                        if clb[][].name in self.nets[net]:
                                            foundSink = True
                                            maze[col, row] = pathfinder
                                            sinkCoord = (col, row)
                                            sink = clb[][]
                                            break
                        except e:
                            print("Error: ", e)
                            self.isValid = False
                            return
                        finally:
                            await self.mutex[currentTrack].unvisit()
                        
                        if foundSink:
                            break
                    if foundSink:
                        break

                if foundSink:
                    await self.mutex[currentTrack].lock(id)
                    try:
                        var isEnd = False
                        var isFree = True
                        var coord = sinkCoord
                        pathfinder = maze[sinkCoord[0], sinkCoord[1]]
                        # Verfolge den Pfad zurück und prüft ob der Weg frei ist
                        while not isEnd:
                            var col = coord[0]
                            var row = coord[1]                          
                            if pathfinder == CONNECTED:
                                isEnd = True
                            else:
                                if len(self.chanMap[col, row]) == self.chanWidth and not(net in self.chanMap[col, row]):
                                    isFree = False
                                    isEnd = True
                                elif col > 0 and maze[col-1, row] == pathfinder - 1:
                                    coord = (col-1, row)
                                elif col < self.clbMap.cols - 1 and maze[col+1, row] == pathfinder - 1:
                                    coord = (col+1, row)
                                elif row > 0 and maze[col, row-1] == pathfinder - 1:
                                    coord = (col, row-1)
                                elif row < self.clbMap.rows - 1 and maze[col, row+1] == pathfinder - 1:
                                    coord = (col, row+1)
                                pathfinder -= 1

                        # Füge den Pfad zur Verdrahtungsliste hinzu  
                        if isFree:
                            isEnd = False
                            coord = sinkCoord
                            pathfinder = maze[sinkCoord[0], sinkCoord[1]]
                            while not isEnd:
                                var col = coord[0]
                                var row = coord[1]
                                if coord[0] == sinkCoord[0] and coord[1] == sinkCoord[1]:
                                    routeList.append(sink)
                                    routedClbs.add(sink[].name)
                                    
                                elif pathfinder == CONNECTED:
                                    isEnd = True
                                else:
                                    routeList.append(self.clbMap[col, row][0])
                                    if col > 0 and maze[col-1, row] == pathfinder - 1:
                                        coord = (col-1, row)
                                    elif col < self.clbMap.cols - 1 and maze[col+1, row] == pathfinder - 1:
                                        coord = (col+1, row)
                                    elif row > 0 and maze[col, row-1] == pathfinder - 1:
                                        coord = (col, row-1)
                                    elif row < self.clbMap.rows - 1 and maze[col, row+1] == pathfinder - 1:
                                        coord = (col, row+1)
                                    pathfinder -= 1



                    except e:
                        print("Error: ", e)
                        self.isValid = False
                        return
                    finally:
                        await self.mutex[currentTrack].unlock(id)
                    pathfinder = START
                    initMaze()
                else:
                    try:
                        if len(routedClbs) == len(self.nets[net]):
                            isFinished = True
                        elif pathcount == 0:
                            track += 1
                            currentTrack = (id+track) % self.chanWidth
                            pathfinder = START
                            if currentTrack == id % self.chanWidth:
                                isFinished = True
                                self.isValid = False
                                
                        else:
                            pathfinder += 1
                    except e:
                        print("Error: ", e)
                        self.isValid = False
                        return
            
            self.routeLists[net] = routeList
            return

        parallelize[algo](len(self.netKeys), len(self.netKeys))
            