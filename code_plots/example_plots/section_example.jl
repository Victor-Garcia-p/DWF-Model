#=
Info: Example from README to learn how to make sections and load the parameters of a simulation (ex: wind speed)
Imput: Simulations (.jld2) located at "DWF_model\data"
=#
 
using DrWatson
@quickactivate

include(joinpath(@__DIR__, "..", "plots_functions.jl"))

file_names=["3WM_u₁₀=15_S=35.0-35.0-35.0_dTdz=0.04_T=13.18-13.38-12.71_dim=2D_t=1200.0"]

results = load_simulation.(file_names)

##
variable_plot=AOI_simulation(:, 1, :, 10000)  #because its a section two dimensions must not be fixed
simulation_parameters=read_parameters.(file_names)  #Dict() with the parameters of both simulations


themes=
    Theme(
        colormap= cgrad(:thermal),
        Axis = (
            xlabel="Distance x (m)",
            ylabel="Depth (m)",
            title = "Example of section for a simulation of u₁₀= 15 fixed at 
            y= $(variable_plot[:y]) and t= $(variable_plot[:t])"
            ),
            
        #Other objects such as the Colorbar can be also costumized
        Colorbar=(label = "Temperature ᵒC",ticksize=16, tickalign=1, spinewidth=0.5)
         
)  

with_theme(themes) do
    
    my_section=section(results[1][:xT],results[1][:zT],variable_plot[:data][1],[1,1],true)

    Colorbar(fig[1,2], my_section)
    
end

fig
