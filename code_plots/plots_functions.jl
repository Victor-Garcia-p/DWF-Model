#=
Info: Functions used in all plot files
=#

using CairoMakie
using Oceananigans
using Oceananigans.Units: minute, minutes, hour
using GibbsSeaWater


#Load variables from different simulation files defined on a vector list like ["test1","test2"]
#(T,Sa,νₑ,w)=(Temperature (C), Salinity (psu),  Viscosity (m*s^2), vertical velocity (m/s))
#defauld simularion: Example from Oceananigans renamed using new format

function load_files(name_default::String= "DEF_u₁₀=10_S=35.0_dTdz=0.01_T=20_dim=2D_t=2.400.jld2")::Dict{Symbol, Any}
    filepath_in = joinpath(@__DIR__, "..", "data", name_default .* ".jld2")

    d = Dict{Symbol, Any}()

    d[:Sa] = FieldTimeSeries.(filepath_in, "S")
    d[:T] = FieldTimeSeries.(filepath_in, "T")
    d[:νₑ] = FieldTimeSeries.(filepath_in, "νₑ")
    d[:w] = FieldTimeSeries.(filepath_in, "w")

    d[:xT], d[:yT], d[:zT] = nodes(d[:T][1])
    d[:xw], d[:yw], d[:zw] = nodes(d[:w][1])

    number_simulations=size(d[:T],1)

    @info "4 variables (T,Sa,νₑ,w) loaded from $number_simulations simulations"

    return d
end

#return parameters of the simulations defined on filenames in a dictionary
function read_parameters(filename)

    pars = split(filename, "_")[2:end]
    params = Dict(
        map(x -> split(x, "="), pars)
        )

    @info "New variable 'simulation_params' defined with parameters for simulations"
    return params
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