using CairoMakie
using Oceananigans
using GibbsSeaWater

##SINGLE SIMULATION PLOTS
#model_data_sim.jld2
##0
#0)Define the path and load
path = joinpath(@__DIR__, "grids_generation.jl")
filepath_in= joinpath(@__DIR__, "..", "data","model_data_sim.jld2")

if isfile(path)
    include(path)
else
    # Put an error message
    error("Missing grid file") 
end

#load 
Sa = FieldTimeSeries(filepath_in, "S")
nothing

T = FieldTimeSeries(filepath_in, "T")
nothing

xT, yT, zT = nodes(T)
nothing

#σ0 = gsw_sigma0.(Sa.data,T.data)
#nothing

##Adding isopicnals and text layers to any other plot
T_interest=collect(15:12/100:27)
S_interest=collect(34:3/100:37)

#T_interest = range(-1, 20, length=100)
#S_interest = range(33.5, 36.5, length=100)
#zs = [ gsw_sigma0.(T,S) for T in T_interest, S in S_interest]

T_trans_1=collect(Iterators.flatten(T_interest))
S_trans_1=collect(Iterators.flatten(S_interest))

Column_1=fill(1, (1,length(T_interest)))
Row_1=fill(1,(length(S_interest), 1))

T_trans_2 = reverse(T_trans_1)
S_trans_2 = transpose(S_trans_1)

σ=reverse(transpose(gsw_sigma0.(Row_1*S_trans_2,T_trans_2*Column_1)),dims = 2)

fig=Figure()
ax=Axis(fig[1, 1], xgridcolor = :black,
ygridcolor = :black,
xgridwidth = 1,
ygridwidth = 1)
limits!(ax, 34,37,15,27)

#fig, ax, hm = heatmap(S_trans_1,T_trans_1,σ)

lev=23:0.5:26
test=collect(lev)

con=contour!(S_trans_1,T_trans_1,σ,levels=lev,linewidth=5,
colormap=:reds)

beginnings = Point2f0[]; colors = RGBAf0[]
# First plot in contour is the line plot, first arguments are the points of the contour

segments = con.plots[1][1][]
for (i, p) in enumerate(segments)

    # the segments are separated by NaN, which signals that a new contour starts
    if isnan(p)
        push!(beginnings, segments[i-50])
    end
end

sc = scatter!(ax, beginnings, markersize=30, color=(:white, 1), strokecolor=:white)

#Prepare the coords to add text

vv=hcat(beginnings...)'
vvv=convert(Matrix, vv)

#Loop to locate the text
max=size(vvv,1)

for i in 1:max
    text!("$(round(test[i];digits=2))",position =(vvv[i,1],vvv[i,2]),  align = (:center, :center))
end

#anno = text!(ax, [(string(float(i)), Point3(p..., 2f0)) for (i, p) in enumerate(beginnings)], 
#align=(:center, :center), color=:black)

Colorbar(fig[:, end+1], con)

fig

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
#2) Create a TS diagrame

TS = Figure(resolution=(1200, 800))
ax = Axis(TS[1, 1], ylabel = "Temperature(°C)", xlabel = "Salinity(psu)")
ax.title="Diagrame TS"

sca1=scatter!(ax, Sa.data[32,16,:,41], T.data[32,16,:,41],color=zT,markersize = 20,colormap=:thermal)
Colorbar(TS[1, 2], limits = (-30,0),ticks = -30:6:0,
colormap = cgrad(:thermal, 5, categorical = true), size = 25,
label = "Depth(m)")

display(TS)



##3          
#3) Create a transversal section, x, in a fixed t
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


##COMPARATIVE PLOTS

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