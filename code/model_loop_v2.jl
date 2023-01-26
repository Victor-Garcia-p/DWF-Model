#=
Info: This file contains all the model in a loop. It reads "constants" file and uses them as arguments at the model
to produce different simulations, each in different files (.jld2)

Imput: Grid.jl and constants.jl
Output: A file with the data of each simulation (.jld2)
=#

using Printf
using DrWatson
using Oceananigans
using Oceananigans.Units: minute, minutes, hour
using Random

include("grid_generation.jl")


#define the name of the output files and the path
const path = joinpath(@__DIR__, "..", "data")

struct WaterLayer{T<:Real}
    max_depth::T
    S::T
    T::T
end

mutable struct ModelParameters{A<:Real, N<:Real}
    u₁₀::A
    S::String
    dTdz::N
    T::String
    dim::String
    run::Bool

    function ModelParameters(u₁₀::A, S::String, dTdz::N, T::String) where {A, N}
        new{A,N}(u₁₀, S, dTdz, T, "2D", true)
    end
end

# A seed is used so that the random noise is the same in all simulations
Random.seed!(12345)

## Random noise damped at top and bottom.
Ξ(z) = randn() * z / grid.Lz * (1 + z / grid.Lz) # noise


# Buoyancy that depends on temperature and salinity
# We use the `SeawaterBuoyancy` model with a linear equation of state,

buoyancy = SeawaterBuoyancy(
    equation_of_state = LinearEquationOfState(
        thermal_expansion = 2e-4,
        haline_contraction = 8e-4,
    ),
)

## Boundary conditions
#
# We calculate the surface temperature flux associated with surface heating of
# 200 W m⁻², reference density `ρₒ`, and heat capacity `cᴾ`,
const Qʰ = 200.0  # W m⁻², surface _heat_ flux
const ρₒ = 1026.0 # kg m⁻³, average density at the surface of the world ocean
const cᴾ = 3991.0 # J K⁻¹ kg⁻¹, typical heat capacity for seawater
const Qᵀ = Qʰ / (ρₒ * cᴾ) # K m s⁻¹, surface _temperature_ flux

top_boundary_condition = FluxBoundaryCondition(Qᵀ) # temperature bc

#u₁₀ = 10    # m s⁻¹, average wind velocity 10 meters above the ocean
const cᴰ = 2.5e-3 # dimensionless drag coefficient
const ρₐ = 1.225  # kg m⁻³, average density of air at sea-level


# For salinity, `S`, we impose an evaporative flux of the form
@inline Qˢ(x, y, t, S, evaporation_rate) = -evaporation_rate * S # [salinity unit] m s⁻¹
nothing # hide


## Temperature initial condition for any number of homogeneous water mases (layers)
function initial_temperature(layers::Vector{WaterLayer{T}}, dTdz) where T<:Real

    function func(z)
        for layer in layers
            if z >= -layer.max_depth
                return layer.T + dTdz * grid.Lz * 1e-6 * Ξ(z)
            end
        end
    end

    Tᵢ(x, y, z) = func(z)

end


function initial_salinity(layers::Vector{WaterLayer{T}}) where T<:Real

    function func(z)
        for layer in layers
            if z >= -layer.max_depth
                return layer.S
            end
        end
    end

    Sᵢ(x, y, z) = func(z)
end


function sort_layers(layers::WaterLayer{<:Real}...)
    # order by max_depth (shallower first)
    sorted_layers = sort([layer for layer in layers], by = v -> v.max_depth, rev=false)

end

