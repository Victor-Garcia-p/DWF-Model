#=
Info: This file is the grid of the model, where all the operation will be taking place
=#

using Oceananigans

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


grid = RectilinearGrid(size = (32, 32, Nz), x = (0, 64), y = (0, 64), z = z_faces)
#
