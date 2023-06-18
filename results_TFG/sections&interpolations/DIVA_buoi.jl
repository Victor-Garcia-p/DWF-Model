#=
Info: Script to load buoy data and use DIVA

Output: Fig 6a
=#

using DrWatson
@quickactivate

using NCDatasets 
using DIVAnd
using Dates


include(projectdir("code_plots","plots_functions.jl"))
include(projectdir("code_model","model_functions.jl"))
include(projectdir("results_TFG","plots_functions2.jl"))

#0) Load buoi data
buoi_data=load_NCF("OS_LION_2013_D_30min.nc")

#1) Select time to load 
raw_timestep=range(8325, stop=9045,step=1)
time_step=floor.(Int,collect(raw_timestep))

AOI=AOI_NCF(buoi_data,raw_timestep)

function DIVA_transform(x,y,variable)

    all_x=[]
    all_y=[]
    all_variable=[]

    for t in eachindex(variable[1,:])
        values=variable[:,t]

        value_valid = [a for a in values if !ismissing(a)]
        y_valid = [xi for (xi,a) in zip(y, values) if !ismissing(a)]
        x_valid =fill(x[t],size(y_valid))

        push!(all_variable,value_valid)
        push!(all_x,x_valid)
        push!(all_y,y_valid)

    end

    #Join all observations in one array
    d = Dict{Symbol, Any}()

    d[:var]=vcat(all_variable...)
    d[:x]=vcat(all_x...)
    d[:y]=vcat(all_y...)

    return d
end

##
T_t=DIVA_transform(time_step,AOI[:z],AOI[:T])
S_t=DIVA_transform(time_step,AOI[:z],AOI[:S])


"""
**Imput**
correlation length (how much y do we want?)
len = (1,27);

obs. error variance normalized by the background error variance
epsilon2 = 1/50;
"""
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

##
gr=[range(8325, stop=9045,step=1),
range(1,stop=1100,length=700)]

xi,yi,T=DIVA_resize(T_t[:x],T_t[:y],T_t[:var],gr,len=(1,50))
xi,yi,S=DIVA_resize(S_t[:x],S_t[:y],S_t[:var],gr,len=(1,50))

#Calculate the density

σ=gsw_sigma0.(S.+mean(S_t[:var]),T.+mean(T_t[:var]))
nothing

#change the format of x axis to dates

#interval of measures since the start
new_interval=range(1,721,step=71)
string_date=string.(Dates.format.(AOI[:t][new_interval], "mm-dd"))

##

themes=
    Theme(
        colormap= cgrad(:viridis,categorical = false),
        
        Figure=(resolution = (1200, 1200)),
 
        Axis = (
            xlabel="Data (més-dia)",
            ylabel=" Profunditat (m)",
            title = "",
            limits = (nothing, nothing, -1100.0,0.0),
            xticks = (time_step[new_interval], string_date),
            yticks=0:-200:-1100,
            yminorticksvisible = true),

        Colorbar=(label = "σ₀ (kg/m^3) ", 
        ticksize=16, tickalign=1, spinewidth=0.5)
        )
#           

with_theme(themes) do
    
    my_section=section(xi[1:end,1],yi[1,1:end,1]*-1,σ,[1,1],true)

    Colorbar(fig[1,2], my_section,ticks = 28.81:0.02:28.97)

end

display(fig)

