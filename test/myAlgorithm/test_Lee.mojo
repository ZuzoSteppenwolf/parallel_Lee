from testing import assert_equal, assert_true, assert_false, assert_almost_equal
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

alias LOG_DIRECTORY = "test/log/"

def test_Lee1():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()


    var outpads = Set[String]()
    outpads.add("B")

    var T_seq_in: Float64 = 1000
    var T_seq_out: Float64 = 100

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(len(route.routeLists["1"][0]), 6, "Route Liste für Netz 1 ist nicht 6 lang")
    assert_equal(route.getCriticalPath(outpads, T_seq_in, T_seq_out), 6, "Lee Kritischerpfad ist nicht 6")
    assert_equal(route.chanMap[0][1, 0], id, "kein Kanal bei (1, 0)")
    assert_equal(route.chanMap[0][2, 1], id, "kein Kanal bei (2, 1)")
    assert_equal(route.chanMap[0][2, 3], id, "kein Kanal bei (2, 3)")
    assert_equal(route.chanMap[0][3, 4], id, "kein Kanal bei (3, 4)")
    assert_equal(route.routeLists["1"][0][0].block[].name, "A", "Falscher Source Block")
    assert_equal(route.routeLists["1"][0][1].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1].block[].coord[0], 1, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1].block[].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][2].block[].type, Blocktype.CHANY, "Kein CHANY Kanal bei (1, 1)")
    assert_equal(route.routeLists["1"][0][2].block[].coord[0], 1, "Falsche CHANY Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["1"][0][2].block[].coord[1], 1, "Falsche CHANY Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["1"][0][3].block[].type, Blocktype.CHANY, "Kein CHANY Kanal bei (1, 2)")
    assert_equal(route.routeLists["1"][0][3].block[].coord[0], 1, "Falsche CHANY Kanal Koordinaten bei (1, 2)")
    assert_equal(route.routeLists["1"][0][3].block[].coord[1], 2, "Falsche CHANY Kanal Koordinaten bei (1, 2)")
    assert_equal(route.routeLists["1"][0][4].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (2, 2)")
    assert_equal(route.routeLists["1"][0][4].block[].coord[0], 2, "Falsche CHANX Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][4].block[].coord[1], 2, "Falsche CHANX Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][5].block[].name, "B", "Falscher Sink Block")

