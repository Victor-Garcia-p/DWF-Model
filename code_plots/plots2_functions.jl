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

function profile(
    x_variable=variable_plot,
    y_variable=zT,
    dim=[1,1],
    overwrite=false
    )

    if dim==[1,1] && overwrite==true
        global fig = Figure()
    end

    fig[dim[1],dim[2]] = GridLayout()

    ax=Axis(fig[dim[1],dim[2]])

    for i in eachindex(x_variable)

        scatterlines!(ax, x_variable[i], zT)
    end    

    fig
end


#find the maxim and minimum of a variable
function max_min(variable)
    return (minimum(variable), maximum(variable))
end
nothing