from memory import UnsafePointer, memset_zero
"""
@file Matrix.mojo


"""
trait Element(Comparable, Stringable, Copyable):
    pass

@value
struct Matrix[type: Element, rows: Int, cols: Int]:
    var data: UnsafePointer[type]
    var size: Int

    fn __init__(out self):
        self.size = rows * cols
        self.data = UnsafePointer[type].alloc(rows * cols)
        memset_zero(self.data, rows * cols)

    fn __getitem__(borrowed self, row: Int, col: Int) -> type:
        return self.data[(row * cols) + col]

    fn __setitem__[width: Int = 1](mut self, row: Int, col: Int, val: type):
        self.data[(row * cols) + col] = val

    fn __len__(borrowed self) -> Int:
        return self.size

    fn __del__(owned self):
        self.data.free()

    fn __str__(borrowed self) -> String:
        var result: String = "[\n"
        for row in range(rows-1, -1, -1):
            result += "["
            for col in range(cols):
                result += str(self.data[(row * cols) + col])
                if col < cols - 1:
                    result += ", "
            result += "]\n"
        result += "]"
        return result

    fn __eq__(borrowed self, other: Matrix[type, rows, cols]) -> Bool:
        if self.size != other.size:
            return False
        for i in range(self.size):
            if self.data[i] != other.data[i]:
                return False
        return True

    fn __ne__(borrowed self, other: Matrix[type, rows, cols]) -> Bool:
        return not self.__eq__(other)
