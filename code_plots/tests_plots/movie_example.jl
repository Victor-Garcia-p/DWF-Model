#first executate the file to load data
using Printf

#location
#variables
#number of simulations

movie_arguments = Dict(:variables=>[:w,:T,:Sa,:νₑ])

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

for i in eachindex(file_names)
    movie_AOU(i;movie_arguments...)
    movie_name(file_names[i])
    build_movie()
    record_movie()

end

