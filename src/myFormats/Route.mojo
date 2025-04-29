from collections import Dict, List
from myUtil.Block import Block
from myUtil.Enum import *
from myUtil.Matrix import Matrix
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
    netKeys: List[String], pins: List[Pin], clbMap: Matrix[List[Block.SharedBlock]], 
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
                        line = String("  IPIN (").join(block[].coord[0]).join(",").join(block[].coord[1]).join(")  Pin: ").join(netPins[net][block[].name]).join("\n")
                        file.write(line)
                        line = String("  SINK (").join(block[].coord[0]).join(",").join(block[].coord[1]).join(")  Class: ").join(pins[netPins[net][block[].name]].pinClass).join("\n")
                        file.write(line)
                    else:
                        if isFirst:
                            line = String("SOURCE (").join(block[].coord[0]).join(",").join(block[].coord[1]).join(")  Class: ").join(pins[netPins[net][block[].name]].pinClass).join("\n")
                            file.write(line)

                        line = String("  OPIN (").join(block[].coord[0]).join(",").join(block[].coord[1]).join(")  Pin: ").join(netPins[net][block[].name]).join("\n")
                        file.write(line)
                except e:
                    print("Error writing CLB: ", e)

            @parameter
            fn writePad(isSink: Bool, block: Block.SharedBlock, isFirst: Bool = False):
                var line: String = ""
                if isSink:
                    line = String("  IPIN (").join(block[].coord[0]).join(",").join(block[].coord[1]).join(")  Pad: ").join(block[].subblk).join("\n")
                    file.write(line)
                    line = String("  SINK (").join(block[].coord[0]).join(",").join(block[].coord[1]).join(")  Pad: ").join(block[].subblk).join("\n")
                    file.write(line)
                else:
                    if isFirst:
                        line = String("SOURCE (").join(block[].coord[0]).join(",").join(block[].coord[1]).join(")  Pad: ").join(block[].subblk).join("\n")
                        file.write(line)

                    line = String("  OPIN (").join(block[].coord[0]).join(",").join(block[].coord[1]).join(")  Pad: ").join(block[].subblk).join("\n")
                    file.write(line)

            @parameter
            fn writeChan(block: Block.SharedBlock):
                var line: String = ""
                if block[].type == Blocktype.CHANX:
                    line = String(" CHANX (").join(block[].coord[0]).join(",").join(block[].coord[1]).join(")  Track: ").join(block[].subblk).join("\n")
                    file.write(line)
                elif block[].type == Blocktype.CHANY:
                    line = String(" CHANY (").join(block[].coord[0]).join(",").join(block[].coord[1]).join(")  Track: ").join(block[].subblk).join("\n")
                    file.write(line)

            file.write(String("Array size: ").join(clbMap.cols-2).join(" x ").join(clbMap.rows-2).join(" logic blocks.\n"))
            writeNL()
            file.write("Routing:\n")
            

            for netIdx in range(len(netKeys)):
                var isFirst: Bool = True
                var net = netKeys[netIdx]
                writeNL()
                if net in routeLists:
                    file.write(String("Net ").join(netIdx).join(" (").join(net).join(")\n"))
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
                    file.write(String("Net ").join(netIdx).join(" (").join(net).join("): global net connecting:\n"))
                    writeNL()
                    for clb in globalNets[net]:
                        var clbName = clb[][0]
                        var line: String = String("Block ").join(clbName).join(" (#").join(clbNums[clbName]).join(") at (").join(archiv[clbName][0]).join(", ").
                           join(archiv[clbName][1]).join("), Pin Class ").join(clb[][1]).join(")\n")
                        """
                        var block: Block.SharedBlock = Block.SharedBlock(Block("Error"))
                        for otherClb in clbMap[archiv[clbName][0], archiv[clbName][1]]:
                            if otherClb[][].name == clbName:
                                block = otherClb[]
                                break
                        if block[].type == Blocktype.CLB:
                            line = line.join(clb[][1])
                        elif block[].type == Blocktype.INPAD:
                            line = line.join(-1)
                        elif block[].type == Blocktype.OUTPAD:
                            line = line.join(-1)
                        else:
                            print("Error Write Net: ", net)
                            return False
                        line = line.join(".\n")
                        """
                        file.write(line)
                writeNL()

    except:
        return False

    return True