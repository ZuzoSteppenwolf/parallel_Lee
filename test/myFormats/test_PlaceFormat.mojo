from testing import assert_equal
from myFormats.Place import Place, Block
from myUtil.Enum import Blocktype


def test_PlaceFormat_1():

    var place = Place("test/.place/test_PlaceFormat.place")
    assert_equal(place.isValid, True, "Place ist nicht valide")
    assert_equal(place.net, "test/test.net", "Net ist nicht valide")
    assert_equal(place.arch, "test/test.arch", "Arch ist nicht valide")
    assert_equal("A" in place.map[0, 0], True, "Block A nicht in map")
    assert_equal("B" in place.map[0, 1], True, "Block B nicht in map")
    assert_equal("C" in place.map[1, 0], True, "Block C nicht valide")
    assert_equal("D" in place.map[1, 1], True, "Block D nicht in map")
    assert_equal(place.map[0, 0]["A"][0], Block("A", Blocktype.NONE, 0), "Block A in map nicht valide")
    assert_equal(place.map[0, 1]["B"][0], Block("B", Blocktype.NONE, 0), "Block B in map nicht valide")
    assert_equal(place.map[1, 0]["C"][0], Block("C", Blocktype.NONE, 0), "Block C in map nicht valide")
    assert_equal(place.map[1, 1]["D"][0], Block("D", Blocktype.NONE, 0), "Block D in map nicht valide")
    assert_equal(place.archiv["A"][0], 0, "Archiv A[0] nicht valide")
    assert_equal(place.archiv["A"][1], 0, "Archiv A[1] nicht valide")
    assert_equal(place.archiv["B"][1], 1, "Archiv B[0] nicht valide")
    assert_equal(place.archiv["B"][0], 0, "Archiv B[1] nicht valide")
    assert_equal(place.archiv["C"][0], 1, "Archiv C[0] nicht valide")
    assert_equal(place.archiv["C"][1], 0, "Archiv C[1] nicht valide")
    assert_equal(place.archiv["D"][0], 1, "Archiv D[0] nicht valide")
    assert_equal(place.archiv["D"][1], 1, "Archiv D[1] nicht valide")
    return

def test_PlaceFormat_2():
    var place = Place("test/.place/test_invalidMatrix.place")
    assert_equal(place.isValid, False)
    return

def test_PlaceFormat_3():
    var place = Place("test/.place/test_invalidFirstLine.place")
    assert_equal(place.isValid, False)
    return

def test_PlaceFormat_4():
    var place = Place("test/.place/test_invalidSecLine.place")
    assert_equal(place.isValid, False)
    return

def test_PlaceFormat_5():
    var place = Place("test/.place/test_invalidPlacement.place")
    assert_equal(place.isValid, False)
    return