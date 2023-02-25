function profile(
    x_variable=variable_plot,
    y_variable=zT,
    dim=[1,1],
    overwrite=false
    )

    if dim==[1,1] && overwrite==true
        global fig = Figure()
    end

    fig[dim[1],dim[2]] = GridLayout()

    ax=Axis(fig[dim[1],dim[2]])

    for i in eachindex(x_variable)

        scatterlines!(ax, x_variable[i], zT)
    end    

    fig
end

#file of plots

themes=[
Theme(
    Axis = (
        xlabel="T (ºC)",
        ylabel="Depth (m)",
        title = "PLOT1"
)),

Theme(
    Axis = (
        xlabel="T (ºC)",
        ylabel="Depth (m)",
        title = "PLOT2"
    ))
]

##
profile(variable_plot,zT,[1,1],true)

with_theme(themes[2]) do

    profile(variable_plot,zT,[1,2])
    
end

with_theme(themes[1]) do

    profile(variable_plot,zT,[1,1])
    
end

display(fig)