def test_Lee2():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("C", Blocktype.CLB, 4, 1)
    clb.coord = Tuple(1, 2)   
    nets["2"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 2))
    nets["2"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 2

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 0.1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()

    var outpads = Set[String]()
    outpads.add("B")

    var T_seq_in: Float64 = 1000
    var T_seq_out: Float64 = 100

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads, T_seq_in, T_seq_out), 5.2, "Lee Kritischerpfad ist nicht 5,2")
    assert_equal(len(route.routeLists["1"][0]), 6, "Route Liste für Netz 1 ist nicht 6 lang")
    assert_equal(route.routeLists["1"][0][0].block[].name, "A", "Falscher Source Block")
    assert_equal(route.routeLists["1"][0][1].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1].block[].coord[0], 1, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1].block[].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][2].block[].type, Blocktype.CHANY, "Kein CHANY Kanal bei (1, 1)")
    assert_equal(route.routeLists["1"][0][2].block[].coord[0], 1, "Falsche CHANY Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["1"][0][2].block[].coord[1], 1, "Falsche CHANY Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["1"][0][3].block[].type, Blocktype.CHANY, "Kein CHANY Kanal bei (1, 2)")
    assert_equal(route.routeLists["1"][0][3].block[].coord[0], 1, "Falsche CHANY Kanal Koordinaten bei (1, 2)")
    assert_equal(route.routeLists["1"][0][3].block[].coord[1], 2, "Falsche CHANY Kanal Koordinaten bei (1, 2)")
    assert_equal(route.routeLists["1"][0][4].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (2, 2)")
    assert_equal(route.routeLists["1"][0][4].block[].coord[0], 2, "Falsche CHANX Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][4].block[].coord[1], 2, "Falsche CHANX Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][5].block[].name, "B", "Falscher Sink Block")

    assert_equal(route.routeLists["2"][0][0].block[].name, "C", "Falscher Source Block")
    assert_equal(route.routeLists["2"][0][1].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (1, 1)")
    assert_equal(route.routeLists["2"][0][1].block[].coord[0], 1, "Falsche CHANX Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["2"][0][1].block[].coord[1], 1, "Falsche CHANX Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["2"][0][2].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (2, 1)")
    assert_equal(route.routeLists["2"][0][2].block[].coord[0], 2, "Falsche CHANX Kanal Koordinaten bei (2, 1)")
    assert_equal(route.routeLists["2"][0][2].block[].coord[1], 1, "Falsche CHANX Kanal Koordinaten bei (2, 1)")
    assert_equal(route.routeLists["2"][0][3].block[].name, "B", "Falscher Sink Block")

def test_Lee3():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](42, 42, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 40)
    nets["1"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()

    assert_true(route.isValid, "Lee ist nicht valide")

def test_Lee4():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](42, 42, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("C", Blocktype.CLB, 4, 1)
    clb.coord = Tuple(1, 20)   
    nets["2"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(10, 40)
    nets["1"].append(Tuple(clb.name, 2))
    nets["2"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 2

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()

    assert_true(route.isValid, "Lee ist nicht valide")

def test_Lee5():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](42, 42, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("C", Blocktype.CLB, 4, 1)
    clb.coord = Tuple(1, 20)   
    nets["2"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(10, 40)
    nets["1"].append(Tuple(clb.name, 2))
    nets["2"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 2

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run(False)

    assert_true(route.isValid, "Lee ist nicht valide")

def test_Lee6():
    alias id = 0
    var chanWidth = 2
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](42, 42, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("C", Blocktype.CLB, 4, 1)
    clb.coord = Tuple(1, 20)   
    nets["2"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(10, 40)
    nets["1"].append(Tuple(clb.name, 2))
    nets["2"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 2

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()

    assert_true(route.isValid, "Lee ist nicht valide")

def test_Lee7():
    alias id = 0
    var chanWidth = 2
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("C", Blocktype.CLB, 4, 1)
    clb.coord = Tuple(1, 2)   
    nets["2"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    clb = Block("D", Blocktype.CLB, 4, 1)
    clb.coord = Tuple(2, 1)   
    nets["3"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 2

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 2))
    nets["2"].append(Tuple(clb.name, 0))
    nets["3"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 3

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()

    assert_true(route.isValid, "Lee ist nicht valide")

def test_Lee8():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    clb = Block("C", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 2)
    nets["1"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 2

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()

    assert_true(route.isValid, "Lee ist nicht valide")

def test_Lee9():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    clb = Block("C", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 2)
    nets["1"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 2

    clb = Block("D", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 1)
    nets["1"].append(Tuple(clb.name, 3))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 3

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
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
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    clb = Block("D", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 1)
    nets["1"].append(Tuple(clb.name, 3))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 2

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.chanMap[0][1, 0], id, "kein Kanal bei (1, 0)")
    assert_equal(route.chanMap[0][3, 0], id, "kein Kanal bei (3, 0)")
    assert_equal(route.chanMap[0][4, 1], id, "kein Kanal bei (4, 1)")
    assert_equal(route.chanMap[0][4, 3], id, "kein Kanal bei (4, 3)")
    assert_equal(route.chanMap[0][3, 4], id, "kein Kanal bei (3, 4)")
    assert_equal(route.routeLists["1"][0][0].block[].name, "A", "Falscher Source Block")
    assert_equal(route.routeLists["1"][0][1].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1].block[].coord[0], 1, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1].block[].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][2].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (2, 0)")
    assert_equal(route.routeLists["1"][0][2].block[].coord[0], 2, "Falsche CHANX Kanal Koordinaten bei (2, 0)")
    assert_equal(route.routeLists["1"][0][2].block[].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (2, 0)")
    assert_equal(route.routeLists["1"][0][3].block[].type, Blocktype.CHANY, "Kein CHANY Kanal bei (2, 1)")
    assert_equal(route.routeLists["1"][0][3].block[].coord[0], 2, "Falsche CHANY Kanal Koordinaten bei (2, 1)")
    assert_equal(route.routeLists["1"][0][3].block[].coord[1], 1, "Falsche CHANY Kanal Koordinaten bei (2, 1)")
    assert_equal(route.routeLists["1"][0][4].block[].name, "D", "Falscher Sink Block")
    assert_equal(route.routeLists["1"][0][5].block[].type, Blocktype.CHANY, "Kein CHANY Kanal bei (2, 1)")
    assert_equal(route.routeLists["1"][0][5].block[].coord[0], 2, "Falsche CHANY Kanal Koordinaten bei (2, 1)")
    assert_equal(route.routeLists["1"][0][5].block[].coord[1], 1, "Falsche CHANY Kanal Koordinaten bei (2, 1)")
    assert_equal(route.routeLists["1"][0][6].block[].type, Blocktype.CHANY, "Kein CHANY Kanal bei (2, 2)")
    assert_equal(route.routeLists["1"][0][6].block[].coord[0], 2, "Falsche CHANY Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][6].block[].coord[1], 2, "Falsche CHANY Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][7].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (2, 2)")
    assert_equal(route.routeLists["1"][0][7].block[].coord[0], 2, "Falsche CHANX Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][7].block[].coord[1], 2, "Falsche CHANX Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][8].block[].name, "B", "Falscher Sink Block")

def test_Lee11():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 1))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    clb = Block("D", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 1)
    nets["1"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 2

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.routeLists["1"][0][0].block[].name, "A", "Falscher Source Block")
    assert_equal(route.routeLists["1"][0][1].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1].block[].coord[0], 1, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1].block[].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][2].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (2, 0)")
    assert_equal(route.routeLists["1"][0][2].block[].coord[0], 2, "Falsche CHANX Kanal Koordinaten bei (2, 0)")
    assert_equal(route.routeLists["1"][0][2].block[].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (2, 0)")
    assert_equal(route.routeLists["1"][0][3].block[].name, "D", "Falscher Sink Block")
    assert_equal(route.routeLists["1"][0][4].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (1, 0)")
    assert_equal(route.routeLists["1"][0][4].block[].coord[0], 1, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][4].block[].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][5].block[].type, Blocktype.CHANY, "Kein CHANY Kanal bei (1, 1)")
    assert_equal(route.routeLists["1"][0][5].block[].coord[0], 1, "Falsche CHANY Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["1"][0][5].block[].coord[1], 1, "Falsche CHANY Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["1"][0][6].block[].type, Blocktype.CHANY, "Kein CHANY Kanal bei (1, 2)")
    assert_equal(route.routeLists["1"][0][6].block[].coord[0], 1, "Falsche CHANY Kanal Koordinaten bei (1, 2)")
    assert_equal(route.routeLists["1"][0][6].block[].coord[1], 2, "Falsche CHANY Kanal Koordinaten bei (1, 2)")
    assert_equal(route.routeLists["1"][0][7].block[].name, "B", "Falscher Sink Block")

def test_Lee12():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("C", Blocktype.CLB, 4, 1)
    clb.coord = Tuple(1, 2)   
    nets["2"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 1))
    nets["2"].append(Tuple(clb.name, 1))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 2

    clb = Block("D", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 1)
    nets["1"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 3

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
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
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 1)
    nets["1"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()

    var outpads = Set[String]()
    outpads.add("B")

    var T_seq_in: Float64 = 1000
    var T_seq_out: Float64 = 100

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads, T_seq_in, T_seq_out), 3, "Lee Kritischerpfad ist nicht 3")

def test_Lee14():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 2)
    nets["1"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()

    var outpads = Set[String]()
    outpads.add("B")

    var T_seq_in: Float64 = 1000
    var T_seq_out: Float64 = 100

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads, T_seq_in, T_seq_out), 3, "Lee Kritischerpfad ist nicht 3")

