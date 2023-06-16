#=
Info: This script calculates the errors of simulations to buoi and creates a dataframe with 
all this data. This dataframe can be used in a Taylor diagram to plot the results

Output: dataframe (used to create Fig 8 of TFG)
=#


using DrWatson
@quickactivate

using NCDatasets 

include(projectdir("code_plots","plots_functions.jl"))
include(projectdir("code_model","model_functions.jl"))
include("plots_functions2.jl")

#1) Load NCF files (reference simulation)

data=load_NCF("OS_LION_2013_D_30min.nc")

raw_timestep=collect(range(9141, stop=9477))
time_step=floor.(Int,raw_timestep)

z2_index=
[3,8,13,17,18,20]

function buoi_ref(;data=data,ref_time=time_step,ref_depths=z2_index,variable=:T)
    all_boi_data=Any[]

    for i in eachindex(ref_time)
        time=AOI_NCF(data,ref_time[i])
        push!(all_boi_data,time)
    end
    
    boi_time=Any[]
    
    for i in eachindex(ref_time)
        time=all_boi_data[i][:t]
        push!(boi_time,time)
    end  

    boi_data=hcat([all_boi_data[j][variable] for j=eachindex(all_boi_data)]...)

    control_depth=[]
        
    for z in eachindex(ref_depths)
        depth_n=boi_data[ref_depths[z],:]

        push!(control_depth,depth_n)  
    end

    matrix_depths=hcat(control_depth...)
    clean_matrix=transpose(matrix_depths)

    return clean_matrix

end

buoi_data=gsw_sigma0.(buoi_ref(variable=:S),buoi_ref(variable=:T))

##
#2) Load simulations to compare
file_names=["Precon_u₁₀=30_S=38.412-38.522-38.533-38.518-38.503-38.487-38.475-38.482-38.485-38.492-38.492_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932-12.906-12.901-12.901-12.897-12.904_t=605000.0"]

results = load_simulation.(file_names)
simulation_parameters=read_parameters.(file_names)  #Dict() with the parameters of both simulations

##
#Select only the times that the buoi has measures
#step=time_step
raw_sim_timestep=collect(range(1, stop=10081,step=30))
sim_time_step=floor.(Int,raw_sim_timestep)

#Which index of simulations have a depth similar to the buoi?
z_index=
[8, 14, 22, 30, 35, 40]

function sim_control_definition(;files=file_names,sim_results=results,depths_index=z_index,time_index=sim_time_step,variable=:T)
    all_depths=[]

    for i in eachindex(files)

        control_time=[]

        for t in eachindex(time_index)
            time_n=sim_results[i][variable].data[1,1,:,time_index[t]]

            push!(control_time,time_n)  
        end

        matrix_time=hcat(control_time...)

        push!(all_depths,matrix_time)

    end

    simulation_data=[]

    for i in eachindex(files)

        control_depth=[]
    
        for z in eachindex(depths_index)
            depth_n=all_depths[i][depths_index[z],:]
    
            push!(control_depth,depth_n)  
        end
    
        matrix_depths=vcat(control_depth...)

        size_timestep=size(time_index,1)
        size_controldepths=size(depths_index,1)
        clean_matrix=reshape(matrix_depths,(size_controldepths,size_timestep))
    
        push!(simulation_data,clean_matrix)
    end
    
    return simulation_data

end

#Vector of all the simulations, setted on control depths and times (according to buoi)

sim_data=[]

for i in eachindex(file_names)
    S_sim_data=sim_control_definition(variable=:Sa)
    T_sim_data=sim_control_definition(variable=:T)

    sigma=gsw_sigma0.(S_sim_data[i],T_sim_data[i])

    push!(sim_data,sigma)
end

#3) Calculate the values for a Taylor diagram

function statistics_csv(;sim_data=sim_data,buoi_data=buoi_data,sim_params=simulation_parameters,variable_name=:T)
    
    string_variable_name=string(variable_name)
    
    std_values = [std(buoi_data)]
    rho_values= [1.0]  
    name_out=["REF"]

    vectorized_buoi=vec(buoi_data)

    for i in eachindex(file_names)

        std_loop = std(sim_data[i])

        vectorized_sim=vec(sim_data[i])
        
        rho_loop = cor(vectorized_buoi,vectorized_sim)

        value=sim_params[i][variable_name]
        name_loop = "$string_variable_name = $value" 

        push!(std_values,std_loop)
        push!(rho_values, rho_loop)
        push!(name_out,name_loop)
    end

    df=DataFrame(std=std_values,rho=rho_values,name=name_out)

    return df

end

df=statistics_csv(variable_name="u₁₀")

CSV.write("simulations_statistics.csv", df)

