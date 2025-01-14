"""
@file Util.mojo

Utility Funktionen für Mojo

@author Marvin Wollbrück
"""


"""
Bereinigt die übergebenen Zeilen von Kommentaren und Zeilenumbrüchen

@param lines: Liste von Zeilen
@return: Liste von bereinigten Zeilen
"""
fn clearUpLines(owned lines: List[String]) -> List[String]:
    var newLines = List[String]()
    var isContinued = False
    while len(lines) > 0:
        var line = lines.pop(0)
        if line == "" or line.isspace():
            continue
        var newLine = String(line.strip())
        if newLine.startswith("#"):
            continue
        var offset = newLine.find("#")
        if offset > -1:
            newLine = String(newLine[:offset].strip())
        offset = newLine.find("\\")
        if offset > -1:
            newLine = newLine[:offset]
            if isContinued:
                newLines[-1] += newLine
            else:
                isContinued = True
                newLines.append(newLine)
            continue
        if isContinued:
            isContinued = False
            newLines[-1] += newLine
        else:
            newLines.append(newLine)
        
    return newLines