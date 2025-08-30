from testing import assert_equal, assert_true, assert_false
from collections import Dict, List, Set
from myFormats.Route import writeRouteFile
from myUtil.Block import Block, BlockPair
from myFormats.Arch import *
from myUtil.Enum import *
from myUtil.Matrix import ListMatrix
"""
@author Marvin Wollbrück
"""

def test_Route_1():
    var path = "test/output/test_Route_1out.route"
    var routeLists = Dict[String, Dict[Int, List[BlockPair[Int]]]]()
    var netKeys = List[String]()
    var pins = List[Pin]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](42, 42, List[Block.SharedBlock]())
    var clbNums = Dict[String, Int]()
    var globalNets = Dict[String, List[Tuple[String, Int]]]()
    var archiv = Dict[String, Tuple[Int, Int]]()
    var net1 = "[7326]"

    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))
    netKeys.append(net1)

    var clb1 = Block.SharedBlock(Block("clb1", Blocktype.CLB, 1, 1))
    clb1[].coord = (33, 37)
    clbMap[clb1[].coord[0], clb1[].coord[1]].append(clb1)
    clbNums[clb1[].name] = 0
    var clb2 = Block.SharedBlock(Block("clb2", Blocktype.CLB, 1, 1))
    clb2[].coord = (33, 36)
    clbMap[clb2[].coord[0], clb2[].coord[1]].append(clb2)
    clbNums[clb2[].name] = 1

    archiv[clb1[].name] = clb1[].coord
    archiv[clb2[].name] = clb2[].coord

    routeLists[net1] = Dict[Int, List[BlockPair[Int]]]()
    routeLists[net1][8] = List[BlockPair[Int]]()
    routeLists[net1][8].append(BlockPair(clb1, 4))
    var chan = Block.SharedBlock(Block("chanx", Blocktype.CHANX, 1, 8))
    chan[].coord = (33, 36)
    chan[].preconnections.append(clb1)
    routeLists[net1][8].append(BlockPair(chan, -1))
    clb2[].preconnections.append(chan)
    routeLists[net1][8].append(BlockPair(clb2, 2))


    
    assert_true(writeRouteFile(path, routeLists, netKeys, pins, (clbMap.cols-2, clbMap.rows-2), clbNums, globalNets, archiv), "Writing gas failed")
    with open(path, "r") as out:
        with open("test/.route/test_Route_1.route", "r") as expected:
            assert_equal(out.read(), expected.read(), "Output does not match expected output")

def test_Route_2():
    var path = "test/output/test_Route_2out.route"
    var routeLists = Dict[String, Dict[Int, List[BlockPair[Int]]]]()
    var netKeys = List[String]()
    var pins = List[Pin]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](62, 62, List[Block.SharedBlock]())
    var clbNums = Dict[String, Int]()
    var globalNets = Dict[String, List[Tuple[String, Int]]]()
    var archiv = Dict[String, Tuple[Int, Int]]()
    var net1 = "[7326]"

    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))
    netKeys.append(net1)

    var clb1 = Block.SharedBlock(Block("clb1", Blocktype.CLB, 1, 1))
    clb1[].coord = (33, 37)
    clbMap[clb1[].coord[0], clb1[].coord[1]].append(clb1)
    clbNums[clb1[].name] = 0
    var clb2 = Block.SharedBlock(Block("clb2", Blocktype.CLB, 1, 1))
    clb2[].coord = (33, 36)
    clbMap[clb2[].coord[0], clb2[].coord[1]].append(clb2)
    clbNums[clb2[].name] = 1

    archiv[clb1[].name] = clb1[].coord
    archiv[clb2[].name] = clb2[].coord

    routeLists[net1] = Dict[Int, List[BlockPair[Int]]]()
    routeLists[net1][8] = List[BlockPair[Int]]()
    routeLists[net1][8].append(BlockPair(clb1, 4))
    var chan = Block.SharedBlock(Block("chanx", Blocktype.CHANX, 1, 8))
    chan[].coord = (33, 36)
    chan[].preconnections.append(clb1)
    routeLists[net1][8].append(BlockPair(chan, -1))
    clb2[].preconnections.append(chan)
    routeLists[net1][8].append(BlockPair(clb2, 2))

    var net2 = "pclk"
    netKeys.append(net2)
    globalNets[net2] = List[Tuple[String, Int]]()

    var clb = Block.SharedBlock(Block("pclk", Blocktype.INPAD, 1, 0))
    clb[].coord = (7, 61)
    clbMap[clb[].coord[0], clb[].coord[1]].append(clb)
    clbNums[clb[].name] = 8
    archiv[clb[].name] = clb[].coord
    globalNets[net2].append((clb[].name, -1))
    
    clb = Block.SharedBlock(Block("[16920]", Blocktype.CLB, 1, 1))
    clb[].coord = (53, 30)
    clbMap[clb[].coord[0], clb[].coord[1]].append(clb)
    clbNums[clb[].name] = 136
    archiv[clb[].name] = clb[].coord
    globalNets[net2].append((clb[].name, 5))

    clb = Block.SharedBlock(Block("[17024]", Blocktype.CLB, 1, 1))
    clb[].coord = (2, 49)
    clbMap[clb[].coord[0], clb[].coord[1]].append(clb)
    clbNums[clb[].name] = 137
    archiv[clb[].name] = clb[].coord
    globalNets[net2].append((clb[].name, 5))

    clb = Block.SharedBlock(Block("[17050]", Blocktype.CLB, 1, 1))
    clb[].coord = (16, 28)
    clbMap[clb[].coord[0], clb[].coord[1]].append(clb)
    clbNums[clb[].name] = 138
    archiv[clb[].name] = clb[].coord
    globalNets[net2].append((clb[].name, 5))

    
    assert_true(writeRouteFile(path, routeLists, netKeys, pins, (clbMap.cols-2, clbMap.rows-2), clbNums, globalNets, archiv), "Writing gas failed")
    with open(path, "r") as out:
        with open("test/.route/test_Route_2.route", "r") as expected:
            assert_equal(out.read(), expected.read(), "Output does not match expected output")

