#info: This file creates the model considering the grid, boundary conditions and initial conditions
#input: grid, initial & boundary conditions functions 
#output: jld2 ("model_data") with the data of the model previous of the simulation
#output2: jld2 ("model_data_sim") copy of the same file, but this will be overwriten by the simulation
#time excecution: 1,5 min aprox

#ERROR: the "initial conditions" file has and error because it is not possible to define variables and the order @load gives and error

using Oceananigans
using JLD2
using Printf

path="D:/Documents/Universidad/TFG/DWC_model/data/"
filename1 = "model_data.jld2"
filename2 = "model_data_sim.jld2"

include("initial_conditions.jl")
@load path * "grid.jld2" grid
include("forcing_conditions.jl")


#2n alternative: @load "boundary_conditions.jld2" buoyancy u_bcs T_bcs S_bcs Qᵘ Qᵀ Qˢ evaporation_bc
#include("boundary_conditions.jl")
#we are using the alternative as function not not working: @load "grid.jld2" uᵢ Tᵢ S


# ## Buoyancy that depends on temperature and salinity
#
# We use the `SeawaterBuoyancy` model with a linear equation of state,

buoyancy = SeawaterBuoyancy(equation_of_state=LinearEquationOfState(thermal_expansion = 2e-4,
                                                                    haline_contraction = 8e-4))


# ## Model instantiation

#
# We fill in the final details of the model here: upwind-biased 5th-order
# advection for momentum and tracers, 3rd-order Runge-Kutta time-stepping,
# Coriolis forces, and the `AnisotropicMinimumDissipation` closure
# for large eddy simulation to model the effect of turbulent motions at
# scales smaller than the grid scale that we cannot explicitly resolve.

model = NonhydrostaticModel(; grid, buoyancy,
                            advection = UpwindBiasedFifthOrder(),
                            timestepper = :RungeKutta3,
                            tracers = (:T, :S),
                            coriolis = FPlane(f=1e-4),
                            closure = AnisotropicMinimumDissipation(),
                            boundary_conditions = (u=u_bcs, T=T_bcs, S=S_bcs))

# Notes:
#
# * To use the Smagorinsky-Lilly turbulence closure (with a constant model coefficient) rather than
#   `AnisotropicMinimumDissipation`, use `closure = SmagorinskyLilly()` in the model constructor.
#
# * To change the `architecture` to `GPU`, replace `architecture = CPU()` with
#   `architecture = GPU()`.

## `set!` the `model` fields using functions or constants:
set!(model, u=uᵢ, w=uᵢ, T=Tᵢ, S=S)

# ## Setting up a simulation
#
# We set-up a simulation with an initial time-step of 10 seconds
# that stops at 40 minutes, with adaptive time-stepping and progress printing.

simulation = Simulation(model, Δt=10.0, stop_time=40minutes)

# The `TimeStepWizard` helps ensure stable time-stepping
# with a Courant-Freidrichs-Lewy (CFL) number of 1.0.   


wizard = TimeStepWizard(cfl=1.0, max_change=1.1, max_Δt=1minute)
simulation.callbacks[:wizard] = Callback(wizard, IterationInterval(10))

# Nice progress messaging is helpful:

## Print a progress message
progress_message(sim) = @printf("Iteration: %04d, time: %s, Δt: %s, max(|w|) = %.1e ms⁻¹, wall time: %s\n",
                                iteration(sim), prettytime(sim), prettytime(sim.Δt),
                                maximum(abs, sim.model.velocities.w), prettytime(sim.run_wall_time))

simulation.callbacks[:progress] = Callback(progress_message, IterationInterval(20))

# We then set up the simulation:

# ## Output
#
# We use the `JLD2OutputWriter` to save ``x, z`` slices of the velocity fields,
# tracer fields, and eddy diffusivities. The `prefix` keyword argument
# to `JLD2OutputWriter` indicates that output will be saved in
# `ocean_wind_mixing_and_convection.jld2`.

## Create a NamedTuple with eddy viscosity
eddy_viscosity = (; νₑ = model.diffusivity_fields.νₑ)

simulation.output_writers[:slices] =
    JLD2OutputWriter(model, merge(model.velocities, model.tracers, eddy_viscosity),
                     filename = path * filename1,
                     indices = (:, grid.Ny/2, :),
                     schedule = TimeInterval(1minute),
                     overwrite_existing = true)

#Make a copy of the file that will be used in the simulation

simulation.output_writers[:slices] =
    JLD2OutputWriter(model, merge(model.velocities, model.tracers, eddy_viscosity),
                     filename = path * filename2,
                     indices = (:, grid.Ny/2, :),
                     schedule = TimeInterval(1minute),
                     overwrite_existing = true)