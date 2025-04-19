from memory import ArcPointer, UnsafePointer
from time import sleep
from utils import BlockingSpinLock
from os import Atomic

"""
@file Threading.mojo

Komponenten für multithreaded Programmierung

@author: Marvin Wollbrück
"""

"""
Mutex-Struktur
"""
struct Mutex:
    var owner: UnsafePointer[BlockingSpinLock]
    var visitor: UnsafePointer[Atomic[DType.int64]]

    alias sleep_sec = 0.000001
    alias FREE = -1

    # Konstruktor
    fn __init__(out self):
        self.owner = UnsafePointer[BlockingSpinLock].alloc(1)
        self.owner[0] = BlockingSpinLock()
        self.visitor = UnsafePointer[Atomic[DType.int64]].alloc(1)
        self.visitor[0] = Atomic[DType.int64](0)

    # Copy-Konstruktor
    fn __copyinit__(out self, other: Mutex):
        self.owner = other.owner
        self.visitor = other.visitor

    # Move-Konstruktor
    fn __moveinit__(out self, owned other: Mutex):
        self.owner = other.owner
        self.visitor = other.visitor

    # Sperrt den Mutex
    # und wartet bis keine Besucher mehr da sind
    # @param id: ID des Workers
    fn lock(mut self, id: Int):
        self.owner[0].lock(id)
        while self.visitor[].load() != 0:
            sleep(self.sleep_sec)
    
    # Entsperrt den Mutex
    # @param id: ID des Workers
    fn unlock(mut self, id: Int):
        _ = self.owner[0].unlock(id)

    # Besucht den Mutex
    # wartet bis der Mutex frei ist
    fn visit(mut self):
        while self.owner[0].counter.load() != self.FREE:
            sleep(self.sleep_sec)
        _ = self.visitor[].fetch_add(1)

    # Verlaesst den Mutex
    fn unvisit(mut self):
        _ = self.visitor[].fetch_sub(1)

    # Destructor
    fn __del__(owned self):
        self.owner.free()
        self.visitor.free()