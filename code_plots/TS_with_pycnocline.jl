#=
Info: The file contains all the script to create TS diagram with
picnoclines. Although the picnoclines are coded it

Input: Data from simulation (.jld2)
Output: a plot in the screen

References: Picnoclines are based in 
https://discourse.julialang.org/t/makie-jl-plotting-contour-with-fillrange-true-above-lines/39830/5
=#

using CairoMakie
using Oceananigans
using GibbsSeaWater

#Load files
path = joinpath(@__DIR__, "..", "code","grids_generation.jl")
filepath_in = joinpath(@__DIR__, "..", "data", "model_data_sim.jld2")

include(path)

#Load variables
Sa = FieldTimeSeries(filepath_in, "S")
nothing

T = FieldTimeSeries(filepath_in, "T")
nothing

xT, yT, zT = nodes(T)
nothing

##
#Create a TS diagrame

TS = Figure(resolution=(1200, 800))
ax = Axis(TS[1, 1], ylabel = "Temperature(°C)", xlabel = "Salinity(psu)")
ax.title="Diagrame TS"

sca1=scatter!(ax, Sa.data[32,16,:,41], T.data[32,16,:,41],color=zT,markersize = 20,colormap=:thermal)
Colorbar(TS[1, 2], limits = (-30,0),ticks = -30:6:0,
colormap = cgrad(:thermal, 5, categorical = true), size = 25,
label = "Depth(m)")

display(TS)


##Add isopicnals
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