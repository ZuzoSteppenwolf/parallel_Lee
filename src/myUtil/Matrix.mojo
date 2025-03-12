from memory import UnsafePointer, memset_zero
from collections import Dict
"""
@file Matrix.mojo


"""

@value
struct Matrix[type: Copyable]:
    var data: UnsafePointer[type]
    var cols: Int
    var rows: Int
    var size: Int

    fn __init__(out self, cols: Int, rows: Int):
        self.cols = cols
        self.rows = rows
        self.size = rows * cols
        self.data = UnsafePointer[type].alloc(rows * cols)
        memset_zero(self.data, rows * cols)

    fn __getitem__(self, row: Int, col: Int) raises -> type:
        if row < 0 or row >= self.rows or col < 0 or col >= self.cols:
            raise ("Index out of bounds")
        return self.data[(row * self.cols) + col]

    fn __setitem__[width: Int = 1](mut self, row: Int, col: Int, val: type):
        self.data[(row * self.cols) + col] = val

    fn __len__(self) -> Int:
        return self.size

    fn __del__(owned self):
        self.data.free()
"""
@value
struct Key(KeyElement):
    var row: Int
    var col: Int

    fn __init__(out self, row: Int, col: Int):
        self.row = row
        self.col = col

    fn __eq__(borrowed self, other: Key) -> Bool:
        return self.row == other.row and self.col == other.col

    fn __ne__(borrowed self, other: Key) -> Bool:
        return not self.__eq__(other)

    fn __hash__(borrowed self) -> Int:
        return self.row * 31 + self.col

@value
struct DictMatrix[type: CollectionElement]:
    var data: Dict[Key, type]
    var cols: Int
    var rows: Int
    var size: Int

    fn __init__(out self, cols: Int, rows: Int):
        self.cols = cols
        self.rows = rows
        self.size = rows * cols
        self.data = Dict[Key, type]()

    fn __getitem__(borrowed self, row: Int, col: Int) -> Optional(type):
        if row < 0 or row >= self.rows or col < 0 or col >= self.cols:
            return None
        try:
            return self.data[Key(row, col)]
        except:
            return None

    fn __setitem__[width: Int = 1](mut self, row: Int, col: Int, val: type):
        self.data[Key(row, col)] = val

    fn __len__(borrowed self) -> Int:
        return self.size

    fn __del__(owned self):
        self.data.clear()
"""