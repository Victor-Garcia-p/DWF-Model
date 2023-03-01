#first executate the file to load data
using Printf

#location
#variables
#number of simulations

movie_arguments = Dict(:variables=>[w,T,Sa,νₑ])


function movie_AOU(;x=:,
    y=1,
    z=:,
    variables=[w[1],T[1],Sa[1],νₑ[1]],
    start_time=0minutes)

    global movie_variables=Any[]

    for i in eachindex(variables[1])

        global times = variables[1][i].times
        global intro = searchsortedfirst(times, start_time) 
        
        global n = Observable(intro)

        for j in eachindex(variables)
            variable=@lift interior(variables[j][i][$n], x, y, z)

            push!(movie_variables,variable)
        end
    end

    number_variables=size(variables,1)
    movie_variables=reshape(movie_variables,(number_variables,:))  #reshape the matrix
end

movie_AOU(;movie_arguments...)

##
function build_movie(variables=movie_variables,
    video_filepath_out = projectdir("Plots_out", "Simulations"),
    video_name = "3WM_test_11.mp4")
    
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
    wlims = max_min(w[1].data)
    Tlims = max_min(T[1].data)
    Slims = max_min(Sa[1].data)
    νₑlims = max_min(νₑ[1].data)
    
    
    hm_w = heatmap!(ax_w, xw, zw, variables[1,1]; colormap = :balance, colorrange = wlims)
    Colorbar(fig[2, 2], hm_w; label = "m s⁻¹")
    
    hm_T = heatmap!(ax_T, xT, zT, variables[2,1]; colormap = :thermal, colorrange = Tlims)
    Colorbar(fig[2, 4], hm_T; label = "ᵒC")
    
    hm_S = heatmap!(ax_S, xT, zT, variables[3,1]; colormap = :haline, colorrange = Slims)
    Colorbar(fig[3, 2], hm_S; label = "g / kg")
    
    hm_νₑ = heatmap!(ax_νₑ, xT, zT, variables[4,1]; colormap = :thermal, colorrange = νₑlims)
    Colorbar(fig[3, 4], hm_νₑ; label = "m s⁻²")
    
    fig[1, 1:4] = Label(fig, title, fontsize = 24, tellwidth = false)
        
end

build_movie()


##
function record_movie(figure=fig,
    video_filepath_out = projectdir("Plots_out", "Simulations"),
    video_name="3WM_test_11.mp4")
    
    frames = intro:length(times)

    @info "Making a motion picture of ocean wind mixing and convection..."

    record(fig, joinpath(video_filepath_out, video_name), frames, framerate = 8) do i
        msg = string("Plotting frame ", i, " of ", frames[end])
        print(msg * " \r")
        n[] = i
    end
    nothing #hide
    
end

record_movie()
