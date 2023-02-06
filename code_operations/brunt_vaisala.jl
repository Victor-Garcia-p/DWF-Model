#=
Info: Calculate max Brunt Vaisala for a simulation and compare it to the theoretical max value
to validate the simulation
=#

using DrWatson
using StatsBase
using HypothesisTests

@quickactivate

functions=projectdir("code_plots","plots_functions.jl")

include(functions)

load_file("3WM__u₁₀=0_S=37.95-38.54-38.41_dTdz=0.0_T=13.18-13.38-12.71_dim=2D_t=1200.0")

##1) Brunt Vaisala for a given simulation

#Calculate the density
σ=gsw_sigma0.(Sa.data[:, 16, :, :], T.data[:, 16, :, :])

Δσ_1D=Any[]
max_time=size(σ,3)

for i=1:grid.Nx,j=1:grid.Nz-1, t=1:max_time
    diff=(σ[i,j,t]-σ[i,j+1,t])/grid.Δzᵃᵃᶜ[j-1]
    push!(Δσ_1D,diff)
end

Δσ=reshape(Δσ_1D,(grid.Nx,grid.Nz-1,max_time))          #Density gradient

#Calculate brunt vaisala
#N=sqrt.((g/ρₒ)*Δσ)

function Vaisala(Δσ,g=9.81,ρₒ=1028.96)             #the formula is + because the density gradient was done using depths
    return ((g/ρₒ)*Δσ).^2                       
end

N2=Vaisala(Δσ)                     #units: s^-1

#find max value on each time
max_N2=Any[]                #We want to know which is the max value of N2 in each time

for t in 1:max_time
   max_value=maximum(N2[:,:,t]) 
   push!(max_N2,max_value)
end


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


##3)Stadistics
#We need to know if the simulation mean of N2 is the same of N2_teoric, in this case
#the simulation would be correct
mean_N2=mean.(N2)
mean_N2t=mean(N2t)

standard_deviation=std(N2)

t=OneSampleZTest(N2,N2t)
