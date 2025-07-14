from testing import assert_equal, assert_true, assert_false
from collections import Dict, List, Set
from myFormats.Arch import Pin
from myFormats.Net import *
from myUtil.Enum import *
from myUtil.Matrix import ListMatrix
from myUtil.Block import *
from myUtil.Util import initMap
from myAlgorithm.Lee import Lee
from myUtil.Logger import Log


"""
@file test_Lee.mojo

Test für den Lee Algorithmus

@author: Marvin Wollbrück
"""

def test_Lee1():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
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
    route.run()


    var outpads = Set[String]()
    outpads.add("B")

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(len(route.routeLists["1"][0]), 6, "Route Liste für Netz 1 ist nicht 6 lang")
    assert_equal(route.getCriticalPath(outpads), 7, "Lee Kritischerpfad ist nicht 7")
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
    assert_equal(route.routeLists["1"][0][4][].coord[1], 2, "Falsche CHANX Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][5][].name, "B", "Falscher Sink Block")

def test_Lee2():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))

    nets["1"] = List[Tuple[String, Int]]()
    nets["2"] = List[Tuple[String, Int]]()

    var clb = Block("A", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 1)
    nets["1"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("C", Blocktype.CLB, 4, 1)
    clb.coord = Tuple(1, 2)   
    nets["2"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 2))
    nets["2"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.run()

    var outpads = Set[String]()
    outpads.add("B")

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads), 8, "Lee Kritischerpfad ist nicht 8")
    assert_equal(len(route.routeLists["1"][0]), 6, "Route Liste für Netz 1 ist nicht 6 lang")
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
    assert_equal(route.routeLists["1"][0][4][].coord[1], 2, "Falsche CHANX Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][5][].name, "B", "Falscher Sink Block")

    assert_equal(route.routeLists["2"][0][0][].name, "C", "Falscher Source Block")
    assert_equal(route.routeLists["2"][0][1][].type, Blocktype.CHANX, "Kein CHANX Kanal bei (1, 1)")
    assert_equal(route.routeLists["2"][0][1][].coord[0], 1, "Falsche CHANX Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["2"][0][1][].coord[1], 1, "Falsche CHANX Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["2"][0][2][].type, Blocktype.CHANX, "Kein CHANX Kanal bei (2, 1)")
    assert_equal(route.routeLists["2"][0][2][].coord[0], 2, "Falsche CHANX Kanal Koordinaten bei (2, 1)")
    assert_equal(route.routeLists["2"][0][2][].coord[1], 1, "Falsche CHANX Kanal Koordinaten bei (2, 1)")
    assert_equal(route.routeLists["2"][0][3][].name, "B", "Falscher Sink Block")

def test_Lee3():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](42, 42, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))

    nets["1"] = List[Tuple[String, Int]]()
    
    var clb = Block("A", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 1)
    nets["1"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 40)
    nets["1"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.run()    

    assert_true(route.isValid, "Lee ist nicht valide")

def test_Lee4():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](42, 42, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))

    nets["1"] = List[Tuple[String, Int]]()
    nets["2"] = List[Tuple[String, Int]]()

    var clb = Block("A", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 1)
    nets["1"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("C", Blocktype.CLB, 4, 1)
    clb.coord = Tuple(1, 20)   
    nets["2"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(10, 40)
    nets["1"].append(Tuple(clb.name, 2))
    nets["2"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.run()

    assert_true(route.isValid, "Lee ist nicht valide")

def test_Lee5():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](42, 42, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))

    nets["1"] = List[Tuple[String, Int]]()
    nets["2"] = List[Tuple[String, Int]]()

    var clb = Block("A", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 1)
    nets["1"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("C", Blocktype.CLB, 4, 1)
    clb.coord = Tuple(1, 20)   
    nets["2"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(10, 40)
    nets["1"].append(Tuple(clb.name, 2))
    nets["2"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.run(False)

    assert_true(route.isValid, "Lee ist nicht valide")

def test_Lee6():
    alias id = 0
    var chanWidth = 2
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](42, 42, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))

    nets["1"] = List[Tuple[String, Int]]()
    nets["2"] = List[Tuple[String, Int]]()

    var clb = Block("A", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 1)
    nets["1"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("C", Blocktype.CLB, 4, 1)
    clb.coord = Tuple(1, 20)   
    nets["2"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(10, 40)
    nets["1"].append(Tuple(clb.name, 2))
    nets["2"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.run()

    assert_true(route.isValid, "Lee ist nicht valide")

def test_Lee7():
    alias id = 0
    var chanWidth = 2
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))

    nets["1"] = List[Tuple[String, Int]]()
    nets["2"] = List[Tuple[String, Int]]()
    nets["3"] = List[Tuple[String, Int]]()

    var clb = Block("A", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 1)
    nets["1"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("C", Blocktype.CLB, 4, 1)
    clb.coord = Tuple(1, 2)   
    nets["2"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("D", Blocktype.CLB, 4, 1)
    clb.coord = Tuple(2, 1)   
    nets["3"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 2))
    nets["2"].append(Tuple(clb.name, 0))
    nets["3"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.run()

    assert_true(route.isValid, "Lee ist nicht valide")

def test_Lee8():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
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

    clb = Block("C", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 2)
    nets["1"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.run()

    assert_true(route.isValid, "Lee ist nicht valide")

def test_Lee9():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
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

    clb = Block("C", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 2)
    nets["1"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("D", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 1)
    nets["1"].append(Tuple(clb.name, 3))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.run()

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.chanMap[0][1, 0], id, "kein Kanal bei (1, 0)")
    assert_equal(route.chanMap[0][3, 0], id, "kein Kanal bei (3, 0)")
    assert_equal(route.chanMap[0][4, 1], id, "kein Kanal bei (4, 1)")
    assert_equal(route.chanMap[0][4, 3], id, "kein Kanal bei (4, 3)")
    assert_equal(route.chanMap[0][3, 4], id, "kein Kanal bei (3, 4)")
    assert_equal(route.chanMap[0][1, 4], id, "kein Kanal bei (1, 4)")

def test_Lee10():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
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

    clb = Block("D", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 1)
    nets["1"].append(Tuple(clb.name, 3))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.run()

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.chanMap[0][1, 0], id, "kein Kanal bei (1, 0)")
    assert_equal(route.chanMap[0][3, 0], id, "kein Kanal bei (3, 0)")
    assert_equal(route.chanMap[0][4, 1], id, "kein Kanal bei (4, 1)")
    assert_equal(route.chanMap[0][4, 3], id, "kein Kanal bei (4, 3)")
    assert_equal(route.chanMap[0][3, 4], id, "kein Kanal bei (3, 4)")
    assert_equal(route.routeLists["1"][0][0][].name, "A", "Falscher Source Block")
    assert_equal(route.routeLists["1"][0][1][].type, Blocktype.CHANX, "Kein CHANX Kanal bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1][].coord[0], 1, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1][].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][2][].type, Blocktype.CHANX, "Kein CHANX Kanal bei (2, 0)")
    assert_equal(route.routeLists["1"][0][2][].coord[0], 2, "Falsche CHANX Kanal Koordinaten bei (2, 0)")
    assert_equal(route.routeLists["1"][0][2][].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (2, 0)")
    assert_equal(route.routeLists["1"][0][3][].type, Blocktype.CHANY, "Kein CHANY Kanal bei (2, 1)")
    assert_equal(route.routeLists["1"][0][3][].coord[0], 2, "Falsche CHANY Kanal Koordinaten bei (2, 1)")
    assert_equal(route.routeLists["1"][0][3][].coord[1], 1, "Falsche CHANY Kanal Koordinaten bei (2, 1)")
    assert_equal(route.routeLists["1"][0][4][].name, "D", "Falscher Sink Block")
    assert_equal(route.routeLists["1"][0][5][].type, Blocktype.CHANY, "Kein CHANY Kanal bei (2, 1)")
    assert_equal(route.routeLists["1"][0][5][].coord[0], 2, "Falsche CHANY Kanal Koordinaten bei (2, 1)")
    assert_equal(route.routeLists["1"][0][5][].coord[1], 1, "Falsche CHANY Kanal Koordinaten bei (2, 1)")
    assert_equal(route.routeLists["1"][0][6][].type, Blocktype.CHANY, "Kein CHANY Kanal bei (2, 2)")
    assert_equal(route.routeLists["1"][0][6][].coord[0], 2, "Falsche CHANY Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][6][].coord[0], 2, "Falsche CHANY Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][7][].type, Blocktype.CHANX, "Kein CHANX Kanal bei (2, 2)")
    assert_equal(route.routeLists["1"][0][7][].coord[0], 2, "Falsche CHANX Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][7][].coord[1], 2, "Falsche CHANX Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][8][].name, "B", "Falscher Sink Block")

def test_Lee11():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
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
    nets["1"].append(Tuple(clb.name, 1))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("D", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 1)
    nets["1"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.run()

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.routeLists["1"][0][0][].name, "A", "Falscher Source Block")
    assert_equal(route.routeLists["1"][0][1][].type, Blocktype.CHANX, "Kein CHANX Kanal bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1][].coord[0], 1, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1][].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][2][].type, Blocktype.CHANX, "Kein CHANX Kanal bei (2, 0)")
    assert_equal(route.routeLists["1"][0][2][].coord[0], 2, "Falsche CHANX Kanal Koordinaten bei (2, 0)")
    assert_equal(route.routeLists["1"][0][2][].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (2, 0)")
    assert_equal(route.routeLists["1"][0][3][].name, "D", "Falscher Sink Block")
    assert_equal(route.routeLists["1"][0][4][].type, Blocktype.CHANX, "Kein CHANX Kanal bei (1, 0)")
    assert_equal(route.routeLists["1"][0][4][].coord[0], 1, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][4][].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][5][].type, Blocktype.CHANY, "Kein CHANY Kanal bei (1, 1)")
    assert_equal(route.routeLists["1"][0][5][].coord[0], 1, "Falsche CHANY Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["1"][0][5][].coord[1], 1, "Falsche CHANY Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["1"][0][6][].type, Blocktype.CHANY, "Kein CHANY Kanal bei (1, 2)")
    assert_equal(route.routeLists["1"][0][6][].coord[0], 1, "Falsche CHANY Kanal Koordinaten bei (1, 2)")
    assert_equal(route.routeLists["1"][0][6][].coord[1], 2, "Falsche CHANY Kanal Koordinaten bei (1, 2)")
    assert_equal(route.routeLists["1"][0][7][].name, "B", "Falscher Sink Block")

def test_Lee12():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))

    nets["1"] = List[Tuple[String, Int]]()
    nets["2"] = List[Tuple[String, Int]]()

    var clb = Block("A", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 1)
    nets["1"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("C", Blocktype.CLB, 4, 1)
    clb.coord = Tuple(1, 2)   
    nets["2"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 1))
    nets["2"].append(Tuple(clb.name, 1))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("D", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 1)
    nets["1"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.run()


    var outpads = Set[String]()
    outpads.add("B")

    assert_false(route.isValid, "Lee ist nicht valide")

def test_Lee13():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))
    var clb = Block("A", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 2)
    nets["1"] = List[Tuple[String, Int]]()
    nets["1"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 1)
    nets["1"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.run()

    var outpads = Set[String]()
    outpads.add("B")

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads), 4, "Lee Kritischerpfad ist nicht 4")

def test_Lee14():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))
    var clb = Block("A", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 2)
    nets["1"] = List[Tuple[String, Int]]()
    nets["1"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 2)
    nets["1"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.run()

    var outpads = Set[String]()
    outpads.add("B")

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads), 4, "Lee Kritischerpfad ist nicht 4")

