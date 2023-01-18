#=
Info: The file can make profiles, in a given location, and sections of the model

Input: Output of a simulation (.jld2)
Output: A video (mp4)

References: Script entirely from Oceananigans example, "ocean_wind_mixing_and_convection"

=#
using DrWatson
using CairoMakie
using Oceananigans
using GibbsSeaWater

#load the local environment not the global which is defauld in Julia
@quickactivate "DWC_model" 
include("plots_functions.jl")

#names of the files that we want to use (without .jld2)
load_variable("test_def")    

##
#1)Make a temperature profile on two setted xy to compare values
t_0=T[1].data[32,2,:,1]
#t_40=T[1].data[32,16,:,end]
#t_40_2=T[1].data[20,16,:,end]

fig = Figure(resolution=(1200, 800))
ax = Axis(fig[1, 1], ylabel = "Depth (m)", xlabel = "Temperature(C)",
title = "Secció a t=40min variant la magnitud del vent (=condicions inicials)")

sca1=scatter!(ax, T_plot[5], zT)
sca2=scatter!(ax, T_plot[10], zT)
sca0=linesegments!(ax, t_0, zT,linewidth = 0.3)

axislegend(ax,[sca0,sca1,sca2],["Initial situation","5","10"],"Modul velocitat vent (m/s)",
position = :rb,orientation = :horizontal)

display(fig)

##2          
#2) Create a section, x, in a fixed t
#note: a meridional section would be the same fixing x and not the y

Tn=reshape(T.data[:,16,:,1],(32,24))
#Sn=reshape(Sa.data[:,12,:,11],(32,32))

#σ=gsw_sigma0.(Sa.data[:,:,:,21],T.data[:,:,:,21])

fig = Figure(resolution=(1200, 800))

axis_kwargs = (xlabel="x (m)",
               ylabel="z (m)")
#

ax_T  = Axis(fig[1,1]; title = "Temperature at time=X", axis_kwargs...)
hm_T = heatmap!(ax_T,xT, zT,Tn,colormap = :thermal)
Colorbar(fig[1, 2], hm_T; label = "Temperature ᵒC")

#problems with rg
#rg=range(σ,7)
#isovariable_test(ax_T,xT, yT,σ,24.71:0.001:24.73)

display(fig)

##3)
#Create a transversal section evolution in a fixed x (profile of control)
Tn_a=reshape(T[1].data[30,16,:,:],(24,41))
Tn=transpose(Tn_a)

fig = Figure(resolution=(1200, 800))

axis_kwargs = (xlabel="Time (s)",
               ylabel="z (m)",
               aspect = AxisAspect(grid.Lx/grid.Lz))
              
#

ax_T  = Axis(fig[1,1]; title = "Temperature evolution at a fixed location", 
    axis_kwargs...)
hm_T = heatmap!(ax_T,T.times, zT,Tn,colormap = :thermal)
Colorbar(fig[1, 2], hm_T; label = "Temperature ᵒC")

display(fig)