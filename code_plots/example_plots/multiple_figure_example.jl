#=
Info: Example from README to learn how to plot different figures

To plot two figures, plot fig1 without themes, then costumize the other 
figures and lastly costumize fig 1

Imput: Simulations (.jld2) located at "DWF_model\data"
=#

using DrWatson
@quickactivate

include(joinpath(@__DIR__, "..", "plots_functions.jl"))

file_names=["3WM_u₁₀=15_S=35.0-35.0-35.0_dTdz=0.04_T=13.18-13.38-12.71_dim=2D_t=1200.0",
"3WM_u₁₀=0_S=37.95-38.54-38.41_dTdz=0.01_T=13.18-13.38-12.71_dim=2D_t=86400.0"]

results = load_files.(file_names)
simulation_parameters=read_parameters.(file_names)  #Dict() with the parameters of both simulations

section_AOU=define_AOI.(:, 16, :, 21) 
profile_AOU=define_AOI.(16, 16, :, 21) 

##

themes=[
    Theme(
        colormap= cgrad(:thermal),
        Axis = (
            xlabel="Distance x (m)",
            ylabel="Depth (m)",
            title = "Example of section for a simulation of u₁₀= 15"
            ),
            
        #Other objects such as the Colorbar can be also costumized
        Colorbar=(label = "Temperature (ᵒC)", vertical = false,flipaxis = false)
         
    ),  

    Theme(
        Axis = (
            xlabel="T (ºC)",
            ylabel=" ",
            title = "Example of profile with legend"
        ) 
        )
]

##

#Creation of fig[1,1] without theme
section(results[1][:xT],results[1][:zT],section_AOU[:data][1],[1,1],true)

#Creation of fig[1,3] with theme
with_theme(themes[2]) do

    example_profile=profile(profile_AOU[:data],results[1][:zT],[1,2])

    Legend(fig[2, 2],example_profile,["u₁₀=$(simulation_parameters[1]["u₁₀"])",
    "u₁₀=$(simulation_parameters[2]["u₁₀"])"
    ],"Wind speed (m/s)",orientation = :horizontal)
    
end

#Adding theme to fig[1,1]
with_theme(themes[1]) do
    
    example_section=section(results[1][:xT],results[1][:zT],section_AOU[:data][1],[1,1])

    Colorbar(fig[2,1], example_section)
    
end

display(fig)

##


##LAST TEST
profile(profile_AOU[:data],results[1][:zT],[1,1],true)

##

with_theme(themes[2]) do

    prof=profile(profile_AOU[:data],results[1][:zT],[1,1],true)

    Legend(fig[2, 1],prof,["test1","test2"],"Figure tytle",orientation = :horizontal)
    
end

##
prof=profile(profile_AOU[:data],results[1][:zT],[1,1],true)
Legend(fig[2, 1],prof,["test1","test2"],"Figure tytle",orientation = :horizontal)
display(fig)

