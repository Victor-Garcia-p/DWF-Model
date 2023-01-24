# default water layers
include("model_loop_v2.jl")


SW_layer = WaterLayer(10.0, 37.95, 13.18)
LIW_layer = WaterLayer(20.0, 38.54, 13.38)
WMDW_layer = WaterLayer(grid.Lz, 38.41, 12.71)

DWF(LIW_layer, SW_layer,  WMDW_layer)