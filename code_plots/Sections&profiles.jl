#=
Info: The file can make profiles, in a given location, and sections of the model

Input: Output of a simulation (.jld2)
Output: A video (mp4)

References: Script entirely from Oceananigans example, "ocean_wind_mixing_and_convection"

=#
using CairoMakie
using Oceananigans
using GibbsSeaWater

#Load files
path = joinpath(@__DIR__, "..", "code","grids_generation.jl")
filepath_in = joinpath(@__DIR__, "..", "data", "model_data_sim.jld2")

include(path)

#Load the variables and the grid (is the same for TS)
Sa = FieldTimeSeries(filepath_in, "S")
nothing

T = FieldTimeSeries(filepath_in, "T")
nothing

xT, yT, zT = nodes(T)
nothing

##
#1)Make a temperature profile on two setted xy to compare values
t_0=T.data[32,16,:,1]
t_40=T.data[32,16,:,end]
t_40_2=T.data[20,16,:,end]

fig = Figure(resolution=(1200, 800))
ax = Axis(fig[1, 1], ylabel = "Depth (m)", xlabel = "Temperature(C)")
sca1=scatter!(ax, t_40, zT)
sca2=scatter!(ax, t_40_2, zT)
sca0=linesegments!(ax, t_0, zT,linewidth = 0.3)
Legend(fig[1, 2],[sca0,sca1,sca2],["initial","pos1","pos2"])

display(fig)

##2          
#2) Create a transversal section, x, in a fixed t
#note: a meridional section would be the same fixing x and not the y
Tn=reshape(T.data[:,16,:,41],(32,24))

fig = Figure(resolution=(1200, 800))

axis_kwargs = (xlabel="x (m)",
               ylabel="z (m)",
               aspect = AxisAspect(grid.Lx/grid.Lz),
               limits = ((0, grid.Lx), (-grid.Lz, 0)))
#

ax_T  = Axis(fig[1,1]; title = "Temperature at time=X", axis_kwargs...)
hm_T = heatmap!(ax_T,xT, zT,Tn,colormap = :thermal)
Colorbar(fig[1, 2], hm_T; label = "Temperature ᵒC")

display(fig)

##3)
#Create a transversal section evolution in a fixed x (profile of control)
Tn_a=reshape(T.data[30,16,:,:],(24,41))
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