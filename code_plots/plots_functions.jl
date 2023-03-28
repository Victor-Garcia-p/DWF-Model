#=
Info: Functions used in all plot files
=#

using Printf
using CairoMakie
using Oceananigans
using Oceananigans.Units: minute, minutes, hour
using GibbsSeaWater

using CSV, DataFrames, StatsBase

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
    simulation_dictionary=results)

    d = Dict{Symbol, Any}()

    d[:x], d[:y], d[:z], d[:t] = x,y,z,t

    d[:data]=Any[]

    for i in eachindex(simulation_dictionary)
        data_n=simulation_dictionary[i][variable].data[x, y, z, t]
        push!(d[:data],data_n)
    end

    @info "Variable=$variable setted at x=$x y=$y z=$z t=$t"
    return d

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

    profile_lines=Any[]

    for i in eachindex(x)

        plot=scatterlines!(ax, x[i], y)
        push!(profile_lines,plot)
    end    

    return profile_lines
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


#find the maxim and minimum of a variable
function max_min(variable)
    return (minimum(variable), maximum(variable))
end

## make a movie
function movie_AOU(simulation=1;x=:,
    y=1,
    z=:,
    variables=[:w,:T,:Sa,:νₑ],
    start_time=0minutes)

    global times = results[1][:w].times
    global intro = searchsortedfirst(times, start_time)      #is the film starting at 0min?


    global n = Observable(intro)

    global movie_variables=Any[]

    for j in eachindex(variables)
        variable=@lift interior(results[simulation][variables[j]][$n], x, y, z)

        push!(movie_variables,variable)
    end   

    number_simulations=size(file_names,1)

    @info "Movie time is prepared for $simulation / $number_simulations"
end

function movie_name(files=file_names[1],prefix="MOV_")
    
    base_name=chop(files,head = 4, tail = 0)

    global mov_name = string(prefix,base_name)
    
    @info "Movie filename $mov_name"

end

function build_movie(variables=movie_variables,
    video_name = "3WM_test_11.mp4",
    video_filepath_out = projectdir("Plots_out", "Simulations"))
    
    #Make the figure
    global fig = Figure(resolution = (1000, 500))
    
    axis_kwargs = (
        xlabel = "x (m)",
        ylabel = "z (m)",
        aspect = AxisAspect(grid.Lx / grid.Lz),
        limits = ((0, grid.Lx), (-grid.Lz, 0)),
    )
    
    ax_w = Axis(fig[2, 1]; title = "Vertical velocity", axis_kwargs...)
    ax_T = Axis(fig[2, 3]; title = "Temperature", axis_kwargs...)
    ax_S = Axis(fig[3, 1]; title = "Salinity", axis_kwargs...)
    ax_νₑ = Axis(fig[3, 3]; title = "Eddy viscocity", axis_kwargs...)
    
    title = @lift @sprintf("t = %s", prettytime(times[$n]))
    
    #Note: The limits must be setted for depth>6 (if its the surface
    #makie can manage to change the limits automaticly). But for a depth of 7
    #We need to add as otherwise it will appear the
    #error "ERROR: ArgumentError: range step cannot be zero"
    wlims = max_min(results[1][:w].data)
    Tlims = max_min(results[1][:T].data)
    Slims = max_min(results[1][:Sa].data)
    νₑlims = max_min(results[1][:νₑ].data)
    
    
    hm_w = heatmap!(ax_w, results[1][:xw], results[1][:zw], variables[1,1]; colormap = :balance, colorrange = wlims)
    Colorbar(fig[2, 2], hm_w; label = "m s⁻¹")
    
    hm_T = heatmap!(ax_T, results[1][:xT], results[1][:zT], variables[2,1]; colormap = :thermal, colorrange = Tlims)
    Colorbar(fig[2, 4], hm_T; label = "ᵒC")
    
    hm_S = heatmap!(ax_S, results[1][:xT], results[1][:zT], variables[3,1]; colormap = :haline, colorrange = Slims)
    Colorbar(fig[3, 2], hm_S; label = "g / kg")
    
    hm_νₑ = heatmap!(ax_νₑ, results[1][:xT], results[1][:zT], variables[4,1]; colormap = :thermal, colorrange = νₑlims)
    Colorbar(fig[3, 4], hm_νₑ; label = "m s⁻²")
    
    fig[1, 1:4] = Label(fig, title, fontsize = 24, tellwidth = false)

    @info "Finished plotting"
        
end

function record_movie(video_filepath_out = projectdir("Plots_out", "Simulations"))
    
    frames = intro:length(times)

    @info "Making a motion picture of ocean wind mixing and convection..."
    record(fig, joinpath(video_filepath_out, mov_name * ".mp4"), frames, framerate = 8) do i
        msg = string("Plotting frame ", i, " of ", frames[end])
        print(msg * " \r")
        n[] = i
    end
    nothing #hide
end
