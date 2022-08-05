#info: overwrite the file created by the model definition with the simulation
#input: "model_data_sim.jld2" (24kB)
#out: "model_data_sim.jld2" (796kB)
#execution time: 320 iterations, 8min 

#NOTE: THE FILE IS NOT WORKING

using Oceananigans
using JLD2

#Define the path of the data files
path = joinpath(@__DIR__, "..", "data")

#Load the grid
file=joinpath(path,"model_data_sim.jld2")

if isfile(file)
    @load file grid coriolis buoyancy closure serialized timeseries
    @load "simulation.jld2" simulation
else
    # Put an error message
    error("Missing grid file") 
end


run!(simulation)
