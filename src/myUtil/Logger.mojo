from os import remove
from memory import ArcPointer
from utils.write import write_args
from time import monotonic

"""
@file Logger.mojo

Implementierung eines Loggers
"""
struct Log[hasTimestamp: Bool]:   
    var path: String
    var file: ArcPointer[FileHandle]
    var timestamp: UInt

    fn __init__(out self, path: String) raises:
        self.path = path   
        self.file = open(self.path, "w")
        self.timestamp = 0
        if hasTimestamp:
            self.timestamp = monotonic()
        self.writeln("Log created")  

    fn __copyinit__(out self, other: Log[hasTimestamp]):

        self.path = other.path
        self.file = other.file
        self.timestamp = other.timestamp

    fn __moveinit__(out self, owned other: Log[hasTimestamp]):
        self.path = other.path
        self.file = other.file
        self.timestamp = other.timestamp

    fn write(mut self, text: String):
        self.file[].write(text)

    fn write[T: Writable](mut self, text: T):
        self.file[].write(text)

    fn write[*Ts: Writable](mut self, *text: *Ts):
        write_args(self.file[], text)

    fn writeStamp(mut self):
        if hasTimestamp:
            var diff = monotonic() - self.timestamp
            self.file[].write(diff, ": ")

    fn writeln(mut self, text: String):
        self.writeStamp()
        self.file[].write(text, "\n")

    fn writeln[T: Writable](mut self, text: T):
        self.writeStamp()
        self.file[].write(text, "\n")

    fn writeln[*Ts: Writable](mut self, *text: *Ts):
        self.writeStamp()
        write_args(self.file[], text)
        self.file[].write("\n")

    fn __del__(owned self):
        if self.file.count() == 1:
            try:
                self.file[].close()
            except:
                pass

            