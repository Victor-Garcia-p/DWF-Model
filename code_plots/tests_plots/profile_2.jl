

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