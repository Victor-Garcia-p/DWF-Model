
function profile(
    x=variable_plot,
    y=results[1][:zT],
    dim=[1,1],
    overwrite=false
    )

    if dim==[1,1] && overwrite==true
        global fig = Figure()
    end

    fig[dim[1],dim[2]] = GridLayout()

    ax=Axis(fig[dim[1],dim[2]])

    profile_lines=Any[]

    for i in eachindex(x)

        plot=scatterlines!(ax, x[i], y)
        push!(profile_lines,plot)
    end    

    return profile_lines
end

##

using DrWatson
@quickactivate

# 1. Loading the functions
include(joinpath(@__DIR__, "..", "plots_functions.jl"))

# 2. Load the files and its parameters
file_names=["Precon_u₁₀=30_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=2400.0"]

results = load_simulation.(file_names)

# 3. Define the area (AOI)
T_plot=AOI_simulation.(16, 1, :, 41) 
S_plot=AOI_simulation.(16, 1, :, 41,:Sa) 

##
# 4. Display the figure 
#Note: fig should be the same as "profile_default.png

σ=gsw_sigma0.(T_plot[:data][1], S_plot[:data][1])

##

profile(S_plot[:data],results[1][:zT],[1,1],true)
display(fig)

##



##
#include("plots_functions.jl")

#Load files
names = ["test1", "test2"]
load_simulations(names)

#Create a TS diagrame

TS = Figure(resolution = (1200, 800))
ax = Axis(TS[1, 1], ylabel = "Temperature(°C)", xlabel = "Salinity(psu)")
ax.title = "Diagrame TS"

sca1 = scatter!(ax, S_plot[7], T_plot[7], color = zT, markersize = 20, colormap = :thermal)
sca2 = scatter!(
    ax,
    S_plot[10],
    T_plot[10],
    color = zT,
    markersize = 20,
    colormap = :thermal,
    marker = :dtriangle,
)
Colorbar(
    TS[1, 2],
    limits = (-30, 0),
    ticks = -30:6:0,
    colormap = cgrad(:thermal, 5, categorical = true),
    size = 25,
    label = "Depth(m)",
)

axislegend(
    ax,
    [sca1, sca2],
    ["7", "10"],
    "Modul velocitat vent (m/s)",
    position = :rb,
    orientation = :horizontal,
)

display(TS)

##Example to add the isopicnals
##it needs to be converted into a function to be added into any plots

#1)Create some TS data. It needs to have the same lengh! 
T_interest = 15:12/100:27
S_interest = 34:3/100:37

#Transform the T&S into a vector
T_trans_1 = collect(Iterators.flatten(T_interest))
S_trans_1 = collect(Iterators.flatten(S_interest))

#Change the dimensions of the previous transformation so that they can be used
#to calculate the density
T_trans_2 = reverse(T_trans_1)
S_trans_2 = transpose(S_trans_1)

#Calculate density matrix. This is done using the properties of the multiplication
#of matrix to achieve the correct dimensions of the matrix.
Column_1 = fill(1, (1, length(T_interest)))
Row_1 = fill(1, (length(S_interest), 1))

σ = reverse(transpose(gsw_sigma0.(Row_1 * S_trans_2, T_trans_2 * Column_1)), dims = 2)

#Now we can plot the isopicnals. Firsts we will create a heatmap to
#see if the density is correctly located
fig = Figure()

ax = Axis(
    fig[1, 1],
    xgridcolor = :black,
    ygridcolor = :black,
    xgridwidth = 1,
    ygridwidth = 1,
)
limits!(ax, 34, 37, 15, 27)

#add a heatmap to see the density
fig, ax, hm = heatmap(S_trans_1, T_trans_1, σ)
Colorbar(fig[:, end+1], hm)

#Now that we now that the density is correct we can add the isopicnals
#First we will create the lines, which are contours which are writen each 
#x interval ("isopicnals_range").
isopicnals_range = 23:0.5:26
isopicnals_name = collect(isopicnals_range)

con = contour!(
    S_trans_1,
    T_trans_1,
    σ,
    levels = isopicnals_range,
    linewidth = 5,
    colormap = :reds,
)

#Now we will create a point above which we will display the text

beginnings = Point2f[];
colors = RGBAf[];

# First plot in contour is the line plot, first arguments are the points of the contour
segments = con.plots[1][1][]
for (i, p) in enumerate(segments)

    # the segments are separated by NaN, which signals that a new contour starts
    #i-50 indicates that each point will be separated 50 points
    if isnan(p)
        push!(beginnings, segments[i-20])
    end
end

sc = scatter!(ax, beginnings, markersize = 50, color = (:white, 1), strokecolor = :white)

#Prepare the coords to add text
#we will add xy positions and then convert the object into a matrix wich "float32" types
coords_unchanged = hcat(beginnings...)'
coords = convert(Matrix, coords_unchanged)

#Loop to locate the text
maxim = size(coords, 1)

for i = 1:maxim
    text!(
        "$(round(isopicnals_name[i];digits=2))",
        position = (coords[i, 1], coords[i, 2]),
        align = (:center, :center),
    )
end

display(fig)
