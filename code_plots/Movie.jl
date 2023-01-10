#=
Info: The file creates a mp4 video when the data of the model is created.


to show the evolution of 4 variables
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
include("plots_functions.jl")

#names of the files that we want to use (without .jld2)
load_variable("DWF_t_S=35_dTdz=0.01_dim=2D_run=300.0_u₁₀=0")    

#Name and path of thefile
filepath_out = joinpath(@__DIR__, "..", "Plots_out", "Simulations")
video_name = "Test.mp4"

# Turbulence visualization

# We prepare for animating the flow by loading the data into
# FieldTimeSeries and defining functions for computing colorbar limits.


""" Return colorbar levels equispaced between `(-clim, clim)` and encompassing the extrema of `c`. """
function divergent_levels(c, clim, nlevels = 21)
    cmax = maximum(abs, c)
    levels =
        clim > cmax ? range(-clim, stop = clim, length = nlevels) :
        range(-cmax, stop = cmax, length = nlevels)

    return (levels[1], levels[end]), levels
end

""" Return colorbar levels equispaced between `clims` and encompassing the extrema of `c`."""
function sequential_levels(c, clims, nlevels = 21)
    levels = range(clims[1], stop = clims[2], length = nlevels)
    cmin, cmax = minimum(c), maximum(c)
    cmin < clims[1] && (levels = vcat([cmin], levels))
    cmax > clims[2] && (levels = vcat(levels, [cmax]))

    return clims, levels
end
nothing # hide

# We start the animation at ``t = 10minutes`` since things are pretty boring till then:

times = w.times
intro = searchsortedfirst(times, 1minutes)

# We are now ready to animate using Makie. We use Makie's `Observable` to animate
# the data. To dive into how `Observable`s work we refer to
# [Makie.jl's Documentation](https://makie.juliaplots.org/stable/documentation/nodes/index.html).

n = Observable(intro)

#change the last value to 1 to make horizontal plots
wₙ = @lift interior(w[$n], :, 1, :)
Tₙ = @lift interior(T[$n], :, 1, :)
Sₙ = @lift interior(Sa[$n], :, 1, :)
νₑₙ = @lift interior(νₑ[$n], :, 1, :)

fig = Figure(resolution = (1000, 500))

axis_kwargs = (
    xlabel = "x (m)",
    ylabel = "z (m)",
    aspect = AxisAspect(grid.Lx / grid.Lz),
    limits = ((0, grid.Lx), (-grid.Lz,0)),
)

ax_w = Axis(fig[2, 1]; title = "Vertical velocity", axis_kwargs...)
ax_T = Axis(fig[2, 3]; title = "Temperature", axis_kwargs...)
ax_S = Axis(fig[3, 1]; title = "Salinity", axis_kwargs...)
ax_νₑ = Axis(fig[3, 3]; title = "Eddy viscocity", axis_kwargs...)

title = @lift @sprintf("t = %s", prettytime(times[$n]))

#=
#Note: The limits must be setted for depth>6 (if its the surface
#makie can manage to change the limits automaticly). But for a depth of 7
#We need to add as otherwise it will appear the
#error "ERROR: ArgumentError: range step cannot be zero"
wlims = (-0.05, 0.05)
Tlims = (19.9, 19.99)
Slims = (35, 35.005)
νₑlims = (1e-6, 5e-3)
=#

hm_w = heatmap!(ax_w, xw, zw, wₙ; colormap = :balance)
Colorbar(fig[2, 2], hm_w; label = "m s⁻¹")

hm_T = heatmap!(ax_T, xT, zT, Tₙ; colormap = :thermal)
Colorbar(fig[2, 4], hm_T; label = "ᵒC")

hm_S = heatmap!(ax_S, xT, zT, Sₙ; colormap = :haline)
Colorbar(fig[3, 2], hm_S; label = "g / kg")

hm_νₑ = heatmap!(ax_νₑ, xT, zT, νₑₙ; colormap = :thermal)
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

