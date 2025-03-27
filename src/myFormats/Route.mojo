from collections import Dict, List
from myUtil.Block import Block
from myUtil.Enum import *
from myUtil.Matrix import Matrix
from myFormats.Arch import *
"""
@file Route.mojo

Parser für das Route File Format vom VPR Tool
"""

# Schreibt die Route in eine Datei
fn writeRouteFile(fileName: String, routeLists: Dict[String, Dict[Int, List[Block.SharedBlock]]], netKeys: List[String], pins: List[Pin], clbMap: Matrix[List[Block.SharedBlock]], clbNums: Dict[String, Int]) -> Bool:
    pass
    return True