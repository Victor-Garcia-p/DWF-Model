#=
Info: Calculate difference of buoy and sim for sigma

Output: Fig 7
=#


using DrWatson
@quickactivate

using NCDatasets 
using DIVAnd
using Dates
using Serialization
using Oceananigans

σ_sim = deserialize(datadir("variables","sigma_sim.dat"))
σ_buoi = deserialize(datadir("variables","sigma_buoi.dat"))


dif=σ_sim-σ_buoi[1:720,:]
nothing

##
t=720

#vectorize the data of the sim, buoi and difference 
vec_data=[vec(dif[1:t,1:700]),σ_sim[1:t,:],σ_buoi[1:t,:]]

stats=[mean(vec_data[1]),
std(vec_data[1]),
quantile(vec_data[1], 0.25),
quantile(vec_data[1], 0.5),
quantile(vec_data[1], 0.75),
rmsd(vec_data[2],vec_data[3]),
mean(cor(vec_data[2],vec_data[3])),
median(cor(vec_data[2],vec_data[3]))]

stats=round.(stats,digits=3)

##
a=cor(σ_sim[1:t,:],σ_buoi[1:t,:])

b=quantile!(a, 0.75)

##
t=155

a=(mean(cor(σ_sim[1:t,:],σ_buoi[1:t,:],dims=1)))


##

themes=
    Theme(
        colormap= cgrad(:viridis,5,categorical=true),
        Figure=(resolution = (1200, 1200)),
        Axis = (
            xlabel="Data (més-dia)",
            ylabel=" Profunditat (m)",
            title = "",
            limits = (nothing, nothing, -1100.0,0.0),
            #xticks = (collect(date_step), converted_time),
            yticks=0:-200:-1100,
            yminorticksvisible = true,
            #xminorticksvisible = true,
            xticklabelsvisible = true),
            

        #Other objects such as the Colorbar can be also costumized
        Colorbar=(label = "Δσ₀ (kg/m^3) (simulació-boia)",ticksize=16, tickalign=1, spinewidth=0.5
        )
         
)  

with_theme(themes) do
    
    my_section=section(xi[1:end-1,1],yi[1,1:end,1]*-1,dif,[1,1],true)

    Colorbar(fig[1,2], my_section)

end

display(fig)



