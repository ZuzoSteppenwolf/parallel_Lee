# Vorwort

Dieses Programm wurde für die Veranstaltung "Prakt. Rechnergestützter Entwurf digitaler Systeme" der Fachhochschule Wedel entwickelt. Dabei wurde eine aus drei Aufgaben ausgewählt: Clustering, Platzierung oder Verdrahtung. Diese unterscheiden sich in ihre jeweilige Syntheseschritte und entsprechender Bewertung. Grundsätzlich wird von jeder Aufgabe verlangt, dass ein vorgestellter Algorithmus aus der gleichnamigen Vorlesung, "Rechnergestützter Entwurf digitaler Systeme", ausgewählt wird und mit einer eigenen kreativen Komponente erweitert wird. 

Das fertige Programm wird mit vorgefertigten Benchmarks getestet, analysiert und bewertet. Die Ergebnisse werden mit dem VPR-Programm (Versatile Place and Route), von Vaughn Betz und Jonathan Rose, in der Version 4.30 verglichen. Dabei stehen ingenieurtechnisch-wissenschaftliche Kriterien im Fokus.

Das Programm implementiert den Lee-Algorithmus bzw. Maze-Algorithmus. Als kreative Komponente werden mehrere Netze in Echtzeit parallel verdrahtet. Zudem wurde dies in der noch jungen Programmiersprache Mojo von Modular implementiert.

# Kompilieren

Zur Kompilierung wird eine Umgebung benötigt die [Mojo](https://docs.modular.com/stable/mojo/manual/get-started "Mojo get started") installiert hat.

Ist dies sichergestellt, dann kann das Reporsitory in die Umgebung kopiert werden. Um eine ausführbare Datei zu erzeugen kann die Datei [build.sh](build.sh) genutzt werden. Diese erzeugt eine Datei namens "lee".

# Nutzung

Das Programm liest drei Dateien ein. Einmal die Platzierungsdatei, welche die Matrixgröße und die Platzierungskoordinaten der Ein- und Ausgabepads und der Configurable Logic Block's (CLB), dann die Netzlistedatei, die die Vernetzung der Pads und CLBs wiedergibt, und zuletzt die Architekturdatei, diese gibt Auskunft über die FPGA Architektur, für die verdrahtet werden soll.

Es wird eine Ausgabedatei generiert, die die fertige Kanal-Verdrahtung der Pads und CLBs anhand der Netzliste wiedergibt.

Diese Dateien sind entsprechend der Formate die auch VPR nutzt. Die Details der Formate kann in [manual_430.pdf](manual_430.pdf) von Vaughn Betz nachgeschlagen werden.

Beim ausführen in der Kommandozeile einer Konsole müssen die Pfade der oben beschriebene Dateien in bestimmter Reihenfolge angegeben werden. Zusätzlich können drei Optionen mit angegeben werden.

Durch das Aufrufen der Help-Funktion wird folgendes ausgegeben:
```
$>./lee -h
Usage: ./lee <placments> <netlist> <architecture> <route> [OPTIONS]
    
placments: Path to the placments file
netlist: Path to the netlist file
architecture: Path to the architecture file
route: Path to the output route file

Options:
  -h, --help: Print this help message
  --route_chan_width <int>: Set the channel width for routing
    disabled binary search
  --max_iterations <int>: Set the maximum iterations for the routing
  --single_thread: Run the algorithm in single thread mode
```
Neben der Reihenfolge der Dateipfade, werden auch die Optionen gezeigt.

--route_chan_width <int>
: Mit dies kann eine feste Kanalbreite für das Verdrahten als Ganzzahl angegeben werden. Dabei wird die Binäresuche nach der niedrigsten möglichen Kanalbreite deaktiviert.

--max_iterations <int>
: Hiermit werden die maximale Verdrahtungsversuche pro Kanalbreite als Ganzzahl festgelegt. Standard sind 30 Versuche.

--single_thread
: Diese Option verdrahtet die Netze sequentiell, der Einlese-Reihenfolge, in einem Thread, statt parallel in mehreren Threads.

## Fehlermeldungen

| Fehlermeldung | Erklärung |
| ------------- | --------- |
| Invalid channel width: [X] | Die mitgegebene Kanalbreite ist keine positive Ganzzahl |
| Invalid max iterations: [X] | Die mitgegebene maximale Versuchsanzahl ist keine positive Ganzzahl |
| Invalid placement file | Die Platzierungsdatei entspricht nicht dem Format |
| Architecture file is different from placement file: [placments] != [placments in file] | Die angegebene Architekturdatei unterscheidet sich in der Signatur zur der in der Platzierungsdatei |
| Netlist file is different from placement file: [netlist] != [netlist in file] | Die angegebene Netzlistedatei unterscheidet sich in der Signatur zur der in der Platzierungsdatei |
| Invalid architecture file | Die Architekturdatei entspricht nicht dem Format |
| Multiple subblocks in architecture file are not supported | Es werden keine Cluster unterstützt |
| Fractional channel width not supported, must be 1 | Alle Kanäle müssen die selbe Breite haben |
| Non-uniform channel width are not supported | Alle Kanäle müssen die selbe Breite haben |
| Multiple segments in architecture file are not supported | Nur eine Art Kanalsegment wird unterstützt |
| Multiple switches in architecture file are not supported | Nur ein Switchblocktyp wird unterstützt |
| Longline segments or segments with length > 1 are not supported | Nur Kanäle mit einer Spannweite von 1 CLB unterstützt |
| Fractional switch/connection block are not supported, must be 1 | Nur ein Switchblocktyp wird unterstützt |
| Only subset switch block type are supported | Nur Subset für Switchblocktyp wird unterstützt |
| Only fractional connection between input, output, pad pins and channels are supported | Ábsolute Werte werden nicht unterstützt |
| Only full connection between input, output, pad pins and channels are supported | Alle Pins der Pads und CLBs müssen mit der kompletten Kanalbreite Verbindungsblöcke haben |
| Invalid netlist file | Die Netzlistedatei entspricht nicht dem Format |

## Logs

Das Programm erstellt im Ausführungsverzeichnis ein Log-Verzeichnis. In diesem werden Logs für das einlesen der Dateien und dem Ausführen des Algorithmus erstellt.

Die drei Logs zum Einlesen, geben das Eingelesene wieder. In diesen werden auch Formatfehlern protokolliert.

Im Algorithmus Log (lee) wird der parallele Ablauf protokolliert.