#!/bin/bash

# Erzeugt Mojo Packages, aus den Quellen, im test Verzeichnis
# und führt die Tests aus.
# @author Marvin Wollbrück
magic run mojo package src/myUtil -o test/myUtil.mojopkg
magic run mojo package src/myFormats -o test/myFormats.mojopkg
magic run mojo package src/algorithm -o test/algorithm.mojopkg

#magic run mojo test test/test_Matrix.mojo
#magic run mojo test test/test_PlaceFormat.mojo 
#magic run mojo test test/test_ArchFormat.mojo 