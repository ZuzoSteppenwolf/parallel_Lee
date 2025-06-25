from collections import List
from myUtil.Enum import ChanType, Faceside, SwitchType, FcType
from myUtil.Util import clearUpLines
from myUtil.Logger import Log
"""
@file Arch.mojo

Parser für das Arch File Format vom VPR Tool

@author Marvin Wollbrück
"""

"""
Datenstruktur für die Kanalbreite eines FPGA-Designs.
"""
@value
struct ChanWidth:
    var type: ChanType
    var peak: Float64
    var width: Float64
    var xpeak: Float64
    var dc: Float64

    # Konstruktor
    # @arg type: Typ der Kanalbreite
    # @arg peak: peak
    # @arg width: width (optional, Standardwert -1)
    # @arg xpeak: xpeak (optional, Standardwert -1)
    # @arg dc: dc (optional, Standardwert -1)
    fn __init__(out self, type: ChanType, peak: Float64, width: Float64 = -1, xpeak: Float64 = -1, dc: Float64 = -1):
        self.type = type
        self.peak = peak
        self.width = width
        self.xpeak = xpeak
        self.dc = dc

    fn __eq__(self, other: ChanWidth) -> Bool:
        return self.type == other.type and self.peak == other.peak and self.width == other.width and self.xpeak == other.xpeak and self.dc == other.dc

    fn __ne__(self, other: ChanWidth) -> Bool:
        return not self.__eq__(other)

    fn __str__(self) -> String:
        return "Type: " + String(self.type) + ", Peak: " + String(self.peak) + ", Width: " + String(self.width) + ", Xpeak: " + String(self.xpeak) + ", DC: " + String(self.dc)

"""
Datenstruktur für die Pins eines FPGA-Designs.
"""
@value
struct Pin:
    var isInpin: Bool # Input-Pin, sonst Output-Pin
    var pinClass: Int8
    var isGlobal: Bool
    var sides: List[Faceside]

    # Konstruktor
    # @arg isInpin: True, wenn es sich um einen Input-Pin handelt, sonst False
    # @arg pinClass: Klasse des Pins
    # @arg sides: Liste der Seiten, an denen der Pin angeschlossen ist
    # @arg isGlobal: True, wenn es sich um einen globalen Pin handelt, sonst False (Standardwert False)
    fn __init__(out self, isInpin: Bool, pinClass: Int8, sides: List[Faceside], isGlobal: Bool = False):
        self.isInpin = isInpin
        self.pinClass = pinClass
        self.isGlobal = isGlobal
        self.sides = sides

    fn __eq__(self, other: Pin) -> Bool:
        return self.isInpin == other.isInpin and self.pinClass == other.pinClass and self.isGlobal == other.isGlobal and self.sides == other.sides

    fn __ne__(self, other: Pin) -> Bool:
        return not self.__eq__(other)

    fn __str__(self) -> String:
        var strsides = String("")
        for side in self.sides:
            strsides += String(side[]) + String(", ")
            strsides = strsides[:-2]
        return "IsInpin: " + String(self.isInpin) + ", PinClass: " + String(self.pinClass) + ", IsGlobal: " + String(self.isGlobal) + ", Sides: " + strsides

"""
Datenstruktur für die Segmentlinie eines FPGA-Designs.
"""
@value
struct Segmentline:
    var frequency: Float64
    var length: Int8
    var isLongline: Bool
    var wire_switch: Int8
    var opin_switch: Int8
    var frac_cb: Float64
    var frac_sb: Float64
    var rmetal: Float64
    var cmetal: Float64

    fn __eq__(self, other: Segmentline) -> Bool:
        return self.frequency == other.frequency and self.length == other.length and self.isLongline == other.isLongline and self.wire_switch == other.wire_switch and self.opin_switch == other.opin_switch and self.frac_cb == other.frac_cb and self.frac_sb == other.frac_sb and self.rmetal == other.rmetal and self.cmetal == other.cmetal

    fn __ne__(self, other: Segmentline) -> Bool:
        return not self.__eq__(other)

    fn __str__(self) -> String:
        return "Frequency: " + String(self.frequency) + ", Length: " + String(self.length) + ", IsLongline: " + String(self.isLongline) + ", WireSwitch: " + String(self.wire_switch) + ", OpinSwitch: " + String(self.opin_switch) + ", FracCB: " + String(self.frac_cb) + ", FracSB: " + String(self.frac_sb) + ", Rmetal: " + String(self.rmetal) + ", Cmetal: " + String(self.cmetal)

