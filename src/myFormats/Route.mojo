from collections import Dict, List
from myUtil.Block import Block, BlockPair
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
# @param arraySize Größe des Arrays[X,Y]
# @param clbNums Dict der CLB-Nummern
# @param globalNets Dict der globalen Netze
# @param archiv Dict der Archivierung der CLBs
# @return True, wenn die Routen geschrieben wurden, sonst False
fn writeRouteFile(path: String, routeLists: Dict[String, Dict[Int, List[BlockPair[Int]]]], 
    netKeys: List[String], pins: List[Pin], arraySize: Tuple[Int, Int], 
    clbNums: Dict[String, Int], globalNets: Dict[String, List[Tuple[String, Int]]], 
    archiv: Dict[String, Tuple[Int, Int]]) -> Bool:

    try:
        with open(path, "w") as file:
            @parameter
            fn writeNL():
                file.write("\n")
            
            # Schreibt die CLB-Informationen in die Datei
            # @arg isSink: True, wenn es sich um einen Sink handelt, sonst False
            # @arg block: Block, der geschrieben werden soll
            # @arg net: Name des Netzes, zu dem der Block gehört
            # @arg isFirst: True, wenn es sich um den ersten Block des Netzes handelt
            @parameter
            fn writeClb(isSink: Bool, block: BlockPair[Int], net: String, isFirst: Bool = False):
                try:
                    var line: String = ""
                    if isSink:
                        line = String("  IPIN (") + String(block.block[].coord[0])+ "," + String(block.block[].coord[1]) + ")  Pin: " + String(block.value) + "\n"
                        file.write(line)
                        line = String("  SINK (") + String(block.block[].coord[0])+ "," + String(block.block[].coord[1]) + ")  Class: " + String(pins[block.value].pinClass) + "\n"
                        file.write(line)
                    else:
                        if isFirst:
                            line = String("SOURCE (") + String(block.block[].coord[0])+ "," + String(block.block[].coord[1]) + ")  Class: " + String(pins[block.value].pinClass) + "\n"
                            file.write(line)

                        line = String("  OPIN (") + String(block.block[].coord[0])+ "," + String(block.block[].coord[1]) + ")  Pin: " + String(block.value) + "\n"
                        file.write(line)
                except e:
                    print("Error writing CLB: ", e)

            # Schreibt die Pad-Informationen in die Datei
            # @arg isSink: True, wenn es sich um einen Sink handelt, sonst False
            # @arg block: Pad, das geschrieben werden soll
            # @arg isFirst: True, wenn es sich um den ersten Block des Netzes handelt
            @parameter
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
            @parameter
            fn writeChan(block: Block.SharedBlock):
                var line: String = ""
                if block[].type == Blocktype.CHANX:
                    line = String(" CHANX (") + String(block[].coord[0]) + "," + String(block[].coord[1]) + ")  Track: " + String(block[].subblk) + "\n"
                    file.write(line)
                elif block[].type == Blocktype.CHANY:
                    line = String(" CHANY (") + String(block[].coord[0]) + "," + String(block[].coord[1]) + ")  Track: " + String(block[].subblk) + "\n"
                    file.write(line)

            # Schreibe die Header-Informationen
            file.write(String("Array size: ") + String(arraySize[0]) + " x " + String(arraySize[1]) + " logic blocks.\n")
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
                        var blocks = routeLists[net][track]
                        for block in blocks:
                            if block.block[].type == Blocktype.CLB:
                                writeClb(pins[block.value].isInpin, block, net, isFirst)
                            elif block.block[].type == Blocktype.INPAD:
                                writePad(False, block.block[], isFirst)
                            elif block.block[].type == Blocktype.OUTPAD:
                                writePad(True, block.block[], isFirst)
                            elif block.block[].type == Blocktype.CHANX or block.block[].type == Blocktype.CHANY:
                                writeChan(block.block[])
                            isFirst = False
                # Sonst ist das Netz Global
                else:
                    file.write(String("Net ") + String(netIdx) + " (" + String(net) + "): global net connecting:\n")
                    writeNL()
                    for clb in globalNets[net]:
                        var clbName = clb[0]
                        var line: String = String("Block ") + String(clbName) + " (#" + String(clbNums[clbName]) + ") at (" + String(archiv[clbName][0]) + ", " +
                           String(archiv[clbName][1]) + "), Pin class "
                        if clb[1] > -1:
                            line += String(pins[clb[1]].pinClass)
                        else:
                            line += String(clb[1])
                        line += ".\n"
                        file.write(line)

    except:
        return False

    return True