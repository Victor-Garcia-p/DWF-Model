#info: This file creates the model considering the grid, boundary conditions and initial conditions
#input: grid, initial & boundary conditions functions 
#output: jld2 ("model_data") with the data of the model previous of the simulation
#output2: jld2 ("model_data_sim") copy of the same file, but this will be overwriten by the simulation
#time excecution: 1,5 min aprox

using Oceananigans
using JLD2
using Printf
using Random

#Define the path of the data files
path = joinpath(@__DIR__, "..", "data")

#Load the grid
file=joinpath(path,"grid.jld2")

if isfile(file)
    @load file grid
else
    # Put an error message
    error("Missing grid file") 
end

#Load forcing&initial conditions
include("forcing_conditions.jl")
include("initial_conditions.jl")

#define the name of the output files
filename1 = "model_data_v20.jld2"
filename2 = "model_data_v_20_sim.jld2" #a copy of the same file


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

simulation = Simulation(model, Δt=10.0, stop_time=20minutes)

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
                     filename = joinpath(path,filename1),
                     indices = (:, grid.Ny/2, :),
                     schedule = TimeInterval(1minute),
                     overwrite_existing = true)
nothing

#Make a copy of the file that will be used in the simulation

simulation.output_writers[:slices] =
    JLD2OutputWriter(model, merge(model.velocities, model.tracers, eddy_viscosity),
                     filename = joinpath(path,filename2),
                     indices = (:, grid.Ny/2, :),
                     schedule = TimeInterval(1minute),
                     overwrite_existing = true)
#run!(simulation)