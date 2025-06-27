from testing import assert_equal, assert_true
from myFormats.Arch import Pin
from myFormats.Net import *
from myUtil.Enum import *
"""
@author Marvin Wollbrück
"""

alias sbblknum = 1
def initPins() -> List[Pin]:
    var pins = List[Pin]()
    pins.append(Pin(True, 0, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.LEFT)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.TOP)))
    pins.append(Pin(True, 0, List[Faceside](Faceside.RIGHT)))
    pins.append(Pin(False, 1, List[Faceside](Faceside.BOTTOM)))
    pins.append(Pin(True, 2, List[Faceside](Faceside.TOP), True))
    return pins

def test_NetFormat_1():
    var pins = initPins()

    var net = Net("test/.net/test_twoNet.net", sbblknum, pins)
    assert_true(net.isValid, "Net ist nicht valide")
    assert_equal(len(net.nets), 2, "Netzwerk ist nicht valide")
    assert_equal(len(net.nets["i_0_"]), 2, "Netzwerk i_0_ ist nicht valide")
    assert_equal(len(net.nets["o_1_"]), 2, "Netzwerk o_1_ ist nicht valide")
    assert_equal(len(net.globalNets), 0, "GlobalNetzwerk ist nicht valide")
    assert_equal(len(net.inpads), 1, "InputPads ist nicht valide")
    assert_equal(len(net.outpads), 1, "OutputPads ist nicht valide")
    assert_equal(len(net.clbs), 1, "CLBs ist nicht valide")
    assert_equal(len(net.netList), 2, "NetList ist nicht valide")

def test_NetFormat_2():
    var pins = initPins()

    var net = Net("test/.net/test_globalNet.net", sbblknum, pins)
    assert_true(net.isValid, "Net ist nicht valide")
    assert_equal(len(net.nets), 2, "Netzwerk ist nicht valide")
    assert_equal(len(net.nets["i_0_"]), 2, "Netzwerk i_0_ ist nicht valide")
    assert_equal(len(net.nets["o_1_"]), 2, "Netzwerk o_1_ ist nicht valide")
    assert_equal(len(net.globalNets), 1, "GlobalNetzwerk ist nicht valide")
    assert_equal(len(net.inpads), 2, "InputPads ist nicht valide")
    assert_equal(len(net.outpads), 1, "OutputPads ist nicht valide")
    assert_equal(len(net.clbs), 1, "CLBs ist nicht valide")
    assert_equal(len(net.netList), 3, "NetList ist nicht valide")
    assert_equal(len(net.globalNets["pclk"]), 2, "GlobalNetzwerk pclk ist nicht valide")