"""
Datenstruktur für die Switchs eines FPGA-Designs.
"""
@value
struct Switch:
    var switch: Int8
    var isBuffered: Bool
    var R: Float64
    var Cin: Float64
    var Cout: Float64
    var Tdel: Float64

    fn __eq__(self, other: Switch) -> Bool:
        return self.switch == other.switch and self.isBuffered == other.isBuffered and self.R == other.R and self.Cin == other.Cin and self.Cout == other.Cout and self.Tdel == other.Tdel

    fn __ne__(self, other: Switch) -> Bool:
        return not self.__eq__(other)

    fn __str__(self) -> String:
        return "Switch: " + String(self.switch) + ", IsBuffered: " + String(self.isBuffered) + ", R: " + String(self.R) + ", Cin: " + String(self.Cin) + ", Cout: " + String(self.Cout) + ", Tdel: " + String(self.Tdel)

@value
struct Subblock:
    var t_comb: Float64
    var t_seq_in: Float64
    var t_seq_out: Float64

    fn __eq__(self, other: Subblock) -> Bool:
        return self.t_comb == other.t_comb and self.t_seq_in == other.t_seq_in and self.t_seq_out == other.t_seq_out

    fn __ne__(self, other: Subblock) -> Bool:
        return not self.__eq__(other)

    fn __str__(self) -> String:
        return "T_Comb: " + String(self.t_comb) + ", T_Seq_In: " + String(self.t_seq_in) + ", T_Seq_Out: " + String(self.t_seq_out)

