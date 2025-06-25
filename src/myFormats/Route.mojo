from collections import Dict, List
from myUtil.Block import Block
from myUtil.Enum import *
from myUtil.Matrix import Matrix, ListMatrix
from myFormats.Arch import *
"""
@file Route.mojo

Parser für das Route File Format vom VPR Tool

@author Marvin Wollbrück
"""

# Schreibt die Route in eine Datei
# @param path Name der Datei
# @param routeLists Liste der Routen
# @param netKeys Liste der Netzkeys
# @param pins Liste der Pins
# @param clbMap Matrix der CLBs
# @param clbNums Dict der CLB-Nummern
# @param netPins Dict der Netz-IOPins
# @param globalNets Dict der globalen Netze
# @param archiv Dict der Archivierung der CLBs
# @return True, wenn die Routen geschrieben wurden, sonst False
fn writeRouteFile(path: String, routeLists: Dict[String, Dict[Int, List[Block.SharedBlock]]], 
    netKeys: List[String], pins: List[Pin], clbMap: ListMatrix[List[Block.SharedBlock]], 
    clbNums: Dict[String, Int], netPins: Dict[String, Dict[String, Int]],
    globalNets: Dict[String, List[Tuple[String, Int]]], archiv: Dict[String, Tuple[Int, Int]]) -> Bool:

    try:
        with open(path, "w") as file:
            @argeter
            fn writeNL():
                file.write("\n")
            
            # Schreibt die CLB-Informationen in die Datei
            # @arg isSink: True, wenn es sich um einen Sink handelt, sonst False
            # @arg block: Block, der geschrieben werden soll
            # @arg net: Name des Netzes, zu dem der Block gehört
            # @arg isFirst: True, wenn es sich um den ersten Block des Netzes handelt
            @argeter
            fn writeClb(isSink: Bool, block: Block.SharedBlock, net: String, isFirst: Bool = False):
                try:
                    var line: String = ""
                    if isSink:
                        line = String("  IPIN (") + String(block[].coord[0])+ "," + String(block[].coord[1]) + ")  Pin: " + String(netPins[net][block[].name]) + "\n"
                        file.write(line)
                        line = String("  SINK (") + String(block[].coord[0])+ "," + String(block[].coord[1]) + ")  Class: " + String(pins[netPins[net][block[].name]].pinClass) + "\n"
                        file.write(line)
                    else:
                        if isFirst:
                            line = String("SOURCE (") + String(block[].coord[0])+ "," + String(block[].coord[1]) + ")  Class: " + String(pins[netPins[net][block[].name]].pinClass) + "\n"
                            file.write(line)

                        line = String("  OPIN (") + String(block[].coord[0])+ "," + String(block[].coord[1]) + ")  Pin: " + String(netPins[net][block[].name]) + "\n"
                        file.write(line)
                except e:
                    print("Error writing CLB: ", e)

            # Schreibt die Pad-Informationen in die Datei
            # @arg isSink: True, wenn es sich um einen Sink handelt, sonst False
            # @arg block: Pad, das geschrieben werden soll
            # @arg isFirst: True, wenn es sich um den ersten Block des Netzes handelt
            @argeter
            fn writePad(isSink: Bool, block: Block.SharedBlock, isFirst: Bool = False):
                var line: String = ""
                if isSink:
                    line = String("  IPIN (") + String(block[].coord[0]) + "," + String(block[].coord[1]) + ")  Pad: " + String(block[].subblk) + "\n"
                    file.write(line)
                    line = String("  SINK (") + String(block[].coord[0]) + "," + String(block[].coord[1]) + ")  Pad: " + String(block[].subblk) + "\n"
                    file.write(line)
                else:
                    if isFirst:
                        line = String("SOURCE (") + String(block[].coord[0]) + "," + String(block[].coord[1]) + ")  Pad: " + String(block[].subblk) + "\n"
                        file.write(line)

                    line = String("  OPIN (") + String(block[].coord[0]) + "," + String(block[].coord[1]) + ")  Pad: " + String(block[].subblk) + "\n"
                    file.write(line)

            # Schreibt die Kanal-Informationen in die Datei
            # @arg block: Kanal, der geschrieben werden soll
            @argeter
            fn writeChan(block: Block.SharedBlock):
                var line: String = ""
                if block[].type == Blocktype.CHANX:
                    line = String(" CHANX (") + String(block[].coord[0]) + "," + String(block[].coord[1]) + ")  Track: " + String(block[].subblk) + "\n"
                    file.write(line)
                elif block[].type == Blocktype.CHANY:
                    line = String(" CHANY (") + String(block[].coord[0]) + "," + String(block[].coord[1]) + ")  Track: " + String(block[].subblk) + "\n"
                    file.write(line)

            # Schreibe die Header-Informationen
            file.write(String("Array size: ") + String(clbMap.cols-2) + " x " + String(clbMap.rows-2) + " logic blocks.\n")
            writeNL()
            file.write("Routing:\n")
            
            # Schreibt die Routen für jedes Netz
            for netIdx in range(len(netKeys)):
                var isFirst: Bool = True
                var net = netKeys[netIdx]
                writeNL()
                # Prüft, ob das Netz in den Routenlisten vorhanden ist
                if net in routeLists:
                    file.write(String("Net ") + String(netIdx) + " (" + String(net) + ")\n")
                    writeNL()
                    for track in routeLists[net]:
                        var blocks = routeLists[net][track[]]
                        for block in blocks:
                            if block[][].type == Blocktype.CLB:
                                writeClb(pins[netPins[net][block[][].name]].isInpin, block[], net, isFirst)
                            elif block[][].type == Blocktype.INPAD:
                                writePad(False, block[], isFirst)
                            elif block[][].type == Blocktype.OUTPAD:
                                writePad(True, block[], isFirst)
                            elif block[][].type == Blocktype.CHANX or block[][].type == Blocktype.CHANY:
                                writeChan(block[])
                            isFirst = False
                # Sonst ist das Netz Global
                else:
                    file.write(String("Net ") + String(netIdx) + " (" + String(net) + "): global net connecting:\n")
                    writeNL()
                    for clb in globalNets[net]:
                        var clbName = clb[][0]
                        var line: String = String("Block ") + String(clbName) + " (#" + String(clbNums[clbName]) + ") at (" + String(archiv[clbName][0]) + ", " +
                           String(archiv[clbName][1]) + "), Pin class "
                        if clb[][1] > -1:
                            line += String(pins[clb[][1]].pinClass)
                        else:
                            line += String(clb[][1])
                        line += ".\n"
                        file.write(line)

    except:
        return False

    return True