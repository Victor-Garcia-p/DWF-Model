#first executate the file to load data

function section(
    x=xT,
    y=zT,
    data=variable_plot[1],
    dim=[1,1],
    overwrite=false
    )

    reshaped_data = reshape(data, (size(x,1),size(y,1)))

    if dim==[1,1] && overwrite==true
        global fig = Figure()
    end

    fig[dim[1],dim[2]] = GridLayout()

    ax=Axis(fig[dim[1],dim[2]])
    
    global my_section=heatmap!(ax, x, y, reshaped_data)
    
    fig
end

##

themes=
    Theme(
        colormap= cgrad(:thermal),
        Axis = (
            xlabel="T (ºC)",
            ylabel="Depth (m)",
            title = "PLOT1"),
            

        Colorbar=(label = "Temperature ᵒC",ticksize=16, tickalign=1, spinewidth=0.5)
        
    )
    

with_theme(themes) do
    
    section(xT,zT,variable_plot[1],[1,1],true),
    Colorbar(fig[1,2], my_section)
    
end

fig
