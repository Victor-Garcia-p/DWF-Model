#=
Info: This scripts is used to calculate SI of buoy and simulations

Input: data of simulations with wind from 0 to 50 m/s (SI_data_v0_v50.dat)
and buoy data.

Output: Fig 9
=#

# 0. Before starting, load the project environment 
using DrWatson


@quickactivate

include(projectdir("code_plots","plots_functions.jl"))
include("plots_functions2.jl")

##
using Serialization
using Dates

results=deserialize(datadir("variables","SI_data_v0_v50.dat"))
buoi_results=deserialize(datadir("variables","sigma_sim.dat"))

##
#2) Calculation of SI for simulations
file_names=[
"SI_u₁₀=0_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=605000.0",
"SI_u₁₀=10_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=605000.0",
"SI_u₁₀=15_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=605000.0",
"SI_u₁₀=20_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=605000.0",
"SI_u₁₀=25_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=605000.0",
"SI_u₁₀=30_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=605000.0",    
"SI_u₁₀=35_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=605000.0",
"SI_u₁₀=40_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=605000.0",
"SI_u₁₀=45_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=605000.0",
"SI_u₁₀=50_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=605000.0"
]

#results= load_simulation.(file_names)
simulation_parameters=read_parameters.(file_names)  #Dict() with the parameters of both simulations

##
time_step=range(1,stop=10081,step=500)
buoi_time_step=range(8325, stop=9045,step=1)

sigma=sigma_calculator(time_step=time_step)
nothing

##
function SI_calculator(data,z_index_ref=40,time=time_step)

    sim_Si=Float32[]

    #fix the time
    for t in eachindex(time)
        individual_Si=[]
    
        #fix the depth
        for z in 1:z_index_ref
            difference=data[t][z]-data[t][z_index_ref]
            push!(individual_Si,difference)
        end
        
        n_Si=sum(individual_Si)
    
        push!(sim_Si,n_Si)
    end
    
    return sim_Si
end

data=SI_calculator.(sigma)
nothing

buoi_SI=[]

for t in 1:21
    depth_ref=buoi_results[t,636]

    individual_SI=[]

    for z in 1:720
        n_SI=buoi_results[z,636]-depth_ref
        push!(individual_SI,n_SI)
    end

    total_SI=sum(individual_SI)
    push!(buoi_SI,total_SI)
end

data[1]=buoi_SI


##
#creation of the x axis

date_step=range(1,stop=time_step[end],length=10)

converted_time=[]

for i in eachindex(date_step)
    
    full_date=Dates.unix2datetime(1358207940+60*date_step[i])
    converted_date=Dates.format(full_date, "mm-dd")
    string_date=string(converted_date)
    
    push!(converted_time,string_date)
end


##
# 3)Create the plot

function SI_plot(
    x=variable_plot,
    y=results[1][:zT],
    dim=[1,1],
    overwrite=false
    )

    if dim==[1,1] && overwrite==true
        global fig = Figure()
    end

    fig[dim[1],dim[2]] = GridLayout()

    ax=Axis(fig[dim[1],dim[2]])

    profile_lines=Any[]

    for i in eachindex(y)

        plot=scatterlines!(ax, x, y[i],marker=:utriangle,color=:red)
        push!(profile_lines,plot)
    end    

    return profile_lines
end

##
themes=
    Theme(
        Axis = (
            xlabel="Temps de simulació (s) desde 02-01-13",
            ylabel="SI (kg*m^2)",
            yminorticksvisible=true,
            limits=(-100,10100,nothing,nothing),
            xticks=0:1000:10000))  
#

legend_labels=[]

for i in 2:10
    value=simulation_parameters[i]["u₁₀"]
    N_labels="u₁₀= $value"

    push!(legend_labels,N_labels)
end

with_theme(themes) do

    sim=SI_plot(time_step,data[2:10],[1,1],true)
    Legend(fig[1,2],sim,string.(legend_labels),"Velocitats del vent")
    
end

display(fig)


##
themes=
    Theme(
        Axis = (
            xlabel="Temps de simulació (s) desde 02-01-13",
            ylabel="SI (kg*m^2)",
            yminorticksvisible=true,
            limits=(-100,10100,nothing,nothing),
            xticks=0:1000:10000))  
#

with_theme(themes) do

    sim=SI_plot(time_step,data[1:1],[1,1],true)
    Legend(fig[1,2],sim,["Boia (referència)"])
    
end

display(fig)
