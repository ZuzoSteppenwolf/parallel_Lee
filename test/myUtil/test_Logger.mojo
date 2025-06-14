from myUtil.Logger import Log
from testing import assert_equal

"""
@file test_Logger.mojo
Test für den Logger
"""

def test_Logger1():
    var log = Log[False, testDebug = True]("test/output/test1.log")
    log.writeln("Test")
    log.writeln("Test2")
    log.writeln("Test3")
    log.writeln("Test4")
    log.writeln("Test5")
    log.writeln("Test6")
    log.writeln("Test7")
    log.writeln("Test8")
    log.writeln("Test9")
    log.writeln("Test10")

    with open(log.path + ".log", "r") as file:
        lines = file.read().split("\n")
        assert_equal(lines[0], "Log created")
        assert_equal(lines[1], "Test")
        assert_equal(lines[2], "Test2")
        assert_equal(lines[3], "Test3")
        assert_equal(lines[4], "Test4")
        assert_equal(lines[5], "Test5")
        assert_equal(lines[6], "Test6")
        assert_equal(lines[7], "Test7")
        assert_equal(lines[8], "Test8")
        assert_equal(lines[9], "Test9")
        assert_equal(lines[10], "Test10")

def test_Logger2():
    var log = Log[False, testDebug = True]("test/output/test2.log")
    log.write("Test")
    log.write("Test2")
    log.write("Test3")

    with open(log.path + ".log", "r") as file:
        lines = file.read().split("\n")
        assert_equal(lines[0], "Log created")
        assert_equal(lines[1], "TestTest2Test3")

def test_Logger3(): 
    var log = Log[False, testDebug = True]("test/output/test3.log")
    log.write("Test")
    log = Log[False, testDebug = True]("test/output/test3.log")
    log.write("Test2")

    with open(log.path + ".log", "r") as file:
        lines = file.read().split("\n")
        assert_equal(lines[0], "Log created")
        assert_equal(lines[1], "Test2")

def test_Logger4():
    var log = Log[False, testDebug = True]("test/output/test4.log")
    log.write(1)
    log.write(2)
    log.write(3)

    with open(log.path + ".log", "r") as file:
        lines = file.read().split("\n")
        assert_equal(lines[0], "Log created")
        assert_equal(lines[1], "123")

def test_Logger5():
    var log = Log[False, testDebug = True]("test/output/test5.log")
    log.write(1)
    var logCopy = log
    logCopy.write(2)

    with open(log.path + ".log", "r") as file:
        lines = file.read().split("\n")
        assert_equal(lines[0], "Log created")
        assert_equal(lines[1], "12")

def test_Logger6():
    var log = Log[False, testDebug = True]("test/output/test6.log")
    log.write(1, 2, 3)

    with open(log.path + ".log", "r") as file:
        lines = file.read().split("\n")
        assert_equal(lines[0], "Log created")
        assert_equal(lines[1], "123")