"""
Datenstruktur für die Architektur eines FPGA-Designs.
"""
@value
struct Arch:
    var isValid: Bool
    # Kanalbeschreibung
    var io_rat: Int8
    var chan_width_io: Float64
    var chan_width_x: ChanWidth
    var chan_width_y: ChanWidth
    # Logikblockbeschreibung
    var pins: List[Pin]
    var subblocks_per_clb: Int8
    var subblock_lut_size: Int8
    # Detailed Routing
    var switch_block_type: SwitchType
    var fc_type: FcType
    var fc_input: Float64
    var fc_output: Float64
    var fc_pad: Float64
    var segments: List[Segmentline]
    var switches: List[Switch]
    var R_minW_nmos: Float64
    var R_minW_pmos: Float64
    # Timing
    var c_ipin_cblock: Float64
    var t_ipin_cblock: Float64
    var t_ipad: Float64
    var t_opad: Float64
    var t_clb_ipin_to_sblk_ipin: Float64
    var t_sblk_opin_to_clb_opin: Float64
    var t_sblk_opin_to_sblk_ipin: Float64
    var subblocks: List[Subblock]
    # Log
    var log: Optional[Log[True]]

    # Konstruktor
    fn __init__(out self, path: String):
        self.io_rat = -1
        self.chan_width_io = -1
        self.chan_width_x = ChanWidth(ChanType.NONE, 0)
        self.chan_width_y = ChanWidth(ChanType.NONE, 0)
        self.pins = List[Pin]()
        self.subblocks_per_clb = -1
        self.subblock_lut_size = -1
        self.switch_block_type = SwitchType.NONE
        self.fc_type = FcType.NONE
        self.fc_input = -1
        self.fc_output = -1
        self.fc_pad = -1
        self.segments = List[Segmentline]()
        self.switches = List[Switch]()
        self.R_minW_nmos = -1
        self.R_minW_pmos = -1
        self.c_ipin_cblock = -1
        self.t_ipin_cblock = -1
        self.t_ipad = -1
        self.t_opad = -1
        self.t_clb_ipin_to_sblk_ipin = -1
        self.t_sblk_opin_to_clb_opin = -1
        self.t_sblk_opin_to_sblk_ipin = -1
        self.subblocks = List[Subblock]()
        self.isValid = False
        try:
            self.log = Log[True]("log/arch.log")
        except:
            self.log = None
        self.isValid = self.parse(path)

    # Liest die Architekturdatei und speichert die Informationen in der Struktur
    # @arg path: Pfad zur Architekturdatei
    # @return: True, wenn die Datei erfolgreich gelesen wurde, sonst False
    fn parse(mut self, path: String) -> Bool:
        try:
            var lines: List[String]
            with open(path, "r") as file:
                lines = file.read().split("\n")
            lines = clearUpLines(lines)
            if len(lines) == 0:
                return False
            for line in lines:
                var words = line[].split()
                if len(words) == 0:
                    continue
                if words[0] == "io_rat":
                    self.io_rat = atol(words[1])
                    if self.log:
                        self.log.value().writeln("io_rat: " + String(self.io_rat))

                elif words[0] == "chan_width_io":
                    self.chan_width_io = atof(words[1])
                    if self.log:
                        self.log.value().writeln("chan_width_io: " + String(self.chan_width_io))

                elif words[0] == "chan_width_x":
                    var type = ChanType(words[1])
                    if type == ChanType.NONE:
                        return False
                    elif type == ChanType.UNIFORM:
                        self.chan_width_x = ChanWidth(type, atof(words[2]))
                    else:
                        self.chan_width_x = ChanWidth(type, atof(words[2]), atof(words[3]), atof(words[4]), atof(words[5]))
                    
                    if self.log:
                        self.log.value().writeln("chan_width_x: " + String(self.chan_width_x))

                elif words[0] == "chan_width_y":
                    var type = ChanType(words[1])
                    if type == ChanType.NONE:
                        return False
                    elif type == ChanType.UNIFORM:
                        self.chan_width_y = ChanWidth(type, atof(words[2]))
                    else:
                        self.chan_width_y = ChanWidth(type, atof(words[2]), atof(words[3]), atof(words[4]), atof(words[5]))
                    
                    if self.log:
                        self.log.value().writeln("chan_width_y: " + String(self.chan_width_y))

                elif words[0] == "inpin":
                    if words[1] != "class:":
                        return False
                    var isInpin = True
                    var pinClass = atol(words[2])
                    var sides = List[Faceside]()
                    if words[3] == "global":
                        for i in range(4, len(words)):
                            sides.append(Faceside(words[i]))
                        self.pins.append(Pin(isInpin, pinClass, sides, True))
                    else:
                        for i in range(3, len(words)):
                            sides.append(Faceside(words[i]))
                        self.pins.append(Pin(isInpin, pinClass, sides))

                    if self.log:
                        self.log.value().writeln("inpin: " + String(self.pins[-1]))

                elif words[0] == "outpin":
                    if words[1] != "class:":
                        return False
                    var isInpin = False
                    var pinClass = atol(words[2])
                    var sides = List[Faceside]()
                    for i in range(3, len(words)):
                        sides.append(Faceside(words[i]))
                    self.pins.append(Pin(isInpin, pinClass, sides))
                    if self.log:
                        self.log.value().writeln("outpin: " + String(self.pins[-1]))

                elif words[0] == "subblocks_per_clb":
                    self.subblocks_per_clb = atol(words[1])
                    if self.log:
                        self.log.value().writeln("subblocks_per_clb: " + String(self.subblocks_per_clb))

                elif words[0] == "subblock_lut_size":
                    self.subblock_lut_size = atol(words[1])
                    if self.log:
                        self.log.value().writeln("subblock_lut_size: " + String(self.subblock_lut_size))

                elif words[0] == "switch_block_type":
                    self.switch_block_type = SwitchType(words[1])
                    if self.log:
                        self.log.value().writeln("switch_block_type: " + String(self.switch_block_type))

                elif words[0] == "Fc_type":
                    self.fc_type = FcType(words[1])
                    if self.log:
                        self.log.value().writeln("Fc_type: " + String(self.fc_type))

                elif words[0] == "Fc_input":
                    self.fc_input = atof(words[1])
                    if self.log:
                        self.log.value().writeln("Fc_input: " + String(self.fc_input))

                elif words[0] == "Fc_output":
                    self.fc_output = atof(words[1])
                    if self.log:
                        self.log.value().writeln("Fc_output: " + String(self.fc_output))

                elif words[0] == "Fc_pad":
                    self.fc_pad = atof(words[1])
                    if self.log:
                        self.log.value().writeln("Fc_pad: " + String(self.fc_pad))

                elif words[0] == "segment":
                    var freq = -1.
                    var length = -1
                    var isLongline = False
                    var wire_switch = -1
                    var opin_switch = -1
                    var frac_cb = -1.
                    var frac_sb = -1.
                    var rmetal = -1.
                    var cmetal = -1.
                    # Liest die Segmentinformationen aus der Zeile
                    for i in range(1, len(words), 2):
                        if words[i] == "frequency:":
                            freq = atof(words[i+1])
                        elif words[i] == "length:":
                            if words[i+1] == "longline":
                                isLongline = True
                            else:
                                length = atol(words[i+1])
                        elif words[i] == "wire_switch:":
                            wire_switch = atol(words[i+1])
                        elif words[i] == "opin_switch:":
                            opin_switch = atol(words[i+1])
                        elif words[i] == "Frac_cb:":
                            frac_cb = atof(words[i+1])
                        elif words[i] == "Frac_sb:":
                            frac_sb = atof(words[i+1])
                        elif words[i] == "Rmetal:":
                            rmetal = atof(words[i+1])
                        elif words[i] == "Cmetal:":
                            cmetal = atof(words[i+1])
                        else:
                            return False
                    self.segments.append(Segmentline(freq, length, isLongline, wire_switch, opin_switch, frac_cb, frac_sb, rmetal, cmetal))
                    if self.log:
                        self.log.value().writeln("segment: " + String(self.segments[-1]))

                elif words[0] == "switch":
                    var switch = atol(words[1])
                    var isBuffered = False
                    var R = -1.
                    var Cin = -1.
                    var Cout = -1.
                    var Tdel = -1.
                    # Liest die Switchinformationen aus der Zeile
                    for i in range(2, len(words), 2):
                        if words[i] == "buffered:":
                            if words[i+1] == "yes":
                                isBuffered = True
                            elif words[i+1] != "no":
                                return False
                        elif words[i] == "R:":
                            R = atof(words[i+1])
                        elif words[i] == "Cin:":
                            Cin = atof(words[i+1])
                        elif words[i] == "Cout:":
                            Cout = atof(words[i+1])
                        elif words[i] == "Tdel:":
                            Tdel = atof(words[i+1])
                        else:
                            return False
                    self.switches.append(Switch(switch, isBuffered, R, Cin, Cout, Tdel))
                    if self.log:
                        self.log.value().writeln("switch: " + String(self.switches[-1]))

                elif words[0] == "R_minW_nmos":
                    self.R_minW_nmos = atof(words[1])
                    if self.log:
                        self.log.value().writeln("R_minW_nmos: " + String(self.R_minW_nmos))

                elif words[0] == "R_minW_pmos":
                    self.R_minW_pmos = atof(words[1])
                    if self.log:
                        self.log.value().writeln("R_minW_pmos: " + String(self.R_minW_pmos))

                elif words[0] == "C_ipin_cblock":
                    self.c_ipin_cblock = atof(words[1])
                    if self.log:
                        self.log.value().writeln("C_ipin_cblock: " + String(self.c_ipin_cblock))

                elif words[0] == "T_ipin_cblock":
                    self.t_ipin_cblock = atof(words[1]) 
                    if self.log:
                        self.log.value().writeln("T_ipin_cblock: " + String(self.t_ipin_cblock))

                elif words[0] == "T_ipad":
                    self.t_ipad = atof(words[1])
                    if self.log:
                        self.log.value().writeln("T_ipad: " + String(self.t_ipad))

                elif words[0] == "T_opad":
                    self.t_opad = atof(words[1])
                    if self.log:
                        self.log.value().writeln("T_opad: " + String(self.t_opad))

                elif words[0] == "T_clb_ipin_to_sblk_ipin":
                    self.t_clb_ipin_to_sblk_ipin = atof(words[1])
                    if self.log:
                        self.log.value().writeln("T_clb_ipin_to_sblk_ipin: " + String(self.t_clb_ipin_to_sblk_ipin))

                elif words[0] == "T_sblk_opin_to_clb_opin":
                    self.t_sblk_opin_to_clb_opin = atof(words[1])
                    if self.log:
                        self.log.value().writeln("T_sblk_opin_to_clb_opin: " + String(self.t_sblk_opin_to_clb_opin))

                elif words[0] == "T_sblk_opin_to_sblk_ipin":
                    self.t_sblk_opin_to_sblk_ipin = atof(words[1])
                    if self.log:
                        self.log.value().writeln("T_sblk_opin_to_sblk_ipin: " + String(self.t_sblk_opin_to_sblk_ipin))

                elif words[0] == "T_subblock":
                    var t_comb = -1.
                    var t_seq_in = -1.
                    var t_seq_out = -1.
                    # Liest die Subblockinformationen aus der Zeile
                    for i in range(1, len(words), 2):
                        if words[i] == "T_comb:":
                            t_comb = atof(words[i+1])
                        elif words[i] == "T_seq_in:":
                            t_seq_in = atof(words[i+1])
                        elif words[i] == "T_seq_out:":
                            t_seq_out = atof(words[i+1])
                        else:
                            return False
                    self.subblocks.append(Subblock(t_comb, t_seq_in, t_seq_out))
                    if self.log:
                        self.log.value().writeln("T_subblock: " + String(self.subblocks[-1]))
                else:
                    if self.log:
                        self.log.value().writeln("Error: ", words[0], " nicht gefunden")
                    return False
        except e:
            if self.log:
                self.log.value().writeln("Error: ", e)
            return False
        return True

