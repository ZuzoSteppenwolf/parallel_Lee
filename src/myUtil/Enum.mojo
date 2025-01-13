

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

@register_passable("trivial")
struct ChanType:
    var value: Int8

    alias NONE = ChanType(0)
    alias GAUSSIAN = ChanType(1)
    alias UNIFORM = ChanType(2)
    alias PULSE = ChanType(3)
    alias DELTA = ChanType(4)

    fn __init__(out self, value: Int8):
        self.value = value

    fn __init__(out self, value: String):
        if value == "gaussian":
            self.value = 1
        elif value == "uniform":
            self.value = 2
        elif value == "pulse":
            self.value = 3
        elif value == "delta":
            self.value = 4
        else:
            self.value = 0

    fn __eq__(borrowed self, other: ChanType) -> Bool:
        return self.value == other.value

    fn __ne__(borrowed self, other: ChanType) -> Bool:
        return not self.__eq__(other)

    fn __lt__(borrowed self, other: ChanType) -> Bool:
        return self.value < other.value

    fn __gt__(borrowed self, other: ChanType) -> Bool:
        return self.value > other.value

    fn __le__(borrowed self, other: ChanType) -> Bool:
        return self.value <= other.value

    fn __ge__(borrowed self, other: ChanType) -> Bool:
        return self.value >= other.value

    fn __str__(borrowed self) -> String:
        if self.value == 0:
            return "NONE"
        elif self.value == 1:
            return "GAUSSIAN"
        elif self.value == 2:
            return "UNIFORM"
        elif self.value == 3:
            return "PULSE"
        elif self.value == 4:
            return "DELTA"
        else:
            return "UNKNOWN"

@register_passable("trivial")
struct Faceside:
    var value: Int8

    alias NONE = Faceside(0)
    alias TOP = Faceside(1)
    alias BOTTOM = Faceside(2)
    alias LEFT = Faceside(3)
    alias RIGHT = Faceside(4)

    fn __init__(out self, value: Int8):
        self.value = value

    fn __init__(out self, value: String):
        if value == "top":
            self.value = 1
        elif value == "bottom":
            self.value = 2
        elif value == "left":
            self.value = 3
        elif value == "right":
            self.value = 4
        else:
            self.value = 0

    fn __eq__(borrowed self, other: Faceside) -> Bool:
        return self.value == other.value

    fn __ne__(borrowed self, other: Faceside) -> Bool:
        return not self.__eq__(other)

    fn __lt__(borrowed self, other: Faceside) -> Bool:
        return self.value < other.value

    fn __gt__(borrowed self, other: Faceside) -> Bool:
        return self.value > other.value

    fn __le__(borrowed self, other: Faceside) -> Bool:
        return self.value <= other.value

    fn __ge__(borrowed self, other: Faceside) -> Bool:
        return self.value >= other.value

    fn __str__(borrowed self) -> String:
        if self.value == 0:
            return "NONE"
        elif self.value == 1:
            return "TOP"
        elif self.value == 2:
            return "BOTTOM"
        elif self.value == 3:
            return "LEFT"
        elif self.value == 4:
            return "RIGHT"
        else:
            return "UNKNOWN"

@register_passable("trivial")
struct SwitchType:
    var value: Int8

    alias NONE = SwitchType(0)
    alias SUBSET = SwitchType(1)
    alias WILTON = SwitchType(2)
    alias UNIVERSAL = SwitchType(3)

    fn __init__(out self, value: Int8):
        self.value = value

    fn __init__(out self, value: String):
        if value == "subset":
            self.value = 1
        elif value == "wilton":
            self.value = 2
        elif value == "universal":
            self.value = 3
        else:
            self.value = 0

    fn __eq__(borrowed self, other: SwitchType) -> Bool:
        return self.value == other.value
    
    fn __ne__(borrowed self, other: SwitchType) -> Bool:
        return not self.__eq__(other)

    fn __lt__(borrowed self, other: SwitchType) -> Bool:
        return self.value < other.value

    fn __gt__(borrowed self, other: SwitchType) -> Bool:
        return self.value > other.value

    fn __le__(borrowed self, other: SwitchType) -> Bool:
        return self.value <= other.value

    fn __ge__(borrowed self, other: SwitchType) -> Bool:
        return self.value >= other.value

    fn __str__(borrowed self) -> String:
        if self.value == 0:
            return "NONE"
        elif self.value == 1:
            return "SUBSET"
        elif self.value == 2:
            return "WILTON"
        elif self.value == 3:
            return "UNIVERSAL"
        else:
            return "UNKNOWN"

@register_passable("trivial")
struct FcType:
    var value: Int8

    alias NONE = FcType(0)
    alias ABSOLUTE = FcType(1)
    alias FRACTIONAL = FcType(2)

    fn __init__(out self, value: Int8):
        self.value = value

    fn __init__(out self, value: String):
        if value == "absolute":
            self.value = 1
        elif value == "fractional":
            self.value = 2
        else:
            self.value = 0

    fn __eq__(borrowed self, other: FcType) -> Bool:
        return self.value == other.value

    fn __ne__(borrowed self, other: FcType) -> Bool:
        return not self.__eq__(other)

    fn __lt__(borrowed self, other: FcType) -> Bool:
        return self.value < other.value

    fn __gt__(borrowed self, other: FcType) -> Bool:
        return self.value > other.value

    fn __le__(borrowed self, other: FcType) -> Bool:
        return self.value <= other.value

    fn __ge__(borrowed self, other: FcType) -> Bool:
        return self.value >= other.value

    fn __str__(borrowed self) -> String:
        if self.value == 0:
            return "NONE"
        elif self.value == 1:
            return "ABSOLUTE"
        elif self.value == 2:
            return "FRACTIONAL"
        else:
            return "UNKNOWN"