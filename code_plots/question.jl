using CairoMakie
using Oceananigans
using GibbsSeaWater

include("test_funct.jl")

##WORKING example 
T_interest=15:12/100:27
S_interest=34:3/100:37

T_trans_1=collect(Iterators.flatten(T_interest))
S_trans_1=collect(Iterators.flatten(S_interest))

σ=TS_σ(T_trans_1,S_trans_1)

fig=Figure()

ax=Axis(fig[1, 1], xgridcolor = :black,
ygridcolor = :black,
xgridwidth = 1,
ygridwidth = 1)

#add a heatmap to see the density
fig, ax, hm = heatmap(S_trans_1,T_trans_1,σ)
Colorbar(fig[:, end+1], hm)

isovariable_test(ax,S_trans_1,T_trans_1,σ,23:0.4:25)

display(fig)


##NOT WORKING example (with data of the model)

#Load the variables of the model
include("test_funct.jl")
load_variable()    

T_interest=T.data[32,16,:,41]
S_interest=Sa.data[32,16,:,41]

T_trans=convert(Vector{Float64},T_interest)
S_trans=convert(Vector{Float64},S_interest)

σ=TS_σ(T_trans,S_trans)

#T_rg=range(T_interest,25)
#S_rg=range(S_interest,25)

#T_trans_1=collect(Iterators.flatten(T_rg))
#S_trans_1=collect(Iterators.flatten(S_rg))

fig=Figure()

ax=Axis(fig[1, 1], xgridcolor = :black,
ygridcolor = :black,
xgridwidth = 1,
ygridwidth = 1)

#add a heatmap to see the density
fig, ax, hm = heatmap(S_trans,T_trans,σ)
Colorbar(fig[:, end+1], hm)

ran=range(σ,3)

isovariable_test(ax,S_trans,T_trans,σ,ran)

display(fig)


##






