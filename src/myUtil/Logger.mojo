from os import remove
from memory import ArcPointer
from utils.write import write_args
from time import monotonic
from myUtil.Threading import Mutex
from python import Python

"""
@file Logger.mojo

Implementierung eines Loggers
@author: Marvin Wollbrück
"""

"""
Erzeugt eine Logdatei und schreibt in diese.
Die Logdatei wird im Konstruktor geöffnet und im Destruktor geschlossen.

@param hasTimestamp: True, wenn ein Zeitstempel in der Logdatei geschrieben werden soll
"""
struct Log[hasTimestamp: Bool]:   
    var path: String
    var file: ArcPointer[FileHandle]
    var timestamp: UInt

    # Konstruktor
    # @param path: Pfad zur Logdatei
    fn __init__(out self, path: String) raises:
        self.path = path   
        self.file = open(self.path, "w")
        self.timestamp = 0
        if hasTimestamp:
            self.timestamp = monotonic()
        self.writeln("Log created")  

    # Copy-Konstruktor
    fn __copyinit__(out self, other: Log[hasTimestamp]):

        self.path = other.path
        self.file = other.file
        self.timestamp = other.timestamp

    # Move-Konstruktor
    fn __moveinit__(out self, owned other: Log[hasTimestamp]):
        self.path = other.path
        self.file = other.file
        self.timestamp = other.timestamp

    # Schreibt in die Logdatei
    # @param text: Text, der in die Logdatei geschrieben werden soll
    fn write(mut self, text: String):
        self.file[].write(text)

    # Schreibt in die Logdatei
    # @param text: Writeable Objekt, das in die Logdatei geschrieben werden soll
    fn write[T: Writable](mut self, text: T):
        self.file[].write(text)

    # Schreibt in die Logdatei
    # @param text: Writeable Objekte, die in die Logdatei geschrieben werden soll
    fn write[*Ts: Writable](mut self, *text: *Ts):
        write_args(self.file[], text)

    # Schreibt den Zeitstempel in ns in die Logdatei
    fn writeStamp(mut self):
        if hasTimestamp:
            var diff = monotonic() - self.timestamp
            self.file[].write(diff, "ns: ")

    # Schreibt in die Logdatei eine Zeile
    # @param text: Text, der in die Logdatei geschrieben werden soll
    fn writeln(mut self, text: String):
        self.writeStamp()
        self.file[].write(text, "\n")

    # Schreibt in die Logdatei eine Zeile
    # @param text: Writeable Objekt, das in die Logdatei geschrieben werden soll
    fn writeln[T: Writable](mut self, text: T):
        self.writeStamp()
        self.file[].write(text, "\n")

    # Schreibt in die Logdatei eine Zeile
    # @param text: Writeable Objekte, die in die Logdatei geschrieben werden soll
    fn writeln[*Ts: Writable](mut self, *text: *Ts):
        self.writeStamp()
        write_args(self.file[], text)
        self.file[].write("\n")

    # Löscht die Logdatei
    fn __del__(owned self):
        if self.file.count() == 1:
            try:
                self.file[].close()
            except:
                pass

"""
Erzeugt eine Threadsafe Logdatei und schreibt in diese.
Die Logdatei wird im Konstruktor geöffnet und im Destruktor geschlossen.

@param hasTimestamp: True, wenn ein Zeitstempel in der Logdatei geschrieben werden soll
"""
struct async_Log[hasTimestamp: Bool]:
    var log: ArcPointer[Log[hasTimestamp]]
    var mutex: Mutex

    # Konstruktor
    # @param path: Pfad zur Logdatei
    fn __init__(out self, path: String) raises:
        self.log = ArcPointer[Log[hasTimestamp]](Log[hasTimestamp](path))
        self.mutex = Mutex()

    # Copy-Konstruktor
    fn __copyinit__(out self, other: async_Log[hasTimestamp]):
        self.log = other.log
        self.mutex = other.mutex

    # Move-Konstruktor
    fn __moveinit__(out self, owned other: async_Log[hasTimestamp]):
        self.log = other.log
        self.mutex = other.mutex

    # Schreibt in die Logdatei eine Zeile
    # @param id: ID des Threads
    # @param text: Text, der in die Logdatei geschrieben werden soll
    fn writeln[*Ts: Writable](mut self, id: Int, *text: *Ts):
        self.mutex.lock(id)
        self.log[].writeStamp()
        write_args(self.log[].file[], text)
        self.log[].write("\n")
        self.mutex.unlock(id)