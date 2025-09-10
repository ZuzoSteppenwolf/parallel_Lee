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

Unterscheidet zwischen Besuchern und Besitzern.
Besitzer sind die Threads, die den Mutex gesperrt haben.

Besucher sind die Threads, die den Mutex besuchen wollen,
aber nicht gesperrt haben. Dabei darf der Mutex nicht gesperrt sein,
damit der Besucher den Mutex besuchen kann.
"""
struct Mutex(Copyable, Movable):
    var owner: UnsafePointer[BlockingSpinLock]
    var visitor: UnsafePointer[Atomic[DType.int64]]

    alias sleep_sec = 0.000001
    alias FREE = -1

    # Konstruktor
    fn __init__(out self):
        self.owner = UnsafePointer[BlockingSpinLock].alloc(1)
        self.owner[] = BlockingSpinLock()
        self.visitor = UnsafePointer[Atomic[DType.int64]].alloc(1)
        self.visitor[] = Atomic[DType.int64](0)

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
    # @arg id: ID des Workers
    fn lock(mut self, id: Int):
        self.owner[].lock(id)
        while self.visitor[].load() != 0:
            sleep(self.sleep_sec)
    
    # Entsperrt den Mutex
    # @arg id: ID des Workers
    fn unlock(mut self, id: Int):
        _ = self.owner[].unlock(id)

    # Besucht den Mutex
    # wartet bis der Mutex frei ist
    fn visit(mut self):
        while self.owner[].counter.load() != self.FREE:
            sleep(self.sleep_sec)
        _ = self.visitor[].fetch_add(1)

    # Verlaesst den Mutex
    fn unvisit(mut self):
        _ = self.visitor[].fetch_sub(1)

    # Destructor
    fn __del__(owned self):
        self.owner.free()
        self.visitor.free()

"""
Atomarer Bool-Wert
Zum Setzen und Abfragen eines Bool-Wertes in einem Multithreaded-Umfeld
Das Setzen benötigt eine Dereferenzierung
Das Abfragen des Wertes benötigt keine Dereferenzierung
"""
struct AtomicBool(Copyable, Movable, Boolable):
    var value: UnsafePointer[Atomic[DType.uint8]]

    # Konstruktor
    fn __init__(out self):
        self.value = UnsafePointer[Atomic[DType.uint8]].alloc(1)
        self.value[] = Atomic[DType.uint8](0)

    # Copy-Konstruktor
    fn __copyinit__(out self, other: AtomicBool):
        self.value = other.value

    # Move-Konstruktor
    fn __moveinit__(out self, owned other: AtomicBool):
        self.value = other.value

    # Setzt den Wert
    fn __setitem__(mut self, owned val: Bool):
        var current = self.value[].load()
        if val:
            _ = self.value[].compare_exchange_weak(current, 1)
        else:
            _ = self.value[].compare_exchange_weak(current, 0)

    # Konvertiert in Bool
    # @return: Bool-Wert
    fn __bool__(self) -> Bool:
        if self.value[].load() != 0:
            return True
        else:
            return False

    # Destructor
    fn __del__(owned self):
        self.value.free()