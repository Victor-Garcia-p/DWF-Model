#=
Info: This scripts is used to set the model with data of a buoi (NCD). It creates n layers ("WaterLayer"), for a given time, 
in all the points where there is data of Temperature and Salinity on the buoi.

Input: data from buoi (located at DWF-Model\data\Lion_mooring) and files of the model (code_model folder)
Output: a simulation (.jld2) with the parameters defined by the user or taken as default (from model_functions)

References: Buoi data from LION observatory data (Bosse et al., 2023)
https://www.seanoe.org/data/00333/44411/
DOI=10.17882/44411
=#

using DrWatson
@quickactivate

include(projectdir("code_plots","plots_functions.jl"))
include(projectdir("code_model","model_functions.jl"))
include("plots_functions2.jl")


data=load_NCF("OS_LION_2013_D_30min.nc")

#ID station: 6837 = 15-12-12
#ID station: 8325 = 15-01-13
#ID station: 9141 = 01-02-13 

AOI=AOI_NCF(data,6837)

#find depths that has values of T and S and are less that 1100m (default max index)
layers=create_layers(data,6837)
SW_layer=layers[1]

##
#Set the value of a constant for each simulation. If it’s not specified is taken as default
#To perform more simulations, add another dictionary 
#ex: Dict (:u₁₀=>15) to make a simulation with u₁₀=15 m/s and other values as default

model_arguments = [Dict(:u₁₀=>25.0, :dTdz=>0.00)  
                                          ]
#

simulation_arguments= [Dict(:t=>43200minutes)]

for kwargs in model_arguments, kwargs2 in simulation_arguments
    build_model(layers;kwargs...,kwargs2...)
    prepare_simulation!(params,model;kwargs2...)
    
    run!(simulation)
end


