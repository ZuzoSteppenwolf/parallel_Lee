from myUtil.Block import Block
from myUtil.Enum import Blocktype
from testing import assert_equal
from collections import List
from memory import ArcPointer

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
    #assert_equal(block.preconnections, List[ArcPointer[Block]]())
    
    return