##
#5)Diagrame of Taylor

#1)Load the requirements

using JLD2
using CairoMakie

#define the path and load the variables
path = joinpath(@__DIR__, "grids_generation.jl")

filepath_in= joinpath(@__DIR__, "..", "data","model_data_v_10_sim.jld2")
filepath_in_2= joinpath(@__DIR__, "..", "data","model_data_v_20_sim.jld2")

if isfile(path)
    include(path)
else
    # Put an error message
    error("Missing grid file") 
end

#load the data for simulation 1&2
T_10 = FieldTimeSeries(filepath_in,"T")
T_20 = FieldTimeSeries(filepath_in_2,"T")

#Nodes do not change because the grid is the same
xT, yT, zT = nodes(T_10)

##
#2)Make a comparative profile of both simulations at the same location
t_20=T_10.data[32,16,:,21]
t_20_2=T_20.data[32,16,:,21]

fig = Figure(resolution=(1200, 800))
ax = Axis(fig[1, 1], ylabel = "Depth (m)", xlabel = "Temperature(C)")
sca1=scatter!(ax, t_20, zT)
sca2=scatter!(ax, t_20_2, zT)

Legend(fig[1, 2],[sca1,sca2],["v_10","v_20"])

display(fig)

##
#Calculate de standard desviation
using StatsBase
v10_std=std(t_20)
v20_std=std(t_20_2)

#Calculate the Pearson coeficient
Pear=cor(t_20,t_20_2)

#Calculate the root-mean-square deviation, RMSD
error=rmsd(t_20,t_20_2)
