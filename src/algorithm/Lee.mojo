from myFormats.Place import *
from myUtil.Matrix import *
from myUtil.Enum import *
from myUtil.Util import *
from collections import Dict, List

"""
@file Lee.mojo
Erzeugt eine Verdrahtungsliste mit dem Lee-Algorithmus.
Die Netze werden in echtzeit parallel verarbeitet.

@author Marvin Wollbrück
"""
alias STANDARD_CHANEL_WIDTH = 12

"""
Lässt nur ein Thread auf die Mutex-Struktur zugreifen.
"""
struct Mutex:
    var map: Matrix[Dict[String, List[Block]]]
    var semaphore: Bool
    var visitor: Int


    fn __init__(out self, owned map: Matrix[Dict[String, List[Block]]]):
        self.map = map
        self.semaphore = False
        self.visitor = -1

    fn lock(mut self, visitor: Int):
        while self.semaphore:
            pass
        self.semaphore = True
        self.visitor = visitor

    fn unlock(mut self, visitor: Int):
        if self.visitor == visitor:
            self.semaphore = False
            self.visitor = -1

    fn isLocked(borrowed self) -> Bool:
        return self.semaphore

    fn addBlock(mut self, x: Int, y: Int, net: String, block: Block, visitor: Int):
        pass
        
    

fn algo():