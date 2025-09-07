from testing import assert_equal
from myFormats.Place import Place, Block
from myUtil.Enum import Blocktype
"""
@author Marvin Wollbrück
"""

alias LOG_DIRECTORY = "test/log/"

def test_PlaceFormat_1():

    var place = Place("test/.place/test_PlaceFormat.place", logDir=LOG_DIRECTORY)
    assert_equal(place.isValid, True, "Place ist nicht valide")
    assert_equal(place.net, "test/test.net", "Net ist nicht valide")
    assert_equal(place.arch, "test/test.arch", "Arch ist nicht valide")
    assert_equal(place.archiv["A"][0], 0, "Archiv A[0] nicht valide")
    assert_equal(place.archiv["A"][1], 0, "Archiv A[1] nicht valide")
    assert_equal(place.archiv["B"][1], 1, "Archiv B[0] nicht valide")
    assert_equal(place.archiv["B"][0], 0, "Archiv B[1] nicht valide")
    assert_equal(place.archiv["C"][0], 1, "Archiv C[0] nicht valide")
    assert_equal(place.archiv["C"][1], 0, "Archiv C[1] nicht valide")
    assert_equal(place.archiv["D"][0], 1, "Archiv D[0] nicht valide")
    assert_equal(place.archiv["D"][1], 1, "Archiv D[1] nicht valide")
    assert_equal(place.clbSubblk["A"], 0, "CLB Subblock A nicht valide")
    assert_equal(place.clbSubblk["B"], 0, "CLB Subblock B nicht valide")
    assert_equal(place.clbSubblk["C"], 0, "CLB Subblock C nicht valide")
    assert_equal(place.clbSubblk["D"], 1, "CLB Subblock D nicht valide")
    return

def test_PlaceFormat_2():
    var place = Place("test/.place/test_invalidMatrix.place", logDir=LOG_DIRECTORY)
    assert_equal(place.isValid, False)
    return

def test_PlaceFormat_3():
    var place = Place("test/.place/test_invalidFirstLine.place", logDir=LOG_DIRECTORY)
    assert_equal(place.isValid, False)
    return

def test_PlaceFormat_4():
    var place = Place("test/.place/test_invalidSecLine.place", logDir=LOG_DIRECTORY)
    assert_equal(place.isValid, False)
    return

def test_PlaceFormat_5():
    var place = Place("test/.place/test_invalidPlacement.place", logDir=LOG_DIRECTORY)
    assert_equal(place.isValid, False)
    return