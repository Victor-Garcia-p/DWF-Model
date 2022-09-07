#use: this file contains all the functions required to create the grid
#and also the parameters like stretching or refinement
#output: file jld2 with only the grid data. Saved in the path that the users specify

using Oceananigans

#load the data, if the file is missing print a message
filename="grid.jld2"
path = joinpath(@__DIR__, "..", "data", filename)

# ## The grid
#
# We use 32²×24 grid points with 2 m grid spacing in the horizontal and
# varying spacing in the vertical, with higher resolution closer to the
# surface. Here we use a stretching function for the vertical nodes that
# maintains relatively constant vertical spacing in the mixed layer, which
# is desirable from a numerical standpoint:

const Nz = 24          # number of points in the vertical direction
const Lz = 32          # (m) domain depth

const refinement = 1.2 # controls spacing near surface (higher means finer spaced)
const stretching = 12  # controls rate of stretching at bottom

## Normalized height ranging from 0 to 1
h(k) = (k - 1) / Nz

## Linear near-surface generator
ζ₀(k) = 1 + (h(k) - 1) / refinement

## Bottom-intensified stretching function 
Σ(k) = (1 - exp(-stretching * h(k))) / (1 - exp(-stretching))

## Generating function
function z_faces(k)
    Lz * (ζ₀(k) * Σ(k) - 1)
end


grid = RectilinearGrid(size = (32, 32, Nz), 
                          x = (0, 64),
                          y = (0, 64),
                          z = z_faces)
#save the grid into a jld2 file. it can be opened with @load

#@save path grid 