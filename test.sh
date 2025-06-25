#!/bin/bash

# Führt die Tests aus
# @author Marvin Wollbrück

magic run mojo test -I src test

#magic run mojo test -I src test/myUtil
#magic run mojo test -I src test/myUtil/test_Logger.mojo 
#magic run mojo test -I src test/myUtil/test_Block.mojo
#magic run mojo test -I src test/myUtil/test_Matrix.mojo
#magic run mojo test -I src test/myUtil/test_Util.mojo

#magic run mojo test -I src test/myFormats
#magic run mojo test -I src test/myFormats/test_ArchFormat.mojo
#magic run mojo test -I src test/myFormats/test_NetFormat.mojo
#magic run mojo test -I src test/myFormats/test_PlaceFormat.mojo
magic run mojo test -I src test/myFormats/test_RouteFormat.mojo

#magic run mojo test -I src test/myAlgorithm
#magic run mojo test -I src test/myAlgorithm/test_Lee.mojo