function build_model(layers::Vector{WaterLayer{T}};
             u₁₀=10,
             dTdz=0.01,
             evaporation_rate=1e-3 / hour,
             ) where T <:Real



    # Finally, we impose a temperature gradient `dTdz` both initially and at the
    # bottom of the domain, culminating in the boundary conditions on temperature,

    T_bcs = FieldBoundaryConditions(
        top = top_boundary_condition,
        bottom = GradientBoundaryCondition(dTdz),
    )

    # Note that a positive temperature flux at the surface of the ocean
    # implies cooling. This is because a positive temperature flux implies
    # that temperature is fluxed upwards, out of the ocean.
    #
    # For the velocity field, we imagine a wind blowing over the ocean surface
    # with an average velocity at 10 meters `u₁₀`, and use a drag coefficient `cᴰ`
    # to estimate the kinematic stress (that is, stress divided by density) exerted
    # by the wind on the ocean:


    Qᵘ = -ρₐ / ρₒ * cᴰ * u₁₀ * abs(u₁₀) # m² s⁻²

    # The boundary conditions on `u` are thus

    u_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(Qᵘ))


    # We build the `Flux` evaporation `BoundaryCondition` with the function `Qˢ`,
    # indicating that `Qˢ` depends on salinity `S` and passing
    # the parameter `evaporation_rate`,

    evaporation_bc =
        FluxBoundaryCondition(
            Qˢ, field_dependencies = :S, parameters = evaporation_rate)

    # The full salinity boundary conditions are

    S_bcs = FieldBoundaryConditions(top = evaporation_bc)

    ##MODEL DEFINITION
    #Create the base of the filename. At the end DrWatson will add to the same base name
    #some parameters that will include initial conditions, etc.
    model = NonhydrostaticModel(;
        grid,
        buoyancy = buoyancy,
        advection = UpwindBiasedFifthOrder(),
        timestepper = :RungeKutta3,
        tracers = (:T, :S),
        coriolis = FPlane(f = 1e-4),
        closure = AnisotropicMinimumDissipation(),
        boundary_conditions = (u = u_bcs, T = T_bcs, S = S_bcs),
    )
    #

    ## Velocity initial condition: random noise scaled by the friction velocity.
    uᵢ(x, y, z) = sqrt(abs(Qᵘ)) * 1e-3 * Ξ(z)

    ## `set!` the `model` fields using functions or constants:
    set!(model,
         u = uᵢ,
         w = uᵢ,
         T = initial_temperature(layers, dTdz),
         S = initial_salinity(layers)
         )

    params = ModelParameters(
       u₁₀,
       join(map(x->string(x.S), layers), "-"),
       dTdz,
       join(map(x->string(x.T), layers), "-")
       )

    @info "The model was built for $(length(layers)) layers, with u₁₀=$u₁₀, dTdZ=$dTdz and evaporation_rate=$evaporation_rate"
    return model, params

end



function build_simulation_name(params, simulation_prefix)
    # params to generate simulation file name
    filename = savename(simulation_prefix, params, "jld2", sort = false)
    @info "Simulation filename: $filename"

    return filename
end


function prepare_simulation!(params,
                             model;
                             dimension=(:, 16, :),
                             end_time=1140minutes,
                             Δt=10.0,
                             simulation_prefix="3WM_")

    # ## Setting up a simulation
    #
    # We set-up a simulation with an initial time-step of 10 seconds
    # that stops at 40 minutes, with adaptive time-stepping and progress printing.

    simulation = Simulation(model, Δt = Δt, stop_time = end_time)

    # The `TimeStepWizard` helps ensure stable time-stepping
    # with a Courant-Freidrichs-Lewy (CFL) number of 1.0.


    wizard = TimeStepWizard(cfl = 1.0, max_change = 1.1, max_Δt = 1minute)
    simulation.callbacks[:wizard] = Callback(wizard, IterationInterval(10))

    # Nice progress messaging is helpful:

    ## Print a progress message
    progress_message(sim) = @printf(
        "Iteration: %04d, time: %s, Δt: %s, max(|w|) = %.1e ms⁻¹, wall time: %s\n",
        iteration(sim),
        prettytime(sim),
        prettytime(sim.Δt),
        maximum(abs, sim.model.velocities.w),
        prettytime(sim.run_wall_time)
    )

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

    ##save the output
    params.dim = sizeof(dimension) == 0 ? "3D" : "2D"
    filename = build_simulation_name(params, simulation_prefix)

    simulation.output_writers[:slices] = JLD2OutputWriter(
        model,
        merge(model.velocities, model.tracers, eddy_viscosity),
        filename = joinpath(path, filename),
        indices = dimension,
        schedule = TimeInterval(1minute),
        overwrite_existing = true,
    )

    return simulation
end





