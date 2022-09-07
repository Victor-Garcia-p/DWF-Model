#=
Info: The file compares the profiles of of diferents simulations in sections or profiles.
The two simulations must have the same lengh 

Input: Grid file (.jl)
Output: A plot printed on screen

References: ...
=#
using CairoMakie
using Oceananigans
using GibbsSeaWater

include("plots_functions.jl")

#names of the files that we want to use (without .jld2)
names=["model_data_v_10_sim","model_data_v_20_sim"]
load_variable(names)    

##
#1)Make a comparative profile of both simulations at the same location
t_20=T[1].data[32,16,:,21]
t_20_2=T[2].data[32,16,:,21]

fig = Figure(resolution=(1200, 800))
ax = Axis(fig[1, 1], ylabel = "Depth (m)", xlabel = "Temperature(C)")
sca1=scatter!(ax, t_20, zT)
sca2=scatter!(ax, t_20_2, zT)

Legend(fig[1, 2],[sca1,sca2],["v_10","v_20"])

display(fig)