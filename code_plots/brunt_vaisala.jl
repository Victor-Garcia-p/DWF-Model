using DrWatson
using CairoMakie
using Oceananigans
using GibbsSeaWater

#load the local environment not the global which is defauld in Julia
@quickactivate "DWC_model"
include("plots_functions.jl")

load_file("3WM__u₁₀=0_S=37.92-38.32-38.49_dTdz=0.01_T=14.17-13.22-12.93_dim=2D_run=1200.0")

## 1)Calculate the density
σ=gsw_sigma0.(Sa.data[:, 16, :, :], T.data[:, 16, :, :])

Δσ_1D=Any[]
max_time=size(σ,3)

for i=1:grid.Nx,j=1:grid.Nz-1,t=1:max_time
    diff=(σ[i,j,t]-σ[i,j+1,t])/grid.Δzᵃᵃᶜ[j-1]
    push!(Δσ_1D,diff)
end

Δσ=reshape(Δσ_1D,(grid.Nx,grid.Nz-1,max_time))          #Density gradient

#2)Calculate brunt vaisala
#N=sqrt.((g/ρₒ)*Δσ)

function Vaisala(Δσ,g=9.81,ρₒ=1028.96)             #the formula is + because the density gradient was done using depths
    return N2=((g/ρₒ)*Δσ).^2                       
end

Vaisala(Δσ)                     #units: s^-1

#3)Find max time 
max_vector=Any[]                #We want to know which is the max value of N2 in each time

for t in 1:max_time
   max_value=maximum(N2[:,:,t]) 
   push!(max_vector,max_value)
end

##
#Then we want to calculate the value given a gradient of density
σ_theoretic=[25.18,29.09,29.11]
Δz_theoretic=10


##
t=Any[]
for i=1:24
    tt=grid.zᵃᵃᶜ[i]
    push!(t,tt)
end
tt=reverse(t*10)*ones(1,32)

N2_2=gsw_nsquared.(Sa.data[:, 16, :, 21],T.data[:, 16, :, 21],tt)

##



##
for i=1:grid.Nx,j=1:grid.Nz-1,t=1:1
    dif=σ[i,j,t]-σ[i,j+1,t]
    push!(Δσ[i,j,1],dif)
end

##
1:32, 1:24, 1:21

AA=inv(A)
#Δσ=σ/grid.Δzᵃᵃᶜ[1:grid.Nz]





