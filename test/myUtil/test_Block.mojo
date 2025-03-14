from myUtil.Block import Block
from myUtil.Enum import Blocktype
from testing import assert_equal
from collections import List

"""
Testet die Block Klasse

@author Marvin Wollbrück
"""

def test_Block_1():
    
    var block = Block("test")
    assert_equal(block.name, "test")
    assert_equal(block.subblk, 0)
    assert_equal(block.type, Blocktype.NONE)
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

    assert_equal(start[].getDelay()[0], 1.0)
    assert_equal(middle[].getDelay()[0], 2.0)
    assert_equal(end[].getDelay()[0], 3.0)

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

    assert_equal(start[].getDelay()[0], 1.0)
    assert_equal(middle1[].getDelay()[0], 2.0)
    assert_equal(middle2[].getDelay()[0], 3.0)
    assert_equal(end[].getDelay()[0], 3.0)
    assert_equal(end[].getDelay()[1], 4.0)

    return
    