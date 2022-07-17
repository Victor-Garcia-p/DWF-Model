#info: overwrite the file created by the model definition with the simulation
#input: "model_data.jld2" (24kB)
#out: "model_data.jld2" (796kB)
#execution time: 320 iterations, 8min 

using Oceananigans
using JLD2

@load "model_data.jld2"

run!(simulation)
