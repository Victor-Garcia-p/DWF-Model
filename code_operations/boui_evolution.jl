using DrWatson
@quickactivate

using NCDatasets 

#helloow a

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

boi_data=Any[]

for i in 8325:11684
    time=AOI_NCF(data,i)
    push!(boi_data,time)
end

boi_time=Any[]
v = Array{Float32}(undef,(3360,26))

for i in eachindex(boi_data)
    time=boi_data[i][:t]
    push!(boi_time,time)
end

for i in eachindex(boi_data)

    for j in eachindex(boi_data)

    end
    T=boi_data[i][:T]
    push!(v[i,j],T)
end


#Plot for the real convection phase

section(boi_time,boi_data[1][:z],boi_T,[1,1],true)

display(fig)

