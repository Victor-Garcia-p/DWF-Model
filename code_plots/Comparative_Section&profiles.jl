#=
Info: The file compares the profiles of of diferents simulations in sections or profiles.
all the simulations must have the same lenght

Input: simulation data (.jld2)
Output: A plot printed on screen

=#

using CairoMakie
using Oceananigans
using GibbsSeaWater
using DrWatson

@quickactivate

include("plots_functions.jl")
include(projectdir("code", "constants.jl"))

#names of the files that we want to use (without .jld2)
#names=["model_data_v_10_sim","model_data_v_20_sim"]

files = Any[]
name_concatenation(1, 10)

load_file(files)

#1)Make a comparative profile of both simulations at the same location
#load_AOI(32, 2, :, 41, 1, 10, "S") #"T_plot" variable is defined with all the simulations

##
fig = Figure(resolution = (1200, 800))
ax = Axis(
    fig[1, 1],
    ylabel = "Profunditat (m)",
    xlabel = "Temperatura(C)",
    xticks = 19.6:0.05:20,
    title = "Perfil a t=40min variant la magnitud del vent (=condicions inicials)",
)
sca1 = scatter!(ax, T_plot[1], zT, marker = :rect, markersize = 18)
#sca2=scatter!(ax, T_plot[3], zT)
sca3 = scatter!(ax, T_plot[5], zT, marker = :dtriangle, markersize = 20)
#sca4=scatter!(ax, T_plot[8], zT)
sca5 = scatter!(ax, T_plot[10], zT, markersize = 13)

axislegend(
    ax,
    [sca1, sca3, sca5],
    ["1", "5", "10"],
    "Modul velocitat vent (m/s)",
    position = :rb,
    orientation = :horizontal,
)
display(fig)

