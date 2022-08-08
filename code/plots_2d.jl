#1)Load the requirements

using JLD2
using CairoMakie

#define the path and load the variables
path = joinpath(@__DIR__, "grids_generation.jl")
filepath_in= joinpath(@__DIR__, "..", "data","model_data_sim.jld2")

if isfile(path)
    include(path)
else
    # Put an error message
    error("Missing grid file") 
end

#load the data
T = FieldTimeSeries(filepath_in,"T")
S = FieldTimeSeries(filepath_in, "S")

xT, yT, zT = nodes(T)

##
#2)Make a profile
t_0=T.data[32,16,:,1]
t_40=T.data[32,16,:,41]
t_40_2=T.data[20,16,:,41]

fig = Figure(resolution=(1200, 800))
ax = Axis(fig[1, 1], ylabel = "Depth (m)", xlabel = "Temperature(C)")
sca1=scatter!(ax, t_40, zT)
sca2=scatter!(ax, t_40_2, zT)
sca0=linesegments!(ax, t_0, zT,linewidth = 1)

Legend(fig[1, 2],[sca0,sca1,sca2],["initial","pos1","pos2"])

display(fig)

##
#3) Create a TS diagrame

TS = Figure(resolution=(1200, 800))
ax = Axis(TS[1, 1], ylabel = "Temperature(°C)", xlabel = "Salinity(psu)")
ax.title="Diagrame TS"

sca1=scatter!(ax, S.data[32,16,:,41], T.data[32,16,:,41],color=zT,markersize = 20,colormap=:thermal)
Colorbar(TS[1, 2], limits = (-30,0),ticks = -30:6:0,
    colormap = cgrad(:thermal, 5, categorical = true), size = 25,
    label = "Depth(m)")
#
display(TS)

##          
#4) Create a transversal section, x, in a fixed t
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

##
#4) Create a transversal section evolution in a fixed x (profile of control)
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