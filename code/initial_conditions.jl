#info: this file contains the initial conditions of the model.
#note:The functions contains variables that are not loaded (ej: model.grid). As a consequence the function can not be 
#solved. The file purpose is just to define rather than to solve any equation.

using Oceananigans
using Random

# ## Initial conditions
#
# Our initial condition for temperature consists of a linear stratification superposed with
# random noise damped at the walls, while our initial condition for velocity consists
# only of random noise.

## Random noise damped at top and bottom. A seed is used so that the random noise is the same in all simulations
Random.seed!(12345)
Ξ(z) = randn() * z / model.grid.Lz * (1 + z / model.grid.Lz) # noise

## Temperature initial condition: a stable density gradient with random noise superposed.
Tᵢ(x, y, z) = 20 + dTdz * z + dTdz * model.grid.Lz * 1e-6 * Ξ(z)

## Velocity initial condition: random noise scaled by the friction velocity.
uᵢ(x, y, z) = sqrt(abs(Qᵘ)) * 1e-3 * Ξ(z)

#Reference salinity used to set the model (function !set)
S = 35

#not working properly @save ("initial_conditions.jld2") Ξ(z)