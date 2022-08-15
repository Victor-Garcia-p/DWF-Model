##
#5)Diagrame of Taylor

#1)Load the requirements

using JLD2
using CairoMakie
using StatsBase

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
#Load the data
t_20=T_10.data[32,16,:,21]
t_20_2=T_20.data[32,16,:,21]

#Calculate de standard desviation
σr=std(t_20)
σf=std(t_20_2)

#Calculate the Pearson coeficient
E=cor(t_20,t_20_2)

#Calculate the root-mean-square deviation, RMSD
error=rmsd(t_20,t_20_2)

#make the graph

θdata = 0:0.1:2π
rdata = 10 .* sin.(2*θdata)

rs = range(1, round(maximum(rdata)), length = 4)
θs = 0:π/4:2π
rborder = maximum(rs) * 1.10

f = Figure()
ax = Axis(f[1, 1], aspect = 1.0)

for r in rs
    lines!(ax, Circle(Point2f(0), r), color = :lightgray)
end

lines!(ax, Circle(Point2f(0), rborder), color = :lightgray)

radiallines = zeros(Point2f, 2 * length(θs))

for (i, θ) in enumerate(θs)
    radiallines[i*2] = Point2f(rborder * cos(θ), rborder * sin(θ))
end

linesegments!(ax, radiallines, color = :lightgray)

for r in rs
    text!("$(r)", position = (r, 0), align = (:center, :bottom))
end

for θ in θs[1 : end-1]
    offset = rborder * 0.1
    xpos = (rborder + offset) * cos(θ)
    ypos = (rborder + offset) * sin(θ)
    text!("$(Int64(θ * 180/π))°", position = (xpos, ypos), align = (:center, :center))
end

lines!(ax, rdata .* cos.(θdata), rdata .* sin.(θdata))
hidespines!(ax)
hidedecorations!(ax)

display(f)
