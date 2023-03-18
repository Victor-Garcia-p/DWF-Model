#=
Info:
Input: Simulations from the model (.jld2)
Output: Differents plots
=#

using DrWatson

@quickactivate                  #load the local environment of the project and custom functions

include("plots_functions.jl")
include(joinpath(@__DIR__, "..", "code_model/grid_generation.jl"))

#names of the files (without .jld2)
file_names=["3WM_u₁₀=15_S=35.0-35.0-35.0_dTdz=0.04_T=13.18-13.38-12.71_dim=2D_t=1200.0",
"3WM__u₁₀=0_S=37.95-38.54-38.41_dTdz=0.01_T=13.18-13.38-12.71_dim=2D_t=43200.0"]

results = load_files.(file_names)
test=read_parameters.(file_names)

variable_plot=define_AOI(16, 16, :, 21) 
nothing

##
#Add the parameters for each plot
themes=[
    Theme(
        Axis = (
            xlabel="T (ºC)",
            ylabel="Depth (m)",
            title = "PLOT1"),

        Colorbar=(label = "Temperature ᵒC",ticksize=16, tickalign=1, spinewidth=0.5),
        Legend=(framevisible = false)

    ),

    Theme(
        Axis = (
            xlabel="T (ºC)",
            ylabel="Depth (m)",
            title = "PLOT2"
        ))
    ]

##

#test for 1 plot
with_theme(themes[1]) do

    profile(variable_plot,zT,[1,1])

end

display(fig)


#multiple plots
#1)create fig[1] without themes
#2)create fig[2] with themes
#3)add themes to fig[1]
with_theme(themes[1]) do

    profile(variable_plot,zT,[1,1])

end

profile(variable_plot,zT,[1,1],true)

with_theme(themes[2]) do

    profile(variable_plot,zT,[1,2])

end

with_theme(themes[1]) do

    profile(variable_plot,zT,[1,1])

end

display(fig)