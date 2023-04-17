
using DrWatson
@quickactivate

using NCDatasets

include(projectdir("code_plots","plots_functions.jl"))
include(projectdir("code_model","model_functions.jl"))

function load_NCF(file)

    path=datadir("Lion_mooring",file)
    ds = Dataset(path)
    
    d = Dict{Symbol, Any}()

    d[:T]=ds["POTENTIAL_TEMP"]
    d[:S]=ds["PSAL"]
    d[:z]=ds["DEPTH"]
    d[:t]=ds["TIME"]

    @info "New NCF with T,S,z,time"
    return d
end

data=load_NCF("OS_LION_2013_D_30min.nc")

function AOI_NCF(data,time=:,depth=:)
    d = Dict{Symbol, Any}()

    d[:T]=data[:T][depth,time]
    d[:S]=data[:S][depth,time]
    d[:z]=data[:z][depth,1]
    d[:t]=data[:t][time]

    @info "AOU defined"
    return d
end

AOI=AOI_NCF(data,8325)

#max,S,t

function create_layers(data,time,last_index=26)

    d =Vector{WaterLayer{Float64}}()

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

            valid_layer=WaterLayer(corrected_1,
            corrected_2,
            corrected_3)
            
            push!(d,valid_layer)
        end

    end

    n_layers=size(d,1)
    
    @info "$n_layers layers defined"
    return d
end

layers=create_layers(data,8325)
SW_layer=layers[1]

##
function extra_layers(measure=8325,initial_index=[1,3],final_index=20)
      
    more_T=collect(skipmissing(data[:T][initial_index[1]:final_index,measure]))
    more_z=collect(data[:z][initial_index[2]:final_index,measure])

    return more_T,more_z
end

more_T,more_z=extra_layers()

gradient=Any[]

for i in 2:18
    grad=(more_T[i-1]-more_T[i])/(more_z[i-1]-more_z[i])

    push!(gradient,grad)
end



##
#Set the value of a constant for each simulation. If it’s not specified is taken as default
#To perform more simulations, add another dictionary 
#ex: Dict (:u₁₀=>15) to make a simulation with u₁₀=15 m/s and other values as default

model_arguments = [Dict(:u₁₀=>30, :dTdz=>0.00)  
                                          ]
#

simulation_arguments= [Dict(:t=>10080minutes)]

for kwargs in model_arguments, kwargs2 in simulation_arguments
    build_model(layers;kwargs...,kwargs2...)
    prepare_simulation!(params,model;kwargs2...)
    
    run!(simulation)
end


