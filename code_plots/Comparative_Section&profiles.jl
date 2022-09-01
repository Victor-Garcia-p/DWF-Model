#=
Info: The file compares the profiles of of diferents simulations in sections or profiles.
The two simulations must have the same lengh 

Input: Grid file (.jl)
Output: A plot printed on screen

References: ...
=#
using CairoMakie
using Oceananigans

##
#6)Make a comparative profile of both simulations at the same location

#define the path and load the variables
filepath_in= joinpath(@__DIR__, "..", "data","model_data_v_10_sim.jld2")
filepath_in_2= joinpath(@__DIR__, "..", "data","model_data_v_20_sim.jld2")

#load the data for simulation 1&2
T_10 = FieldTimeSeries(filepath_in,"T")
T_20 = FieldTimeSeries(filepath_in_2,"T")

#Nodes do not change because the grid is the same
xT, yT, zT = nodes(T_10)

#2)Make a comparative profile of both simulations at the same location
t_20=T_10.data[32,16,:,21]
t_20_2=T_20.data[32,16,:,21]

fig = Figure(resolution=(1200, 800))
ax = Axis(fig[1, 1], ylabel = "Depth (m)", xlabel = "Temperature(C)")
sca1=scatter!(ax, t_20, zT)
sca2=scatter!(ax, t_20_2, zT)

Legend(fig[1, 2],[sca1,sca2],["v_10","v_20"])

display(fig)