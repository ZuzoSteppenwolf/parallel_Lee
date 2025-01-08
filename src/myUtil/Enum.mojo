

@register_passable("trivial")
struct Blocktype:
    var value: Int8

    alias NONE = Blocktype(0)
    alias INPAD = Blocktype(1)
    alias OUTPAD = Blocktype(2)
    alias CLB = Blocktype(3)
    alias CHANX = Blocktype(4)
    alias CHANY = Blocktype(5)

    fn __init__(out self, value: Int8):
        self.value = value

    fn __eq__(borrowed self, other: Blocktype) -> Bool:
        return self.value == other.value

    fn __ne__(borrowed self, other: Blocktype) -> Bool:
        return not self.__eq__(other)

    fn __lt__(borrowed self, other: Blocktype) -> Bool:
        return self.value < other.value

    fn __gt__(borrowed self, other: Blocktype) -> Bool:
        return self.value > other.value

    fn __le__(borrowed self, other: Blocktype) -> Bool:
        return self.value <= other.value

    fn __ge__(borrowed self, other: Blocktype) -> Bool:
        return self.value >= other.value

    fn __str__(borrowed self) -> String:
        if self.value == 0:
            return "NONE"
        elif self.value == 1:
            return "INPAD"
        elif self.value == 2:
            return "OUTPAD"
        elif self.value == 3:
            return "CLB"
        elif self.value == 4:
            return "CHANX"
        elif self.value == 5:
            return "CHANY"
        else:
            return "UNKNOWN"