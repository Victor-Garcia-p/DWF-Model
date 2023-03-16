using PlotlyJS
#σ = gsw_sigma0.(Sa[1].data[:, 16, :, 21], T[1].data[:, 16, :, 21])

xx=convert(Vector{},results[1][:xT])
yy=convert(Vector{},results[1][:zT])
zz=convert(Matrix{Float64},variable_plot[1])'

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
