from collections import List
from myUtil.Enum import ChanType, Faceside, SwitchType, FcType
"""
@file Arch.mojo

@author Marvin Wollbrück
"""

@value
struct ChanWidth:
    var type: ChanType
    var peak: Float16
    var width: Float16
    var xpeak: Float16
    var dc: Float16

    fn __init__(out self, type: ChanType, peak: Float16, width: Float16 = -1, xpeak: Float16 = -1, dc: Float16 = -1):
        self.type = type
        self.peak = peak
        self.width = width
        self.xpeak = xpeak
        self.dc = dc

@value
struct Pin:
    var isInpin: Bool # Input-Pin, sonst Output-Pin
    var pinClass: Int8
    var isGlobal: Bool
    var sides: List[Faceside]

    fn __init__(out self, isInpin: Bool, pinClass: Int8, sides: List[Faceside], isGlobal: Bool = False):
        self.isInpin = isInpin
        self.pinClass = pinClass
        self.isGlobal = isGlobal
        self.sides = sides

@value
struct Segmentline:
    var frequency: Float16
    var length: Float16
    var isLongline: Bool
    var wire_switch: Int8
    var opin_switch: Int8
    var frac_cb: Float16
    var frac_sb: Float16
    var rmetal: Float16
    var cmetal: Float16

@value
struct Switch:
    var switch: Int8
    var isBufferes: Bool
    var R: Float16
    var Cin: Float16
    var Cout: Float16
    var Tdel: Float16

@value
struct Subblock:
    var t_comb: Float16
    var t_seq_in: Float16
    var t_seq_out: Float16

@value
struct arch:
    var isValid: Bool
    # Kanalbeschreibung
    var io_rat: Int8
    var chan_width_io: Float16
    var chan_width_x: ChanWidth
    var chan_width_y: ChanWidth
    # Logikblockbeschreibung
    var pins: List[Pin]
    var subblocks_per_clb: Int8
    var subblock_lut_size: Int8
    # Detailed Routing
    var switch_block_type: SwitchType
    var fc_type: FcType
    var fc_input: Float16
    var fc_output: Float16
    var fc_pad: Float16
    var segments: List[Segmentline]
    var switches: List[Switch]
    var R_minW_nmos: Float16
    var R_minW_pmos: Float16
    # Timing
    var c_inpin_cblock: Float16
    var t_inpin_cblock: Float16
    var t_ipad: Float16
    var t_opad: Float16
    var t_clb_ipin_to_sblk_ipin: Float16
    var t_sblk_opin_to_clb_opin: Float16
    var t_sblk_opin_to_sblk_ipin: Float16
    var subblocks: List[Subblock]

    fn __init__(out self, path: String):
        self.io_rat = 0
        self.chan_width_io = 0
        self.chan_width_x = ChanWidth(ChanType.NONE, 0)
        self.chan_width_y = ChanWidth(ChanType.NONE, 0)
        self.pins = List[Pin]()
        self.subblocks_per_clb = 0
        self.subblock_lut_size = 0
        self.switch_block_type = SwitchType.NONE
        self.fc_type = FcType.NONE
        self.fc_input = 0
        self.fc_output = 0
        self.fc_pad = 0
        self.segments = List[Segmentline]()
        self.switches = List[Switch]()
        self.R_minW_nmos = 0
        self.R_minW_pmos = 0
        self.c_inpin_cblock = 0
        self.t_inpin_cblock = 0
        self.t_ipad = 0
        self.t_opad = 0
        self.t_clb_ipin_to_sblk_ipin = 0
        self.t_sblk_opin_to_clb_opin = 0
        self.t_sblk_opin_to_sblk_ipin = 0
        self.subblocks = List[Subblock]()
        self.isValid = False
        self.isValid = self.parse(path)

    fn parse(mut self, path: String) -> Bool:
        try:
            with open(path, "r") as file:
                var lines = file.read().split("\n")

        except IOError:
            return False
        return True