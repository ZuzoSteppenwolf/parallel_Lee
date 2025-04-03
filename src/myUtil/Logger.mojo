from os import remove
from memory import ArcPointer

"""
@file Logger.mojo

Implementierung eines Loggers
"""

struct Log:
    var path: String
    var file: ArcPointer[FileHandle]

    fn __init__(out self, path: String) raises:
        self.path = path   
        self.file = open(self.path, "w")

    fn __copyinit__(out self, other: Log):
        self.path = other.path
        self.file = other.file

    fn __moveinit__(out self, owned other: Log):
        self.path = other.path
        self.file = other.file

    fn write(mut self, text: String):
        self.file[].write(text)


    fn write[T: Writable](mut self, text: T):
        self.file[].write(text)

    fn writeln(mut self, text: String):
        self.file[].write(text, "\n")


    fn writeln[T: Writable](mut self, text: T):
        self.file[].write(text, "\n")

    fn __del__(owned self):
        if self.file.count() == 1:
            try:
                self.file[].close()
            except:
                pass
            