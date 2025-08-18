from os import remove
from memory import ArcPointer
from utils.write import write_args
from time import monotonic
from myUtil.Threading import Mutex

"""
@file Logger.mojo

Implementierung eines Loggers
@author: Marvin Wollbrück
"""

alias MAX_LINES = 100000
alias MAX_FILES = 100

"""
Erzeugt eine Logdatei und schreibt in diese.
Die Logdatei wird im Konstruktor geöffnet und im Destruktor geschlossen.
Die Logdatei erneurt sich, wenn die maximale Anzahl an Zeilen erreicht ist.

@param hasTimestamp: True, wenn ein Zeitstempel in der Logdatei geschrieben werden soll
@param maxLines: Maximale Anzahl an Zeilen, die in der Logdatei geschrieben werden sollen
                bei 0 wird die Logdatei nicht erneuert
@param maxFiles: Maximale Anzahl an Logdateien, die erstellt werden sollen
"""
struct Log[hasTimestamp: Bool, testDebug: Bool = False, maxLines: Int = MAX_LINES, maxFiles: Int = MAX_FILES]:   
    var path: String
    var file: ArcPointer[FileHandle]
    var timestamp: UInt
    var lines: Int
    var files: Int8

    # Konstruktor
    # @arg path: Pfad zur Logdatei
    fn __init__(out self, path: String) raises:
        self.path = String(path.rstrip(".log"))      
        self.timestamp = 0
        self.lines = 0
        self.files = -1
        if testDebug:
            self.file = open(self.path + ".log", "w")
        else:
            self.file = open(self.path + "_" + String(self.files) + ".log", "w")
        if hasTimestamp:
            self.timestamp = monotonic()
        self.writeln("Log created")  

    # Copy-Konstruktor
    fn __copyinit__(out self, other: Log[hasTimestamp, testDebug, maxLines, maxFiles]):

        self.path = other.path
        self.file = other.file
        self.lines = other.lines
        self.files = other.files
        self.timestamp = other.timestamp

    # Move-Konstruktor
    fn __moveinit__(out self, owned other: Log[hasTimestamp, testDebug, maxLines, maxFiles]):
        self.path = other.path
        self.file = other.file
        self.lines = other.lines
        self.files = other.files
        self.timestamp = other.timestamp

    # Schreibt in die Logdatei
    # @arg text: Text, der in die Logdatei geschrieben werden soll
    fn write(mut self, text: String):
        self.file[].write(text)

    # Schreibt in die Logdatei
    # @arg text: Writeable Objekt, das in die Logdatei geschrieben werden soll
    fn write[T: Writable](mut self, text: T):
        self.file[].write(text)

    # Schreibt in die Logdatei
    # @arg text: Writeable Objekte, die in die Logdatei geschrieben werden soll
    fn write[*Ts: Writable](mut self, *text: *Ts):
        write_args(self.file[], text)

    # Prüft, ob die maximale Anzahl an Zeilen erreicht ist
    # und erstellt eine neue Logdatei, wenn dies der Fall ist
    fn newFile(mut self):
        try:
            if maxLines > 0:
                if self.lines >= maxLines:
                    self.lines = 0
                    self.files += 1
                    self.files %= maxFiles
                    self.file[].close()
                    self.file = open(self.path + "_" + String(self.files) + ".log", "w")
                    self.writeln("Log created")
                self.lines += 1    
        except:
                pass

    # Schreibt den Zeitstempel in ns in die Logdatei
    fn writeStamp(mut self):
        if hasTimestamp:
            var diff = monotonic() - self.timestamp
            self.file[].write(diff, "ns: ")

    # Schreibt in die Logdatei eine Zeile
    # @arg text: Text, der in die Logdatei geschrieben werden soll
    fn writeln(mut self, text: String):
        self.newFile()
        self.writeStamp()
        self.file[].write(text, "\n")

    # Schreibt in die Logdatei eine Zeile
    # @arg text: Writeable Objekt, das in die Logdatei geschrieben werden soll
    fn writeln[T: Writable](mut self, text: T):
        self.newFile()
        self.writeStamp()
        self.file[].write(text, "\n")

    # Schreibt in die Logdatei eine Zeile
    # @arg text: Writeable Objekte, die in die Logdatei geschrieben werden soll
    fn writeln[*Ts: Writable](mut self, *text: *Ts):
        self.newFile()
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
Die Logdatei erneurt sich, wenn die maximale Anzahl an Zeilen erreicht ist.

@param hasTimestamp: True, wenn ein Zeitstempel in der Logdatei geschrieben werden soll
@param maxLines: Maximale Anzahl an Zeilen, die in der Logdatei geschrieben werden sollen
                bei 0 wird die Logdatei nicht erneuert
@param maxFiles: Maximale Anzahl an Logdateien, die erstellt werden sollen
"""
struct async_Log[hasTimestamp: Bool, testDebug: Bool = False, maxLines: Int = MAX_LINES, maxFiles: Int = MAX_FILES]:
    var log: ArcPointer[Log[hasTimestamp, testDebug, maxLines, maxFiles]]
    var mutex: Mutex

    # Konstruktor
    # @arg path: Pfad zur Logdatei
    fn __init__(out self, path: String) raises:
        self.log = ArcPointer[Log[hasTimestamp, testDebug, maxLines, maxFiles]](Log[hasTimestamp, testDebug, maxLines, maxFiles](path))
        self.mutex = Mutex()

    # Copy-Konstruktor
    fn __copyinit__(out self, other: async_Log[hasTimestamp, testDebug, maxLines, maxFiles]):
        self.log = other.log
        self.mutex = other.mutex

    # Move-Konstruktor
    fn __moveinit__(out self, owned other: async_Log[hasTimestamp, testDebug, maxLines, maxFiles]):
        self.log = other.log
        self.mutex = other.mutex

    # Schreibt in die Logdatei eine Zeile
    # @arg id: ID des Threads
    # @arg text: Text, der in die Logdatei geschrieben werden soll
    fn writeln[*Ts: Writable](mut self, id: Int, *text: *Ts):
        self.mutex.lock(id)
        self.log[].newFile()
        self.log[].writeStamp()
        write_args(self.log[].file[], text)
        self.log[].write("\n")
        self.mutex.unlock(id)