#=
Info: Functions used in all plot files
=#

using CairoMakie
using Oceananigans
using Oceananigans.Units: minute, minutes, hour
using GibbsSeaWater

"""
Load variables from different simulation files defined on a vector list like ["test1","test2"]

4 variables are saved into a dictionary
(T,Sa,νₑ,w)=(Temperature (C), Salinity (psu),  Viscosity (m*s^2), vertical velocity (m/s)). 
"""
function load_files(filename::String= "DEF_u₁₀=10_S=35.0_dTdz=0.01_T=20_dim=2D_t=2.400.jld2")::Dict{Symbol, Any}
    filepath_in = joinpath(@__DIR__, "..", "data", filename .* ".jld2")

    d = Dict{Symbol, Any}()

    d[:Sa] = FieldTimeSeries.(filepath_in, "S")
    d[:T] = FieldTimeSeries.(filepath_in, "T")
    d[:νₑ] = FieldTimeSeries.(filepath_in, "νₑ")
    d[:w] = FieldTimeSeries.(filepath_in, "w")

    d[:xT], d[:yT], d[:zT] = nodes(d[:T][1])
    d[:xw], d[:yw], d[:zw] = nodes(d[:w][1])


    @info "New simulation loaded"
    return d
end

"""
Return parameters of the simulations defined on filenames in a dictionary

Example: 
Imput="DEF_u₁₀=10_S=35.0_dTdz=0.01_T=20_dim=2D_t=2.400.jld2"

Output=Dict{String, Any}("S" => 35.0, "T" => 20, "dTdz" => 0.01, "t" => 2.4, "dim" => "2D", "u₁₀" => 10)
"""
function read_parameters(filename::String= "DEF_u₁₀=10_S=35.0_dTdz=0.01_T=20_dim=2D_t=2.400.jld2")

    kwargs_variables=parse_savename(filename)
    simulation_params=kwargs_variables[2]

    number_entries=length(simulation_params)

    @info "$number_entries parameters of a new simulation loaded"
    return simulation_params
end


"""
Set the location (x,y,z,t) for a given variable

"""
function define_AOI(
    x,
    y,
    z,
    t,
    variable = :T,
    results_dictionary=results)

    variable_plot = Any[]

    for i in eachindex(results)
        variable_interest = results_dictionary[i][variable].data[x, y, z, t]

        push!(variable_plot, variable_interest)
    end

    @info "Variable=$variable setted at x=$x y=$y z=$z t=$t"
    return variable_plot

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
