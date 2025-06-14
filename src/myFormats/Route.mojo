from collections import Dict, List
from myUtil.Block import Block
from myUtil.Enum import *
from myUtil.Matrix import Matrix, ListMatrix
from myFormats.Arch import *
"""
@file Route.mojo

Parser für das Route File Format vom VPR Tool
"""

# Schreibt die Route in eine Datei
# @param path Name der Datei
# @param routeLists Liste der Routen
# @param netKeys Liste der Netzkeys
# @param pins Liste der Pins
# @param clbMap Matrix der CLBs
# @param clbNums Dict der CLB-Nummern
# @param netPins Dict der Netz-IOPins
# @return True, wenn die Routen geschrieben wurden, sonst False
fn writeRouteFile(path: String, routeLists: Dict[String, Dict[Int, List[Block.SharedBlock]]], 
    netKeys: List[String], pins: List[Pin], clbMap: ListMatrix[List[Block.SharedBlock]], 
    clbNums: Dict[String, Int], netPins: Dict[String, Dict[String, Int]],
    globalNets: Dict[String, List[Tuple[String, Int]]], archiv: Dict[String, Tuple[Int, Int]]) -> Bool:

    try:
        with open(path, "w") as file:
            @parameter
            fn writeNL():
                file.write("\n")
            
            @parameter
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

            @parameter
            fn writeChan(block: Block.SharedBlock):
                var line: String = ""
                if block[].type == Blocktype.CHANX:
                    line = String(" CHANX (") + String(block[].coord[0]) + "," + String(block[].coord[1]) + ")  Track: " + String(block[].subblk) + "\n"
                    file.write(line)
                elif block[].type == Blocktype.CHANY:
                    line = String(" CHANY (") + String(block[].coord[0]) + "," + String(block[].coord[1]) + ")  Track: " + String(block[].subblk) + "\n"
                    file.write(line)

            file.write(String("Array size: ") + String(clbMap.cols-2) + " x " + String(clbMap.rows-2) + " logic blocks.\n")
            writeNL()
            file.write("Routing:\n")
            

            for netIdx in range(len(netKeys)):
                var isFirst: Bool = True
                var net = netKeys[netIdx]
                writeNL()
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
                else:
                    file.write(String("Net ") + String(netIdx) + " (" + String(net) + "): global net connecting:\n")
                    writeNL()
                    for clb in globalNets[net]:
                        var clbName = clb[][0]
                        var line: String = String("Block ") + String(clbName) + " (#" + String(clbNums[clbName]) + ") at (" + String(archiv[clbName][0]) + ", " +
                           String(archiv[clbName][1]) + "), Pin Class " + String(clb[][1]) + ")\n"
                        """
                        var block: Block.SharedBlock = Block.SharedBlock(Block("Error"))
                        for otherClb in clbMap[archiv[clbName][0], archiv[clbName][1]]:
                            if otherClb[][].name == clbName:
                                block = otherClb[]
                                break
                        if block[].type == Blocktype.CLB:
                            line = line + String(clb[][1])
                        elif block[].type == Blocktype.INPAD:
                            line = line + String(-1)
                        elif block[].type == Blocktype.OUTPAD:
                            line = line + String(-1)
                        else:
                            print("Error Write Net: ", net)
                            return False
                        line = line + ".\n"
                        """
                        file.write(line)
                writeNL()

    except:
        return False

    return True