def test_Route_3():
    var path = "test/output/test_Route_3out.route"
    var routeLists = Dict[String, Dict[Int, List[BlockPair[Int]]]]()
    var netKeys = List[String]()
    var pins = List[Pin]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](62, 62, List[Block.SharedBlock]())
    var clbNums = Dict[String, Int]()
    var globalNets = Dict[String, List[Tuple[String, Int]]]()
    var archiv = Dict[String, Tuple[Int, Int]]()

    var net1 = "[7326]"
    var track = 8

    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))
    netKeys.append(net1)

    var clb1 = Block.SharedBlock(Block("clb1", Blocktype.CLB, 1, 1))
    clb1[].coord = (33, 37)
    clbMap[clb1[].coord[0], clb1[].coord[1]].append(clb1)
    clbNums[clb1[].name] = 0
    var clb2 = Block.SharedBlock(Block("clb2", Blocktype.CLB, 1, 1))
    clb2[].coord = (33, 36)
    clbMap[clb2[].coord[0], clb2[].coord[1]].append(clb2)
    clbNums[clb2[].name] = 1

    archiv[clb1[].name] = clb1[].coord
    archiv[clb2[].name] = clb2[].coord

    routeLists[net1] = Dict[Int, List[BlockPair[Int]]]()
    routeLists[net1][track] = List[BlockPair[Int]]()
    routeLists[net1][track].append(BlockPair(clb1, 4))
    var chan = Block.SharedBlock(Block("chanx", Blocktype.CHANX, 1, track))
    chan[].coord = (33, 36)
    chan[].preconnections.append(clb1)
    routeLists[net1][track].append(BlockPair(chan, -1))
    clb2[].preconnections.append(chan)
    routeLists[net1][track].append(BlockPair(clb2, 2))

    var net2 = "pclk"
    netKeys.append(net2)
    globalNets[net2] = List[Tuple[String, Int]]()

    var clb = Block.SharedBlock(Block("pclk", Blocktype.INPAD, 1, 0))
    clb[].coord = (7, 61)
    clbMap[clb[].coord[0], clb[].coord[1]].append(clb)
    clbNums[clb[].name] = 8
    archiv[clb[].name] = clb[].coord
    globalNets[net2].append((clb[].name, -1))
    
    clb = Block.SharedBlock(Block("[16920]", Blocktype.CLB, 1, 1))
    clb[].coord = (53, 30)
    clbMap[clb[].coord[0], clb[].coord[1]].append(clb)
    clbNums[clb[].name] = 136
    archiv[clb[].name] = clb[].coord
    globalNets[net2].append((clb[].name, 5))

    clb = Block.SharedBlock(Block("[17024]", Blocktype.CLB, 1, 1))
    clb[].coord = (2, 49)
    clbMap[clb[].coord[0], clb[].coord[1]].append(clb)
    clbNums[clb[].name] = 137
    archiv[clb[].name] = clb[].coord
    globalNets[net2].append((clb[].name, 5))

    clb = Block.SharedBlock(Block("[17050]", Blocktype.CLB, 1, 1))
    clb[].coord = (16, 28)
    clbMap[clb[].coord[0], clb[].coord[1]].append(clb)
    clbNums[clb[].name] = 138
    archiv[clb[].name] = clb[].coord
    globalNets[net2].append((clb[].name, 5))


    var net3 = "tin_pdata_8_8_"
    track = 11
    netKeys.append(net3)

    clb1 = Block.SharedBlock(Block("inpad1", Blocktype.INPAD, 1, 0))
    clb1[].coord = (61,31)
    clbMap[clb1[].coord[0], clb1[].coord[1]].append(clb1)
    clbNums[clb1[].name] = 6
    clb2 = Block.SharedBlock(Block("clb3", Blocktype.CLB, 1, 1))
    clb2[].coord = (58,31)
    clbMap[clb2[].coord[0], clb2[].coord[1]].append(clb2)
    clbNums[clb2[].name] = 7

    archiv[clb1[].name] = clb1[].coord
    archiv[clb2[].name] = clb2[].coord

    routeLists[net3] = Dict[Int, List[BlockPair[Int]]]()
    routeLists[net3][track] = List[BlockPair[Int]]()
    routeLists[net3][track].append(BlockPair(clb1, -1))
    chan = Block.SharedBlock(Block("chany(60,31)", Blocktype.CHANY, 1, track))
    chan[].coord = (60,31)
    chan[].preconnections.append(clb1)
    routeLists[net3][track].append(BlockPair(chan, -1))

    var chan2 = Block.SharedBlock(Block("chanx(60,31)", Blocktype.CHANX, 1, track))
    chan2[].coord = (60,31)
    chan2[].preconnections.append(chan)
    routeLists[net3][track].append(BlockPair(chan2, -1))

    chan = Block.SharedBlock(Block("chanx(59,31)", Blocktype.CHANX, 1, track))
    chan[].coord = (59,31)
    chan[].preconnections.append(chan2)
    routeLists[net3][track].append(BlockPair(chan, -1))

    chan2 = Block.SharedBlock(Block("chany(58,31)", Blocktype.CHANY, 1, track))
    chan2[].coord = (58,31)
    chan2[].preconnections.append(chan)
    routeLists[net3][track].append(BlockPair(chan2, -1))

    clb2[].preconnections.append(chan2)
    routeLists[net3][track].append(BlockPair(clb2, 3))

    assert_true(writeRouteFile(path, routeLists, netKeys, pins, (clbMap.cols-2, clbMap.rows-2), clbNums, globalNets, archiv), "Writing gas failed")
    with open(path, "r") as out:
        with open("test/.route/test_Route_3.route", "r") as expected:
            assert_equal(out.read(), expected.read(), "Output does not match expected output")