def test_Lee15():
    alias id = 0
    var chanWidth = 2
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()


    var outpads = Set[String]()
    outpads.add("B")

    var T_seq_in: Float64 = 1000
    var T_seq_out: Float64 = 100

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(len(route.routeLists["1"]), 1, "Zwei Tracks für Netz 1")
    assert_equal(len(route.routeLists["1"][0]), 6, "Route Liste für Netz 1 ist nicht 6 lang")
    assert_equal(route.getCriticalPath(outpads, T_seq_in, T_seq_out), 6, "Lee Kritischerpfad ist nicht 6")
    assert_equal(route.chanMap[0][1, 0], id, "kein Kanal bei (1, 0)")
    assert_equal(route.chanMap[0][2, 1], id, "kein Kanal bei (2, 1)")
    assert_equal(route.chanMap[0][2, 3], id, "kein Kanal bei (2, 3)")
    assert_equal(route.chanMap[0][3, 4], id, "kein Kanal bei (3, 4)")
    assert_equal(route.routeLists["1"][0][0].block[].name, "A", "Falscher Source Block")
    assert_equal(route.routeLists["1"][0][1].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1].block[].coord[0], 1, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1].block[].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][2].block[].type, Blocktype.CHANY, "Kein CHANY Kanal bei (1, 1)")
    assert_equal(route.routeLists["1"][0][2].block[].coord[0], 1, "Falsche CHANY Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["1"][0][2].block[].coord[1], 1, "Falsche CHANY Kanal Koordinaten bei (1, 1)")
    assert_equal(route.routeLists["1"][0][3].block[].type, Blocktype.CHANY, "Kein CHANY Kanal bei (1, 2)")
    assert_equal(route.routeLists["1"][0][3].block[].coord[0], 1, "Falsche CHANY Kanal Koordinaten bei (1, 2)")
    assert_equal(route.routeLists["1"][0][3].block[].coord[1], 2, "Falsche CHANY Kanal Koordinaten bei (1, 2)")
    assert_equal(route.routeLists["1"][0][4].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (2, 2)")
    assert_equal(route.routeLists["1"][0][4].block[].coord[0], 2, "Falsche CHANX Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][4].block[].coord[1], 2, "Falsche CHANX Kanal Koordinaten bei (2, 2)")
    assert_equal(route.routeLists["1"][0][5].block[].name, "B", "Falscher Sink Block")

def test_Lee16():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](7, 6, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(4, 3)
    nets["1"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.chanMap[0][3, 4] = route.BLOCKED
    route.chanMap[0][4, 1] = route.BLOCKED
    route.run()


    var outpads = Set[String]()
    outpads.add("B")

    var T_seq_in: Float64 = 1000
    var T_seq_out: Float64 = 100

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(len(route.routeLists["1"][0]), 8, "Route Liste für Netz 1 ist nicht 8 lang")
    assert_equal(route.getCriticalPath(outpads, T_seq_in, T_seq_out), 8, "Lee Kritischerpfad ist nicht 8")
    assert_equal(route.chanMap[0][1, 0], id, "kein Kanal bei (1, 0)")
    assert_equal(route.chanMap[0][3, 0], id, "kein Kanal bei (3, 0)")
    assert_equal(route.chanMap[0][5, 0], id, "kein Kanal bei (5, 0)")
    assert_equal(route.chanMap[0][6, 1], id, "kein Kanal bei (6, 1)")
    assert_equal(route.chanMap[0][6, 3], id, "kein Kanal bei (6, 3)")
    assert_equal(route.chanMap[0][7, 4], id, "kein Kanal bei (7, 4)")
    assert_equal(route.routeLists["1"][0][0].block[].name, "A", "Falscher Source Block")
    assert_equal(route.routeLists["1"][0][1].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1].block[].coord[0], 1, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][1].block[].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (1, 0)")
    assert_equal(route.routeLists["1"][0][2].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (2, 0)")
    assert_equal(route.routeLists["1"][0][2].block[].coord[0], 2, "Falsche CHANX Kanal Koordinaten bei (2, 0)")
    assert_equal(route.routeLists["1"][0][2].block[].coord[1], 0, "Falsche CHANx Kanal Koordinaten bei (2, 0)")
    assert_equal(route.routeLists["1"][0][3].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (3, 0)")
    assert_equal(route.routeLists["1"][0][3].block[].coord[0], 3, "Falsche CHANX Kanal Koordinaten bei (3, 0)")
    assert_equal(route.routeLists["1"][0][3].block[].coord[1], 0, "Falsche CHANX Kanal Koordinaten bei (3, 0)")
    assert_equal(route.routeLists["1"][0][4].block[].type, Blocktype.CHANY, "Kein CHANY Kanal bei (3, 1)")
    assert_equal(route.routeLists["1"][0][4].block[].coord[0], 3, "Falsche CHANY Kanal Koordinaten bei (3, 1)")
    assert_equal(route.routeLists["1"][0][4].block[].coord[1], 1, "Falsche CHANY Kanal Koordinaten bei (3, 1)")
    assert_equal(route.routeLists["1"][0][5].block[].type, Blocktype.CHANY, "Kein CHANY Kanal bei (3, 2)")
    assert_equal(route.routeLists["1"][0][5].block[].coord[0], 3, "Falsche CHANY Kanal Koordinaten bei (3, 2)")
    assert_equal(route.routeLists["1"][0][5].block[].coord[1], 2, "Falsche CHANY Kanal Koordinaten bei (3, 2)")
    assert_equal(route.routeLists["1"][0][6].block[].type, Blocktype.CHANX, "Kein CHANX Kanal bei (4, 2)")
    assert_equal(route.routeLists["1"][0][6].block[].coord[0], 4, "Falsche CHANX Kanal Koordinaten bei (4, 2)")
    assert_equal(route.routeLists["1"][0][6].block[].coord[1], 2, "Falsche CHANX Kanal Koordinaten bei (4, 2)")
    assert_equal(route.routeLists["1"][0][7].block[].name, "B", "Falscher Sink Block")

def test_Lee17():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](102, 3, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(100, 1)
    nets["1"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.chanMap[0][3, 4] = route.BLOCKED
    route.chanMap[0][4, 1] = route.BLOCKED
    route.run()


    var outpads = Set[String]()
    outpads.add("B")

    var T_seq_in: Float64 = 1000
    var T_seq_out: Float64 = 100

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads, T_seq_in, T_seq_out), 102, "Lee Kritischerpfad ist nicht 102")

def test_Lee18():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](102, 102, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(100, 100)
    nets["1"].append(Tuple(clb.name, 3))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.chanMap[0][3, 4] = route.BLOCKED
    route.chanMap[0][4, 1] = route.BLOCKED
    route.run()


    var outpads = Set[String]()
    outpads.add("B")

    var T_seq_in: Float64 = 1000
    var T_seq_out: Float64 = 100

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads, T_seq_in, T_seq_out), 202, "Lee Kritischerpfad ist nicht 202")

def test_Lee19():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](1002, 5, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1000, 1)
    nets["1"].append(Tuple(clb.name, 0))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.chanMap[0][3, 4] = route.BLOCKED
    route.chanMap[0][4, 1] = route.BLOCKED
    route.run()


    var outpads = Set[String]()
    outpads.add("B")

    var T_seq_in: Float64 = 100000
    var T_seq_out: Float64 = 10000

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads, T_seq_in, T_seq_out), 1002, "Lee Kritischerpfad ist nicht 1002")

