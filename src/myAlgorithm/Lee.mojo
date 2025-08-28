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
from os import os
from tempfile import NamedTemporaryFile
from sys.info import sizeof

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
@fieldwise_init
struct PathTree(Copyable, Movable):
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
            var hasPrio = False
            # nächster mögliche Knoten in selber Richtung
            if prioNextCol >= 0 and prioNextCol < self.maze[].cols and prioNextRow >= 0 and prioNextRow < self.maze[].rows:
                if self.maze[][prioNextCol, prioNextRow] == self.pathfinder - 1:
                    hasPrio = self.turns != 0
                    var turns = self.turns
                    if not (abs(self.lastCoord[0] - col) < 2 and abs(self.lastCoord[1] - row) < 2):
                        turns += 1
                    var child = PathTree(self.id, (prioNextCol, prioNextRow), self.maze, self.chanMap, self.coord, turns, self.pathfinder-1)
                    child.computePath()
                    if not child.isDeadEnd:
                        self.children.append(child)
            
            # Wenn Prio-Knoten Sackgasse ist, dann
            if not hasPrio:
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
                    if child.turns < self.turns:
                        self.turns = child.turns
                var childs = List[PathTree]()
                for child in self.children:
                    if child.turns == self.turns:
                        childs.append(child)
                        break
                self.children = childs

    # Gibt den günstigsten Pfad zurück
    # @returns den günstigsten Pfad
    # @raises Exception
    fn getPath(self) raises -> List[Tuple[Int, Int]]:
        var path = List[Tuple[Int, Int]]()
        if self.isLeaf:
            path.append(self.coord)
        elif not self.isDeadEnd:
            for child in self.children:
                if child.turns == self.turns:
                    path.extend(child.getPath())
                    path.append(self.coord)
                    break
        return path

