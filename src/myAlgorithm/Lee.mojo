from myFormats.Place import *
from myUtil.Matrix import *
from myUtil.Enum import *
from myUtil.Util import *
from myUtil.Block import *
from myUtil.Threading import Mutex
from myUtil.Logger import async_Log
from myFormats.Arch import *
from collections import Dict, List, Set
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
            and self.chanMap[][col, row] != self.id
            and self.chanMap[][col, row] != Lee.CONNECTED:
            self.isDeadEnd = True

        # Überprüfen ob der Knoten am Ziel ist, somit Blatt
        elif self.maze[][col, row] == Lee.CONNECTED:
            self.isLeaf = True

        # Gültiger Knoten
        else:
            # nächste mögliche Knoten
            if col > 0 and self.maze[][col-1, row] == self.pathfinder - 1:
                var turns = self.turns
                if self.lastCoord[1] != row:
                    turns += 1
                var child = PathTree(self.id, (col-1, row), self.maze, self.chanMap, self.coord, turns, self.pathfinder-1)
                child.computePath()
                if not child.isDeadEnd:
                    self.children.append(child)
            if col < self.maze[].cols - 1 and self.maze[][col+1, row] == self.pathfinder - 1:
                var turns = self.turns
                if self.lastCoord[1] != row:
                    turns += 1
                var child = PathTree(self.id, (col+1, row), self.maze, self.chanMap, self.coord, turns, self.pathfinder-1)
                child.computePath()
                if not child.isDeadEnd:
                    self.children.append(child)
            if row > 0 and self.maze[][col, row-1] == self.pathfinder - 1:
                var turns = self.turns
                if self.lastCoord[0] != col:
                    turns += 1
                var child = PathTree(self.id, (col, row-1), self.maze, self.chanMap, self.coord, turns, self.pathfinder-1)
                child.computePath()
                if not child.isDeadEnd:
                    self.children.append(child)
            if row < self.maze[].rows - 1 and self.maze[][col, row+1] == self.pathfinder - 1:
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
    var clbMap: Matrix[List[Block.SharedBlock]]
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
        self.clbMap = Matrix[List[Block.SharedBlock]](0, 0)
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

        for _ in range(chanWidth):
            self.mutex.append(Mutex())

        self.chanWidth = chanWidth
        self.chanDelay = chanDelay
        self.pins = pins
        self.isValid = True       

        for net in nets:
            self.netKeys.append(net[])

        try:
            self.log = async_Log[True](self.LOG_PATH)
        except:
            self.log = None

    fn run(mut self):
        
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
                    routeList[i].append(self.clbMap[coord[0], coord[1]][0])
                except e:
                    if self.log:
                        self.log.value().writeln(id, "Error: ", e)
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
                if self.log:
                    self.log.value().writeln(id, "Error: ", e)
                self.isValid = False
                return

            var refMapClbs = Matrix[List[Block.SharedBlock]](self.chanMap[currentTrack].cols, self.chanMap[currentTrack].rows)
            initMap(refMapClbs)
            initMap(maze, EMPTY)
            var sourceCoord: Tuple[Int, Int] = (0, 0)
            try:
                sourceCoord = self.archiv[self.nets[net][0][0]]
            except e:
                if self.log:
                    self.log.value().writeln(id, "Error: ", e)
                self.isValid = False
                return

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
                    col = 1
                    row = coord[1]*2-1

                elif coord[0] == self.clbMap.cols-1:
                    col = maze.cols-2
                    row = coord[1]*2-1

                elif coord[1] == 0:
                    col = coord[0]*2-1
                    row = 1

                elif coord[1] == self.clbMap.rows-1:
                    col = coord[0]*2-1
                    row = maze.rows-2

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
                    
                # Verdrahtungskarte Uebertragen
                for col in range(maze.cols):
                    for row in range(maze.rows):                
                        self.mutex[currentTrack].visit()
                        # Debugging
                        #if self.log:
                        #    self.log.value().writeln(id, "ID: ", id, "; Visit mutex")
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
                            if self.log:
                                self.log.value().writeln(id, "Error: ", e)
                            self.isValid = False
                            return
                        finally:
                            self.mutex[currentTrack].unvisit()
                            # Debugging
                            #if self.log:
                            #    self.log.value().writeln(id, "ID: ", id, "; Unvisit mutex")

                # Setze Start und Zielkoordinaten                
                try:
                    for i in range(len(self.nets[net])):
                        var coord: Tuple[Int, Int] = self.archiv[self.nets[net][i][0]]
                        var col = 0
                        var row = 0
                        for pinIdx in range(len(self.pins[self.nets[net][i][1]].sides)):
                            # erster Block ist Source
                            if i == 0:
                                getChanCoord(coord, i, pinIdx, col, row)
                                maze[col, row] = CONNECTED
                                # Debugging
                                #if self.log:
                                #    self.log.value().writeln(id, "ID: ", id, "; Set source at: ", col, ";", row, " on track: ", currentTrack)

                            else:
                                getChanCoord(coord, i, pinIdx, col, row)
                                if not self.nets[net][i][0] in routedClbs:
                                    maze[col, row] = SINK
                                    # Debugging
                                    #if self.log:
                                    #    self.log.value().writeln(id, "ID: ", id, "; Set sink at: ", col, ";", row, " on track: ", currentTrack)
                                    
                                else:
                                    maze[col, row] = EMPTY

                            if maze[col, row] != EMPTY:
                                var isContained = False
                                for clb in refMapClbs[col, row]:
                                    if clb[][].name == self.nets[net][i][0]:
                                        isContained = True
                                        break
                                if not isContained:
                                    refMapClbs[col, row].append(self.clbMap[coord[0], coord[1]][0])

                except e:
                    if self.log:
                        self.log.value().writeln(id, "Error: ", e)
                    self.isValid = False
                    return
                # end initMaze

            # Start des Algorithmus
            if self.log:
                self.log.value().writeln(id, "ID: ", id, "; Start Lee-Algorithm for net: ", net)
            initMaze()
            if self.log:
                self.log.value().writeln(id, "ID: ", id, "; Init local maze")
            
            var isFinished = False
            var pathfinder = START
            var pathcount = 0
            var sinkCoord: Tuple[Int, Int] = (0, 0)
            var sink: Block.SharedBlock = Block.SharedBlock(Block("Error"))
            var chanArchiv = Dict[String, Tuple[Int, Int]]()
            while not isFinished and self.isValid:
                var foundSink = False
                pathcount = 0
                # Suche nach dem nächsten Pfad
                try:
                    if maze[sourceCoord[0], sourceCoord[1]] == SINK:
                        sinkCoord = sourceCoord
                        foundSink = True
                        maze[sourceCoord[0], sourceCoord[1]] = CONNECTED
                        pathfinder = CONNECTED
                        # Debugging
                        #if self.log:
                        #    self.log.value().writeln(id, "ID: ", id, "; Found sink at: ", sourceCoord[0], ";", sourceCoord[1], " on track: ", currentTrack)
                    else:
                        for col in range(maze.cols):
                            for row in range(maze.rows):
                                try:
                                    if maze[col, row] == EMPTY or maze[col, row] == SINK:
                                        @parameter
                                        fn computePathfinder() raises:
                                            if maze[col, row] == SINK:
                                                maze[col, row] = pathfinder
                                                sinkCoord = (col, row)
                                                sink = refMapClbs[col, row][0]
                                                foundSink = True
                                                # Debugging
                                                #if self.log:
                                                #    self.log.value().writeln(id, "ID: ", id, "; Found sink at: ", col, ";", row, " on track: ", currentTrack)
                                            else:
                                                maze[col, row] = pathfinder
                                                pathcount += 1

                                        if col > 0 and maze[col-1, row] == pathfinder - 1:
                                            computePathfinder()
                                        elif col < maze.cols - 1 and maze[col+1, row] == pathfinder - 1:
                                            computePathfinder()
                                        elif row > 0 and maze[col, row-1] == pathfinder - 1:
                                            computePathfinder()
                                        elif row < maze.rows - 1 and maze[col, row+1] == pathfinder - 1:
                                            computePathfinder()

                                        
                                except e:
                                    if self.log:
                                        self.log.value().writeln(id, "Error: ", e)
                                    self.isValid = False
                                    return
                                
                                if foundSink:
                                    break
                            if foundSink:
                                break
                except e:
                    if self.log:
                        self.log.value().writeln(id, "Error: ", e)
                    self.isValid = False
                    return
                # Debugging
                #if self.log:
                #    self.log.value().writeln(id, "ID: ", id, "; Pathcount: ", pathcount, " on track: ", currentTrack)

                if foundSink:
                    # Debugging
                    if self.log:
                        self.log.value().writeln(id, "ID: ", id, "; Found sink at: ", sinkCoord[0], ";", sinkCoord[1], " on track: ", currentTrack)
                        self.log.value().writeln(id, "ID: ", id, "; visitcount: ", self.mutex[currentTrack].visitor[].load(), " on track: ", currentTrack)

                    # Wenn Ziel gefunden, dann Pfad berechnen
                    self.mutex[currentTrack].lock(id)
                    # Debugging
                    if self.log:
                        self.log.value().writeln(id, "ID: ", id, "; Lock mutex")
                    try:
                        
                        var isFree = True
                        var coord = sinkCoord
                        pathfinder = maze[sinkCoord[0], sinkCoord[1]]
                        var pathCoords = List[Tuple[Int, Int]]()

                        var tree = PathTree(id, coord, UnsafePointer.address_of(maze), UnsafePointer.address_of(self.chanMap[currentTrack]), coord, 0, pathfinder)
                        # Debugging
                        if self.log:
                            self.log.value().writeln(id, "ID: ", id, "; Create path tree")
                        tree.computePath()
                        isFree = not tree.isDeadEnd
                        # Debuggung
                        if self.log:
                            self.log.value().writeln(id, "ID: ", id, "; isFree: ", isFree)
                        if isFree:
                            pathCoords = tree.getPath()



                        # Füge den Pfad zur Verdrahtungsliste hinzu  
                        if isFree:
                            if self.log:
                                self.log.value().writeln(id, "ID: ", id, "; Free path for sink at: ", sinkCoord[0], ";", sinkCoord[1], " on track: ", currentTrack)
                            
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
                                self.chanMap[currentTrack][col, row] = id
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
                                                self.chanMap[currentTrack][col, row] = id
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
                                            self.chanMap[currentTrack][col, row] = id

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
                                        self.chanMap[currentTrack][col, row] = id
                                        
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
                                            self.chanMap[currentTrack][col, row] = id
                            if self.log:
                                self.log.value().writeln(id, "ID: ", id, "; Added path to routeList on track: ", currentTrack)


                    except e:
                        if self.log:
                            self.log.value().writeln(id, "Error: ", e)
                        self.isValid = False
                        return
                    finally:
                        self.mutex[currentTrack].unlock(id)
                        # Debugging
                        if self.log:
                            self.log.value().writeln(id, "ID: ", id, "; Unlock mutex")
                    pathfinder = START
                    initMap(maze, Lee.EMPTY)
                    initMaze()
                else:
                    try:
                        if len(routedClbs) == len(self.nets[net]):
                            if self.log:
                                self.log.value().writeln(id, "ID: ", id, "; All blocks routed")
                            isFinished = True
                        elif pathcount == 0:
                            if self.log:
                                self.log.value().writeln(id, "ID: ", id, "; No sink found")
                            track += 1
                            currentTrack = (id+track) % self.chanWidth
                            pathfinder = START
                            if currentTrack == id % self.chanWidth:
                                if self.log:
                                    self.log.value().writeln(id, "ID: ", id, "; No path found")
                                isFinished = True
                                self.isValid = False
                            else:
                                if self.log:
                                    self.log.value().writeln(id, "ID: ", id, "; No path found, try next track")
                                initMap(refMapClbs)  
                                initMaze()    
                                chanArchiv = Dict[String, Tuple[Int, Int]]()
                        else:
                            pathfinder += 1
                              
                    except e:
                        if self.log:
                            self.log.value().writeln(id, "Error: ", e)
                        self.isValid = False
                        return
            
            self.routeLists[net] = routeList
            if self.log:
                self.log.value().writeln(id, "ID: ", id, "; End Lee-Algorithm for net: ", net)
            return
            # end algo

        # Berechne die Pfade
        if self.log:
            self.log.value().writeln(-1, "Start Parallel Lee-Algorithm")
            self.log.value().writeln(-1, "Netzanzahl: ", len(self.netKeys))
        parallelize[algo](len(self.netKeys), len(self.netKeys))
        if self.log:
            self.log.value().writeln(-1, "End Parallel Lee-Algorithm")
        # Debugging
        self.writeChanMap()

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

