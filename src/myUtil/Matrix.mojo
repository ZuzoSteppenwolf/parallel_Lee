from memory import UnsafePointer, memset_zero
from collections import InlineArray
"""
@file Matrix.mojo


"""

@value
struct Matrix[type: CollectionElement]:
    var data: UnsafePointer[type]
    var cols: Int
    var rows: Int
    var size: Int

    fn __init__(out self, cols: Int, rows: Int):
        self.cols = cols
        self.rows = rows
        self.size = rows * cols
        self.data = UnsafePointer[type].alloc(rows * cols)

    fn __getitem__(self, col: Int, row: Int) raises -> type:
        if row < 0 or row >= self.rows or col < 0 or col >= self.cols:
            raise ("Index out of bounds")
        return self.data[(row * self.cols) + col]

    fn __setitem__[width: Int = 1](mut self, col: Int, row: Int, owned val: type):
        self.data[(row * self.cols) + col] = val

    fn __len__(self) -> Int:
        return self.size

    fn __del__(owned self):
        self.data.free()

    # Initialitiert den gegebenen Speicherbereich mit gegebenem Wert
    # @param idx Der Index des Speicherbereichs, der initialisiert werden soll
    # @param val Der Wert, mit dem der Speicherbereich initialisiert werden soll
    fn initMemSpace(mut self, idx: Int, owned val: type):
        (self.data+idx).init_pointee_move(val^)

@value
struct ListMatrix[type: CollectionElement]:
    var data: List[type]
    var cols: Int
    var rows: Int
    var size: Int

    fn __init__(out self, cols: Int, rows: Int, val: type):
        self.data = List[type]()
        self.cols = cols
        self.rows = rows
        self.size = rows * cols
        self.data.resize(self.size, val)

    fn __getitem__(self, col: Int, row: Int) raises -> type:
        if row < 0 or row >= self.rows or col < 0 or col >= self.cols:
            raise ("Index out of bounds")
        return self.data[(row * self.cols) + col]

    fn __setitem__[width: Int = 1](mut self, col: Int, row: Int, owned val: type):
        self.data[(row * self.cols) + col] = val

    fn __len__(self) -> Int:
        return self.size
