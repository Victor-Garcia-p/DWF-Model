#=
Info: This file contains all the model (function DWF). It reads "constants" file and uses them as arguments to
make the data of the simulation, returned at (.jld2).

The loop is used to make several simulations if there are defined several constants (ex: u₁₀ = [1 m/s, 2 m/s])

Imput: Grid.jl and constants.jl
Output: A file with the data of the simulation (.jld2)
=#

using Printf
using DrWatson
using Oceananigans
using Oceananigans.Units: minute, minutes, hour
using Random

include("constants.jl")

#Set the model
function DWF(u₁₀,dTdz,S,end_time,dimensions,names,run="false")
    include("grids_generation.jl")
    # ## Initial conditions
    #
    # Our initial condition for temperature consists of a linear stratification superposed with
    # random noise damped at the walls, while our initial condition for velocity consists
    # only of random noise.

    ## Random noise damped at top and bottom. A seed is used so that the random noise is the same in all simulations
    Random.seed!(12345)
    Ξ(z) = randn() * z / model.grid.Lz * (1 + z / model.grid.Lz) # noise

    ## Temperature initial condition: 3 water mases homogeneous
    Tᵢ(x, y, z) = z >= -SW_lim ? SW[2] :
                z >= -LIW_lim ? LIW[2] : DW[2] 
    #
    
    ## Velocity initial condition: random noise scaled by the friction velocity.
    uᵢ(x, y, z) = sqrt(abs(Qᵘ)) * 1e-3 * Ξ(z)


    # ## Boundary conditions
    #
    # We calculate the surface temperature flux associated with surface heating of
    # 200 W m⁻², reference density `ρₒ`, and heat capacity `cᴾ`,

    local Qʰ = 200.0  # W m⁻², surface _heat_ flux
    local ρₒ = 1026.0 # kg m⁻³, average density at the surface of the world ocean
    local cᴾ = 3991.0 # J K⁻¹ kg⁻¹, typical heat capacity for seawater

    Qᵀ = Qʰ / (ρₒ * cᴾ) # K m s⁻¹, surface _temperature_ flux

    # Finally, we impose a temperature gradient `dTdz` both initially and at the
    # bottom of the domain, culminating in the boundary conditions on temperature,

    #const dTdz = 0.01 # K m⁻¹

    T_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(Qᵀ),
                                    bottom = GradientBoundaryCondition(dTdz))

    # Note that a positive temperature flux at the surface of the ocean
    # implies cooling. This is because a positive temperature flux implies
    # that temperature is fluxed upwards, out of the ocean.
    #
    # For the velocity field, we imagine a wind blowing over the ocean surface
    # with an average velocity at 10 meters `u₁₀`, and use a drag coefficient `cᴰ`
    # to estimate the kinematic stress (that is, stress divided by density) exerted
    # by the wind on the ocean:

    #const u₁₀ = 10    # m s⁻¹, average wind velocity 10 meters above the ocean
    local cᴰ = 2.5e-3 # dimensionless drag coefficient
    local ρₐ = 1.225  # kg m⁻³, average density of air at sea-level

    Qᵘ = - ρₐ / ρₒ * cᴰ * u₁₀ * abs(u₁₀) # m² s⁻²

    # The boundary conditions on `u` are thus

    u_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(Qᵘ))

    ##Salinity

    #Definition of water masses 3 water mases homogeneous
    Sᵢ(x, y, z) = z >= -SW_lim ? SW[1] :
    z >= -LIW_lim ? LIW[1] : DW[1] 
    #

    # For salinity, `S`, we impose an evaporative flux of the form

    @inline Qˢ(x, y, t, S, evaporation_rate) = - evaporation_rate * S # [salinity unit] m s⁻¹
    nothing # hide

    # where `S` is salinity. We use an evporation rate of 1 millimeter per hour,

    local evaporation_rate = 1e-3 / hour # m s⁻¹

    # We build the `Flux` evaporation `BoundaryCondition` with the function `Qˢ`,
    # indicating that `Qˢ` depends on salinity `S` and passing
    # the parameter `evaporation_rate`,

    evaporation_bc = FluxBoundaryCondition(Qˢ, field_dependencies=:S, parameters=evaporation_rate)

    # The full salinity boundary conditions are

    S_bcs = FieldBoundaryConditions(top=evaporation_bc)

    #define the name of the output files and the path
    path = joinpath(@__DIR__, "..", "data")

    #Create the base of the filename. At the end DrWatson will add to the same base name
    #some parameters that will include initial conditions, etc.
    basename1 = "data"
    basename2 = "data" #a copy of the same file

    #Define the parameters of the simulation (at the future this will be opened from a file)
    #end_time=20minutes          #Runtime for simulation
    #dimensions = (:, 2, :)      #used to create 3D files or 2D (a x or y must be setted)


    # ## Buoyancy that depends on temperature and salinity
    #
    # We use the `SeawaterBuoyancy` model with a linear equation of state,

    buoyancy = SeawaterBuoyancy(equation_of_state=LinearEquationOfState(thermal_expansion = 2e-4,
                                                                        haline_contraction = 8e-4))
    #

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
    set!(model, u=uᵢ, w=uᵢ, T=Tᵢ, S=Sᵢ)

    # ## Setting up a simulation
    #
    # We set-up a simulation with an initial time-step of 10 seconds
    # that stops at 40 minutes, with adaptive time-stepping and progress printing.

    simulation = Simulation(model, Δt=10.0, stop_time=end_time)

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

    ##Add the parameters, such as initial conditions, to the name of the file (DrWatson)
    if sizeof(dimensions)==0
        dim="3D"
    else
        dim="2D"
    end
    params= names(u₁₀,dTdz,S,dim,end_time)

    filename1=savename(simulation_prefix, params,"jld2")

    ##save the output

    simulation.output_writers[:slices] =
        JLD2OutputWriter(model, merge(model.velocities, model.tracers, eddy_viscosity),
                        filename = joinpath(path,filename1),
                        indices = dimensions,
                        schedule = TimeInterval(1minute),
                        overwrite_existing = true)
    #
    if run==true
        return run!(simulation)
    end
end

for i=1:10
    DWF(u₁₀[i],dTdz[i],S[i],end_time[i],dimension[i],simulation_name,true)

    println("__LAST SIMULATION COMPLETED__")
end

