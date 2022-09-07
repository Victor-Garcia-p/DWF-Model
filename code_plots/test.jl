using CairoMakie
using Oceananigans
using GibbsSeaWater

include("plots_functions.jl")

#names of the files that we want to use (without .jld2)
load_variable("model_data_3Dgrid_t40_sim")    

##
Tn=reshape(T.data[:,:,1,41],(32,32))

fig = Figure(resolution=(1200, 800))

axis_kwargs = (xlabel="x (m)",
               ylabel="z (m)")
#

ax_T  = Axis(fig[1,1]; title = "Temperature at time=X", axis_kwargs...)
hm_T = heatmap!(ax_T,xT, yT,Tn,colormap = :thermal)
Colorbar(fig[1, 2], hm_T; label = "Temperature ᵒC")

display(fig)

