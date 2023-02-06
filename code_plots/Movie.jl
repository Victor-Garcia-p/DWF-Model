#=
Info: The file creates a mp4 video of 4 variables of a single simulation

Input: Output of a simulation (.jld2)
Output: a .mp4 (location: DWF_model\Plots_out\Simulations)
    
It ends at the simulation max time and starts at a value defined 
by the user. 

References: Script entirely from Oceananigans example, "ocean_wind_mixing_and_convection"
=#

using CairoMakie
using Printf
using Oceananigans.Units: minute, minutes, hour
using GibbsSeaWater

include("plots_functions.jl")

#names of the file that we want to use (without .jld2)
load_file(
    "3WM__u₁₀=15_S=35.0-35.0-35.0_dTdz=0.04_T=13.18-13.38-12.71_dim=2D_t=720.0"
)

video_filepath_out = joinpath(@__DIR__, "..", "Plots_out", "Simulations")
video_name = "3WM_test_8.mp4"


#Set some parameters for the movie
times = w.times
intro = searchsortedfirst(times, 0minutes)      #is the film starting at 0min?


n = Observable(intro)

#Load variables
wₙ = @lift interior(w[$n], :, 1, :)
Tₙ = @lift interior(T[$n], :, 1, :)
Sₙ = @lift interior(Sa[$n], :, 1, :)
νₑₙ = @lift interior(νₑ[$n], :, 1, :)

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

