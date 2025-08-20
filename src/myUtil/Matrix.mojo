from memory import UnsafePointer, memset_zero
from collections import InlineArray
"""
@file Matrix.mojo

Matrix-Datenstruktur

@author Marvin Wollbrück
"""

"""
Standard Matrix, welche auf einen Speicherbereich zugreift
und diese direkt verwaltet.
"""
@fieldwise_init
struct Matrix[type: Copyable & Movable](Copyable, Movable):
    var data: UnsafePointer[type]
    var cols: Int
    var rows: Int
    var size: Int

    # Konstruktor
    # @arg cols: Anzahl der Spalten
    # @arg rows: Anzahl der Zeilen
    fn __init__(out self, cols: Int, rows: Int):
        self.cols = cols
        self.rows = rows
        self.size = rows * cols
        self.data = UnsafePointer[type].alloc(rows * cols)

    # Greift auf den Wert an der gegebenen Position zu
    # und gibt diesen zurück.
    # @arg col: Spalte
    # @arg row: Zeile
    # @return: Wert an der gegebenen Position
    fn __getitem__(self, col: Int, row: Int) raises -> type:
        if row < 0 or row >= self.rows or col < 0 or col >= self.cols:
            raise ("Index out of bounds (" + String(col) + "; " + String(row) + ")")
        return (self.data + (row * self.cols) + col)[]

    # Setzt den Wert an der gegebenen Position
    # @arg col: Spalte
    # @arg row: Zeile
    # @arg val: Wert, der gesetzt werden soll
    fn __setitem__(mut self, col: Int, row: Int, owned val: type):
        (self.data + (row * self.cols) + col)[] = val

    fn __len__(self) -> Int:
        return self.size

    fn __del__(owned self):
        self.data.free()

    # Initialitiert den gegebenen Speicherbereich mit gegebenem Wert
    # @arg idx Der Index des Speicherbereichs, der initialisiert werden soll
    # @arg val Der Wert, mit dem der Speicherbereich initialisiert werden soll
    fn initMemSpace(mut self, idx: Int, owned val: type):
        (self.data+idx).init_pointee_move(val^)

"""
List-basierte Matrix, welche auf eine Liste zugreift.
"""
@fieldwise_init
struct ListMatrix[type: Copyable & Movable](Copyable, Movable):
    var data: List[type]
    var cols: Int
    var rows: Int
    var size: Int

    # Konstruktor
    # @arg cols: Anzahl der Spalten
    # @arg rows: Anzahl der Zeilen
    # @arg val: Wert, mit dem die Matrix initialisiert werden soll
    fn __init__(out self, cols: Int, rows: Int, val: type):
        self.data = List[type]()
        self.cols = cols
        self.rows = rows
        self.size = rows * cols
        self.data.resize(self.size, val)

    # Greift auf den Wert an der gegebenen Position zu
    # und gibt diesen zurück.
    # @arg col: Spalte
    # @arg row: Zeile
    # @return: Wert an der gegebenen Position
    fn __getitem__(self, col: Int, row: Int) raises -> type:
        if row < 0 or row >= self.rows or col < 0 or col >= self.cols:
            raise ("Index out of bounds (" + String(col) + "; " + String(row) + ")")
        return self.data[(row * self.cols) + col]

    # Setzt den Wert an der gegebenen Position
    # @arg col: Spalte
    # @arg row: Zeile
    # @arg val: Wert, der gesetzt werden soll
    fn __setitem__(mut self, col: Int, row: Int, owned val: type):
        self.data[(row * self.cols) + col] = val

    # Gibt die Größe der Matrix zurück
    # Spalten * Zeilen
    # @return: Größe der Matrix
    fn __len__(self) -> Int:
        return self.size
