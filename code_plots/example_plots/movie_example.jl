#=
Info: Example from README to learn how to make a movie (similar to a section)

Input: Simulations (.jld2) located at "DWF_model\data"
Output: A video (.mp4) located at "DWF_model\Plots_out\Simulations"
=#

using DrWatson
@quickactivate

include(joinpath(@__DIR__, "..", "plots_functions.jl"))
include(joinpath(@__DIR__, "..", "..", "code_model/grid_generation.jl"))

file_names=["3WM2_u₁₀=30_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=645000.0"]

results = load_simulation.(file_names)

#select variables to plot
movie_arguments = Dict(:variables=>[:w,:T,:Sa,:νₑ])

for i in eachindex(file_names)
    movie_AOU(i;movie_arguments...)
    movie_name(file_names[i])
    build_movie()
    record_movie()

end

