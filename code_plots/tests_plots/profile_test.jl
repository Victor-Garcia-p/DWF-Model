#first executate the file to load data

function profile(
    x=variable_plot,
    y=zT,
    dim=[1,1],
    overwrite=false
    )

    if dim==[1,1] && overwrite==true
        global fig = Figure()
    end

    fig[dim[1],dim[2]] = GridLayout()

    ax=Axis(fig[dim[1],dim[2]])

    global my_sections=Any[]

    for i in eachindex(x)

        plot=scatterlines!(ax, x[i], y)
        push!(my_sections,plot)
    end    

    fig
end

#file of plots

themes=
    Theme(
        Axis = (
            xlabel="T (ºC)",
            ylabel="Depth (m)",
            title = "PLOT1"),

        Colorbar=(label = "Temperature ᵒC",ticksize=16, tickalign=1, spinewidth=0.5),
        
        Legend=(framecolor=(:red, 200), bgcolor=(:red, 0.5)))
#


##
with_theme(themes) do

    profile(variable_plot,results[1][:zT],[1,1],true),
    Legend(fig[1, 2],my_sections,["test1","test2"],"Figure tytle")
    
end

fig

##
   

##Do two plots differents
profile(variable_plot,zT,[1,1],true)

with_theme(themes[2]) do

    profile(variable_plot,zT,[1,2])
    
end

with_theme(themes[1]) do

    profile(variable_plot,zT,[1,1])
    
end

display(fig)

##
#Example for README

themes=
    Theme(
        Axis = (
            xlabel="T (ºC)",
            ylabel="Depth (m)",
            title = "PLOT1"))
#

with_theme(themes) do

    profile(variable_plot,results[1][:zT],[1,1],true)
    
end

fig
