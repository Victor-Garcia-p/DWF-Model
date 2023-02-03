#=
Info: Run this script to perform the simulations using "model_loop_v3" file.

Imput: model_loop_v3.jl (the DWF model splided into functions)
Output: simulations are in format .jld2 (location: DWF_model/data).

the name is created with constants following the formula:
3WM__u₁₀=A_S=SW-LIW-WMDW_dTdz=B_T=SW-LIW-WMDW_dim=C_run=D

where:
u₁₀="A" is the wind speed (m/s^2) at 10m of the surface
S= Salinity (PSU) of each water mass separed with "-" 
dTdz="B" is a gradient of temperature (°C/m), the rate which water cools in depth
T= Temperature (°C) of each water mass separed with "-" 
dim=dimension of the simulation (2D or 3D)
run=simulation time (s)
=#

include("model_loop_v3.jl")

SW_layer = WaterLayer(10.0, 35.0, 13.18)    
LIW_layer = WaterLayer(20.0, 35.0, 13.38)
WMDW_layer = WaterLayer(grid.Lz, 35.0, 12.71)


layers = [SW_layer,LIW_layer,WMDW_layer]        #how many layers has the model?


#set the value of a constant for each simulation. If its not specified is taken as 
#defauld value. To perform more simulations just add another dictionary
#ex: Dict(:u₁₀=>15) to create a simulation with u₁₀=>15 m/s and other values as defauld

keyword_arguments = [Dict(:u₁₀=>15, :dTdz=>0.04) 
                                          ]
#

for kwargs in keyword_arguments
    build_model(layers;kwargs...)
    build_simulation_name(params,"t")
    prepare_simulation!(params,model)
    
    run!(simulation)
end

