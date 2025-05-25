from myFormats.Place import *
from myUtil.Matrix import *
from myUtil.Enum import *
from myUtil.Util import *
from myUtil.Block import *
from myUtil.Threading import Mutex
from myUtil.Logger import async_Log
from myFormats.Arch import *
from collections import Dict, List, Set, Deque, InlineArray
from time import sleep
from algorithm import parallelize

"""
@file Lee.mojo
Erzeugt eine Verdrahtungsliste mit dem Lee-Algorithmus.
Die Netze werden in echtzeit parallel verarbeitet.

@author Marvin Wollbrück
"""
# Hilfs-Arrays für die 4 Bewegungsrichtungen
alias DCOL = InlineArray[Int, 4](-1, 0, 1, 0)
alias DROW = InlineArray[Int, 4](0, 1, 0, -1)

"""
PathTree-Struktur

Die Struktur wird verwendet um den optimalsten Pfad zu finden.
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

    # Konstruktor
    # @param id: ID des Pfades
    # @param coord: Koordinate des Pfades
    # @param maze: Zeiger auf das Maze
    # @param chanMap: Zeiger auf die Kanal-Map
    # @param lastCoord: Koordinate des letzten Knotens
    # @param turns: Anzahl der Knoten im Pfad
    # @param pathfinder: Wert des Pfadfinderscursor
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
        
        # Überprüfe ob der Knoten eine Sackgasse ist
        if self.chanMap[][col, row] != Lee.EMPTY 
            and self.chanMap[][col, row] != Lee.SWITCH
            and self.chanMap[][col, row] != self.id:
            self.isDeadEnd = True

        # Überprüfen ob der Knoten am Ziel ist, somit Blatt
        elif self.maze[][col, row] == Lee.CONNECTED:
            self.isLeaf = True

        # Gültiger Knoten
        else:
            var prioMoveCol = self.coord[0] - self.lastCoord[0]
            var prioMoveRow = self.coord[1] - self.lastCoord[1]
            var prioNextCol = col + prioMoveCol
            var prioNextRow = row + prioMoveRow

            # nächster mögliche Knoten in selber Richtung
            if prioNextCol >= 0 and prioNextCol < self.maze[].cols and prioNextRow >= 0 and prioNextRow < self.maze[].rows:
                if self.maze[][prioNextCol, prioNextRow] == self.pathfinder - 1:
                    var turns = self.turns
                    if self.lastCoord[0] != col:
                        turns += 1
                    var child = PathTree(self.id, (prioNextCol, prioNextRow), self.maze, self.chanMap, self.coord, turns, self.pathfinder-1)
                    child.computePath()
                    if not child.isDeadEnd:
                        self.children.append(child)
            
            # Wenn Prio-Knoten Sackgasse ist, dann
            if len(self.children) == 0:
                # nächste mögliche Knoten suchen
                if col > 0 and prioNextCol != col-1 and self.maze[][col-1, row] == self.pathfinder - 1:
                    var turns = self.turns
                    if self.lastCoord[1] != row:
                        turns += 1
                    var child = PathTree(self.id, (col-1, row), self.maze, self.chanMap, self.coord, turns, self.pathfinder-1)
                    child.computePath()
                    if not child.isDeadEnd:
                        self.children.append(child)

                if col < self.maze[].cols - 1 and prioNextCol != col+1 and self.maze[][col+1, row] == self.pathfinder - 1:
                    var turns = self.turns
                    if self.lastCoord[1] != row:
                        turns += 1
                    var child = PathTree(self.id, (col+1, row), self.maze, self.chanMap, self.coord, turns, self.pathfinder-1)
                    child.computePath()
                    if not child.isDeadEnd:
                        self.children.append(child)

                if row > 0 and prioNextRow != row-1 and self.maze[][col, row-1] == self.pathfinder - 1:
                    var turns = self.turns
                    if self.lastCoord[0] != col:
                        turns += 1
                    var child = PathTree(self.id, (col, row-1), self.maze, self.chanMap, self.coord, turns, self.pathfinder-1)
                    child.computePath()
                    if not child.isDeadEnd:
                        self.children.append(child)

                if row < self.maze[].rows - 1 and prioNextRow != row+1 and self.maze[][col, row+1] == self.pathfinder - 1:
                    var turns = self.turns
                    if self.lastCoord[0] != col:
                        turns += 1
                    var child = PathTree(self.id, (col, row+1), self.maze, self.chanMap, self.coord, turns, self.pathfinder-1)
                    child.computePath()
                    if not child.isDeadEnd:
                        self.children.append(child)

            # Überprüfe ob der Knoten eine Sackgasse ist
            self.isDeadEnd = len(self.children) == 0
            if not self.isDeadEnd:
                # nach den wenigsten Knicken suchen
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
Lee-Struktur
"""     
@value  
struct Lee:
    alias LOG_PATH = "log/lee.log"
    alias SINK = -4
    alias SWITCH = -3
    alias BLOCKED = -2
    alias EMPTY = -1
    alias CONNECTED = 0
    var isValid: Bool
    var routeLists: Dict[String, Dict[Int, List[Block.SharedBlock]]]
    var chanMap: List[Matrix[Int]]
    var clbMap: ListMatrix[List[Block.SharedBlock]]
    var netKeys: List[String]
    var nets: Dict[String, List[Tuple[String, Int]]]
    var mutex: List[Mutex]
    var chanWidth: Int
    var chanDelay: Float64
    var pins: List[Pin]
    var archiv: Dict[String, Tuple[Int, Int]]
    var log: Optional[async_Log[True]]
    
    # Konstruktor
    fn __init__(out self):
        self.isValid = False
        self.routeLists = Dict[String, Dict[Int, List[Block.SharedBlock]]]()
        self.chanMap = List[Matrix[Int]]()
        self.clbMap = ListMatrix[List[Block.SharedBlock]](0, 0, List[Block.SharedBlock]())
        self.netKeys = List[String]()
        self.nets = Dict[String, List[Tuple[String, Int]]]()
        self.mutex = List[Mutex]()
        self.chanWidth = 0
        self.chanDelay = 0.0
        self.pins = List[Pin]()
        self.archiv = Dict[String, Tuple[Int, Int]]()
        try:
            self.log = async_Log[True](self.LOG_PATH)
        except:
            self.log = None

    # Konstruktor
    # @param nets: Netze
    # @param clbMap: CLB-Map
    # @param archiv: Archiv
    # @param chanWidth: Kanalbreite
    # @param chanDelay: Kanalverzögerung
    # @param pins: Pins
    fn __init__(out self, nets: Dict[String, List[Tuple[String, Int]]], clbMap: ListMatrix[List[Block.SharedBlock]], archiv: Dict[String, Tuple[Int, Int]], chanWidth: Int, chanDelay: Float64, pins: List[Pin]):
        try:
            self.log = async_Log[True](self.LOG_PATH)
        except:
            self.log = None
        self.routeLists = Dict[String, Dict[Int, List[Block.SharedBlock]]]()
        for key in nets.keys():
            self.routeLists[key[]] = Dict[Int, List[Block.SharedBlock]]()
            try:
                for i in range(chanWidth):
                    self.routeLists[key[]][i] = List[Block.SharedBlock]()
            except e:
                if self.log:
                    self.log.value().writeln(-1, "Error: ", e)
                self.isValid = False
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

        for _ in range(chanWidth):
            self.mutex.append(Mutex())

        self.chanWidth = chanWidth
        self.chanDelay = chanDelay
        self.pins = pins
        self.isValid = True       

        for net in nets:
            self.netKeys.append(net[])

        

    fn run(mut self, runParallel: Bool = True):
        
        # Der Lee-Algorithmus für ein Netz
        # @param id: ID des Netzes
        @parameter
        fn algo(id: Int):
            alias SINK = Lee.SINK
            alias SWITCH = Lee.SWITCH
            alias BLOCKED = Lee.BLOCKED
            alias EMPTY = Lee.EMPTY
            alias CONNECTED = Lee.CONNECTED
            alias START = CONNECTED + 1
            
            # Initialisierung
            var routeList = Dict[Int, List[Block.SharedBlock]]()
            for i in range(self.chanWidth):
                routeList[i] = List[Block.SharedBlock]()
                try:
                    var coord = self.archiv[self.nets[self.netKeys[id]][0][0]]
                    for clb in self.clbMap[coord[0], coord[1]]:
                        if clb[][].name == self.nets[self.netKeys[id]][0][0]:
                            routeList[i].append(clb[])
                            break
                except e:
                    if self.log:
                        self.log.value().writeln(id, "ID: ", id, "; Error: ", e)
                    self.isValid = False
                    return
            var net = self.netKeys[id]
            var routedClbs = Set[String]()
            #var track = 0
            var currentTrack = 0#(id+track) % self.chanWidth
            var maze = Matrix[Int](self.chanMap[currentTrack].cols, self.chanMap[currentTrack].rows)

            try:
                routedClbs.add(self.nets[net][0][0])
            except e:
                if self.log:
                    self.log.value().writeln(id, "ID: ", id, "; Error: ", e)
                self.isValid = False
                return

            var refMapClbs = Matrix[List[Block.SharedBlock]](self.chanMap[currentTrack].cols, self.chanMap[currentTrack].rows)
            initMap(refMapClbs)
            initMap(maze, EMPTY)
            var sourceCoord: Tuple[Int, Int]
            try:
                sourceCoord = self.archiv[self.nets[net][0][0]]
            except e:
                if self.log:
                    self.log.value().writeln(id, "ID: ", id, "; Error: ", e)
                self.isValid = False
                return

            var wavefront = Deque[Tuple[Int, Int]]()

            # Gibt die Kanalkoordinate des I/O-Pins des Blocks
            # param coord: Koordinate des Blocks
            # param idx: Index des Blocks in der Netzliste
            # param pinIdx: Index des Pins
            # param col: Ergebnis Spalte des Blocks
            # param row: Ergebnis Zeile des Blocks
            @parameter
            fn getChanCoord(coord: Tuple[Int, Int], idx: Int, pinIdx: Int, mut col: Int, mut row: Int) raises:
                # Wenn Block am Rand, dann Pad
                if coord[0] == 0:
                    col = 0
                    row = coord[1]*2-1

                elif coord[0] == self.clbMap.cols-1:
                    col = maze.cols-1
                    row = coord[1]*2-1

                elif coord[1] == 0:
                    col = coord[0]*2-1
                    row = 0

                elif coord[1] == self.clbMap.rows-1:
                    col = coord[0]*2-1
                    row = maze.rows-1

                # Sonst CLB
                else:
                    var pinSide = self.pins[self.nets[net][idx][1]].sides[pinIdx]
                    if pinSide == Faceside.TOP:
                        col = coord[0]*2-1
                        row = coord[1]*2

                    elif pinSide == Faceside.RIGHT:
                        col = coord[0]*2
                        row = coord[1]*2-1

                    elif pinSide == Faceside.BOTTOM:
                        col = coord[0]*2-1
                        row = coord[1]*2-2

                    elif pinSide == Faceside.LEFT:
                        col = coord[0]*2-2
                        row = coord[1]*2-1
            # end getChanCoord

            # Initialisiere das Labyrinth
            @parameter
            fn initMaze():
                try:
                    wavefront.clear()
                    self.mutex[currentTrack].visit()
                    # Debugging
                    #if self.log:
                    #    self.log.value().writeln(id, "ID: ", id, "; Visit mutex at Track: ", currentTrack)
                    # Verdrahtungskarte Uebertragen
                    for col in range(maze.cols):
                        for row in range(maze.rows):                
                            if self.chanMap[currentTrack][col, row] == Lee.EMPTY 
                                or self.chanMap[currentTrack][col, row] == Lee.BLOCKED:
                                maze[col, row] = self.chanMap[currentTrack][col, row]

                            elif self.chanMap[currentTrack][col, row] == id:
                                maze[col, row] = CONNECTED
                                wavefront.append((col, row))

                            elif self.chanMap[currentTrack][col, row] == Lee.SWITCH:
                                maze[col, row] = EMPTY

                            else:
                                maze[col, row] = BLOCKED
                        

                    # Setze Start und Zielkoordinaten                
                    for i in range(len(self.nets[net])):
                        var coord: Tuple[Int, Int] = self.archiv[self.nets[net][i][0]]
                        var col = 0
                        var row = 0
                        for pinIdx in range(len(self.pins[self.nets[net][i][1]].sides)):
                            # erster Block ist Source
                            if i == 0:
                                getChanCoord(coord, i, pinIdx, col, row)
                                if self.chanMap[currentTrack][col, row] == Lee.EMPTY: #or self.chanMap[currentTrack][col, row] == id:
                                    maze[col, row] = CONNECTED
                                    wavefront.append((col, row))
                                # Debugging
                                #if self.log:
                                #    self.log.value().writeln(id, "ID: ", id, "; Source at: ", coord[0], ";", coord[1])
                                #    self.log.value().writeln(id, "ID: ", id, "; Set source at: ", col, ";", row, " on track: ", currentTrack)
                                #    self.log.value().writeln(id, "ID: ", id, "; Set Value ", self.chanMap[currentTrack][col, row])


                            else:
                                getChanCoord(coord, i, pinIdx, col, row)
                                if self.chanMap[currentTrack][col, row] == Lee.EMPTY and not self.nets[net][i][0] in routedClbs:
                                    maze[col, row] = SINK
                                    # Debugging
                                    #if self.log:
                                    #    self.log.value().writeln(id, "ID: ", id, "; Set sink at: ", col, ";", row, " on track: ", currentTrack)                                                                

                            if maze[col, row] != EMPTY:
                                var isContained = False
                                for clb in refMapClbs[col, row]:
                                    if clb[][].name == self.nets[net][i][0]:
                                        isContained = True
                                        break
                                if not isContained:
                                    for clb in self.clbMap[coord[0], coord[1]]:
                                        if clb[][].name == self.nets[net][i][0]:
                                            refMapClbs[col, row].append(clb[])
                                            break
                except e:
                    if self.log:
                        self.log.value().writeln(id, "ID: ", id, "; Error: ", e)
                    self.isValid = False
                    return
                finally:
                    self.mutex[currentTrack].unvisit()
                    # Debugging
                    #if self.log:
                        #self.writeMap(id, maze)
                    #    self.log.value().writeln(id, "ID: ", id, "; Unvisit mutex at Track: ", currentTrack)
                        
                # end initMaze

            # Start des Algorithmus
            if self.log:
                self.log.value().writeln(id, "ID: ", id, "; Start Lee-Algorithm for net: ", net)
            initMaze()
            if self.log:
                self.log.value().writeln(id, "ID: ", id, "; Init local maze")
            
            var isFinished = False
            var sinkCoord: Tuple[Int, Int] = (0, 0)
            var chanArchiv = Dict[String, Tuple[Int, Int]]()
            while not isFinished and self.isValid:
                var foundSink = False
                # Suche nach dem nächsten Pfad
                try:
                    for pinIdx in range(len(self.pins[self.nets[net][0][1]].sides)):
                        var col = 0
                        var row = 0
                        getChanCoord(sourceCoord, 0, pinIdx, col, row)
                        if maze[col, row] == SINK:
                            sinkCoord = (col, row)
                            foundSink = True
                            maze[col, row] = CONNECTED
                            if self.log:
                                self.log.value().writeln(id, "ID: ", id, "; Found sink at source: ", col, ";", row, " Value ", col, row, " on track: ", currentTrack)
                            break
                    if not foundSink:
                        while wavefront and not foundSink and self.isValid:
                            var coord = wavefront.popleft()
                            pathfinder = maze[coord[0], coord[1]] + 1
                            for i in range(4):
                                var col = coord[0] + DCOL[i]
                                var row = coord[1] + DROW[i]
                                if col >= 0 and col < maze.cols and row >= 0 and row < maze.rows:
                                    if maze[col, row] == SINK:
                                        foundSink = True
                                        sinkCoord = (col, row)
                                        maze[col, row] = pathfinder
                                        if self.log:
                                            self.log.value().writeln(id, "ID: ", id, "; Found sink at: ", col, ";", row, " Value ", maze[col, row], " on track: ", currentTrack)
                                        break
                                    if maze[col, row] == EMPTY:
                                        maze[col, row] = pathfinder
                                        wavefront.append((col, row))

                except e:
                    if self.log:
                        self.log.value().writeln(id, "ID: ", id, "; Error: ", e)
                    self.isValid = False
                    return
                # Debugging
                #if self.log:
                #    self.writeMap(id, maze)
                #    self.log.value().writeln(id, "ID: ", id, "; Pathcount: ", pathcount, " on track: ", currentTrack)

                if foundSink:
                    # Debugging
                    if self.log:
                        self.log.value().writeln(id, "ID: ", id, "; Found sink at: ", sinkCoord[0], ";", sinkCoord[1], " on track: ", currentTrack)
                    #    self.log.value().writeln(id, "ID: ", id, "; visitcount: ", self.mutex[currentTrack].visitor[].load(), " on track: ", currentTrack)

                    # Wenn Ziel gefunden, dann Pfad berechnen
                    self.mutex[currentTrack].lock(id)
                    # Debugging
                    #if self.log:
                    #    self.log.value().writeln(id, "ID: ", id, "; Lock mutex at Track: ", currentTrack)
                    try:
                        
                        var isFree = True
                        var coord = sinkCoord
                        pathfinder = maze[sinkCoord[0], sinkCoord[1]]
                        var pathCoords = List[Tuple[Int, Int]]()

                        var tree = PathTree(id, coord, UnsafePointer(to=maze), UnsafePointer(to=self.chanMap[currentTrack]), coord, 0, pathfinder)
                        # Debugging
                        #if self.log:
                        #    self.log.value().writeln(id, "ID: ", id, "; Create path tree")
                        tree.computePath()
                        isFree = not tree.isDeadEnd
                        # Debuggung
                        #if self.log:
                        #    self.log.value().writeln(id, "ID: ", id, "; isFree: ", isFree)
                        if isFree:
                            pathCoords = tree.getPath()



                        # Füge den Pfad zur Verdrahtungsliste hinzu  
                        if isFree:
                            #if self.log:
                            #    self.log.value().writeln(id, "ID: ", id, "; Free path for sink at: ", sinkCoord[0], ";", sinkCoord[1], " on track: ", currentTrack)
                            
                            var preChan: Optional[Block.SharedBlock] = None
                            while pathCoords:
                                var coord = pathCoords[0]
                                
                                if self.chanMap[currentTrack][coord[0], coord[1]] == id:
                                    for clb in refMapClbs[coord[0], coord[1]]:
                                        if clb[][].type == Blocktype.CHANX or clb[][].type == Blocktype.CHANY:
                                            preChan = clb[]
                                            break
                                    for chan in preChan.value()[].preconnections:
                                        if chan[][].type == Blocktype.CHANX or chan[][].type == Blocktype.CHANX:
                                            var chanCol = chanArchiv[chan[][].name][0]
                                            var chanRow = chanArchiv[chan[][].name][1]
                                            var nextCol = pathCoords[0][0]
                                            var nextRow = pathCoords[0][1]
                                            if abs(chanCol - nextCol) < 2 and abs(chanRow - nextRow) < 2:
                                                preChan = chan[]
                                                break
                                elif self.chanMap[currentTrack][coord[0], coord[1]] != Lee.SWITCH:
                                    var chan: Block.SharedBlock
                                    if preChan is None:
                                        for pinIdx in range(len(self.pins[self.nets[net][0][1]].sides)):
                                            var col = 0
                                            var row = 0
                                            getChanCoord(sourceCoord, 0, pinIdx, col, row)
                                            if col == coord[0] and row == coord[1]:
                                                for clb in refMapClbs[col, row]:
                                                    if clb[][].name == self.nets[net][0][0]:
                                                        preChan = clb[]
                                                        break
                                    var col = coord[0]
                                    var row = coord[1]
                                    if col % 2 == 0 and row % 2 == 1:
                                        var name = String(id).join("CHANY").join(col).join(row).join("T").join(currentTrack)
                                        chan = Block.SharedBlock(Block(name, Blocktype.CHANY, self.chanDelay))
                                    elif col % 2 == 1 and row % 2 == 0:
                                        var name = String(id).join("CHANX").join(col).join(row).join("T").join(currentTrack)
                                        chan = Block.SharedBlock(Block(name, Blocktype.CHANX, self.chanDelay))            
                                    else:
                                        self.isValid = False
                                        if self.log:
                                            self.log.value().writeln(id, "ID: ", id, "; Error: Coordinate corresponds to no channel block")
                                        return
                                    if preChan is None:
                                        if self.log:
                                            self.log.value().writeln(id, "ID: ", id, "; Error: PreChan is None")
                                        self.isValid = False
                                        return
                                    
                                    chan[].coord = ((col+1)//2, (row+1)//2)
                                    chan[].subblk = currentTrack
                                    chan[].addPreconnection(preChan.value())
                                    chanArchiv[chan[].name] = (col, row)
                                    if len(pathCoords) == 1:
                                        for clb in refMapClbs[col, row]:
                                            if clb[][].name != self.nets[net][0][0] and (clb[][].type == Blocktype.CLB or clb[][].type == Blocktype.OUTPAD):
                                                clb[][].addPreconnection(chan)
                                                routedClbs.add(clb[][].name)
                                    refMapClbs[col, row].append(chan[])
                                    self.chanMap[currentTrack][coord[0], coord[1]] = id                        
                                _ = pathCoords.pop(0)
                            if self.log:
                                self.log.value().writeln(id, "ID: ", id, "; Added path to routeList on track: ", currentTrack)


                    except e:
                        if self.log:
                            self.log.value().writeln(id, "ID: ", id, "; Error: ", e)
                        self.isValid = False
                        return
                    finally:
                        self.mutex[currentTrack].unlock(id)
                        # Debugging
                        #if self.log:
                        #    self.log.value().writeln(id, "ID: ", id, "; Unlock mutex at Track: ", currentTrack)
                    #initMap(maze, Lee.EMPTY)
                    initMaze()
                    if self.log:
                        self.log.value().writeln(id, "ID: ", id, "; Init local maze")
                else:
                    try:
                        if len(routedClbs) == len(self.nets[net]):
                            if self.log:
                                self.log.value().writeln(id, "ID: ", id, "; All blocks routed")
                            isFinished = True
                        else:
                            if self.log:
                                self.log.value().writeln(id, "ID: ", id, "; No sink found")
                            #track += 1
                            currentTrack += 1#(id+track) % self.chanWidth
                            if currentTrack == self.chanWidth:#id % self.chanWidth:
                                if self.log:
                                    self.log.value().writeln(id, "ID: ", id, "; No path found")
                                isFinished = True
                                self.isValid = False
                            else:
                                if self.log:
                                    self.log.value().writeln(id, "ID: ", id, "; No path found, try next track")
                                initMap(refMapClbs)  
                                initMaze()    
                                if self.log:
                                    self.log.value().writeln(id, "ID: ", id, "; Init local maze")
                                chanArchiv = Dict[String, Tuple[Int, Int]]()
                              
                    except e:
                        if self.log:
                            self.log.value().writeln(id, "ID: ", id, "; Error: ", e)
                        self.isValid = False
                        return
            if routeList:
                self.routeLists[net] = routeList
            if self.log:
                self.log.value().writeln(id, "ID: ", id, "; End Lee-Algorithm for net: ", net)
            return
            # end algo

        # Berechne die Pfade
        if self.log:
            self.log.value().writeln(-1, "Netzanzahl: ", len(self.netKeys))
        if runParallel:
            if self.log:
                self.log.value().writeln(-1, "Start Parallel Lee-Algorithm")
            parallelize[algo](len(self.netKeys), len(self.netKeys))
        else:
            if self.log:
                self.log.value().writeln(-1, "Start Lee-Algorithm")
            for i in range(len(self.netKeys)):
                algo(i)
        if self.log:
            self.log.value().writeln(-1, "End Lee-Algorithm")
        # Debugging
        #self.writeChanMap()

    # Gibt den Kritischenpfad zurück
    # @param outpads: Ausgänge
    # @returns den Kritischenpfad
    fn getCriticalPath(mut self, outpads: Set[String]) -> Float64:
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
            if self.log:
                self.log.value().writeln(-1, "Error: Critical Path could not be calculated")
        return criticalPath

    # Schreibt die chanMap in das Log
    fn writeChanMap(mut self):
        try:
            if self.log:
                self.log.value().writeln(-1, "Start write chanMap(s)")
                for i in range(self.chanWidth):
                    self.log.value().writeln(-1, "chanMap: ", i)
                    self.log.value().writeln(-1, "[")
                    for row in range(self.chanMap[i].rows-1, -1, -1):
                        var line: String = "["             
                        for col in range(self.chanMap[i].cols):
                            if self.chanMap[i][col, row] == Lee.EMPTY:
                                line = line + "E"
                            elif self.chanMap[i][col, row] == Lee.SWITCH:
                                line = line + "S"
                            elif self.chanMap[i][col, row] == Lee.BLOCKED:
                                line = line + "B"
                            else:
                                line = line + String(self.chanMap[i][col, row])
                            if col != self.chanMap[i].cols - 1:
                                line = line + ", "
                        line = line + "]"
                        self.log.value().writeln(-1, line)
                    self.log.value().writeln(-1, "]")
                self.log.value().writeln(-1, "End write chanMap(s)")
        except e:
            if self.log:
                self.log.value().writeln(-1, "Error: ", e)

    fn writeMap(mut self, id: Int, map: Matrix[Int]):
        try:
            self.log.value().writeln(id, "ID:", id, "; ", "[")
            for row in range(map.rows-1, -1, -1):
                var line: String = "["             
                for col in range(map.cols):
                    if map[col, row] == Lee.EMPTY:
                        line = line + "E"
                    elif map[col, row] == Lee.SWITCH:
                        line = line + "S"
                    elif map[col, row] == Lee.BLOCKED:
                        line = line + "B"
                    else:
                        line = line + String(map[col, row])
                    if col != map.cols - 1:
                        line = line + ", "
                line = line + "]"
                self.log.value().writeln(id, "ID:", id, "; ", line)
            self.log.value().writeln(id, "ID:", id, "; ", "]")
        except e:
            if self.log:
                self.log.value().writeln(id, "Error: ", e)
