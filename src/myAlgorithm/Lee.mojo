from myFormats.Place import *
from myUtil.Matrix import *
from myUtil.Enum import *
from myUtil.Util import *
from myUtil.Block import *
from myFormats.Arch import *
from collections import Dict, List, Set, InlineArray
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
PathTree-Struktur
"""
@value
struct PathTree:
    var isDeadEnd: Bool
    var isLeaf: Bool
    var lastCoord: Tuple[Int, Int]
    var coord: Tuple[Int, Int]
    var children: List[PathTree]
    var maze: UnsafePointer[Matrix[Int]]
    var chanMap: UnsafePointer[Matrix[Int]]
    var turns: Int
    var pathfinder: Int
    var id: Int

    fn __init__(out self, id: Int, coord: Tuple[Int, Int], maze: UnsafePointer[Matrix[Int]], chanMap: UnsafePointer[Matrix[Int]], lastCoord: Tuple[Int, Int], turns: Int, pathfinder: Int):
        self.id = id
        self.pathfinder = pathfinder
        self.isDeadEnd = False
        self.lastCoord = lastCoord
        self.coord = coord
        self.children = List[PathTree]()
        self.maze = maze
        self.chanMap = chanMap
        self.turns = turns
        self.isLeaf = False

    # Berechnet den/die Pfad/e
    # @raises Exception
    fn computePath(mut self) raises:
        var col = self.coord[0]
        var row = self.coord[1]
        if self.chanMap[][col, row] != Lee.EMPTY 
            and self.chanMap[][col, row] != Lee.SWITCH
            and self.chanMap[][col, row] != self.id
            and self.chanMap[][col, row] != Lee.CONNECTED:
            self.isDeadEnd = True
        elif self.pathfinder == Lee.CONNECTED:
            self.isLeaf = True
        else:
            if col > 0 and self.maze[][col-1, row] == self.pathfinder - 1:
                var turns = self.turns
                if self.lastCoord[1] != row:
                    turns += 1
                var child = PathTree(self.id, (col-1, row), self.maze, self.chanMap, self.coord, turns, self.pathfinder-1)
                child.computePath()
                if not child.isDeadEnd:
                    self.children.append(child)
            elif col < self.maze[].cols - 1 and self.maze[][col+1, row] == self.pathfinder - 1:
                var turns = self.turns
                if self.lastCoord[1] != row:
                    turns += 1
                var child = PathTree(self.id, (col+1, row), self.maze, self.chanMap, self.coord, turns, self.pathfinder-1)
                child.computePath()
                if not child.isDeadEnd:
                    self.children.append(child)
            elif row > 0 and self.maze[][col, row-1] == self.pathfinder - 1:
                var turns = self.turns
                if self.lastCoord[0] != col:
                    turns += 1
                var child = PathTree(self.id, (col, row-1), self.maze, self.chanMap, self.coord, turns, self.pathfinder-1)
                child.computePath()
                if not child.isDeadEnd:
                    self.children.append(child)
            elif row < self.maze[].rows - 1 and self.maze[][col, row+1] == self.pathfinder - 1:
                var turns = self.turns
                if self.lastCoord[0] != col:
                    turns += 1
                var child = PathTree(self.id, (col, row+1), self.maze, self.chanMap, self.coord, turns, self.pathfinder-1)
                child.computePath()
                if not child.isDeadEnd:
                    self.children.append(child)
            else:
                self.isDeadEnd = True

            self.isDeadEnd = len(self.children) == 0
            if not self.isDeadEnd:
                self.turns = self.children[0].turns
                for child in self.children:
                    if child[].turns < self.turns:
                        self.turns = child[].turns

    # Gibt den günstigsten Pfad zurück
    # @returns den günstigsten Pfad
    # @raises Exception
    fn getPath(self) raises -> List[Tuple[Int, Int]]:
        var path = List[Tuple[Int, Int]]()
        if self.isLeaf:
            path.append(self.coord)
        elif not self.isDeadEnd:
            for child in self.children:
                if child[].turns == self.turns:                  
                    path.extend(child[].getPath())
                    path.append(self.coord)
                    break


        return path


"""
Mutex-Struktur
"""
struct Mutex:
    var owner: ArcPointer[Int]
    var visitor:  ArcPointer[Int]

    alias FREE = -1


    fn __init__(out self):
        self.owner =  ArcPointer[Int](self.FREE)
        self.visitor =  ArcPointer[Int](0)

    fn __copyinit__(out self, other: Mutex):
        self.owner =  other.owner
        self.visitor =  other.visitor

    fn __moveinit__(out self, owned other: Mutex):
        self.owner =  other.owner
        self.visitor =  other.visitor

    async fn lock(mut self, id: Int):
        while not self.owner[] == self.FREE:
            sleep(0.1)
        self.owner[] = id
        while self.visitor[] != 0:
            sleep(0.1)
    
    async fn unlock(mut self, id: Int):
        if self.owner[] == id:
            self.owner[] = self.FREE

    async fn visit(mut self):
        while self.owner[] != self.FREE:
            sleep(0.1)
        self.visitor[] += 1

    async fn unvisit(mut self):
        if self.visitor[] > 0:
            self.visitor[] -= 1


"""
Lee-Struktur
"""     
@value  
struct Lee:
    alias SINK = -4
    alias SWITCH = -3
    alias BLOCKED = -2
    alias EMPTY = -1
    alias CONNECTED = 0
    var isValid: Bool
    var routeLists: Dict[String, Dict[Int, List[Block.SharedBlock]]]
    var chanMap: List[Matrix[Int]]
    var clbMap: Matrix[List[Block.SharedBlock]]
    var netKeys: List[String]
    var nets: Dict[String, List[Tuple[String, Int]]]
    var mutex: List[Mutex]
    var chanWidth: Int
    var chanDelay: Float64
    var pins: List[Pin]
    var archiv: Dict[String, Tuple[Int, Int]]
    
    fn __init__(out self):
        self.isValid = False
        self.routeLists = Dict[String, Dict[Int, List[Block.SharedBlock]]]()
        self.chanMap = List[Matrix[Int]]()
        self.clbMap = Matrix[List[Block.SharedBlock]](0, 0)
        self.netKeys = List[String]()
        self.nets = Dict[String, List[Tuple[String, Int]]]()
        self.mutex = List[Mutex]()
        self.chanWidth = 0
        self.chanDelay = 0.0
        self.pins = List[Pin]()
        self.archiv = Dict[String, Tuple[Int, Int]]()

    fn __init__(out self, nets: Dict[String, List[Tuple[String, Int]]], clbMap: Matrix[List[Block.SharedBlock]], archiv: Dict[String, Tuple[Int, Int]], chanWidth: Int, chanDelay: Float64, pins: List[Pin]):
        self.routeLists = Dict[String, Dict[Int, List[Block.SharedBlock]]]()
        self.chanMap = List[Matrix[Int]]()
        for i in range(chanWidth):
            self.chanMap.append(Matrix[Int]((clbMap.cols-2)*2+1, (clbMap.rows-2)*2+1))
            initMap(self.chanMap[i], Lee.EMPTY)
            for col in range(1, self.chanMap[i].cols, 2):
                for row in range(1, self.chanMap[i].rows, 2):
                    self.chanMap[i][col, row] = Lee.BLOCKED
            for col in range(0, self.chanMap[i].cols, 2):
                for row in range(0, self.chanMap[i].rows, 2):
                    self.chanMap[i][col, row] = Lee.SWITCH
        self.clbMap = clbMap
        self.netKeys = List[String]()
        self.nets = nets
        self.archiv = archiv
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
            alias SINK = Lee.SINK
            alias SWITCH = Lee.SWITCH
            alias BLOCKED = Lee.BLOCKED
            alias EMPTY = Lee.EMPTY
            alias CONNECTED = Lee.CONNECTED
            alias START = CONNECTED + 1
            
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


            try:
                routedClbs.add(self.nets[net][0][0])
            except e:
                print("Error: ", e)
                self.isValid = False
                return

            var refMapClbs = Matrix[List[Block.SharedBlock]](self.chanMap[currentTrack].cols, self.chanMap[currentTrack].rows)
            initMap(refMapClbs)
            var sourceCoord: Tuple[Int, Int] = (0, 0)
            try:
                sourceCoord = archiv[self.nets[net][0][0]]
            except e:
                print("Error: ", e)
                self.isValid = False
                return
            # Initialisiere das Labyrinth
            @parameter
            fn initMaze():
                try:
                    for i in range(len(self.nets[net])):
                        var coord: Tuple[Int, Int] = (0, 0)
                        if i == 0:
                            coord = archiv[self.nets[net][i][0]]
                            if coord[0] == 0:
                                maze[1, coord[1]*2-1] = CONNECTED
                                if len(refMapClbs[1, coord[1]*2-1]) == 0:
                                    refMapClbs[1, coord[1]*2-1].append(self.clbMap[coord[0], coord[1]][0])

                            elif coord[0] == self.clbMap.cols-1:
                                maze[maze.cols-1, coord[1]*2-1] = CONNECTED
                                if len(refMapClbs[maze.cols-1, coord[1]*2-1]) == 0:
                                    refMapClbs[maze.cols-1, coord[1]*2-1].append(self.clbMap[coord[0], coord[1]][0])

                            elif coord[1] == 0:
                                maze[coord[0]*2-1, 1] = CONNECTED
                                if len(refMapClbs[coord[0]*2-1, 1]) == 0:
                                    refMapClbs[coord[0]*2-1, 1].append(self.clbMap[coord[0], coord[1]][0])

                            elif coord[1] == self.clbMap.rows-1:
                                maze[coord[0]*2-1, maze.rows-1] = CONNECTED
                                if len(refMapClbs[coord[0]*2-1, maze.rows-1]) == 0:
                                    refMapClbs[coord[0]*2-1, maze.rows-1].append(self.clbMap[coord[0], coord[1]][0])

                        else:
                            if not self.nets[net][i][0] in routedClbs:
                                coord = archiv[self.nets[net][i][0]]
                                var pinSide = self.pins[self.nets[net][i][1]].sides[0]
                                if pinSide == Faceside.TOP:
                                    maze[coord[0]*2-1, coord[1]*2] = SINK
                                    if len(refMapClbs[coord[0]*2-1, coord[1]*2]) == 0:
                                        refMapClbs[coord[0]*2-1, coord[1]*2].append(self.clbMap[coord[0], coord[1]][0])

                                elif pinSide == Faceside.RIGHT:
                                    maze[coord[0]*2, coord[1]*2-1] = SINK
                                    if len(refMapClbs[coord[0]*2, coord[1]*2-1]) == 0:
                                        refMapClbs[coord[0]*2, coord[1]*2-1].append(self.clbMap[coord[0], coord[1]][0])

                                elif pinSide == Faceside.BOTTOM:
                                    maze[coord[0]*2-1, coord[1]*2-2] = SINK
                                    if len(refMapClbs[coord[0]*2-1, coord[1]*2-2]) == 0:
                                        refMapClbs[coord[0]*2-1, coord[1]*2-2].append(self.clbMap[coord[0], coord[1]][0])

                                elif pinSide == Faceside.LEFT:
                                    maze[coord[0]*2-2, coord[1]*2-1] = SINK
                                    if len(refMapClbs[coord[0]*2-2, coord[1]*2-1]) == 0:
                                        refMapClbs[coord[0]*2-2, coord[1]*2-1].append(self.clbMap[coord[0], coord[1]][0])

                except e:
                    print("Error: ", e)
                    self.isValid = False
                    return
                    
                for col in range(maze.cols):
                    for row in range(maze.rows):
                        await self.mutex[currentTrack].visit()
                        try:
                            if self.chanMap[currentTrack][col, row] == Lee.EMPTY 
                                or self.chanMap[currentTrack][col, row] == Lee.BLOCKED:
                                maze[col, row] = self.chanMap[currentTrack][col, row]

                            elif self.chanMap[currentTrack][col, row] == id:
                                maze[col, row] = CONNECTED

                            elif self.chanMap[currentTrack][col, row] == Lee.SWITCH:
                                maze[col, row] = EMPTY

                            else:
                                maze[col, row] = BLOCKED
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
            var chanArchiv = Dict[String, Tuple[Int, Int]]()
            while not isFinished:
                var foundSink = False
                pathcount = 0
                # Suche nach dem nächsten Pfad
                try:
                    if maze[sourceCoord[0], sourceCoord[1]] == SINK:
                        sinkCoord = sourceCoord
                        foundSink = True
                        maze[sourceCoord[0], sourceCoord[1]] = CONNECTED
                        pathfinder = CONNECTED
                    else:
                        for col in range(self.clbMap.cols):
                            for row in range(self.clbMap.rows):
                                try:
                                    if maze[col, row] == EMPTY:
                                        if col > 0 and maze[col-1, row] == pathfinder - 1:
                                            maze[col, row] = pathfinder
                                            pathcount += 1
                                        elif col < self.clbMap.cols - 1 and maze[col+1, row] == pathfinder - 1:
                                            maze[col, row] = pathfinder
                                            pathcount += 1
                                        elif row > 0 and maze[col, row-1] == pathfinder - 1:
                                            maze[col, row] = pathfinder
                                            pathcount += 1
                                        elif row < self.clbMap.rows - 1 and maze[col, row+1] == pathfinder - 1:
                                            maze[col, row] = pathfinder
                                            pathcount += 1
                                        elif maze[col, row] == SINK:
                                            maze[col, row] = pathfinder
                                            sinkCoord = (col, row)
                                            sink = refMapClbs[col, row][0]
                                            foundSink = True
                                except e:
                                    print("Error: ", e)
                                    self.isValid = False
                                    return
                                
                                if foundSink:
                                    break
                            if foundSink:
                                break
                except e:
                    print("Error: ", e)
                    self.isValid = False
                    return

                if foundSink:
                    await self.mutex[currentTrack].lock(id)
                    try:
                        var isFree = True
                        var coord = sinkCoord
                        pathfinder = maze[sinkCoord[0], sinkCoord[1]]
                        var pathCoords = List[Tuple[Int, Int]]()


                        var tree = PathTree(id, coord, UnsafePointer.address_of(maze), UnsafePointer.address_of(self.chanMap[currentTrack]), coord, 0, pathfinder)
                        tree.computePath()
                        isFree = not tree.isDeadEnd
                        if isFree:
                            pathCoords = tree.getPath()



                        # Füge den Pfad zur Verdrahtungsliste hinzu  
                        if isFree:
                            if len(pathCoords) == 1:
                                var col = pathCoords[0][0]
                                var row = pathCoords[0][1]
                                var chan: Block.SharedBlock = Block.SharedBlock(Block("Error"))
                                if col % 2 == 0 and row % 2 == 1:
                                    var name = "CHANY".join(col).join(row)
                                    chan = Block.SharedBlock(Block(name, Blocktype.CHANY, self.chanDelay))
                                elif col % 2 == 1 and row % 2 == 0:
                                    var name = "CHANX".join(col).join(row)
                                    chan = Block.SharedBlock(Block(name, Blocktype.CHANX, self.chanDelay))
                                else:
                                    self.isValid = False
                                    return

                                for idx in range(len(refMapClbs[col, row])):
                                    if idx == 0:
                                        chan[].addPreconnection(refMapClbs[col, row][idx])
                                        routeList[currentTrack].append(chan)
                                    else:
                                        refMapClbs[col, row][idx][].addPreconnection(chan)
                                        routeList[currentTrack].append(refMapClbs[col, row][idx])
                                        routedClbs.add(refMapClbs[col, row][idx][].name)
                                refMapClbs[col, row].append(chan)
                                chanArchiv[chan[].name] = (col, row)
                            else:
                                var preChan: Block.SharedBlock = Block.SharedBlock(Block("Error"))
                                for idx in range(len(pathCoords)):                                   
                                    var col = pathCoords[idx][0]
                                    var row = pathCoords[idx][1]
                                    if idx == 0:
                                        if len(refMapClbs[col, row]) == 1:
                                            if refMapClbs[col, row][0][].type == Blocktype.CHANX or refMapClbs[col, row][0][].type == Blocktype.CHANY:
                                                preChan = refMapClbs[col, row][0] 
                                            else:
                                                if col % 2 == 0 and row % 2 == 1:
                                                    var name = "CHANY".join(col).join(row)
                                                    preChan = Block.SharedBlock(Block(name, Blocktype.CHANY, self.chanDelay))
                                                    preChan[].coord = ((col+1)//2, (row+1)//2)
                                                    preChan[].subblk = currentTrack
                                                elif col % 2 == 1 and row % 2 == 0:
                                                    var name = "CHANX".join(col).join(row)
                                                    preChan = Block.SharedBlock(Block(name, Blocktype.CHANX, self.chanDelay))
                                                    preChan[].coord = ((col+1)//2, (row+1)//2)
                                                    preChan[].subblk = currentTrack
                                                else:
                                                    self.isValid = False
                                                    return
                                                preChan[].addPreconnection(refMapClbs[col, row][idx])
                                                routeList[currentTrack].append(preChan)
                                                chanArchiv[preChan[].name] = (col, row)
                                                refMapClbs[col, row].append(preChan)
                                        else:
                                            for clb in refMapClbs[col, row]:
                                                if clb[][].type == Blocktype.CHANX or clb[][].type == Blocktype.CHANY:
                                                    preChan = clb[]
                                                    break    
                                            var chan = preChan[].preconnections[0]
                                            if chan[].type == Blocktype.CHANX or chan[].type == Blocktype.CHANY:
                                                var chanCol = chanArchiv[chan[].name][0]
                                                var chanRow = chanArchiv[chan[].name][1]
                                                var nextCol = pathCoords[idx+1][0]
                                                var nextRow = pathCoords[idx+1][1]
                                                if abs(chanCol - nextCol) < 2 and abs(chanRow - nextRow) < 2:
                                                    preChan = chan
                                            
                                            routeList[currentTrack].append(preChan)

                                    elif idx == len(pathCoords)-1:
                                        var chan: Block.SharedBlock = Block.SharedBlock(Block("Error"))
                                        if col % 2 == 0 and row % 2 == 1:
                                            var name = "CHANY".join(col).join(row)
                                            chan = Block.SharedBlock(Block(name, Blocktype.CHANY, self.chanDelay))
                                            chan[].coord = ((col+1)//2, (row+1)//2)
                                            chan[].subblk = currentTrack
                                        elif col % 2 == 1 and row % 2 == 0:
                                            var name = "CHANX".join(col).join(row)
                                            chan = Block.SharedBlock(Block(name, Blocktype.CHANX, self.chanDelay))
                                            chan[].coord = ((col+1)//2, (row+1)//2)
                                            chan[].subblk = currentTrack
                                        else:
                                            self.isValid = False
                                            return
                                        chan[].addPreconnection(preChan)
                                        routeList[currentTrack].append(chan)
                                        chanArchiv[chan[].name] = (col, row)
                                        for clb in refMapClbs[col, row]:
                                            clb[][].addPreconnection(chan)
                                            routeList[currentTrack].append(clb[])
                                            routedClbs.add(clb[][].name)

                                        refMapClbs[col, row].append(chan)
                                        preChan = chan
                                        
                                    else:
                                        var isChan = False
                                        var chan: Block.SharedBlock = Block.SharedBlock(Block("Error"))
                                        if col % 2 == 0 and row % 2 == 1:
                                            var name = "CHANY".join(col).join(row)
                                            chan = Block.SharedBlock(Block(name, Blocktype.CHANY, self.chanDelay))
                                            chan[].coord = ((col+1)//2, (row+1)//2)
                                            chan[].subblk = currentTrack
                                            isChan = True
                                        elif col % 2 == 1 and row % 2 == 0:
                                            var name = "CHANX".join(col).join(row)
                                            chan = Block.SharedBlock(Block(name, Blocktype.CHANX, self.chanDelay))
                                            chan[].coord = ((col+1)//2, (row+1)//2)
                                            chan[].subblk = currentTrack
                                            isChan = True
                                        else:
                                            isChan = False
                                        if isChan:
                                            chan[].addPreconnection(preChan)
                                            routeList[currentTrack].append(chan)
                                            chanArchiv[chan[].name] = (col, row)
                                            refMapClbs[col, row].append(chan)
                                            preChan = chan


                    except e:
                        print("Error: ", e)
                        self.isValid = False
                        return
                    finally:
                        await self.mutex[currentTrack].unlock(id)
                    pathfinder = START
                    initMap(maze, Lee.EMPTY)
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
                                initMap(refMapClbs)  
                                initMaze()    
                                chanArchiv = Dict[String, Tuple[Int, Int]]()
                        else:
                            pathfinder += 1
                        initMaze()    
                    except e:
                        print("Error: ", e)
                        self.isValid = False
                        return
            
            self.routeLists[net] = routeList
            return

        parallelize[algo](len(self.netKeys), len(self.netKeys))

    fn getCriticalPath(self, outpads: Set[String]) -> Float64:
        var criticalPath: Float64 = 0.0
        try:
            for padname in outpads:
                var coord = self.archiv[padname[]]
                var clb = self.clbMap[coord[0], coord[1]][0]
                var delays = clb[].getDelay()
                for delay in delays:
                    if delay[] > criticalPath:
                        criticalPath = delay[]
        except e:
            criticalPath = 0.0
            print("Error: Critical Path could not be calculated")
        return criticalPath
