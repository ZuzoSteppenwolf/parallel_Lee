from os import remove

"""
@file Logger.mojo

Implementierung eines Loggers
"""

struct Log:
    var path: String

    fn __init__(out self, path: String):
        self.path = path
        try:
            remove(path)
        except:
            pass

    fn __copyinit__(out self, other: Log):
        self.path = other.path

    fn __moveinit__(out self, owned other: Log):
        self.path = other.path

    fn write(self, text: String):
        try:
            with open(self.path, "w") as file:
                file.write(text)
        except:
            pass

    fn write[T: Writable](self, text: T):
        try:
            with open(self.path, "w") as file:
                file.write(text)
        except:
            pass

    fn writeln(self, text: String):
        try:
            with open(self.path, "a") as file:
                file.write(text + "\n")
        except:
            pass

    fn writeln[T: Writable](self, text: T):
        try:
            with open(self.path, "a") as file:
                file.write(text)
                file.write("\n")
        except:
            pass