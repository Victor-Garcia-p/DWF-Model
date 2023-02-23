#=
Info: 

Input: 
Output: 

References: 
=#

using DrWatson

#1) el fitxer jld2
#2) el nom de la variable que vols representar 
#3) altres parametres especifics del tipus de plot com a keyword arguments (time-step del video, etc). O alguna cosa semblant a aquesta.

@quickactivate                  #load the local environment of the project and custom functions

include("plots_functions.jl")
load_grid()

#names of the files (without .jld2)
file_names=["3WM_u₁₀=15_S=35.0-35.0-35.0_dTdz=0.04_T=13.18-13.38-12.71_dim=2D_t=1200.0",
"3WM_u₁₀=20_S=35.0-35.0-35.0_dTdz=0.04_T=13.18-13.38-12.71_dim=2D_t=1200.0"]


load_file(file_names)
read_variables(file_names)

load_AOI(32, 16, :, 21, T)

##


function profile(x=2)

    fig = Figure(resolution = (1200, 800))
    ax = Axis(
    fig[1, 1],
    ylabel = "Depth (m)",
    xlabel = "Temperature(C)",
    title = "Secció a t=40min variant la magnitud del vent (=condicions inicials)",
    )

    return sca1 = scatter!(ax, t_0, zT)
    
end

#t_0 = T[2].data[32, 16, :, end]
#t_02 = T[1].data[32, 16, :, end]

t_0 = variable_plot[1]
t_02 = T[1].data[32, 16, :, 3]


fig = Figure(resolution = (1200, 800))
ax = Axis(
    fig[1, 1],
    ylabel = "Depth (m)",
    xlabel = "Temperature(C)",
    title = "Secció a t=40min variant la magnitud del vent (=condicions inicials)",
)

sca1 = scatter!(ax, t_0, zT)
sca2 = scatter!(ax, t_02, zT)
#sca0 = scatter!(ax, t_0, zT, linewidth = 0.3)

#=
#axislegend(
    ax,
    [sca0, sca1, sca2],
    ["Initial situation", "5", "10"],
    "Modul velocitat vent (m/s)",
    position = :rb,
    orientation = :horizontal,
)
=#

display(fig)

##2          
#2) Create a section, x, in a fixed t
#note: a meridional section would be the same fixing x and not the y

σ = gsw_sigma0.(Sa.data[:, 16, :, 21], T.data[:, 16, :, 21])

Tn = reshape(σ, (32, 24))
#Sn=reshape(Sa.data[:,12,:,11],(32,32))

#σ=gsw_sigma0.(Sa.data[:,:,:,21],T.data[:,:,:,21])

fig = Figure(resolution = (1200, 800))

axis_kwargs = (xlabel = "x (m)", ylabel = "z (m)")
#

ax_T = Axis(fig[1, 1]; title = "Temperature at time=X", axis_kwargs...)
hm_T = heatmap!(ax_T, xT, zT, Tn, colormap = :thermal)
Colorbar(fig[1, 2], hm_T; label = "Temperature ᵒC")

#problems with rg
#rg=range(σ,7)
#isovariable_test(ax_T,xT, yT,σ,24.71:0.001:24.73)

display(fig)

##3)
#Create a transversal section evolution in a fixed x (profile of control)
Tn_a = reshape(T[1].data[30, 16, :, :], (24, 41))
Tn = transpose(Tn_a)

fig = Figure(resolution = (1200, 800))

axis_kwargs =
    (xlabel = "Time (s)", ylabel = "z (m)", aspect = AxisAspect(grid.Lx / grid.Lz))

#

ax_T = Axis(fig[1, 1]; title = "Temperature evolution at a fixed location", axis_kwargs...)
hm_T = heatmap!(ax_T, T.times, zT, Tn, colormap = :thermal)
Colorbar(fig[1, 2], hm_T; label = "Temperature ᵒC")

display(fig)
