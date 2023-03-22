#=
Info: Example from README to learn how to make a movie (similar to a section)

Imput: Simulations (.jld2) located at "DWF_model\data"
Output: A video (.mp4) located at "DWF_model\Plots_out\Simulations"
=#

using DrWatson
@quickactivate

include(joinpath(@__DIR__, "..", "plots_functions.jl"))
include(joinpath(@__DIR__, "..", "..", "code_model/grid_generation.jl"))

file_names=["3WM_u₁₀=15_S=35.0-35.0-35.0_dTdz=0.04_T=13.18-13.38-12.71_dim=2D_t=1200.0",
"3WM_u₁₀=0_S=37.95-38.54-38.41_dTdz=0.01_T=13.18-13.38-12.71_dim=2D_t=86400.0"]

results = load_files.(file_names)

#select variables to plot
movie_arguments = Dict(:variables=>[:w,:T,:Sa,:νₑ])

for i in eachindex(file_names)
    movie_AOU(i;movie_arguments...)
    movie_name(file_names[i])
    build_movie()
    record_movie()

end

