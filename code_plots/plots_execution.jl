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
"3WM_u₁₀=0_S=37.95-38.54-38.41_dTdz=0.01_T=13.18-13.38-12.71_dim=2D_t=86400.0"]

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


##

# Output in a txt file
# opening file with .txt extension and in write mode
 
# let the ans be the output of a question

# The simplest case:

 
# std, rho ,name
std = [1,2]
rho = [3,4]

name = ["sim1","sim2"]

df = DataFrame(std=std, rho=rho, name=name)

## 
using CSV, DataFrames, StatsBase

function statistics_csv(results,name,variable=:T,min_time=21,reference_sim=1)
    
    std_values = Any[]

    #transform all the simulations into one array and fix a common time (the min time of all simulations)
    reference_simulation=vec(results[reference_sim][variable].data[:,:,:,1:min_time])
    rho_values= Any[]   

    variable_name=string(variable)
    name_out=Any[]

    for i in eachindex(results)

        std_loop = std(results[i][variable].data)
        
        converted_simulation=vec(results[i][:T].data[:,:,:,1:stop_time])

        rho_loop = cor(reference_simulation,converted_simulation)

        value=name[i][variable_name]

        name_loop = "$variable_name = $value" 

        push!(std_values,std_loop)
        push!(rho_values, rho_loop)
        push!(name_out,name_loop)
    end

    df=DataFrame(std=std_values,rho=rho_values,name=name_out)

    return df

end

df=statistics_csv(results,test)

CSV.write("simulations_statistics.csv", df)   



##
function tes(variables=[:w,:T,:Sa,:νₑ])

    a=Any[]
    for j in eachindex(variables)
        an=results[1][variables[j]].data
        push!(a,an)
    end

    return a
end

b=tes()