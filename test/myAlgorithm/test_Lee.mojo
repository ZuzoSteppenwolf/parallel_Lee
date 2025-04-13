from testing import assert_equal, assert_true
from collections import Dict, List, Set
from myFormats.Arch import Pin
from myFormats.Net import *
from myUtil.Enum import *
from myUtil.Matrix import *
from myUtil.Block import *
from myUtil.Util import initMap
from myAlgorithm.Lee import Lee


"""
@file test_Lee.mojo

Test für den Lee Algorithmus

@author: Marvin Wollbrück
"""

def test_Lee_1():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = Matrix[List[Block.SharedBlock]](4, 4)
    initMap(clbMap)
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))
    var clb = Block("A", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 1)
    nets["1"] = List[Tuple[String, Int]]()
    nets["1"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)

    var outpads = Set[String]()
    outpads.add("B")

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads), 6, "Lee Kritischerpfad ist nicht 6")
    assert_equal(route.chanMap[0][1, 0], id, "kein Kanal bei (1, 0)")
    assert_equal(route.chanMap[0][2, 1], id, "kein Kanal bei (2, 1)")
    assert_equal(route.chanMap[0][2, 3], id, "kein Kanal bei (2, 3)")
    assert_equal(route.chanMap[0][3, 4], id, "kein Kanal bei (3, 4)")
    assert_equal(route.routeLists["1"][0][0][].name, "A", "Falscher Source Block")
    assert_equal(route.routeLists["1"][0][1][].type, Blocktype.CHANX, "Kein CHANX Kanal bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1][].coord[0], 1, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1][].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][2][].type, Blocktype.CHANY, "Kein CHANY Kanal bei (1, 1)")
    assert_equal(route.routeLists["1"][0][2][].coord[0], 1, "Falsche CHANY Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["1"][0][2][].coord[1], 1, "Falsche CHANY Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["1"][0][3][].type, Blocktype.CHANY, "Kein CHANY Kanal bei (1, 2)")
    assert_equal(route.routeLists["1"][0][3][].coord[0], 1, "Falsche CHANY Kanal Koordinaten bei (1, 2)")
    assert_equal(route.routeLists["1"][0][3][].coord[1], 2, "Falsche CHANY Kanal Koordinaten bei (1, 2)")
    assert_equal(route.routeLists["1"][0][4][].type, Blocktype.CHANX, "Kein CHANX Kanal bei (2, 2)")
    assert_equal(route.routeLists["1"][0][4][].coord[0], 2, "Falsche CHANX Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][4][].coord[0], 2, "Falsche CHANX Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][5][].name, "B", "Falscher Sink Block")

