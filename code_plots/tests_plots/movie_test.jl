#first executate the file to load data

#location
#variables
#number of simulations


movie_arguments = Dict(:variables=>[w[1],T[1],Sa[1],νₑ[1]])

function movie_AOU(;x=:,
    y=1,
    z=:,
    variables=[w[1],T[1],Sa[1],νₑ[1]],
    start_time=0minutes)

    times = variables[1].times
    intro = searchsortedfirst(times, start_time) 
    
    n = Observable(intro)

    #Load variables
    global movie_variables=Any[]

    for i in variables
        variable=@lift interior(i[$n], x, y, z)

        push!(movie_variables,variable)
    end
end

movie_AOU(;movie_arguments...)


##


video_filepath_out = joinpath(@__DIR__, "..", "Plots_out", "Simulations")
video_name = "3WM_test_9.mp4"


#Set some parameters for the movie
times = w.times
intro = searchsortedfirst(times, 0minutes)      #is the film starting at 0min?




#Make the figure
fig = Figure(resolution = (1000, 500))

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
#ax_σ = Axis(fig[3, 3]; title = "Density", axis_kwargs...)

title = @lift @sprintf("t = %s", prettytime(times[$n]))

#Note: The limits must be setted for depth>6 (if its the surface
#makie can manage to change the limits automaticly). But for a depth of 7
#We need to add as otherwise it will appear the
#error "ERROR: ArgumentError: range step cannot be zero"
wlims = max_min(w.data)
Tlims = max_min(T.data)
Slims = max_min(Sa.data)
νₑlims = max_min(νₑ.data)


hm_w = heatmap!(ax_w, xw, zw, wₙ; colormap = :balance, colorrange = wlims)
Colorbar(fig[2, 2], hm_w; label = "m s⁻¹")

hm_T = heatmap!(ax_T, xT, zT, Tₙ; colormap = :thermal, colorrange = Tlims)
Colorbar(fig[2, 4], hm_T; label = "ᵒC")

hm_S = heatmap!(ax_S, xT, zT, Sₙ; colormap = :haline, colorrange = Slims)
Colorbar(fig[3, 2], hm_S; label = "g / kg")

hm_νₑ = heatmap!(ax_νₑ, xT, zT, νₑₙ; colormap = :thermal, colorrange = νₑlims)
Colorbar(fig[3, 4], hm_νₑ; label = "m s⁻²")

#hm_σ = heatmap!(ax_σ, xT, zT, σ; colormap = :thermal, colorrange = σlims)
#Colorbar(fig[3, 4], hm_σ; label = "kg/m^3")

fig[1, 1:4] = Label(fig, title, fontsize = 24, tellwidth = false)

# And now record a movie.

frames = intro:length(times)

@info "Making a motion picture of ocean wind mixing and convection..."

##
record(fig, joinpath(video_filepath_out, video_name), frames, framerate = 8) do i
    msg = string("Plotting frame ", i, " of ", frames[end])
    print(msg * " \r")
    n[] = i
end
nothing #hide