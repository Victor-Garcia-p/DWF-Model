#=
Info: Functions used in all plot files
=#

using CairoMakie
using Oceananigans
using Oceananigans.Units: minute, minutes, hour
using GibbsSeaWater


#grid loading from "grid_generation"
function load_grid(path=projectdir("code_model", "grid_generation.jl"))
    include(path)
    @info "Grid loaded from $path"
end


#Load variables from different simulation files defined on a vector list like ["test1","test2"]
#(T,Sa,νₑ,w)=(Temperature (C), Salinity (psu),  Viscosity (m*s^2), vertical velocity (m/s))
#defauld simularion: Example from Oceananigans renamed using new format

function load_files(name_defauld = "DEF_u₁₀=10_S=35.0_dTdz=0.01_T=20_dim=2D_t=2.400.jld2")
    filepath_in = datadir.(name_defauld .* ".jld2")

    global Sa = FieldTimeSeries.(filepath_in, "S")
    global T = FieldTimeSeries.(filepath_in, "T")
    global νₑ = FieldTimeSeries.(filepath_in, "νₑ")
    global w = FieldTimeSeries.(filepath_in, "w")

    global xT, yT, zT = nodes(T[1])
    global xw, yw, zw = nodes(w[1])

    number_simulations=size(T,1)

    @info "4 variables (T,Sa,νₑ,w) loaded from $number_simulations simulations"
    return nothing
end

#return parameters of the simulations defined on filenames in a dictionary
function read_parameters(filename)

    global simulation_params=Any[]

    for i in eachindex(filename)

        kwargs_variables=parse_savename(filename[i])
        push!(simulation_params,kwargs_variables[2])
    end 

    @info "New variable 'simulation_params' defined with parameters for simulations"
end

#set the location (x,y,z,t) for a given variable 
#then create a new variable 'variable_plot' with this info

function define_AOI(
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

#make a profile plot (type scatter: variable vs depth)
#profile()


#make a section plot (type heatmap: variable vs depth or time)
#section

#make a movie of a simulation 
#movie()



#find the maxim and minimum of a variable
function max_min(variable)
    return (minimum(variable), maximum(variable))
end