def test_Lee20():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](1002, 5, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("B", Blocktype.OUTPAD, 1, 1)
    clb.coord = Tuple(1000, 0)
    nets["1"].append(Tuple(clb.name, -1))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.chanMap[0][3, 4] = route.BLOCKED
    route.chanMap[0][4, 1] = route.BLOCKED
    route.run()


    var outpads = Set[String]()
    outpads.add("B")

    var T_seq_in: Float64 = 100000
    var T_seq_out: Float64 = 10000

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads, T_seq_in, T_seq_out), 1002, "Lee Kritischerpfad ist nicht 1002")

def test_Lee21():
    alias id = 0
    var chanWidth = 2
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("C", Blocktype.CLB, 4, 1)
    clb.coord = Tuple(1, 2)   
    nets["2"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 2))
    nets["2"].append(Tuple(clb.name, 0))
    nets["3"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 2

    clb = Block("D", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 1)
    nets["3"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 3

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 0.1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()

    var outpads = Set[String]()
    outpads.add("D")

    var T_seq_in: Float64 = 1000
    var T_seq_out: Float64 = 100

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads, T_seq_in, T_seq_out), 6.3, "Lee Kritischerpfad ist nicht 6,3")

def test_Lee22():
    alias id = 0
    var chanWidth = 2
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    CLB2Num[clb.name] = 0

    clb = Block("C", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 2)   
    nets["2"].append(Tuple(clb.name, 4))
    nets["1"].append(Tuple(clb.name, 1))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 2))
    nets["2"].append(Tuple(clb.name, 0))
    nets["3"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 2

    clb = Block("D", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 1)
    nets["3"].append(Tuple(clb.name, 2))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 3

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 0.1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()

    var outpads = Set[String]()
    outpads.add("D")

    var T_seq_in: Float64 = 1000
    var T_seq_out: Float64 = 100

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads, T_seq_in, T_seq_out), 4.6, "Lee Kritischerpfad ist nicht 4,6")

