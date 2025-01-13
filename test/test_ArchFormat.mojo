from testing import assert_equal
from myFormats.Arch import *
from myUtil.Enum import *



def test_ArchFormat_1():

    var lines = List[String]() 
    lines.append("#Kommentar")
    lines.append("Zeile")
    lines.append("Zeile #mit Kommentar")
    lines.append("Zeile \\")
    lines.append("mit Zeilenumbruch")
    lines.append("Zeile \\")
    lines.append("#Kommentar")
    lines.append("mit Kommentar")

    newlines = clearUpLines(lines)

    assert_equal(newlines[0], "Zeile")
    assert_equal(newlines[1], "Zeile")
    assert_equal(newlines[2], "Zeile mit Zeilenumbruch")
    assert_equal(newlines[3], "Zeile mit Kommentar")
    return

def test_ArchFormat_2():
    
    var path = "test/.arch/4lut_sanitized.arch"
    var arch = Arch(path)
    assert_equal(arch.isValid, True)
    assert_equal(arch.io_rat, 2)
    assert_equal(arch.chan_width_io, 1)
    assert_equal(arch.chan_width_x, ChanWidth(ChanType.UNIFORM, 1))
    assert_equal(arch.chan_width_y, ChanWidth(ChanType.UNIFORM, 1))

    assert_equal(arch.pins[0], Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    assert_equal(arch.pins[1], Pin(True, 0, List[Faceside](Faceside.LEFT)))
    assert_equal(arch.pins[2], Pin(True, 0, List[Faceside](Faceside.TOP)))
    assert_equal(arch.pins[3], Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    assert_equal(arch.pins[4], Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    assert_equal(arch.pins[5], Pin(True, 2, List[Faceside](Faceside.TOP), True))

    assert_equal(arch.subblocks_per_clb, 1)
    assert_equal(arch.subblock_lut_size, 4)

    assert_equal(arch.switch_block_type, SwitchType.SUBSET)
    assert_equal(arch.fc_type, FcType.FRACTIONAL)
    assert_equal(arch.fc_input, 1)
    assert_equal(arch.fc_output, 1)
    assert_equal(arch.fc_pad, 1)

    assert_equal(arch.segments[0], Segmentline(1, 1, False, 0, 0, 1, 1, 4.16, 81e-15))
    assert_equal(arch.switches[0], Switch(0, True, 786.9, 7.512e-15, 10.762e-15, 456e-12))

    assert_equal(arch.R_minW_nmos, 1967)
    assert_equal(arch.R_minW_pmos, 3738)

    assert_equal(arch.c_inpin_cblock, 7.512e-15)
    assert_equal(arch.t_inpin_cblock, 1.5e-9)

    assert_equal(arch.t_ipad, 478e-12)
    assert_equal(arch.t_opad, 295e-12)
    assert_equal(arch.t_clb_ipin_to_sblk_ipin, 0)
    assert_equal(arch.t_sblk_opin_to_clb_opin, 0)
    assert_equal(arch.t_sblk_opin_to_sblk_ipin, 0)

    assert_equal(arch.subblocks[0], Subblock(546e-12, 845e-12, 478e-12))
    return
