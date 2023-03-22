##Contours a la llibreria PlotlyJS
##Objectiu: crear un grafic amb nomes el contours i les labels per superpossar-ho
##amb una grafica de makie

using DrWatson

@quickactivate                  #load the local environment of the project and custom functions

#include("plots_functions.jl")

#names of the files (without .jld2)
#file_names=["3WM_u₁₀=15_S=35.0-35.0-35.0_dTdz=0.04_T=13.18-13.38-12.71_dim=2D_t=1200.0",
#"3WM__u₁₀=0_S=37.95-38.54-38.41_dTdz=0.01_T=13.18-13.38-12.71_dim=2D_t=43200.0"]

#load_files(file_names)
#read_parameters(file_names)
#define_AOI(:, 16, :, 21, T)

##
function contours_and_labels(
    ax,
    x,
    y,
    data,
    range="default",
    text_labels=true
    ) 

    if range=="default"
        full_range_variable=LinRange(minimum(data),maximum(data),5)
        range_variable=full_range_variable[2:end-1]
    else
        range_variable=range    
    end

    con=contour!(ax, x, y, data,linewidth=3,color=:white,levels=range_variable)
    
    if text_labels==true
        
        beginnings = Point2f[]

        # First plot in contour is the line plot, first arguments are the points of the contour
        segments = con.plots[1][1][]

        for (i, p) in enumerate(segments)
            
            # the segments are separated by NaN, which signals that a new contour starts
            #the 20 is a number to avoid that the circles are on the right corner
            if isnan(p)
                
                push!(beginnings, segments[i-20])
            end
        end

        scatter!(ax, beginnings, markersize=50, color=(:white), strokecolor=:white)

        
        #Prepare the coords to add text
        #we will add xy positions and then convert the object into a matrix wich "float32" types
        coords_unchanged = hcat(beginnings...)'
        coords = convert(Matrix, coords_unchanged)

        #Loop to locate the text and round the variable before representing
        maxim = size(coords, 1)
        range_rounded=round.(range_variable,digits=2)


        for i = 1:maxim
            label=range_rounded[i]

            text!(
                "$label",
                position = (coords[i, 1], coords[i, 2]),
                align = (:center, :center),
            )
        end

    end
    
    return con
end

##
function section(
    x=xT,
    y=zT,
    data=variable_plot[1],
    dim=[1,1],
    overwrite=false,
    text_labels=true
    )

    reshaped_data = reshape(data, (size(x,1),size(y,1)))

    if dim==[1,1] && overwrite==true
        global fig = Figure()
    end

    fig[dim[1],dim[2]] = GridLayout()

    ax=Axis(fig[dim[1],dim[2]])
    
    section=heatmap!(ax, x, y, reshaped_data)

    if text_labels==true
        contours_and_labels(ax,x,y,reshaped_data,"default",false)
    end

    return section
end

##Heatmap of T
my_section=section(results[1][:xT],results[1][:zT],variable_plot[1],[1,1],true)
Colorbar(fig[1,2], my_section)

fig

