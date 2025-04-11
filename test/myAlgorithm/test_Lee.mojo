from testing import assert_equal, assert_true
from collections import Dict, List, Set
from myFormats.Arch import Pin
from myFormats.Net import *
from myUtil.Enum import *
from myUtil.Matrix import *
from myUtil.Block import *
from myAlgorithm.Lee import Route


"""
@file test_Lee.mojo

Test für den Lee Algorithmus

@author: Marvin Wollbrück
"""

def test_Lee_1():
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = Matrix[List[Block.SharedBlock]](4, 4)
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
    clbMap[clb.coord[0], clb.coord[1]] = List[Block.SharedBlock](Block.SharedBlock(clb))

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"] = List[Tuple[String, Int]]()
    nets["1"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]] = List[Block.SharedBlock](Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Route(nets, clbMap, archiv, chanWidth, 1, pins)

    assert_true(route.isValid)
