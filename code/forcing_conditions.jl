#info: this file contains the forcing conditions, those that affect the water surface (surface T,S and velocity)
#in the script boundary conditions are a general therm of both boundary and forcing
#out: a file with the expressions, that is saved in the path

using Oceananigans
using Oceananigans.Units: minute, minutes, hour
using JLD2

#define the filename and its path

path="D:/Documents/Universidad/TFG/DWC_model/data/"
namefile= "forcing_conditions.jld2"



# ## Boundary conditions
#
# We calculate the surface temperature flux associated with surface heating of
# 200 W m⁻², reference density `ρₒ`, and heat capacity `cᴾ`,

const Qʰ = 200.0  # W m⁻², surface _heat_ flux
const ρₒ = 1026.0 # kg m⁻³, average density at the surface of the world ocean
const cᴾ = 3991.0 # J K⁻¹ kg⁻¹, typical heat capacity for seawater

Qᵀ = Qʰ / (ρₒ * cᴾ) # K m s⁻¹, surface _temperature_ flux

# Finally, we impose a temperature gradient `dTdz` both initially and at the
# bottom of the domain, culminating in the boundary conditions on temperature,

const dTdz = 0.01 # K m⁻¹

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

const u₁₀ = 10    # m s⁻¹, average wind velocity 10 meters above the ocean
const cᴰ = 2.5e-3 # dimensionless drag coefficient
const ρₐ = 1.225  # kg m⁻³, average density of air at sea-level

Qᵘ = - ρₐ / ρₒ * cᴰ * u₁₀ * abs(u₁₀) # m² s⁻²

# The boundary conditions on `u` are thus

u_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(Qᵘ))

# For salinity, `S`, we impose an evaporative flux of the form

@inline Qˢ(x, y, t, S, evaporation_rate) = - evaporation_rate * S # [salinity unit] m s⁻¹
nothing # hide

# where `S` is salinity. We use an evporation rate of 1 millimeter per hour,

const evaporation_rate = 1e-3 / hour # m s⁻¹

# We build the `Flux` evaporation `BoundaryCondition` with the function `Qˢ`,
# indicating that `Qˢ` depends on salinity `S` and passing
# the parameter `evaporation_rate`,

evaporation_bc = FluxBoundaryCondition(Qˢ, field_dependencies=:S, parameters=evaporation_rate)

# The full salinity boundary conditions are

S_bcs = FieldBoundaryConditions(top=evaporation_bc)


#save the file
@save path * namefile u_bcs T_bcs S_bcs Qᵘ Qᵀ Qˢ evaporation_bc