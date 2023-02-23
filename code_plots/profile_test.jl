function profile(
    x_label="my variable (units)",
    y_label="Depth (m)",
    title="a simple plot")
    
    fig = Figure(resolution = (1200, 800))

    ax = Axis(
    fig[1, 1],
    ylabel = y_label,
    xlabel = x_label,
    title = title,
    )

    for i in 1:size(variable_plot,1)
        scatterlines!(ax, variable_plot[i], zT)
    end

    display(fig)    
end

profile()