def test_Route_4():
    var path = "test/output/test_Route_4out.route"
    var routeLists = Dict[String, Dict[Int, List[BlockPair[Int]]]]()
    var netKeys = List[String]()
    var pins = List[Pin]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](42, 42, List[Block.SharedBlock]())
    var clbNums = Dict[String, Int]()
    var globalNets = Dict[String, List[Tuple[String, Int]]]()
    var archiv = Dict[String, Tuple[Int, Int]]()
    var net1 = "[7326]"
    var track = 8

    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))
    netKeys.append(net1)

    var clb1 = Block.SharedBlock(Block("clb1", Blocktype.CLB, 1, 1))
    clb1[].coord = (33, 37)
    clbMap[clb1[].coord[0], clb1[].coord[1]].append(clb1)
    clbNums[clb1[].name] = 0
    var clb2 = Block.SharedBlock(Block("clb2", Blocktype.CLB, 1, 1))
    clb2[].coord = (33, 36)
    clbMap[clb2[].coord[0], clb2[].coord[1]].append(clb2)
    clbNums[clb2[].name] = 1
    var clb3 = Block.SharedBlock(Block("clb3", Blocktype.CLB, 1, 1))
    clb3[].coord = (34, 36)
    clbNums[clb3[].name] = 1

    archiv[clb1[].name] = clb1[].coord
    archiv[clb2[].name] = clb2[].coord
    archiv[clb3[].name] = clb3[].coord

    routeLists[net1] = Dict[Int, List[BlockPair[Int]]]()
    routeLists[net1][track] = List[BlockPair[Int]]()
    routeLists[net1][track].append(BlockPair(clb1, 4))
    var chan = Block.SharedBlock(Block("chanx(33, 36)", Blocktype.CHANX, 1, track))
    chan[].coord = (33, 36)
    chan[].preconnections.append(clb1)
    routeLists[net1][track].append(BlockPair(chan, -1))
    clb2[].preconnections.append(chan)
    routeLists[net1][track].append(BlockPair(clb2, 2))
    routeLists[net1][track].append(BlockPair(chan, -1))

    var chan2 = Block.SharedBlock(Block("chanx(34, 36)", Blocktype.CHANX, 1, track))
    chan2[].coord = (34, 36)
    chan2[].preconnections.append(chan)
    routeLists[net1][track].append(BlockPair(chan2, -1))
    clb3[].preconnections.append(chan2)
    routeLists[net1][track].append(BlockPair(clb3, 2))

    assert_true(writeRouteFile(path, routeLists, netKeys, pins, (clbMap.cols-2, clbMap.rows-2), clbNums, globalNets, archiv), "Writing gas failed")
    with open(path, "r") as out:
        with open("test/.route/test_Route_4.route", "r") as expected:
            assert_equal(out.read(), expected.read(), "Output does not match expected output")

