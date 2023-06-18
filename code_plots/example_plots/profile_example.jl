#=
Info: Example from README to learn how to plot simulations and to use profile function
Imput: Simulations (.jld2) located at "DWF_model\data"
=#

# 0. Before starting, load the project environment 
using DrWatson
using Serialization

@quickactivate

# 1. Loading the functions
include(joinpath(@__DIR__, "..", "plots_functions.jl"))

# 2. Load the files and its parameters
file_names=["3WM2_u₁₀=30_S=37.95-38.54-38.41_dTdz=0.0_T=13.18-13.38-12.71_dim=2D_t=645000.0"]

results_1 = load_simulation.(file_names)

WM_T0=results_1[1][:T].data[1,16,:,1]
WM_TF=results_1[1][:T].data[1,16,:,end]

WM_S0=results_1[1][:Sa].data[1,16,:,1]
WM_SF=results_1[1][:Sa].data[1,16,:,end]

sigma_3WM_0=gsw_sigma0.(WM_S0,WM_T0)
sigma_3WM_F=gsw_sigma0.(WM_SF,WM_TF)

results=deserialize("results.dat")

# 3. Define the area (AOI)
variable_plot_T=AOI_simulation(1, 1, :, 1) 
variable_plot_S=AOI_simulation(1, 1, :, 1,:Sa) 

sigma_buoi=gsw_sigma0.(variable_plot_S[:data][1],variable_plot_T[:data][1])

data=[sigma_3WM_0,sigma_3WM_F,sigma_buoi]

##

# 5. Add some themes to costumize the fig
#Note: fig should be the same as "profile_themes.png

themes=
    Theme(
        Axis = (
            xlabel="Densitat σ₀ (kg/m^3)",
            ylabel="Profunditat (m)",
            title = "PLOT1"))
#

with_theme(themes) do

    prof=profile(data,results[1][:zT],[1,1],true)

    Legend(fig[2,1],prof,["Teoriques t=0","Teoriques t=7.5 dies","Boia final fase precondicionament"],
    "Condicions inicials",orientation=:horizontal)
    
end

fig

