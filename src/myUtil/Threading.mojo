from memory import ArcPointer
from time import sleep

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

    alias FREE = -1

    # Konstruktor
    fn __init__(out self):
        self.owner =  ArcPointer[Int](self.FREE)
        self.visitor =  ArcPointer[Int](0)

    # Copy-Konstruktor
    fn __copyinit__(out self, other: Mutex):
        self.owner =  other.owner
        self.visitor =  other.visitor

    # Move-Konstruktor
    fn __moveinit__(out self, owned other: Mutex):
        self.owner =  other.owner
        self.visitor =  other.visitor

    # Sperrt den Mutex
    # und wartet bis keine Besucher mehr da sind
    # @param id: ID des Workers
    async fn lock(mut self, id: Int):
        while not self.owner[] == self.FREE:
            sleep(0.1)
        self.owner[] = id
        while self.visitor[] != 0:
            sleep(0.1)
    
    # Entsperrt den Mutex
    # @param id: ID des Workers
    async fn unlock(mut self, id: Int):
        if self.owner[] == id:
            self.owner[] = self.FREE

    # Besucht den Mutex
    # wartet bis der Mutex frei ist
    async fn visit(mut self):
        while self.owner[] != self.FREE:
            sleep(0.1)
        self.visitor[] += 1

    # Verlaesst den Mutex
    async fn unvisit(mut self):
        if self.visitor[] > 0:
            self.visitor[] -= 1