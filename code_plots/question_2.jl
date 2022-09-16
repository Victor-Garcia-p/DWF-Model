using CairoMakie
using Oceananigans
using GibbsSeaWater

include("test_funct.jl")
load_variable() 

Tn=reshape(T.data[:,16,:,40],(32,24))

fig = Figure(resolution=(1200, 800))

axis_kwargs = (xlabel="x (m)", ylabel="z (m)")

ax_T  = Axis(fig[1,1]; title = "Temperature at time=X", axis_kwargs...)
hm_T = heatmap!(ax_T,xT, zT,Tn,colormap = :oxy)

#Try to change to 3 and it will not work
ran=range(Tn,5)

#depending on the interval it work or not
#1)Try 19.7:0.01:30 it does not have sense, the max value is 19.952
#2)Try -1:0.01:30. It just starts with -1, so text do not match contours

isovariable_test(ax_T,xT, zT,Tn,ran)

Colorbar(fig[1, 2], hm_T; label = "Temperature ᵒC")

display(fig)