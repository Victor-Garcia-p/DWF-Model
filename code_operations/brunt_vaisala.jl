#=
Info: Calculate max Brunt Vaisala for a simulation and compare it to the theoretical max value
to validate the simulation
=#

using DrWatson
@quickactivate

using StatsBase

include(projectdir("code_model","model_functions.jl"))

data=load_simulation("Precon_u₁₀=30_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=2400.0")

##1) Brunt Vaisala for a given simulation

#Calculate the density
σ=gsw_sigma0.(data[:Sa].data, data[:T].data)

##
profile([σ[1,1,:,1]],data[:zT],[1,1],true)
display(fig)


##
S=[
38.412,	
38.522,	
38.533,	
38.518,	
38.503,	
38.487] 

T=[13.038,13.282,13.188,13.079,	13.035, 12.932]

σ=round.(gsw_sigma0.(S, T),digits=3)

##
Δσ_1D=Any[]
max_time=size(σ,3)

for t=1:max_time
    for i=1:grid.Nx,j=1:grid.Nz-1
        diff=(σ[i,j+1,t]-σ[i,j,t])/grid.Δzᵃᵃᶜ[j-1]
        push!(Δσ_1D,diff)
    end
end

Δσ=reshape(Δσ_1D,(grid.Nz-1,grid.Nx,max_time))          #Density gradient

#Calculate brunt vaisala
#N=sqrt.((g/ρₒ)*Δσ)

function Vaisala(Δσ,g=9.81,ρₒ=1028.96)             #the formula is + because the density gradient was done using depths
    return ((g/ρₒ)*Δσ).^2                       
end

N2=Vaisala(Δσ)                     #units: s^-1

#find max value on each time
max_N2=Any[]                #We want to know which is the max value of N2 in each time

for t in 1:max_time
   max_value=findmax((N2[:,:,t]))
   push!(max_N2,max_value)
end

##
##2) Brunt Vaisala maximum value given a gradient of density
#Then we want to calculate the value given a gradient of density
T_t=[13.18, 13.38,12.71]
S_t=[37.95, 38.54, 38.41]

#σ_teoric=[25.18,29.09,29.11]
σ_teoric=gsw_sigma0.(S_t, T_t)

Δσ_t=Any[]

for i in 1:2
    Δσ2=σ_teoric[i]-σ_teoric[i+1]  
    push!(Δσ_t,Δσ2)
end

N2t=Vaisala(Δσ_t)

max_N2t=maximum(N2t) 

a=(max_N2t,max_N2[1])

##Plot
N2_convert = transpose(reshape(N2[:,:,9], 23, 32))

Δσ_convert = reshape(Δσ[:,:,21], 32,23)

#Plot the figure
fig = Figure(resolution = (1200, 800))

axis_kwargs = (xlabel = "x (m)", ylabel = "z (m)")
#

ax_T = Axis(fig[1, 1]; title = "Stratification Index", axis_kwargs...)
hm_T = heatmap!(ax_T, xT, zT, N2_convert, colormap = :thermal)
Colorbar(fig[1, 2], hm_T; label = "Stratification Index")

display(fig)


##Plot_2
fig = Figure(resolution = (1200, 800))
ax = Axis(
    fig[1, 1],
    ylabel = "Profunditat (m)",
    xlabel = "N2 (s-2)",
    title = "Secció a x=1 i t=20min de Brunt Vaisala máxim",
)

sca1 = scatterlines!(ax, N2[:,1,21], zT[1:23])

display(fig)
