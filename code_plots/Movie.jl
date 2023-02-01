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

using GibbsSeaWater

#2)Video of the data
include("plots_functions.jl")

#names of the files that we want to use (without .jld2)
load_variable(
    "3WM__u₁₀=10_S=35.0_dTdz=0.01_T=20.0_dim=2D_run=true",
)

#Name and path of thefile
filepath_out = joinpath(@__DIR__, "..", "Plots_out", "Simulations")
video_name = "3WM_test_3.mp4"

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

#Set some parameters for the movie
times = w.times
intro = searchsortedfirst(times, 0minutes)

#Create the movie
n = Observable(intro)

#Load variables: change the last value to 1 to make horizontal plots
wₙ = @lift interior(w[$n], :, 1, :)
Tₙ = @lift interior(T[$n], :, 1, :)
Sₙ = @lift interior(Sa[$n], :, 1, :)
νₑₙ = @lift interior(νₑ[$n], :, 1, :)

#Calculate density
#σ=@lift gsw_sigma0.(Sa.data[:,16,:,$n], T.data[:,16,:,$n])


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
wlims = (-0.05, 0.05)
Tlims = (19.7, 19.99)
Slims = (35, 35.005)
νₑlims = (1e-6, 5e-3)
#σlims = (28.2,28.9)

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
record(fig, joinpath(filepath_out, video_name), frames, framerate = 8) do i
    msg = string("Plotting frame ", i, " of ", frames[end])
    print(msg * " \r")
    n[] = i
end
nothing #hide

