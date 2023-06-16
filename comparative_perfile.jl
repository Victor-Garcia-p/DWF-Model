#=
Info: Compare the evolution of the model in Precondicionament phase using two different initial conditions.
The comparation also considers the state of the column according to buoi data

Two different types of initial conditions are tested
Theoric-Initial conditions are defined by Vargas-Yáñez et al. (2020). Only 3 layers of water mases.
Real-Initial conditions are buoi measures 15 of december. 8 layers of water mases.

Input: (loaded from DWF-Model\data\variables)
Theoric initial conditions simulation: 
"Precon_u₁₀=25.0_S=38.4-38.531-38.54-38.516-38.503-38.48_dTdz=0.0_T=13.3-13.299-13.203-13.07-13.031-12.907_t=2.59e6.dat" 

Real initial conditions simulations:
"3WM_u₁₀=30.0_S=37.95-38.54-38.41_dTdz=0.0_T=13.18-13.38-12.71_t=2.dat"

Reference simulation (a short simulation that is used as a reference to load how was the buoi at 15 of January)
"Precon_u₁₀=30_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=2400.0" (located at DWF-Model\data)

Output: Figures 5a and 5b of the TFG

References: Buoi data from LION observatory data (Bosse et al., 2023)
https://www.seanoe.org/data/00333/44411/
DOI=10.17882/44411

Theoric initial conditions from 
Vargas-Yáñez, M., Juza, M., Balbín, R., Velez-Belchí, P., García-Martínez, M. C., Moya, F., & Hernández-Guerra, A. (2020). 
Climatological Hydrographic Properties and Water Mass Transports in the Balearic Channels From Repeated Observations 
Over 1996–2019. Frontiers in Marine Science, 7, 779. https://doi.org/10.3389/FMARS.2020.568602/BIBTEX
=#

using DrWatson
@quickactivate

using Serialization

include(projectdir("code_model","model_functions.jl"))
include(projectdir("code_plots","plots_functions.jl"))
include("plots_functions2.jl")

#the name of this simulation is not important
file_names=["Precon_u₁₀=25.0_S=37.98-38.26-38.49_dTdz=0.0_T=14.09-13.1-12.93_t=2.59e6"]

# Load the simulation that will be compared with the buoi
#results=load_simulation.(file_names)

results=deserialize(datadir("variables","Precon_u₁₀=25.0_S=38.4-38.531-38.54-38.516-38.503-38.48_dTdz=0.0_T=13.3-13.299-13.203-13.07-13.031-12.907_t=2.59e6.dat"))

#Calculate the density for a given time and return a vector that has the data used to make the perfile
time_step=floor.(Int,collect(range(1, stop=2500,length=2)))
push!(time_step,20000)
push!(time_step,40000)

sigma=sigma_calculator(time_step=time_step,x=1,y=1)

#Reference simulation 
file_ref=["Precon_u₁₀=30_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=2400.0"]

ref_results = load_simulation.(file_ref)

ref_S=AOI_simulation(1, 1, :, 1,:Sa,ref_results)
ref_T=AOI_simulation(1, 1, :, 1,:T,ref_results)

sigma_ref=gsw_sigma0.(ref_S[:data][1],ref_T[:data][1])

#add all the data together in one array
push!(sigma[1],sigma_ref)


#Create name of legends
legend_names=[]

for t in eachindex(time_step)
    real_time_n=floor(Int,time_step[t]/(60*24))
    name_n="t (dies)= $real_time_n"
    push!(legend_names,name_n)
end

#add label for the buoi
push!(legend_names,"Boia (final etapa)")

legend_names=string.(legend_names)


marker_sign = repeat([:circle],size(time_step,1))

push!(marker_sign,:utriangle)

#costumize the plot
themes=
    Theme(
        Axis = (
            xlabel="Densitat σ₀ (kg/m^3)",
            ylabel="Profunditat (m)",
            title = "",
            yticks=0:-200:-1100,
            yminorticksvisible = true,
            xticks=28.80:0.05:29.05))
#


with_theme(themes) do

    prof=profile(sigma[1],grid.zᵃᵃᶜ[1:Nz],[1,1],true,marker_sign)

    Legend(fig[1,2],prof,legend_names,"Precondicionament
    (condicions inicials aproximades)")

end

fig