def test_Lee23():
    alias id = 0
    var chanWidth = 1
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
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
    nets["1"].append(Tuple(clb.name, 1))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 0

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 0.1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(len(route.routeLists["1"][0]), 4, "Route Liste für Netz 1 ist nicht 4 lang")

def test_Lee24():
    alias id = 0
    var chanWidth = 2
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))

    nets["1"] = List[Tuple[String, Int]]()
    nets["2"] = List[Tuple[String, Int]]()
    nets["3"] = List[Tuple[String, Int]]()

    var clb = Block("A", Blocktype.INPAD, 1, 1)
    clb.coord = Tuple(0, 1)
    nets["1"].append(Tuple(clb.name, -1))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 0

    clb = Block("C", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(1, 2)  
    clb.hasGlobal = True 
    nets["2"].append(Tuple(clb.name, 4))
    nets["1"].append(Tuple(clb.name, 1))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    clb = Block("B", Blocktype.CLB, 1, 1)
    clb.coord = Tuple(2, 2)
    clb.hasGlobal = True
    nets["1"].append(Tuple(clb.name, 2))
    nets["2"].append(Tuple(clb.name, 0))
    nets["3"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 2

    clb = Block("D", Blocktype.OUTPAD, 1, 1)
    clb.coord = Tuple(3, 1)
    nets["3"].append(Tuple(clb.name, -1))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 3

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 0.1, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()

    var outpads = Set[String]()
    outpads.add("D")

    var T_seq_in: Float64 = 1000
    var T_seq_out: Float64 = 100

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_almost_equal(route.getCriticalPath(outpads, T_seq_in, T_seq_out), 1104.6, "Lee Kritischerpfad ist nicht 1104,6", atol=0.01)

def test_Lee25():
    alias id = 0
    var chanWidth = 2
    var nets = Dict[String, List[Tuple[String, Int]]]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](4, 4, List[Block.SharedBlock]())
    var archiv = Dict[String, Tuple[Int, Int]]()
    var pins = List[Pin]()
    var CLB2Num = Dict[String, Int]()
    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))

    nets["in"] = List[Tuple[String, Int]]()
    nets["1"] = List[Tuple[String, Int]]()
    nets["2"] = List[Tuple[String, Int]]()
    nets["3"] = List[Tuple[String, Int]]()
    nets["out"] = List[Tuple[String, Int]]()

    var clb = Block("in", Blocktype.INPAD, 1, 1)
    clb.coord = Tuple(0, 1)
    nets["in"].append(Tuple(clb.name, -1))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 0

    clb = Block("A", Blocktype.CLB, 10, 1)
    clb.coord = Tuple(1, 1)
    nets["1"].append(Tuple(clb.name, 4))
    nets["in"].append(Tuple(clb.name, 1))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 1

    clb = Block("C", Blocktype.CLB, 10, 1)
    clb.coord = Tuple(1, 2)   
    nets["2"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 2

    clb = Block("B", Blocktype.CLB, 10, 1)
    clb.coord = Tuple(2, 2)
    nets["1"].append(Tuple(clb.name, 2))
    nets["2"].append(Tuple(clb.name, 0))
    nets["3"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 3

    clb = Block("D", Blocktype.CLB, 11, 1)
    clb.coord = Tuple(2, 1)
    nets["3"].append(Tuple(clb.name, 2))
    nets["out"].append(Tuple(clb.name, 4))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 4

    nets["out"].append(Tuple("C", 3))

    clb = Block("out", Blocktype.OUTPAD, 0, 1)
    clb.coord = Tuple(3, 1)
    nets["out"].append(Tuple(clb.name, -1))
    archiv[clb.name] = clb.coord
    clbMap[clb.coord[0], clb.coord[1]].append(Block.SharedBlock(clb))
    CLB2Num[clb.name] = 5

    var lastClb = clbMap[clb.coord[0], clb.coord[1]]

    var route = Lee(nets, clbMap, archiv, chanWidth, 0, pins, CLB2Num, logDir=LOG_DIRECTORY)
    route.run()

    var outpads = Set[String]()
    outpads.add("out")

    var T_seq_in: Float64 = 1000
    var T_seq_out: Float64 = 100

    assert_true(route.isValid, "Lee ist nicht valide")
    assert_equal(route.getCriticalPath(outpads, T_seq_in, T_seq_out), 32, "Lee Kritischerpfad ist nicht 6,3")