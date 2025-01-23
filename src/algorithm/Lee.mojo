from myFormats import *
from myUtil import *
from collections import Dict, List

"""
@file Lee.mojo
Erzeugt eine Verdrahtungsliste mit dem Lee-Algorithmus.
Die Netze werden in echtzeit parallel verarbeitet.

@author Marvin Wollbrück
"""
alias STANDARD_CHANEL_WIDTH = 12

struct monitor:
    var net: String

fn algo():
