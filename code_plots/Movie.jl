#=
Info: The file creates a mp4 video to show the evolution of 4 variables
of the model, of a single simulation. The output will depends on the
configuration of the simulation (ej: it will start at 10min)

Input: Output of a simulation (.jld2)
Output: A video (mp4)

References: Script entirely from Oceananigans example, "ocean_wind_mixing_and_convection"
=#

#0) Import all the package that are required
using CairoMakie

using Printf
using Oceananigans.Units: minute, minutes, hour

#2)Video of the data
filepath_in = joinpath(@__DIR__, "..", "data", "model_data_bouyancy_sim.jld2")

filepath_out = joinpath(@__DIR__, "..", "Plots_out", "Simulations")
video_name = "Quick_test_DEF.mp4"

# Turbulence visualization

# We prepare for animating the flow by loading the data into
# FieldTimeSeries and defining functions for computing colorbar limits.


time_series = (
    w = FieldTimeSeries(filepath_in, "w"),
    T = FieldTimeSeries(filepath_in, "T"),
    S = FieldTimeSeries(filepath_in, "S"),
    νₑ = FieldTimeSeries(filepath_in, "νₑ"),
)

# Coordinate arrays
xw, yw, zw = nodes(time_series.w)
xT, yT, zT = nodes(time_series.T)

""" Return colorbar levels equispaced between `(-clim, clim)` and encompassing the extrema of `c`. """
function divergent_levels(c, clim, nlevels = 21)
    cmax = maximum(abs, c)
    levels =
        clim > cmax ? range(-clim, stop = clim, length = nlevels) :
        range(-cmax, stop = cmax, length = nlevels)

    return (levels[1], levels[end]), levels
end

""" Return colorbar levels equispaced between `clims` and encompassing the extrema of `c`."""
function sequential_levels(c, clims, nlevels = 20)
    levels = range(clims[1], stop = clims[2], length = nlevels)
    cmin, cmax = minimum(c), maximum(c)
    cmin < clims[1] && (levels = vcat([cmin], levels))
    cmax > clims[2] && (levels = vcat(levels, [cmax]))

    return clims, levels
end
nothing # hide

# We start the animation at ``t = 10minutes`` since things are pretty boring till then:

times = time_series.w.times
intro = searchsortedfirst(times, 10minutes)

# We are now ready to animate using Makie. We use Makie's `Observable` to animate
# the data. To dive into how `Observable`s work we refer to
# [Makie.jl's Documentation](https://makie.juliaplots.org/stable/documentation/nodes/index.html).

n = Observable(intro)

wₙ = @lift interior(time_series.w[$n], :, 1, :)
Tₙ = @lift interior(time_series.T[$n], :, 1, :)
Sₙ = @lift interior(time_series.S[$n], :, 1, :)
νₑₙ = @lift interior(time_series.νₑ[$n], :, 1, :)

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

title = @lift @sprintf("t = %s", prettytime(times[$n]))

wlims = (-0.05, 0.05)
Tlims = (19.7, 19.99)
Slims = (35, 35.005)
νₑlims = (1e-6, 5e-3)

hm_w = heatmap!(ax_w, xw, zw, wₙ; colormap = :balance, colorrange = wlims)
Colorbar(fig[2, 2], hm_w; label = "m s⁻¹")

hm_T = heatmap!(ax_T, xT, zT, Tₙ; colormap = :thermal, colorrange = Tlims)
Colorbar(fig[2, 4], hm_T; label = "ᵒC")

hm_S = heatmap!(ax_S, xT, zT, Sₙ; colormap = :haline, colorrange = Slims)
Colorbar(fig[3, 2], hm_S; label = "g / kg")

hm_νₑ = heatmap!(ax_νₑ, xT, zT, νₑₙ; colormap = :thermal, colorrange = νₑlims)
Colorbar(fig[3, 4], hm_νₑ; label = "m s⁻²")

fig[1, 1:4] = Label(fig, title, textsize = 24, tellwidth = false)

# And now record a movie.

frames = intro:length(times)

@info "Making a motion picture of ocean wind mixing and convection..."

record(fig, joinpath(filepath_out, video_name), frames, framerate = 8) do i
    msg = string("Plotting frame ", i, " of ", frames[end])
    print(msg * " \r")
    n[] = i
end
nothing #hide

# ![](ocean_wind_mixing_and_convection.mp4)
