from myUtil.Logger import Log
from testing import assert_equal

"""
@file test_Logger.mojo
Test für den Logger
"""

fn test_Logger1() raises:
    var log = Log("test/output/test1.log")
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

    with open(log.path, "r") as file:
        lines = file.read().split("\n")
        assert_equal(lines[0], "Test")
        assert_equal(lines[1], "Test2")
        assert_equal(lines[2], "Test3")
        assert_equal(lines[3], "Test4")
        assert_equal(lines[4], "Test5")
        assert_equal(lines[5], "Test6")
        assert_equal(lines[6], "Test7")
        assert_equal(lines[7], "Test8")
        assert_equal(lines[8], "Test9")
        assert_equal(lines[9], "Test10")

fn test_Logger2() raises:
    var log = Log("test/output/test2.log")
    log.write("Test")
    log.write("Test2")
    log.write("Test3")

    with open(log.path, "r") as file:
        assert_equal(file.read(), "TestTest2Test3")

fn test_Logger3() raises: 
    var log = Log("test/output/test3.log")
    log.write("Test")
    log = Log("test/output/test3.log")
    log.write("Test2")

    with open(log.path, "r") as file:
        assert_equal(file.read(), "Test2")

fn test_Logger4() raises:
    var log = Log("test/output/test4.log")
    log.write(1)
    log.write(2)
    log.write(3)

    with open(log.path, "r") as file:
        assert_equal(file.read(), "123")
