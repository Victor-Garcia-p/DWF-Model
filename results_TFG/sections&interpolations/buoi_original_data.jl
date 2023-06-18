#=
Info: This script plots the data of the buoi without any interpolation methode. It creates
a time section of the data

Input: Buoi data (OS_LION_2013_D_30min.nc) located at 
DWF-Model\data\Lion_mooring

Output: time section (heatmap plot with x=time y=depth and z=density)

References: Buoi data from LION observatory data (Bosse et al., 2023)
https://www.seanoe.org/data/00333/44411/

DOI=10.17882/44411
=#

using DrWatson
@quickactivate

using Dates

include(projectdir("code_plots","plots_functions.jl"))
include(projectdir("code_model","model_functions.jl"))
include(projectdir("results_TFG","plots_functions2.jl"))

#Load buoi data
buoi_data=load_NCF("OS_LION_2013_D_30min.nc")

#Select time to load 
raw_timestep=range(100, stop=15700,step=1)
time_step=floor.(Int,collect(raw_timestep))

AOI=AOI_NCF(buoi_data,raw_timestep)


"""
Load the TS from each valid layer from the buoi 
and then calculate density
a layer is valid if it has values of TS at the same point.
"""
function valid_point_TS(data,time,last_index=20)

    d =[]

    for i in 1:last_index

        layer=[data[:z][i,1],
            data[:S][i,time],
            data[:T][i,time]]
        
        corrected_layer=collect(skipmissing(layer))

        if size(corrected_layer,1)==3
           
            corrected_1=round(          
            convert(Float64,corrected_layer[1]),digits=3)

            corrected_2=round(          
            convert(Float64,corrected_layer[2]),digits=3)

            corrected_3=round(          
            convert(Float64,corrected_layer[3]),digits=3)

            valid_layer=[corrected_1,
            corrected_2,
            corrected_3]
            
            push!(d,valid_layer)
        end

    end

    return hcat(d...)'
end

all_σ=[]
all_z=[]

for t in 100:15700
    values=valid_point_TS(data,t)
    σ=gsw_sigma0.(values[:,2],values[:,3])
   
    z_n=a[:,1]

    push!(all_σ,σ)
    push!(all_z,z_n)
end

#transform values to plot in y and z axis
z=all_z[1]
σ=hcat(all_σ...)


#X axis: Decide the intervals of time to plot and change the 
#format to seconds to day-month
new_interval=1:2000:15601
string_date=string.(Dates.format.(AOI[:t][new_interval], "mm-dd"))

themes=
    Theme(
        colormap= cgrad(:viridis,8,categorical = false),
        
        Figure=(resolution = (1200, 1200)),
 
        Axis = (
            xlabel="Data (més-dia)",
            ylabel=" Profunditat (m)",
            title = "",
            limits = (nothing, nothing, -1100.0,0.0),
            xticks = (time_step[new_interval], string_date),
            yticks=0:-200:-1100,
            yminorticksvisible = true,
            xminorticksvisible = true),

        Colorbar=(label = "σ₀ (kg/m^3) ", 
        size = 25)
        )
#           

with_theme(themes) do
    
    my_section=section(time_step,z*-1,σ,[1,1],true)

    Colorbar(fig[2,1], my_section, vertical = false, flipaxis = false)

end

display(fig)
