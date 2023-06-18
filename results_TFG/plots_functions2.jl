using Interpolations
using NCDatasets

#load a NCF file
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

#AOI from a NCF file
function AOI_NCF(data,time=:,depth=:)
    d = Dict{Symbol, Any}()

    d[:T]=data[:T][depth,time]
    d[:S]=data[:S][depth,time]
    d[:z]=data[:z][depth,1]
    d[:t]=data[:t][time]

    @info "AOU defined"
    return d
end


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


function sigma_calculator(;time_step=time_step,x=1,y=1)
    variable_plot_T=AOI_simulation.(x, y, :, time_step) 
    variable_plot_S=AOI_simulation.(x, y, :, time_step,:Sa) 

    sigma=[]

    for i in eachindex(file_names)

        sim_n=[]

        for t in eachindex(time_step)
            sigma_n=gsw_sigma0.(variable_plot_S[t][:data][i],variable_plot_T[t][:data][i])
            push!(sim_n,sigma_n)
        end

        push!(sigma,sim_n)
    end

    return sigma
end


"""
Note: z needs to be positive
"""
function regrid(grid_transformed=grid_transformed,values=AOI[:T][1:20],grid_points=AOI[:z][1:20])

    Af = [a for a in values if !ismissing(a)]
    xf = [xi for (xi,a) in zip(grid_points, values) if !ismissing(a)]

    itp = LinearInterpolation(xf, Af,extrapolation_bc=Line()) 

    grid_interest=[]
    
    for z in eachindex(grid_transformed)
        new_point=itp(grid_transformed[z])
        push!(grid_interest,new_point)
    end
    
    return grid_interest
end

function regrid_t(grid_transformed=grid_transformed,values=AOI[:T][1:20],grid_points=AOI[:z][1:20])

    Af = [a for a in values if !ismissing(a)]
    xf = [xi for (xi,a) in zip(grid_points, values) if !ismissing(a)]

    itp = LinearInterpolation(xf, Af,extrapolation_bc=Line()) 

    grid_interest=[]
    
    for z in eachindex(grid_transformed)
        new_point=itp(grid_transformed[z])
        push!(grid_interest,new_point)
    end
    
    return grid_interest
end


function create_layers(data,time,last_index=20)

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