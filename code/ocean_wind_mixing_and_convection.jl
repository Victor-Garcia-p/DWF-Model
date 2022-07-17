# # [Wind- and convection-driven mixing in an ocean surface boundary layer](@id gpu_example)
#
# This example simulates mixing by three-dimensional turbulence in an ocean surface
# boundary layer driven by atmospheric winds and convection. It demonstrates:
#
#   * How to set-up a grid with varying spacing in the vertical direction
#   * How to use the `SeawaterBuoyancy` model for buoyancy with a linear equation of state.
#   * How to use a turbulence closure for large eddy simulation.
#   * How to use a function to impose a boundary condition.
#
# ## Install dependencies
#
# First let's make sure we have all required packages installed.

# ```julia
# using Pkg
# pkg"add Oceananigans, CairoMakie"
# ```

# We start by importing all of the packages and functions that we'll need for this
# example.

using Random
using Printf
using CairoMakie

using Oceananigans
using Oceananigans.Units: minute, minutes, hour

# ## The grid
#
# We use 32²×24 grid points with 2 m grid spacing in the horizontal and
# varying spacing in the vertical, with higher resolution closer to the
# surface. Here we use a stretching function for the vertical nodes that
# maintains relatively constant vertical spacing in the mixed layer, which
# is desirable from a numerical standpoint:

Nz = 24          # number of points in the vertical direction
Lz = 32          # (m) domain depth

refinement = 1.2 # controls spacing near surface (higher means finer spaced)
stretching = 12  # controls rate of stretching at bottom

## Normalized height ranging from 0 to 1
h(k) = (k - 1) / Nz

## Linear near-surface generator
ζ₀(k) = 1 + (h(k) - 1) / refinement

## Bottom-intensified stretching function 
Σ(k) = (1 - exp(-stretching * h(k))) / (1 - exp(-stretching))

## Generating function
z_faces(k) = Lz * (Σ(k)*ζ₀(k) - 1)

#Xyz are the "extent" part. 64/32=2m resolution. 
#It is better to avoid regular grids because if an error is made
#its easy to solve if is irregular
grid = RectilinearGrid(size = (32, 32, Nz), 
                          x = (0, 64),
                          y = (0, 64),
                          z = z_faces)

# We plot vertical spacing versus depth to inspect the prescribed grid stretching:
#Δxᶜᵃᵃ=grid space between cells centers
#xᶜᵃᵃ=coordinates of cells centers

fig = Figure(resolution=(1200, 800))
ax = Axis(fig[1, 1], ylabel = "Depth (m)", xlabel = "Vertical spacing (m)")
lines!(ax, grid.Δzᵃᵃᶜ[1:grid.Nz], grid.zᵃᵃᶜ[1:grid.Nz])
scatter!(ax, grid.Δzᵃᵃᶜ[1:Nz], grid.zᵃᵃᶜ[1:Nz])

save("defauld_streching.png", fig)
nothing #hide