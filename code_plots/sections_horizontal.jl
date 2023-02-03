using DrWatson
using CairoMakie
using Oceananigans
using GibbsSeaWater

#load the local environment not the global which is defauld in Julia
@quickactivate "DWC_model"
include("plots_functions.jl")

#names of the files that we want to use (without .jld2)
load_file("test1")


##2
#2) Create a transversal section, x, in a fixed t
#note: a meridional section would be the same fixing x and not the y

σ = gsw_sigma0.(Sa.data[:, :, :, 41], T.data[:, :, :, 41])

#Calculate the SI (Stratification index)
matrix = Any[]

for i = 1:24, j = 1:24
    push!(matrix, σ[i, j, :])
end

matrix_convert = transpose(reshape(matrix, 24, 24))
S_index = SI.(matrix_convert, 24)

#Plot the figure
fig = Figure(resolution = (1200, 800))

axis_kwargs = (xlabel = "x (m)", ylabel = "z (m)")
#

ax_T = Axis(fig[1, 1]; title = "Stratification Index", axis_kwargs...)
hm_T = heatmap!(ax_T, xT, yT, S_index, colormap = :thermal)
Colorbar(fig[1, 2], hm_T; label = "Stratification Index")

display(fig)
