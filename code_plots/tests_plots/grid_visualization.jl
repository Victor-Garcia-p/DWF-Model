#=
Info: The file creates a plot to show how is the grid of the model.
It plots vertical spacing versus depth to inspect the prescribed grid stretching

Input: Grid file (.jl)
Output: A scatter plot (.png)

References: Script entirely from Oceananigans example, "ocean_wind_mixing_and_convection"
=#

#0) Import all the package that are required
using CairoMakie

#define the path and load the grid
path = joinpath(@__DIR__, "..", "..","code_model")
file = joinpath(path, "grid_generation.jl")

include(file)


#plot sparcing vs depth
fig = Figure(resolution = (1200, 800))
ax = Axis(fig[1, 1], ylabel = "Depth (m)", xlabel = "Vertical spacing (m)")
lines!(ax, grid.Δzᵃᵃᶜ[1:grid.Nz], grid.zᵃᵃᶜ[1:grid.Nz])
scatter!(ax, grid.Δzᵃᵃᶜ[1:Nz], grid.zᵃᵃᶜ[1:Nz])

save("ocean_wind_mixing_convection_grid_spacing.png", fig)
nothing #hide
