from memory import UnsafePointer, memset_zero
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

    fn __getitem__(borrowed self, row: Int, col: Int) -> type:
        return self.data[(row * self.cols) + col]

    fn __setitem__[width: Int = 1](mut self, row: Int, col: Int, val: type):
        self.data[(row * self.cols) + col] = val

    fn __len__(borrowed self) -> Int:
        return self.size

    fn __del__(owned self):
        self.data.free()
