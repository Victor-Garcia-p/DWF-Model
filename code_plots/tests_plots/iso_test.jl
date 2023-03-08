function isovariable_test(ax, S_trans_1, T_trans_1, σ, isopicnals_range = 23:0.5:26)
    #Now that we now that the density is correct we can add the isopicnals
    #First we will create the lines, which are contours which are writen each 
    #x interval ("isopicnals_range").
    isopicnals_name = collect(isopicnals_range)

    con = contour!(
        S_trans_1,
        T_trans_1,
        σ,
        levels = isopicnals_range,
        linewidth = 5,
        colormap = :reds,
    )

    #Now we will create a point above which we will display the text

    beginnings = Point2f[]
    colors = RGBAf[]

    # First plot in contour is the line plot, first arguments are the points of the contour
    segments = con.plots[1][1][]
    for (i, p) in enumerate(segments)

        # the segments are separated by NaN, which signals that a new contour starts
        #i-50 indicates that each point will be separated 50 points
        if isnan(p)
            push!(beginnings, segments[i-30])
        end
    end

    sc = scatter!(
        ax,
        beginnings,
        markersize = 50,
        color = 1:length(beginnings),
        colormap = :reds,
    )

    #Prepare the coords to add text
    #we will add xy positions and then convert the object into a matrix wich "float32" types
    coords_unchanged = hcat(beginnings...)'
    coords = convert(Matrix, coords_unchanged)

    #Loop to locate the text
    maxim = size(coords, 1)

    for i = 1:maxim
        text!(
            "$(round(isopicnals_name[i];digits=2))",
            position = (coords[i, 1], coords[i, 2]),
            align = (:center, :center),
        )
    end
end

##


section(xT,zT,σ,[1,1],true)


##
using PlotlyJS

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




