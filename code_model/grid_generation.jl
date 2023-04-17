#=
Info: This file is the grid of the model. 
To execute the model go to "model_execution"
=#

using Oceananigans

const Nz = 40          # number of points in the vertical direction
const Lz = 1093         # (m) domain depth

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

grid = RectilinearGrid(size = (30, Nz), x = (0, 500), z = z_faces,
topology=(Periodic, Flat,Bounded))
