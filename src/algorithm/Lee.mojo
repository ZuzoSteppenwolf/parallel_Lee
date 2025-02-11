from myFormats.Place import *
from myUtil.Matrix import *
from myUtil.Enum import *
from myUtil.Util import *
from collections import Dict, List
from os import Atomic
from time import sleep

"""
@file Lee.mojo
Erzeugt eine Verdrahtungsliste mit dem Lee-Algorithmus.
Die Netze werden in echtzeit parallel verarbeitet.

@author Marvin Wollbrück
"""
alias STANDARD_CHANEL_WIDTH = 12

var NetKeys = List[String]()

"""
Lässt nur ein Thread auf die Mutex-Struktur zugreifen.
"""
struct Channels:
    var map: Matrix[Dict[String, List[Block]]]
    var owner: Atomic[DType.int64]
    var visitor: Atomic[DType.int64]

    alias FREE = -1


    fn __init__(out self, owned map: Matrix[Dict[String, List[Block]]]):
        self.map = map
        self.owner = Atomic[DType.int64](self.FREE)
        self.visitor = Atomic[DType.int64](0)

    fn lock(mut self, id: Int):
        var owner: SIMD[DType.int64, 1] = self.FREE
        while not self.owner.compare_exchange_weak(owner, id):
            owner = self.FREE
            sleep(0.1)
        while self.visitor.load() != 0:
            sleep(0.1)
    
    fn unlock(mut self, id: Int):
        var owner: SIMD[DType.int64, 1] = id
        _ = self.owner.compare_exchange_weak(owner, self.FREE)

    fn askChannel(mut self, id: Int, row: Int, col: Int, mut count: Int) -> Bool:
        while not self.owner.load() == self.FREE:
            sleep(0.1)
        _ = self.visitor.fetch_add(1)

        count = len(self.map[row, col])
        var hasChannel = NetKeys[id] in self.map[row, col]

        _ = self.visitor.fetch_sub(1)
        return hasChannel
        
    

fn algo():