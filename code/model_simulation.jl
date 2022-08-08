#info: overwrite the file created by the model definition with the simulation
#input: "model_data_sim.jld2" (24kB)
#out: "model_data_sim.jld2" (796kB)
#execution time: 320 iterations, 8min 

using Oceananigans

#Load the grid
file="model_definition.jl"

if isfile(file)
    include(file)
else
    # Put an error message
    error("Missing file") 
end

##
run!(simulation)
