from testing import assert_equal
from myUtil.Util import *



def test_Util_1():

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