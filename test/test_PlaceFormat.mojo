from testing import assert_equal
from myFormats.Place import Place, Block
from myUtil.Enum import Blocktype


def test_PlaceFormat_1():

    var place = Place("test/.place/test_PlaceFormat.place")
    assert_equal(place.isValid, True)
    assert_equal(place.net, "test/test.net")
    assert_equal(place.arch, "test/test.arch")
    assert_equal("A" in place.map[0, 0], True)
    assert_equal("B" in place.map[0, 1], True)
    assert_equal("C" in place.map[1, 0], True)
    assert_equal("D" in place.map[1, 1], True)
    assert_equal(place.map[0, 0]["A"][0], Block("A", 0, Blocktype.NONE))
    assert_equal(place.map[0, 1]["B"][0], Block("B", 0, Blocktype.NONE))
    assert_equal(place.map[1, 0]["C"][0], Block("C", 0, Blocktype.NONE))
    assert_equal(place.map[1, 1]["D"][0], Block("D", 0, Blocktype.NONE))
    assert_equal(place.archiv["A"][0], 0)
    assert_equal(place.archiv["A"][1], 0)
    assert_equal(place.archiv["B"][0], 0)
    assert_equal(place.archiv["B"][1], 1)
    assert_equal(place.archiv["C"][0], 1)
    assert_equal(place.archiv["C"][1], 0)
    assert_equal(place.archiv["D"][0], 1)
    assert_equal(place.archiv["D"][1], 1)
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