##Contours a la llibreria PlotlyJS
##Objectiu: crear un grafic amb nomes el contours i les labels per superpossar-ho
##amb una grafica de makie

using DrWatson
using PlotlyJS

@quickactivate                  #load the local environment of the project and custom functions

include("plots_functions.jl")
load_grid()

#names of the files (without .jld2)
file_names=["3WM_u₁₀=15_S=35.0-35.0-35.0_dTdz=0.04_T=13.18-13.38-12.71_dim=2D_t=1200.0",
"3WM__u₁₀=0_S=37.95-38.54-38.41_dTdz=0.01_T=13.18-13.38-12.71_dim=2D_t=43200.0"]

load_files(file_names)
read_parameters(file_names)
define_AOI(:, 16, :, 21, T)

σ = gsw_sigma0.(Sa[1].data[:, 16, :, 21], T[1].data[:, 16, :, 21])

xx=convert(Vector{},xT)
yy=convert(Vector{},zT)
zz=convert(Matrix{Float64},σ)'

function iso(x,y,z)

    con=PlotlyJS.contour(x=x,y=y,z=z,
        contours_coloring="lines",
        line_width=2,
        showscale=false,
        showlabels=false,
        showgrid=false,
        

        # heatmap gradient coloring is applied between each contour level
        contours=attr(
            showlabels = true, # show labels on contours
            labelfont = attr(   # label font properties
                size = 12,
                color = "black",
            )
        ))

        layout = Layout(
        xaxis=attr(
            visible = false
        ),
        yaxis=attr(
            visible = false
        )
    )
    #

    global fig2=PlotlyJS.plot(con,layout)
end

iso(xx,yy,zz)
