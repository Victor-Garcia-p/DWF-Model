#info: overwrite the file created by the model definition with the simulation
#input: "model_data_sim.jld2" (24kB)
#out: "model_data_sim.jld2" (796kB)
#execution time: 320 iterations, 8min 

using Oceananigans
using JLD2

#load the data
@load "D:/Documents/Universidad/TFG/DWC_model/data/model_data_sim.jld2" 


run!(simulation)
