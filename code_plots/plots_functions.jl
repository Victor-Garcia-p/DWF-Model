#=
Info: Functions used in all plot files
=#
using DrWatson
using CairoMakie
using Oceananigans
using Oceananigans.Units: minute, minutes, hour
using GibbsSeaWater

#Grid load
function load_grid(path=projectdir("code_model", "grid_generation.jl"))
    include(path)
    @info "Grid loaded from $path"
end


#Load a single file and its variables 
#T=Temperature      w=vertical velocity
#Sa=Salinity        νₑ=viscosity

function load_file(name_defauld = "model_data_sim")
    filepath_in = datadir.(name_defauld .* ".jld2")

    global Sa = FieldTimeSeries.(filepath_in, "S")
    global T = FieldTimeSeries.(filepath_in, "T")
    global νₑ = FieldTimeSeries.(filepath_in, "νₑ")
    global w = FieldTimeSeries.(filepath_in, "w")

    global xT, yT, zT = nodes(T[1])
    global xw, yw, zw = nodes(w[1])

    number_simulations=size(T,1)

    @info "$number_simulations simulations loaded"
    return nothing
end

#Return parameters of the simulations 
function read_variables(filename)

    global simulation_params=Any[]

    for i in eachindex(filename)

        kwargs_variables=parse_savename(filename[i])
        push!(simulation_params,kwargs_variables[2])
    end 

    @info "New variable 'simulation_params' defined with parameters for simulations"
end


#This function loads a variable in a setted location (ex: position x,y of
#the grid). It creates a new variable called "T_plot", "S_plot" or "w_plot" (depending of the name) with all
#the output of the function

function load_AOI(
    x,
    y,
    z,
    t,
    variable = T)

    global variable_plot = Any[]

    for i in eachindex(variable)
        variable_interest = variable[i].data[x, y, z, t]

        push!(variable_plot, variable_interest)
    end

    @info "New variable 'variable_plot' setted at x=$x y=$y z=$z t=$t"
end


#function to add contours with the name above to create isopicnals, isotermals...
function isovariable_test(ax, S_trans_1, T_trans_1, σ, isopicnals_range = 23:0.5:26)
    #Now that we now that the density is correct we can add the isopicnals
    #First we will create the lines, which are contours which are writen each 
    #x interval ("isopicnals_range").
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

    beginnings = Point2f[]
    colors = RGBAf[]

    # First plot in contour is the line plot, first arguments are the points of the contour
    segments = con.plots[1][1][]
    for (i, p) in enumerate(segments)

        # the segments are separated by NaN, which signals that a new contour starts
        #i-50 indicates that each point will be separated 50 points
        if isnan(p)
            push!(beginnings, segments[i-30])
        end
    end

    sc = scatter!(
        ax,
        beginnings,
        markersize = 50,
        color = 1:length(beginnings),
        colormap = :reds,
    )

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
end

#
function TS_σ(T, S)
    #Change the dimensions of the previous transformation so that they can be used
    #to calculate the density
    T_trans_2 = reverse(T)
    S_trans_2 = transpose(S)

    #Calculate density matrix. This is done using the properties of the multiplication
    #of matrix to achieve the correct dimensions of the matrix.
    Column_1 = fill(1, (1, length(T)))
    Row_1 = fill(1, (length(S), 1))

    return σ =
        reverse(transpose(gsw_sigma0.(Row_1 * S_trans_2, T_trans_2 * Column_1)), dims = 2)
end

##
function range_(variable, sparcing)

    maxi = maximum(variable)
    mini = minimum(variable)

    interval = round(((maxi - mini) / sparcing); digits = 4)

    T_interest = round(mini; digits = 4):interval:round(maxi; digits = 4)
    return convert(
        StepRangeLen{
            Float64,
            Base.TwicePrecision{Float64},
            Base.TwicePrecision{Float64},
            Int64,
        },
        T_interest,
    )
end


#SI function (Stratification Index)
#the function will make the intergral for a defined point
#of the matrix (ex: between the value that has line 1 row 1
#at time 1 and 2)

function SI(σ, Z = σ[end])
    sum(σ[Z] .- σ)
end

#Structure to make the name of the file
struct name
    u₁₀::Any
    dTdz::Any
    S::Any
    dim::Any
    run::Any
end

#Funtion to create the name of the simulation that we want to plot
function name_concatenation(first_simulation, last_simulation)
    for i = first_simulation:last_simulation
        #Define if the data has 2d o 3d dimensions
        if sizeof(dimension) == 0
            dim = "3D"
        else
            dim = "2D"
        end

        #Create the name of the file
        params = name(u₁₀[i], dTdz[i], S[i], dim, end_time[i])
        file = savename("DWF", params)
        push!(files, file)
    end
end


#Functions of the movie file
""" Return colorbar levels equispaced between `(-clim, clim)` and encompassing the extrema of `c`. """
function divergent_levels(c, clim, nlevels = 21)
    cmax = maximum(abs, c)
    levels =
        clim > cmax ? range(-clim, stop = clim, length = nlevels) :
        range(-cmax, stop = cmax, length = nlevels)

    return (levels[1], levels[end]), levels
end

""" Return colorbar levels equispaced between `clims` and encompassing the extrema of `c`."""
function sequential_levels(c, clims, nlevels = 21)
    levels = range(clims[1], stop = clims[2], length = nlevels)
    cmin, cmax = minimum(c), maximum(c)
    cmin < clims[1] && (levels = vcat([cmin], levels))
    cmax > clims[2] && (levels = vcat(levels, [cmax]))

    return clims, levels
end
nothing


