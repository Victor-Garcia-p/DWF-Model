
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