def test_Route_5():
    var path = "test/output/test_Route_5out.route"
    var routeLists = Dict[String, Dict[Int, List[BlockPair[Int]]]]()
    var netKeys = List[String]()
    var pins = List[Pin]()
    var clbMap = ListMatrix[List[Block.SharedBlock]](42, 42, List[Block.SharedBlock]())
    var clbNums = Dict[String, Int]()
    var globalNets = Dict[String, List[Tuple[String, Int]]]()
    var archiv = Dict[String, Tuple[Int, Int]]()
    var net1 = "[7326]"
    var track = 8

    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))
    netKeys.append(net1)

    var clb1 = Block.SharedBlock(Block("clb1", Blocktype.CLB, 1, 1))
    clb1[].coord = (33, 37)
    clbMap[clb1[].coord[0], clb1[].coord[1]].append(clb1)
    clbNums[clb1[].name] = 0
    var clb2 = Block.SharedBlock(Block("clb2", Blocktype.CLB, 1, 1))
    clb2[].coord = (33, 36)
    clbMap[clb2[].coord[0], clb2[].coord[1]].append(clb2)
    clbNums[clb2[].name] = 1
    var clb3 = Block.SharedBlock(Block("clb3", Blocktype.OUTPAD, 1, 0))
    clb3[].coord = (34, 36)
    clbMap[clb3[].coord[0], clb3[].coord[1]].append(clb3)
    clbNums[clb3[].name] = 1

    archiv[clb1[].name] = clb1[].coord
    archiv[clb2[].name] = clb2[].coord
    archiv[clb3[].name] = clb3[].coord

    routeLists[net1] = Dict[Int, List[BlockPair[Int]]]()
    routeLists[net1][track] = List[BlockPair[Int]]()
    routeLists[net1][track].append(BlockPair(clb1, 4))
    var chan = Block.SharedBlock(Block("chanx(33, 36)", Blocktype.CHANX, 1, track))
    chan[].coord = (33, 36)
    chan[].preconnections.append(clb1)
    routeLists[net1][track].append(BlockPair(chan, -1))
    clb2[].preconnections.append(chan)
    routeLists[net1][track].append(BlockPair(clb2, 2))

    track = 9
    routeLists[net1][track] = List[BlockPair[Int]]()
    routeLists[net1][track].append(BlockPair(clb1, 4))

    chan = Block.SharedBlock(Block("chanx(33, 36)", Blocktype.CHANX, 1, track))
    chan[].coord = (33, 36)
    chan[].preconnections.append(clb1)
    routeLists[net1][track].append(BlockPair(chan, -1))

    var chan2 = Block.SharedBlock(Block("chanx(34, 36)", Blocktype.CHANX, 1, track))
    chan2[].coord = (34, 36)
    chan2[].preconnections.append(chan)
    routeLists[net1][track].append(BlockPair(chan2, -1))
    clb3[].preconnections.append(chan2)
    routeLists[net1][track].append(BlockPair(clb3, 2))


    assert_true(writeRouteFile(path, routeLists, netKeys, pins, (clbMap.cols-2, clbMap.rows-2), clbNums, globalNets, archiv), "Writing gas failed")
    with open(path, "r") as out:
        with open("test/.route/test_Route_5.route", "r") as expected:
            assert_equal(out.read(), expected.read(), "Output does not match expected output")
