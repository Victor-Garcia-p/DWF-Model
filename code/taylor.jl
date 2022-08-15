#info: DIAGRAME OF TAYLOR
#note: part of the script was based on https://github.com/JuliaPlots/Makie.jl/issues/521)

#0)Load the packages and the data
using CairoMakie
using StatsBase

##
#Load simulation files to plot
filepath_in= joinpath(@__DIR__, "..", "data","model_data_v_10_sim.jld2")
filepath_in_2= joinpath(@__DIR__, "..", "data","model_data_v_20_sim.jld2")

#Load the data (temperature perfile of a simulation in a setted location)
t_20=T_10.data[32,16,:,21]
t_20_2=T_20.data[32,16,:,21]

#Calculate de standard desviation
σᵣ=std(t_20)
σf=std(t_20_2)

#Calculate the Pearson coeficient
R=cor(t_20,t_20_2)

#Calculate the root-mean-square deviation, RMSD
Eⁱ=rmsd(t_20,t_20_2)

##MAKE THE GRAPH
#0)Set some TEST values
σᵣ=1          #Standard desviation of a reference simulation
σf=1.16          #Standard desviation of a simulation "f"
Eⁱ=1.5            #Root-mean-square deviation, RMSD (0 to 1)
R=0.05           #Pearson correlation (0 to 1)

#0.1)Convert values into axial coordinates (xy) using cosine theorem
ϕ=acos((σf^2+σᵣ^2-Eⁱ^2)/(2*σf*σᵣ))

x=[σᵣ,σf*cos(ϕ)]
y=[0,σf*sin(ϕ)]

#1)Set the dimensions of the figure
limits=[-0.2,2,-0.15,2]   #limits of the box that contains the plot (invisible)
ticks=0:0.5:2                 #x&y error ticks
R=1.6                         #Radium of the sphere 

f = Figure()
ax = Axis(f[1, 1],ylabel = "Error", xlabel = "Error",title = "Test plot", xticks = ticks,
yticks = ticks)
limits!(ax, BBox(limits[1],limits[2],limits[3],limits[4]))

#2)Make the Eⁱ contours, based on coordinates of reference
rs_2 = range(0,R, length = 5)

for r in rs_2
    lines!(Circle(Point2f(x[1],y[1]), r), color = :blue)
end

#3)Create the radial lines, the values are the Correlation values 
#that are more interesting (ex: correlation of 1, 0.99 or 0)
E=[0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.95,0.99,1]
α=acos.(E)

for Er in α
    x_2=abs(cos(Er)*R)
    y_2=abs(sin(Er)*R)
    lines!(ax, Point2f(0,x_2),Point2f(0,y_2), 
    linestyle = :dash, linewidth = 0.5,color = :red)
end

#4.1)Put a white polygon above the contours that are more far than the R
xx=cos.(α)*R
yy=sin.(α)*R
poly!(Point2f[(limits[2],limits[1]),(limits[4],limits[2]),
(limits[3],limits[4]),(xx[1],yy[1]),(xx[2],yy[2]),(xx[3],yy[3]),(xx[4],yy[4]),(xx[5],yy[5]),
(xx[6],yy[6]),(xx[7],yy[7]),(xx[8],yy[8]),(xx[9],yy[9]),(xx[10],yy[10]),(xx[11],yy[11]),
(xx[12],yy[12]),(xx[13],yy[13])],
color = :white,strokecolor = :white, strokewidth = 1)

#4.2)Another polygon, that is used if the box had values -0
lon=2      #longitude of the second polygon
poly!(Point2f[(0,0),(limits[2],0),(limits[2],-lon),(-lon,-lon),
(-lon,limits[4]),(0,limits[4])],
color = :white,strokecolor = :white, strokewidth = 1)

#5)Locate the simulation points values of reference and the the simulation f
scatter!(ax,x,y,marker = ['X','O'],markersize =20)

#6)Make the contours of the error,σ, starts on 0.0
rs = range(0,R, length = 5)

for r in rs
    lines!(ax, Circle(Point2f(0), r), color = :lightgray)
end

#7)Add text to the radials (script adapted from https://github.com/JuliaPlots/Makie.jl/issues/521)
rborder = R

for θ in α[1:end]
    offset = rborder * 0.1
    xpos = (rborder + offset) * cos(θ)
    ypos = (rborder + offset) * sin(θ)
    text!("$(round(cos.(θ);digits=2))", position = (xpos, ypos), align = (:center, :center))
end

#8)Create a decorative Black contour line at the radium of the circle 
perimeter=lines!(ax,Circle(Point2f(0), R+2/R),color = :black)

#9)Hide the spines and the grid of the figure
hidespines!(ax)
hidedecorations!(ax,grid = true,label = false, 
ticklabels = false, ticks = false, minorgrid = false, minorticks = false)

#10)Make the x&y axis line that has been removed in 8
lines!(ax, Point2f(0,0),Point2f(0,R),linestyle = :dash, 
linewidth = 2,color = :blue)

lines!(ax, Point2f(0,R),Point2f(0,0),linestyle = :dash, 
linewidth = 2,color = :blue)

#11)Display the figure
display(f)

#save("Taylor_test.png",f)