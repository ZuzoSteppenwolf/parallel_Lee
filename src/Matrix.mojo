from memory import UnsafePointer, memset_zero

@value
struct Matrix[type: DType, rows: Int, cols: Int]:
    var data: UnsafePointer[Scalar[type]]

    fn __init__(out self):
        self.data = UnsafePointer[Scalar[type]].alloc(rows * cols)
        memset_zero(self.data, rows * cols)

    fn __getitem__(borrowed self, row: Int, col: Int) -> Scalar[type]:
        return self.data.load(row * cols + col)

    fn __setitem__[width: Int = 1](mut self, row: Int, col: Int, val: SIMD[type, width]):
        self.data.store(row * cols + col, val)

    fn __del__(owned self):
        self.data.free()

    fn __str__(borrowed self) -> String:
        var result: String = "[\n"
        for row in range(rows):
            result += "["
            for col in range(cols):
                result += str(self.data.load(row * cols + col))
                if col < cols - 1:
                    result += ", "
            result += "]\n"
        result += "]"
        return result
