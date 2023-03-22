#=
Info: 
=#
 
using DrWatson
@quickactivate

include(joinpath(@__DIR__, "..", "plots_functions.jl"))

file_names=["3WM_u₁₀=15_S=35.0-35.0-35.0_dTdz=0.04_T=13.18-13.38-12.71_dim=2D_t=1200.0",
"3WM_u₁₀=0_S=37.95-38.54-38.41_dTdz=0.01_T=13.18-13.38-12.71_dim=2D_t=86400.0"]

results = load_files.(file_names)

variable_plot=define_AOI(:, 16, :, 21)  #note: because its a section two dimensions must not be fixed
simulation_parameters=read_parameters.(file_names)

simplified_name=chop.(file_names,head = 4, tail = 0)

themes=
    Theme(
        colormap= cgrad(:thermal),
        Axis = (
            xlabel="Distance x (m)",
            ylabel="Depth (m)",
            title = "Example of section for simulation $file_names[1]"),
            

        Colorbar=(label = "Temperature ᵒC",ticksize=16, tickalign=1, spinewidth=0.5)
        
)  

with_theme(themes) do
    
    my_section=section(results[1][:xT],results[1][:zT],variable_plot[1],[1,1],true)

    Colorbar(fig[1,2], my_section)
    
end

fig
