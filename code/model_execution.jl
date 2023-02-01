include("model_loop_v3.jl")

SW_layer = WaterLayer(grid.Lz, 35.0, 20.0)
#LIW_layer = WaterLayer(20.0, 35.0, 20.0-10.0*0.01)
#WMDW_layer = WaterLayer(grid.Lz, 35.0, 15.0-20.0*0.01)


layers = [SW_layer]

keyword_arguments = [Dict(:u₁₀=>10, :dTdz=>0.01)]
#

build_model(layers)
build_simulation_name(params,"t")
prepare_simulation!(params,model)

run!(simulation)
