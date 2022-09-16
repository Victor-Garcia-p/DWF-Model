#load drom a file TS variables, grid and position of the variables in the grid
#ir requires an argument, name, with the name of all the files

function load_variable(name_defauld="model_data_sim")
    #define the path of the model data&grid
    grid = joinpath(@__DIR__, "..", "code","grids_generation.jl")
    include(grid)
    filepath_in = joinpath.(@__DIR__, "..", "data", name_defauld.*".jld2")

    global Sa = FieldTimeSeries.(filepath_in, "S") 
    global T = FieldTimeSeries.(filepath_in, "T")
    global νₑ = FieldTimeSeries.(filepath_in, "νₑ")
    global w = FieldTimeSeries.(filepath_in, "w")

    global xT, yT, zT = nodes(T[1])
    global xw, yw, zw = nodes(w[1])

    return nothing
end

#function to calculate the density for TS diagram
function TS_σ(T,S)
    #Change the dimensions of the previous transformation so that they can be used
    #to calculate the density
    T_trans_2 = reverse(T)
    S_trans_2 = transpose(S)

    #Calculate density matrix. This is done using the properties of the multiplication
    #of matrix to achieve the correct dimensions of the matrix.
    Column_1=fill(1, (1,length(T_interest)))
    Row_1=fill(1,(length(S_interest), 1))

    return σ=reverse(transpose(gsw_sigma0.(Row_1*S_trans_2,T_trans_2*Column_1)),dims = 2)
end

#function to add contours with the name above to create isopicnals, isotermals...
function isovariable(ax,x,y,z,contour_range=23:0.5:26)
    #Now that we now that the density is correct we can add the isopicnals
    #First we will create the lines, which are contours which are writen each 
    #x interval ("contour_range").
    isovariable_name=collect(contour_range)

    con=contour!(x,y,z,levels=contour_range,linewidth=5,
    colormap=:reds)

    #Now we will create a point above which we will display the text

    beginnings = Point2f[]; colors = RGBAf[]

    # First plot in contour is the line plot, first arguments are the points of the contour
    segments = con.plots[1][1][]
    for (i, p) in enumerate(segments)

        # the segments are separated by NaN, which signals that a new contour starts
        #i-50 indicates that each point will be separated 50 points
        if isnan(p)
            push!(beginnings, segments[i-10])
        end
    end

    scatter!(ax, beginnings, markersize=50,colormap=(:reds, 0.5))

    #Prepare the coords to add text
    #we will add xy positions and then convert the object into a matrix wich "float32" types
    coords_unchanged=hcat(beginnings...)'
    coords=convert(Matrix, coords_unchanged)

    #Loop to locate the text
    max=size(coords,1)

    for i in 1:max
        text!("$(round(isovariable_name[i];digits=2))",position =(coords[i,1],coords[i,2]),  
        align = (:center, :center))
    end

end
