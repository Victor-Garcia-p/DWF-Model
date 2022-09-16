using CairoMakie
using Oceananigans
using GibbsSeaWater


##
include("plots_functions.jl")

#Load files
load_variable()    

TS = Figure(resolution=(1200, 800))
ax = Axis(TS[1, 1], ylabel = "Temperature(°C)", xlabel = "Salinity(psu)")
ax.title="Diagrame TS"

T_interest=T.data[32,16,:,41]
S_interest=Sa.data[32,16,:,41]

T_def=convert(Vector{Float64},T_interest)
S_def=convert(Vector{Float64},S_interest)

sca1=scatter!(ax, S_def, T_def,color=zT,markersize = 20,colormap=:thermal)

σ=TS_σ(T_def,S_def)

isovariable_test(ax,S_def,T_def,σ,22:0.04:24.8)
Colorbar(TS[1, 2], limits = (-30,0),ticks = -30:6:0,
colormap = cgrad(:thermal, 5, categorical = true), size = 25,
label = "Depth(m)")

display(TS)

##
include("test_funct.jl")
load_variable() 

Tn=reshape(T.data[:,16,:,40],(32,24))

fig = Figure(resolution=(1200, 800))

axis_kwargs = (xlabel="x (m)", ylabel="z (m)")

ax_T  = Axis(fig[1,1]; title = "Temperature at time=X", axis_kwargs...)
hm_T = heatmap!(ax_T,xT, zT,Tn,colormap = :oxy)

ran=range(Tn,3)

isovariable_test(ax_T,xT, zT,Tn,19.7:0.03:19.9)

Colorbar(fig[1, 2], hm_T; label = "Temperature ᵒC")


display(fig)


##
a="test"
if typeof(a)==String
    print("String")
end

if typeof(a)==Int64
    print("Int64")
end

##
include("test_funct.jl")

T_interest=15:12/100:27
S_interest=34:3/100:37

T_trans_1=collect(Iterators.flatten(T_interest))
S_trans_1=collect(Iterators.flatten(S_interest))

σ=TS_σ(T_trans_1,S_trans_1)

isovariable_test(S_trans_1,T_trans_1,σ,23:0.4:25)

