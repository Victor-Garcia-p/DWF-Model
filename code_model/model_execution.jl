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

include("model_functions.jl")

SW_layer = WaterLayer(10.0, 37.95, 13.18)
LIW_layer = WaterLayer(20.0, 38.54, 13.38)
WMDW_layer = WaterLayer(grid.Lz, 38.41, 12.71)

layers = [SW_layer,LIW_layer,WMDW_layer]        #how many layers has the model?


#Set the value of a constant for each simulation. If it’s not specified is taken as default
#To perform more simulations, add another dictionary 
#ex: Dict (:u₁₀=>15) to make a simulation with u₁₀=15 m/s and other values as default

model_arguments = [Dict(:u₁₀=>0, :dTdz=>0.01) 
                                          ]
#

simulation_arguments= [Dict(:t=>1440minutes)]

for kwargs in model_arguments, kwargs2 in simulation_arguments
    build_model(layers;kwargs...,kwargs2...)
    prepare_simulation!(params,model;kwargs2...)
    
    run!(simulation)
end

