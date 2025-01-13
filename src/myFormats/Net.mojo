from collections import Dict, List
"""
@file Net.mojo

Parser für das Net File Format vom VPR Tool

@author Marvin Wollbrück
"""

@value
struct Net:
    var nets: Dict[String, List[String]]