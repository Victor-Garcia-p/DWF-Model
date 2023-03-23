#=
Info:
Input: Simulations from the model (.jld2)
Output: Differents plots
=#

using DrWatson

@quickactivate                  #load the local environment of the project and custom functions

include(joinpath(@__DIR__, "..", "plots_functions.jl"))

#names of the files (without .jld2)
file_names=["3WM_u₁₀=15_S=35.0-35.0-35.0_dTdz=0.04_T=13.18-13.38-12.71_dim=2D_t=1200.0",
"3WM_u₁₀=0_S=37.95-38.54-38.41_dTdz=0.01_T=13.18-13.38-12.71_dim=2D_t=86400.0"]

results = load_files.(file_names)
simulation_parameters=read_parameters.(file_names)

##
function statistics_csv(results,name,variable=:T,min_time=21,reference_sim=1)
    
    std_values = Any[]

    #transform all the simulations into one array and fix a common time (the min time of all simulations)
    reference_simulation=vec(results[reference_sim][variable].data[:,:,:,1:min_time])
    rho_values= Any[]   

    variable_name=string(variable)
    name_out=Any[]

    for i in eachindex(results)

        std_loop = std(results[i][variable].data)
        
        converted_simulation=vec(results[i][:T].data[:,:,:,1:min_time])

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

df=statistics_csv(results,simulation_parameters)

CSV.write("simulations_statistics.csv", df)
nothing   