def test_Lee15():
    alias id = 0
    var chanWidth = 2
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
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
    route.run()


    var outpads = Set[String]()
    outpads.add("B")

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(len(route.routeLists["1"]), 1, "Zwei Tracks für Netz 1")
    assert_equal(len(route.routeLists["1"][0]), 6, "Route Liste für Netz 1 ist nicht 6 lang")
    assert_equal(route.getCriticalPath(outpads), 7, "Lee Kritischerpfad ist nicht 7")
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
    assert_equal(route.routeLists["1"][0][4][].coord[1], 2, "Falsche CHANX Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][5][].name, "B", "Falscher Sink Block")

def test_Lee16():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](7, 6, List[Block.SharedBlock]())
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
    clb.coord = Tuple(4, 3)
    nets["1"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.chanMap[0][3, 4] = route.BLOCKED
    route.chanMap[0][4, 1] = route.BLOCKED
    route.run()


    var outpads = Set[String]()
    outpads.add("B")

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(len(route.routeLists["1"][0]), 8, "Route Liste für Netz 1 ist nicht 6 lang")
    assert_equal(route.getCriticalPath(outpads), 9, "Lee Kritischerpfad ist nicht 9")
    assert_equal(route.chanMap[0][1, 0], id, "kein Kanal bei (1, 0)")
    assert_equal(route.chanMap[0][3, 0], id, "kein Kanal bei (3, 0)")
    assert_equal(route.chanMap[0][5, 0], id, "kein Kanal bei (5, 0)")
    assert_equal(route.chanMap[0][6, 1], id, "kein Kanal bei (6, 1)")
    assert_equal(route.chanMap[0][6, 3], id, "kein Kanal bei (6, 3)")
    assert_equal(route.chanMap[0][7, 4], id, "kein Kanal bei (7, 4)")
    assert_equal(route.routeLists["1"][0][0][].name, "A", "Falscher Source Block")
    assert_equal(route.routeLists["1"][0][1][].type, Blocktype.CHANX, "Kein CHANX Kanal bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1][].coord[0], 1, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1][].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][2][].type, Blocktype.CHANX, "Kein CHANX Kanal bei (2, 0)")
    assert_equal(route.routeLists["1"][0][2][].coord[0], 2, "Falsche CHANX Kanal Koordinaten bei (2, 0)")
    assert_equal(route.routeLists["1"][0][2][].coord[1], 0, "Falsche CHANx Kanal Koordinaten bei (2, 0)")
    assert_equal(route.routeLists["1"][0][3][].type, Blocktype.CHANX, "Kein CHANX Kanal bei (3, 0)")
    assert_equal(route.routeLists["1"][0][3][].coord[0], 3, "Falsche CHANX Kanal Koordinaten bei (3, 0)")
    assert_equal(route.routeLists["1"][0][3][].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (3, 0)")
    assert_equal(route.routeLists["1"][0][4][].type, Blocktype.CHANY, "Kein CHANY Kanal bei (3, 1)")
    assert_equal(route.routeLists["1"][0][4][].coord[0], 3, "Falsche CHANY Kanal Koordinaten bei (3, 1)")
    assert_equal(route.routeLists["1"][0][4][].coord[1], 1, "Falsche CHANY Kanal Koordinaten bei (3, 1)")
    assert_equal(route.routeLists["1"][0][5][].type, Blocktype.CHANY, "Kein CHANY Kanal bei (3, 2)")
    assert_equal(route.routeLists["1"][0][5][].coord[0], 3, "Falsche CHANY Kanal Koordinaten bei (3, 2)")
    assert_equal(route.routeLists["1"][0][5][].coord[1], 2, "Falsche CHANY Kanal Koordinaten bei (3, 2)")
    assert_equal(route.routeLists["1"][0][6][].type, Blocktype.CHANX, "Kein CHANX Kanal bei (4, 2)")
    assert_equal(route.routeLists["1"][0][6][].coord[0], 4, "Falsche CHANX Kanal Koordinaten bei (4, 2)")
    assert_equal(route.routeLists["1"][0][6][].coord[1], 2, "Falsche CHANX Kanal Koordinaten bei (4, 2)")
    assert_equal(route.routeLists["1"][0][7][].name, "B", "Falscher Sink Block")

def test_Lee17():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](102, 3, List[Block.SharedBlock]())
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
    clb.coord = Tuple(100, 1)
    nets["1"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.chanMap[0][3, 4] = route.BLOCKED
    route.chanMap[0][4, 1] = route.BLOCKED
    route.run()


    var outpads = Set[String]()
    outpads.add("B")

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads), 103, "Lee Kritischerpfad ist nicht 103")

def test_Lee18():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](102, 102, List[Block.SharedBlock]())
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
    clb.coord = Tuple(100, 100)
    nets["1"].append(Tuple(clb.name, 3))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.chanMap[0][3, 4] = route.BLOCKED
    route.chanMap[0][4, 1] = route.BLOCKED
    route.run()


    var outpads = Set[String]()
    outpads.add("B")

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads), 203, "Lee Kritischerpfad ist nicht 203")

def test_Lee19():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](1002, 5, List[Block.SharedBlock]())
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
    clb.coord = Tuple(1000, 1)
    nets["1"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.chanMap[0][3, 4] = route.BLOCKED
    route.chanMap[0][4, 1] = route.BLOCKED
    route.run()


    var outpads = Set[String]()
    outpads.add("B")

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads), 1003, "Lee Kritischerpfad ist nicht 1003")

def test_Lee20():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](1000002, 5, List[Block.SharedBlock]())
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
    clb.coord = Tuple(1000000, 1)
    nets["1"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins)
    route.chanMap[0][3, 4] = route.BLOCKED
    route.chanMap[0][4, 1] = route.BLOCKED
    route.run()


    var outpads = Set[String]()
    outpads.add("B")

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads), 1000003, "Lee Kritischerpfad ist nicht 1000003")