#!/bin/bash

# Führt die Tests aus
# @author Marvin Wollbrück

pixi run mojo test -I src test

#pixi run mojo test -I src test/myUtil
#pixi run mojo test -I src test/myUtil/test_Logger.mojo 
#pixi run mojo test -I src test/myUtil/test_Block.mojo
#pixi run mojo test -I src test/myUtil/test_Matrix.mojo
#pixi run mojo test -I src test/myUtil/test_Util.mojo

#pixi run mojo test -I src test/myFormats
#pixi run mojo test -I src test/myFormats/test_ArchFormat.mojo
#pixi run mojo test -I src test/myFormats/test_NetFormat.mojo
#pixi run mojo test -I src test/myFormats/test_PlaceFormat.mojo
#pixi run mojo test -I src test/myFormats/test_RouteFormat.mojo

#pixi run mojo test -I src test/myAlgorithm
#pixi run mojo test -I src test/myAlgorithm/test_Lee.mojo
