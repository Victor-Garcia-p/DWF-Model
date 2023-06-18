#=
Info: Use DIVA on a simulation

Output: Fig 6b
=#
using DrWatson
@quickactivate

include(projectdir("code_plots","plots_functions.jl"))
include(projectdir("code_model","model_functions.jl"))
include(projectdir("results_TFG","plots_functions2.jl"))

using Serialization
import Dates
using DIVAnd

file_names=["Precon_u₁₀=30_S=38.412-38.522-38.533-38.518-38.503-38.487_dTdz=0.0_T=13.038-13.282-13.188-13.079-13.035-12.932_t=2400.0"]


##Load the data each time step
results=deserialize(datadir("variables","Taylor_sim_data.dat"))

σ2=[]

function DIVA_resize(x,y,f,final_grid;len=(10,27), epsilon2 = 1/50)

    #x,y,f (time,depth,variable)
    x=convert.(Float64,x)
    y = convert.(Float64,y);
    f = convert.(Float64,f);

    # final grid
    xi,yi = ndgrid(final_grid[1],final_grid[2]);

    # all points are valid points
    mask = trues(size(xi));

    # this problem has a simple cartesian metric
    # pm is the inverse of the resolution along the 1st dimension
    # pn is the inverse of the resolution along the 2nd dimension
    pm = ones(size(xi)) / (xi[2,1]-xi[1,1])
    pn = ones(size(xi)) / (yi[1,2]-yi[1,1]);

    # correlation length (how much y do we want?)
    #len = (1,27);

    # obs. error variance normalized by the background error variance
    #epsilon2 = 1/50;

    # fi is the interpolated field
    fi,s = DIVAndrun(mask,(pm,pn),(xi,yi),(x,y),f.-mean(f),len,epsilon2,alphabc=0);

    return xi,yi,fi
end

for i in 1:5
    time_interval=range(1, stop=10753,step=1)
    sim_time_step=floor.(Int,collect(time_interval))

    T_AOI=AOI_simulation(1,1,:,time_interval)
    S_AOI=AOI=AOI_simulation(1,1,:,time_interval,:Sa)
    nothing

    z=reverse(grid.zᵃᵃᶜ[1:Nz]*-1)
    z_sparcing=reverse(grid.Δzᵃᵃᶜ[1:Nz])

    #Coordinates of each point

    d = Dict{Symbol, Any}()

    d[:T]=vcat(T_AOI[:data][i]...)
    d[:Sa]=vcat(S_AOI[:data][i]...)

    d[:y]=repeat(z,size(sim_time_step,1))
    d[:x]=[]

    for t in eachindex(sim_time_step)
        n=fill(sim_time_step[t],40)
        push!(d[:x],n)
    end

    d[:x]=vcat(d[:x]...)

    ##DIVA
    gr=[range(1,stop=10753,length=721),
    range(1,stop=1100,length=700)]

    xi,yi,T=DIVA_resize(d[:x],d[:y],d[:T],gr,len=(1,50))
    xi,yi,S=DIVA_resize(d[:x],d[:y],d[:Sa],gr,len=(1,50))

    σ=gsw_sigma0.(S.+mean(d[:Sa]),T.+mean(d[:T]))

    push!(σ2,σ)
end

##
#creation of the x axis

date_step=range(1,stop=sim_time_step[end],length=10)

converted_time=[]

for i in eachindex(date_step)
    
    full_date=Dates.unix2datetime(1358207940+60*date_step[i])
    converted_date=Dates.format(full_date, "mm-dd")
    string_date=string(converted_date)
    
    push!(converted_time,string_date)
end

##
themes=
    Theme(
        colormap= cgrad(:viridis,13,categorical=true),
        Figure=(resolution = (1200, 1200)),
        Axis = (
            xlabel="Data (més-dia)",
            ylabel=" Profunditat (m)",
            title = "",
            limits = (nothing, nothing, -1100.0,0.0),
            xticks = (collect(date_step), converted_time),
            yticks=0:-200:-1100,
            yminorticksvisible = true,
            #xminorticksvisible = true,
            xticklabelsvisible = true),
            

        #Other objects such as the Colorbar can be also costumized
        Colorbar=(label = "σ₀ (kg/m^3) ",ticksize=16, tickalign=1, spinewidth=0.5
        )
         
)  

with_theme(themes) do
    
    my_section=section(xi[1:end,1],yi[1,1:end,1]*-1,reverse(σ,dims=2),[1,1],true)

    Colorbar(fig[1,2], my_section,ticks = 28.87:0.02:29.00)

end

display(fig)

##
