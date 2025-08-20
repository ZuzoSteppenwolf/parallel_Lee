from myUtil.Block import Block, BlockPair
from myUtil.Enum import Blocktype
from testing import assert_equal, assert_true, assert_false
from collections import List, Set

"""
Testet die Block Klasse

@author Marvin Wollbrück
"""

def test_Block_1():
    
    var block = Block("test")
    assert_equal(block.name, "test")
    assert_equal(block.subblk, 0)
    assert_true(block.type == Blocktype.NONE)
    assert_equal(block.delay, 0.0)
    assert_equal(len(block.preconnections), 0)

    return

def test_Block_2():
    
    var start = Block.SharedBlock(Block("start"))
    var middle = Block.SharedBlock(Block("middle"))
    var end = Block.SharedBlock(Block("end"))

    end[].preconnections.append(middle)
    middle[].preconnections.append(start)
    
    start[].delay = 1.0
    middle[].delay = 1.0
    end[].delay = 1.0

    assert_equal(len(end[].preconnections), 1)
    assert_equal(len(middle[].preconnections), 1)
    assert_equal(len(start[].preconnections), 0)

    return

def test_Block_3():
    
    var start = Block.SharedBlock(Block("start"))
    var middle1 = Block.SharedBlock(Block("middle1"))
    var middle2 = Block.SharedBlock(Block("middle2"))
    var end = Block.SharedBlock(Block("end"))

    end[].preconnections.append(middle1)
    end[].preconnections.append(middle2)
    middle1[].preconnections.append(start)
    middle2[].preconnections.append(start)
    
    start[].delay = 1.0
    middle1[].delay = 1.0
    middle2[].delay = 2.0
    end[].delay = 1.0

    assert_equal(len(end[].preconnections), 2)
    assert_equal(len(middle1[].preconnections), 1)
    assert_equal(len(middle2[].preconnections), 1)
    assert_equal(len(start[].preconnections), 0)

    return
    
def test_Block_4():
    var block = Block.SharedBlock(Block("block"))
    var bp = BlockPair(block, 1)
    var bp2 = BlockPair(block, 2)
    var bp3 = BlockPair(block, 1)

    var set = Set[BlockPair[Int]]()
    set.add(bp)

    assert_true(bp in set)
    assert_false(bp2 in set)
    assert_true(bp3 in set)