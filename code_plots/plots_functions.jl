#=
Info: Functions used in all plot files
=#

using CairoMakie
using Oceananigans
using Oceananigans.Units: minute, minutes, hour
using GibbsSeaWater

"""
Use: Load variables from different simulation files

Arguments: Vector with a list of simulations located at DWFmodel-Plots_out-Simulations. Names should be 
writen without the format (example: (["test1","test2"])

Output: A Dict() with 

4 variables 
(T,Sa,νₑ,w)=(Temperature (C), Salinity (psu),  Viscosity (m*s^2), vertical velocity (m/s))

Grid information
(xT,yT,zT)=positions of T,S and νₑ
(xw,yw,zw)=positions of w
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

#make a profile
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

    global my_sections=Any[]

    for i in eachindex(x)

        plot=scatterlines!(ax, x[i], y)
        push!(my_sections,plot)
    end    

    fig
end



#make a section (type scatter: variable vs depth)
function section(
    x=xT,
    y=zT,
    data=variable_plot[1],
    dim=[1,1],
    overwrite=false
    )

    reshaped_data = reshape(data, (size(x,1),size(y,1)))

    if dim==[1,1] && overwrite==true
        global fig = Figure()
    end

    fig[dim[1],dim[2]] = GridLayout()

    ax=Axis(fig[dim[1],dim[2]])
    
    return heatmap!(ax, x, y, reshaped_data)
end


#make a section plot (type heatmap: variable vs depth or time)
#section

#make a movie of a simulation
#movie()


#find the maxim and minimum of a variable
function max_min(variable)
    return (minimum(variable), maximum(variable))
end
