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
include("constants.jl")


#Set the model
for i=1:number_simulations
    # Buoyancy that depends on temperature and salinity
    #
    # We use the `SeawaterBuoyancy` model with a linear equation of state,

    buoyancy = SeawaterBuoyancy(equation_of_state=LinearEquationOfState(thermal_expansion = 2e-4,
    haline_contraction = 8e-4))

    ## Boundary conditions
    #
    # We calculate the surface temperature flux associated with surface heating of
    # 200 W m⁻², reference density `ρₒ`, and heat capacity `cᴾ`,

    local Qʰ = 200.0  # W m⁻², surface _heat_ flux
    local ρₒ = 1026.0 # kg m⁻³, average density at the surface of the world ocean
    local cᴾ = 3991.0 # J K⁻¹ kg⁻¹, typical heat capacity for seawater

    Qᵀ = Qʰ / (ρₒ * cᴾ) # K m s⁻¹, surface _temperature_ flux

    # Finally, we impose a temperature gradient `dTdz` both initially and at the
    # bottom of the domain, culminating in the boundary conditions on temperature,

    T_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(Qᵀ),
                                bottom = GradientBoundaryCondition(dTdz[i]))

    # Note that a positive temperature flux at the surface of the ocean
    # implies cooling. This is because a positive temperature flux implies
    # that temperature is fluxed upwards, out of the ocean.
    #
    # For the velocity field, we imagine a wind blowing over the ocean surface
    # with an average velocity at 10 meters `u₁₀`, and use a drag coefficient `cᴰ`
    # to estimate the kinematic stress (that is, stress divided by density) exerted
    # by the wind on the ocean:

    #u₁₀ = 10    # m s⁻¹, average wind velocity 10 meters above the ocean
    local cᴰ = 2.5e-3 # dimensionless drag coefficient
    local ρₐ = 1.225  # kg m⁻³, average density of air at sea-level

    Qᵘ = - ρₐ / ρₒ * cᴰ * u₁₀[i] * abs(u₁₀[i]) # m² s⁻²

    # The boundary conditions on `u` are thus

    u_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(Qᵘ))

    # For salinity, `S`, we impose an evaporative flux of the form

    @inline Qˢ(x, y, t, S, evaporation_rate) = - evaporation_rate * S_WM[i][1] # [salinity unit] m s⁻¹
    nothing # hide

    # where `S` is salinity. We use an evporation rate of 1 millimeter per hour,

    local evaporation_rate = 1e-3 / hour # m s⁻¹

    # We build the `Flux` evaporation `BoundaryCondition` with the function `Qˢ`,
    # indicating that `Qˢ` depends on salinity `S` and passing
    # the parameter `evaporation_rate`,

    evaporation_bc = FluxBoundaryCondition(Qˢ, field_dependencies=:S, parameters=evaporation_rate)

    # The full salinity boundary conditions are

    S_bcs = FieldBoundaryConditions(top=evaporation_bc)

    ##MODEL DEFINITION

    #define the name of the output files and the path
    path = joinpath(@__DIR__, "..", "data")

    #Create the base of the filename. At the end DrWatson will add to the same base name
    #some parameters that will include initial conditions, etc.
    model = NonhydrostaticModel(; grid, buoyancy=buoyancy,
                                advection = UpwindBiasedFifthOrder(),
                                timestepper = :RungeKutta3,
                                tracers = (:T, :S),
                                coriolis = FPlane(f=1e-4),
                                closure = AnisotropicMinimumDissipation(),
                                boundary_conditions = (u=u_bcs, T=T_bcs, S=S_bcs))
    #


    #INITIAL CONDITIONS

    ## Random noise damped at top and bottom. A seed is used so that the random noise is the same in all simulations
    Random.seed!(12345)
    Ξ(z) = randn() * z / model.grid.Lz * (1 + z / model.grid.Lz) # noise

    ##Salinity initial condition    
    Sᵢ(x, y, z) = z >= -SW_lim ? S_WM[i][1] :
    z >= -LIW_lim ? S_WM[i][2] : S_WM[i][3] 
    #
   
    ## Temperature initial condition: 3 water mases homogeneous
    Tᵢ(x, y, z) = z >= -SW_lim ? T_WM[i][1] + dTdz[i] * model.grid.Lz * 1e-6 * Ξ(z) :
    z >= -LIW_lim ? T_WM[i][2] + dTdz[i] * model.grid.Lz * 1e-6 * Ξ(z) : T_WM[i][3] + dTdz[i] * model.grid.Lz * 1e-6 * Ξ(z) 
    #

    ## Velocity initial condition: random noise scaled by the friction velocity.
    uᵢ(x, y, z) = sqrt(abs(Qᵘ)) * 1e-3 * Ξ(z)

    ## `set!` the `model` fields using functions or constants:
    set!(model, u=uᵢ, w=uᵢ, T=Tᵢ, S=Sᵢ)
    
    # ## Setting up a simulation
    #
    # We set-up a simulation with an initial time-step of 10 seconds
    # that stops at 40 minutes, with adaptive time-stepping and progress printing.

    simulation = Simulation(model, Δt=10.0, stop_time=end_time[i])

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
    if sizeof(dimension[i])==0
        dim="3D"
    else
        dim="2D"
    end

    T_concatenated=string(T_WM[i][1],-,T_WM[i][2],-,T_WM[i][3])
    S_concatenated=string(S_WM[i][1],-,S_WM[i][2],-,S_WM[i][3])

    params= simulation_name(u₁₀[i],S_concatenated,dTdz[i],T_concatenated,dim,end_time[1][i])

    filename=savename(simulation_prefix, params,"jld2",sort = false)

    ##save the output

    simulation.output_writers[:slices] =
        JLD2OutputWriter(model, merge(model.velocities, model.tracers, eddy_viscosity),
                        filename = joinpath(path,filename),
                        indices = dimension[i],
                        schedule = TimeInterval(1minute),
                        overwrite_existing = true)
    #
    if run_simulation==true
        return run!(simulation)
    end
end

