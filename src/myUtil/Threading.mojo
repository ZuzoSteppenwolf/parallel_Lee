from memory import ArcPointer, UnsafePointer
from time import sleep
from utils import BlockingSpinLock

"""
@file Threading.mojo

Komponenten für multithreaded Programmierung

@author: Marvin Wollbrück
"""

"""
Mutex-Struktur
"""
struct Mutex:
    var owner: ArcPointer[Int]
    var visitor:  ArcPointer[Int]
    var loc: UnsafePointer[BlockingSpinLock]

    alias sleep_sec = 0.000001
    alias FREE = -1

    # Konstruktor
    fn __init__(out self):
        self.owner =  ArcPointer[Int](self.FREE)
        self.visitor =  ArcPointer[Int](0)
        self.loc = UnsafePointer[BlockingSpinLock].alloc(1)
        self.loc[0] = BlockingSpinLock()

    # Copy-Konstruktor
    fn __copyinit__(out self, other: Mutex):
        self.owner =  other.owner
        self.visitor =  other.visitor
        self.loc = other.loc

    # Move-Konstruktor
    fn __moveinit__(out self, owned other: Mutex):
        self.owner =  other.owner
        self.visitor =  other.visitor
        self.loc = other.loc

    # Sperrt den Mutex
    # und wartet bis keine Besucher mehr da sind
    # @param id: ID des Workers
    fn lock(mut self, id: Int):
        """
        while not self.owner[] == self.FREE:
            sleep(self.sleep_sec)
        self.owner[] = id
    """
        self.loc[0].lock(id)
        while self.visitor[] != 0:
            sleep(self.sleep_sec)
    
    # Entsperrt den Mutex
    # @param id: ID des Workers
    fn unlock(mut self, id: Int):
        _ = self.loc[0].unlock(id)
        """
        if self.owner[] == id:
            self.owner[] = self.FREE
            """

    # Besucht den Mutex
    # wartet bis der Mutex frei ist
    fn visit(mut self):
        while self.owner[] != self.FREE:
            sleep(self.sleep_sec)
        self.visitor[] += 1

    # Verlaesst den Mutex
    fn unvisit(mut self):
        if self.visitor[] > 0:
            self.visitor[] -= 1