"""
Lee-Struktur
"""     
@fieldwise_init
struct Lee(Copyable, Movable):
    alias LOG_PATH = "log/lee.log"
    alias SINK = -4
    alias SWITCH = -3
    alias BLOCKED = -2
    alias EMPTY = -1
    alias CONNECTED = 0
    var isValid: Bool
    var routeLists: Dict[String, Dict[Int, List[BlockPair[Int]]]]
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
    var CLB2Num: Dict[String, Int]
    var Num2CLB: Dict[Int, String]

    # Konstruktor
    fn __init__(out self):
        self.isValid = False
        self.routeLists = Dict[String, Dict[Int, List[BlockPair[Int]]]]()
        self.chanMap = List[Matrix[Int]]()
        self.clbMap = ListMatrix[List[Block.SharedBlock]](0, 0, List[Block.SharedBlock]())
        self.netKeys = List[String]()
        self.nets = Dict[String, List[Tuple[String, Int]]]()
        self.mutex = List[Mutex]()
        self.chanWidth = 0
        self.chanDelay = 0.0
        self.pins = List[Pin]()
        self.archiv = Dict[String, Tuple[Int, Int]]()
        self.CLB2Num = Dict[String, Int]()
        self.Num2CLB = Dict[Int, String]()
        try:
            self.log = async_Log[True](self.LOG_PATH)
        except:
            self.log = None

    # Konstruktor
    # @arg nets: Netze
    # @arg clbMap: CLB-Map
    # @arg archiv: Archiv
    # @arg chanWidth: Kanalbreite
    # @arg chanDelay: Kanalverzögerung
    # @arg pins: Pins
    # @arg CLB2Num: Mapping von CLB-Namen zu Nummern
    fn __init__(out self, nets: Dict[String, List[Tuple[String, Int]]], clbMap: ListMatrix[List[Block.SharedBlock]], archiv: Dict[String, Tuple[Int, Int]], chanWidth: Int, chanDelay: Float64, pins: List[Pin], CLB2Num: Dict[String, Int]):
        try:
            self.log = async_Log[True](self.LOG_PATH)
        except:
            self.log = None
        self.routeLists = Dict[String, Dict[Int, List[BlockPair[Int]]]]()
        for key in nets.keys():
            self.routeLists[key] = Dict[Int, List[BlockPair[Int]]]()
            try:
                for i in range(chanWidth):
                    self.routeLists[key][i] = List[BlockPair[Int]]()
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
            self.netKeys.append(net)

        self.CLB2Num = CLB2Num
        self.Num2CLB = Dict[Int, String]()
        try:
            for key in self.CLB2Num.keys():
                self.Num2CLB[self.CLB2Num[key]] = key
        except e:
            if self.log:
                self.log.value().writeln(-1, "Error: ", e)
            self.isValid = False

    # Führe den Lee-Algorithmus aus
    # @arg runParallel: True, wenn der Algorithmus parallel ausgeführt werden soll, sonst False
    fn run(mut self, runParallel: Bool = True):
        
        # Der Lee-Algorithmus für ein Netz
        # @arg id: ID des Netzes
        @parameter
        fn algo(id: Int):
            alias SINK = Lee.SINK
            alias SWITCH = Lee.SWITCH
            alias BLOCKED = Lee.BLOCKED
            alias EMPTY = Lee.EMPTY
            alias CONNECTED = Lee.CONNECTED
            alias START = CONNECTED + 1
            
            # Initialisierung
            var net = self.netKeys[id]
            var routedClbs = Set[BlockPair[Int]]()
            var sourceCoord: Tuple[Int, Int] = (-1, -1)
            var sourceCLB: Optional[Block.SharedBlock] = None

            var routeList = Dict[Int, List[BlockPair[Int]]]()

            try:
                for i in range(len(self.nets[net])):
                    var coord: Tuple[Int, Int] = self.archiv[self.nets[net][i][0]]
                    var col = 0
                    var row = 0
                    var block: Optional[Block.SharedBlock] = None
                    
                    for clb in self.clbMap[coord[0], coord[1]]:
                        if clb[].type == Blocktype.INPAD or not self.pins[self.nets[net][i][1]].isInpin:
                            if clb[].name == self.nets[net][i][0]:  
                                sourceCLB = clb
                                routedClbs.add(BlockPair(clb, self.nets[net][i][1]))
                                sourceCoord = coord
                                break
                    if sourceCLB:
                        break

                for i in range(self.chanWidth):
                    routeList[i] = List[BlockPair[Int]]()
                    routeList[i].append(BlockPair(sourceCLB.value(), self.nets[net][i][1]))
            except e:
                if self.log:
                    self.log.value().writeln(id, "ID: ", id, "; Error: ", e)
                self.isValid = False
                return

            var currentTrack = 0
            var maze = Matrix[Int](self.chanMap[currentTrack].cols, self.chanMap[currentTrack].rows)

            var refMapClbs = Matrix[List[BlockPair[Int]]](self.chanMap[currentTrack].cols, self.chanMap[currentTrack].rows)
            initMap(refMapClbs)
            initMap(maze, EMPTY)

            var wavefront = Deque[Tuple[Int, Int]]()

            # Gibt die Kanalkoordinate des I/O-Pins des Blocks
            # @arg coord: Koordinate des Blocks
            # @arg idx: Index des Blocks in der Netzliste
            # @arg pinIdx: Index des Pins
            # @arg col: Ergebnis Spalte des Blocks
            # @arg row: Ergebnis Zeile des Blocks
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
                        var block: Optional[Block.SharedBlock] = None
                        for clb in self.clbMap[coord[0], coord[1]]:
                            if clb[].name == self.nets[net][i][0]:
                                block = clb
                                break
                        for pinIdx in range(len(self.pins[self.nets[net][i][1]].sides)):
                            # Outpin ist Source
                            if block.value()[].type == Blocktype.INPAD or not self.pins[self.nets[net][i][1]].isInpin:
                                getChanCoord(coord, i, pinIdx, col, row)
                                if self.chanMap[currentTrack][col, row] == Lee.EMPTY:
                                    maze[col, row] = CONNECTED
                                    wavefront.append((col, row))   

                            else:
                                getChanCoord(coord, i, pinIdx, col, row)
                                if self.chanMap[currentTrack][col, row] == Lee.EMPTY and not BlockPair(block.value(), self.nets[net][i][1]) in routedClbs:
                                    maze[col, row] = SINK
                                    
                                # Füge die CLBs zur Referenzkarte hinzu
                                if maze[col, row] != EMPTY:
                                    var isContained = False
                                    for clb in refMapClbs[col, row]:
                                        if clb.block[].name == self.nets[net][i][0]:
                                            isContained = True
                                            break
                                    if not isContained:
                                        refMapClbs[col, row].append(BlockPair(block.value(), self.nets[net][i][1]))
                except e:
                    if self.log:
                        self.log.value().writeln(id, "ID: ", id, "; Error: ", e)
                    self.isValid = False
                    return
                finally:
                    self.mutex[currentTrack].unvisit()
                    
                        
                # end initMaze

            # Start des Algorithmus
            if self.log:
                self.log.value().writeln(id, "ID: ", id, "; Start Lee-Algorithm for net: ", net)
                try:
                    self.log.value().writeln(id, "ID: ", id, "; Number of Blocks in net: ", len(self.nets[net]))
                except:
                    pass
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
                    # Wenn Source gleich Sink, dann fertig
                    for pinIdx in range(len(self.pins[self.nets[net][0][1]].sides)):
                        var col = 0
                        var row = 0
                        getChanCoord(sourceCoord, 0, pinIdx, col, row)
                        if maze[col, row] == SINK:
                            sinkCoord = (col, row)
                            foundSink = True
                            maze[col, row] = CONNECTED
                            if self.log:
                                self.log.value().writeln(id, "ID: ", id, "; Found sink at source: ", col, ";", row, " Value ", maze[col, row], " on track: ", currentTrack)
                            break
                    # Wenn kein Pfad gefunden wurde, dann suche weiter
                    if not foundSink:
                        while wavefront and not foundSink and self.isValid:
                            var coord = wavefront.popleft()
                            pathfinder = maze[coord[0], coord[1]] + 1
                            # Suche in alle 4 Richtungen
                            for i in range(4):
                                var col = coord[0] + DCOL[i]
                                var row = coord[1] + DROW[i]
                                if col >= 0 and col < maze.cols and row >= 0 and row < maze.rows:
                                    if maze[col, row] == SINK:
                                        foundSink = True
                                        sinkCoord = (col, row)
                                        maze[col, row] = pathfinder
                                        if self.log:
                                            self.log.value().writeln(id, "ID: ", id, "; Found sink at: ", col, ";", row, " on track: ", currentTrack)
                                        break
                                    if maze[col, row] == EMPTY:
                                        maze[col, row] = pathfinder
                                        wavefront.append((col, row))

                except e:
                    if self.log:
                        self.log.value().writeln(id, "ID: ", id, "; Error: ", e)
                    self.isValid = False
                    return
               
                if foundSink:
                    
                    # Wenn Ziel gefunden, dann Pfad berechnen
                    self.mutex[currentTrack].lock(id)

                    try:
                        
                        var isFree = True
                        var coord = sinkCoord
                        pathfinder = maze[sinkCoord[0], sinkCoord[1]]
                        var pathCoords = List[Tuple[Int, Int]]()

                        var tree = PathTree(id, coord, UnsafePointer(to=maze), UnsafePointer(to=self.chanMap[currentTrack]), coord, 0, pathfinder)

                        tree.computePath()
                        isFree = not tree.isDeadEnd

                        if isFree:
                            pathCoords = tree.getPath()
                            if self.log:
                                self.log.value().writeln(id, "ID: ", id, "; Found path is valid")
                        else:
                            if self.log:
                                self.log.value().writeln(id, "ID: ", id, "; Found path is invalid")

                        # Füge den Pfad zur Verdrahtungsliste hinzu  
                        if isFree:
                            
                            var preChan: Optional[Block.SharedBlock] = None
                            while pathCoords:
                                var coord = pathCoords[0]
                                
                                # Bestehender Kanal ermitteln
                                if self.chanMap[currentTrack][coord[0], coord[1]] == id:
                                    for clb in refMapClbs[coord[0], coord[1]]:
                                        if clb.block[].type == Blocktype.CHANX or clb.block[].type == Blocktype.CHANY:
                                            preChan = clb.block
                                            break
                                    for chan in preChan.value()[].preconnections:
                                        if chan[].type == Blocktype.CHANX or chan[].type == Blocktype.CHANY:
                                            var chanCol = chanArchiv[chan[].name][0]
                                            var chanRow = chanArchiv[chan[].name][1]
                                            var nextCol = pathCoords[1][0]
                                            var nextRow = pathCoords[1][1]
                                            if abs(chanCol - nextCol) < 2 and abs(chanRow - nextRow) < 2:
                                                preChan = chan
                                                break
                                    routeList[currentTrack].append(BlockPair(preChan.value(), -1))
                                # Anbindung erweitern bis Sink
                                elif self.chanMap[currentTrack][coord[0], coord[1]] != Lee.SWITCH:
                                    var chan: Block.SharedBlock
                                    # Wenn kein bestehender Kanal vorhanden, dann Source
                                    if preChan is None:
                                        preChan = sourceCLB.value()
                                    # Kanal erstellen
                                    var col = coord[0]
                                    var row = coord[1]
                                    var isSourceChan = False
                                    for pinIdx in range(len(self.pins[self.nets[net][0][1]].sides)):
                                        var sourceCol = 0
                                        var sourceRow = 0
                                        getChanCoord(sourceCoord, 0, pinIdx, sourceCol, sourceRow)
                                        if col == sourceCol and row == sourceRow:
                                            isSourceChan = True
                                            break
                                    var delay = self.chanDelay
                                    if isSourceChan:
                                        delay = self.chanDelay * 2
                                    if col % 2 == 0 and row % 2 == 1:
                                        var name = String(id) + "CHANY" + String(col) + ":" + String(row) + "T" + String(currentTrack)
                                        chan = Block.SharedBlock(Block(name, Blocktype.CHANY, delay))
                                    elif col % 2 == 1 and row % 2 == 0:
                                        var name = String(id) + "CHANX" + String(col) + ":" + String(row) + "T" + String(currentTrack)
                                        chan = Block.SharedBlock(Block(name, Blocktype.CHANX, delay))
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
                                    var preDelay = 0.0
                                    if preChan.value()[].type == Blocktype.CHANX or preChan.value()[].type == Blocktype.CHANY:
                                        preDelay = preChan.value()[].preDelays[0] + preChan.value()[].delay
                                    chan[].addPreconnection(preChan.value(), preDelay)
                                    chanArchiv[chan[].name] = (col, row)
                                    routeList[currentTrack].append(BlockPair(chan, -1))#TODO
                                    # Füge die CLBs hinzu, die mit dem Kanal verbunden sind
                                    if len(pathCoords) == 1:
                                        if self.log:
                                            self.log.value().writeln(id, "ID: ", id, "; Blocks: ", len(refMapClbs[col, row]), " at ", col, ";", row)
                                        for clb in refMapClbs[col, row]:
                                            if (clb.block[].type == Blocktype.CLB or clb.block[].type == Blocktype.OUTPAD):
                                                clb.block[].addPreconnection(sourceCLB.value(), chan[].preDelays[0] + chan[].delay)
                                                routedClbs.add(clb)
                                                routeList[currentTrack].append(clb)
                                                if self.log:
                                                    self.log.value().writeln(id, "ID: ", id, "; Added block ", clb.block[].name, " to routeList on track: ", currentTrack)
                                    refMapClbs[col, row].append(BlockPair(chan, -1))#TODO
                                    self.chanMap[currentTrack][coord[0], coord[1]] = id      
                                    preChan = chan  

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
                    initMaze()
                    if self.log:
                        self.log.value().writeln(id, "ID: ", id, "; Init local maze")
                else:
                    try:
                        # Wenn ganzes Netz abgearbeitet, dann fertig
                        if len(routedClbs) == len(self.nets[net]):
                            if self.log:
                                self.log.value().writeln(id, "ID: ", id, "; All blocks routed")
                            isFinished = True
                        else:
                            if self.log:
                                self.log.value().writeln(id, "ID: ", id, "; No sink found")

                            currentTrack += 1
                            # Wenn alle Kanäle abgearbeitet sind, dann abbrechen
                            if currentTrack == self.chanWidth:
                                if self.log:
                                    self.log.value().writeln(id, "ID: ", id, "; No path found")
                                isFinished = True
                                self.isValid = False
                            else:
                                if self.log:
                                    self.log.value().writeln(id, "ID: ", id, "; No path found, try next track")
                                # Initialisierung für den nächsten Durchgang
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
                var set: Set[Int] = Set[Int]()
                try:
                    for idx in routeList.keys():
                    
                        if not len(routeList[idx]) > 1:
                            set.add(idx)
                    for idx in set:
                        _ = routeList.pop(idx)
                except e:
                    if self.log:
                        self.log.value().writeln(id, "ID: ", id, "; Error: ", e)
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

    # Gibt den Kritischenpfad zurück
    # @arg outpads: Ausgänge
    # @returns den Kritischenpfad
    fn getCriticalPath(mut self, outpads: Set[String]) -> Float64:
        var criticalPath: Float64 = 0.0
        var delays: List[Float64] = List[Float64]()
        try:
            for name in outpads:
                var clb: Block.SharedBlock = self.clbMap[self.archiv[name][0], self.archiv[name][1]][0]
                for block in self.clbMap[self.archiv[name][0], self.archiv[name][1]]:
                    if block[].name == name:
                        clb = block
                        break
                if len(clb[].preconnections) == 0:
                    delays.append(clb[].delay)
                else:   
                
                    with NamedTemporaryFile("rw") as fPreDelays, 
                    NamedTemporaryFile("rw") as fIdxs, 
                    NamedTemporaryFile("rw") as fBlockFront:
                        alias MAX_VISIT_COUNT = 2
                        var preDelays: Int = 0
                        var idxs: Int = 0
                        var blockFront: Int = 0

                        @parameter
                        fn setPreDelays(value: Float64) raises:
                            _ = fPreDelays.seek((preDelays - 1) * sizeof[Float64](), os.SEEK_SET)
                            fPreDelays.write_bytes(value.as_bytes())

                        @parameter
                        fn setIdxs(value: Int64) raises:
                            _ = fIdxs.seek((idxs - 1) * sizeof[Int64](), os.SEEK_SET)
                            fIdxs.write_bytes(value.as_bytes())

                        @parameter
                        fn setBlockFront(block: Block.SharedBlock) raises:
                            _ = fBlockFront.seek((blockFront - 1) * sizeof[Int](), os.SEEK_SET)
                            var value: Int64 = self.CLB2Num[block[].name]
                            fBlockFront.write_bytes(value.as_bytes())

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

                        @parameter
                        fn getBlockFront() raises -> Block.SharedBlock:
                            _ = fBlockFront.seek((blockFront - 1) * sizeof[Int](), os.SEEK_SET)
                            var list = fBlockFront.read_bytes(sizeof[Int]())
                            var ptr2UInt8 = list.steal_data() 
                            var ptr2Int = ptr2UInt8.bitcast[Int]()
                            var name = self.Num2CLB[ptr2Int[]]
                            var result: Block.SharedBlock = self.clbMap[self.archiv[name][0], self.archiv[name][1]][0]
                            for block in self.clbMap[self.archiv[name][0], self.archiv[name][1]]:
                                if block[].name == name:
                                    result = block
                                    break
                            return result

                        for idx in range(len(clb[].preconnections)):                    
                            blockFront += 1
                            setBlockFront(clb[].preconnections[idx])
                            while blockFront > 0:
                                var preDelay: Float64 = 0.0
                                if blockFront < idxs:
                                    idxs -= 1
                                elif blockFront > idxs:
                                    idxs += 1
                                    setIdxs(0)
                                if blockFront < preDelays:
                                    var bufferDelay = getPreDelays()
                                    var bufferIdx = getIdxs()
                                    var bufferBlock = getBlockFront()
                                    preDelay = bufferDelay + bufferBlock[].delay + bufferBlock[].preDelays[bufferIdx - 1]
                                    preDelays -= 1
                                elif blockFront > preDelays:
                                    preDelays += 1
                                    var bufferBlock = getBlockFront()
                                    setPreDelays(bufferBlock[].delay)
                                    bufferBlock[].visitCount += 1

                                var bufferDelay = getPreDelays()
                                if bufferDelay < preDelay:
                                    setPreDelays(preDelay)
                                
                                var bufferBlock = getBlockFront()
                                var bufferIdx = getIdxs()
                                if bufferIdx < len(bufferBlock[].preconnections) and not bufferBlock[].hasCritPath and bufferBlock[].visitCount < MAX_VISIT_COUNT:
                                    blockFront += 1
                                    setBlockFront(bufferBlock[].preconnections[bufferIdx])
                                    setIdxs(bufferIdx + 1)
                                else:
                                    if bufferBlock[].visitCount < MAX_VISIT_COUNT:
                                        bufferBlock[].hasCritPath = True
                                        bufferBlock[].delay = getPreDelays()
                                    blockFront -= 1
                                    bufferBlock[].visitCount -= 1
                            preDelays = 1   
                            var bufferDelay = getPreDelays()
                            delays.append(bufferDelay + clb[].delay + clb[].preDelays[idx])
                            preDelays = 0
                            idxs = 0
                            blockFront = 0
                for delay in delays:
                    if delay > criticalPath:
                        criticalPath = delay
                delays = List[Float64]()
        except e:
            criticalPath = 0.0
            if self.log:
                self.log.value().writeln(-1, "Error: Critical Path could not be calculated")
            
        return criticalPath
