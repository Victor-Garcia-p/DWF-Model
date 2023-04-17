#=
Info: Example from README to learn how to plot simulations and to use profile function
Imput: Simulations (.jld2) located at "DWF_model\data"
=#

# 0. Before starting, load the project environment 
using DrWatson
@quickactivate

# 1. Loading the functions
include(joinpath(@__DIR__, "..", "plots_functions.jl"))

# 2. Load the files and its parameters
file_names=["3WM_u₁₀=15_S=35.0-35.0-35.0_dTdz=0.04_T=13.18-13.38-12.71_dim=2D_t=1200.0"]

results = load_simulation.(file_names)

# 3. Define the area (AOI)
variable_plot=AOI_simulation.(16, 16, :, 21) 

##
# 4. Display the figure 
#Note: fig should be the same as "profile_default.png

profile(variable_plot[:data],results[1][:zT],[1,1],true)
display(fig)

# 5. Add some themes to costumize the fig
#Note: fig should be the same as "profile_themes.png

themes=
    Theme(
        Axis = (
            xlabel="T (ºC)",
            ylabel="Depth (m)",
            title = "PLOT1"))
#

with_theme(themes) do

    profile(variable_plot[:data],results[1][:zT],[1,1],true)
    
end

fig

