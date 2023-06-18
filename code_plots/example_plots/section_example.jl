#=
Info: Example from README to learn how to make sections and load the parameters of a simulation (ex: wind speed)
Imput: Simulations (.jld2) located at "DWF_model\data"
=#
using Serialization 
using DrWatson
@quickactivate

include(joinpath(@__DIR__, "..", "plots_functions.jl"))

file_names=["3WM2_u₁₀=30_S=37.95-38.54-38.41_dTdz=0.0_T=13.18-13.38-12.71_dim=2D_t=645000.0"]

results_1 = load_simulation.(file_names)

##
results =  deserialize("results.dat")

variable_plot=AOI_simulation.(1, 1, :, 1)  #because its a section two dimensions must not be fixed
nothing

##

themes=
    Theme(
        colormap= cgrad(:thermal),
        Axis = (
            xlabel="Distance x (m)",
            ylabel="Depth (m)",
            title = "Example of section for a simulation of u₁₀= 15 fixed at 
            x= $(variable_plot[:x])"
            ),
            
        #Other objects such as the Colorbar can be also costumized
        Colorbar=(label = "Temperature ᵒC",ticksize=16, tickalign=1, spinewidth=0.5)
         
)  

with_theme(themes) do
    
    my_section=section(results[1][:xT],results[1][:zT],variable_plot[:data][1],[1,1],true)

    Colorbar(fig[1,2], my_section)
    
end

fig
