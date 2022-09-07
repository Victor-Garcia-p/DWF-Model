#load drom a file TS variables, grid and position of the variables in the grid
#ir requires an argument, name, with the name of all the files

function load_variable(name_defauld="model_data_sim")
    #define the path of the model data&grid
    grid = joinpath(@__DIR__, "..", "code","grids_generation.jl")
    include(grid)
    filepath_in = joinpath.(@__DIR__, "..", "data", name_defauld.*".jld2")

    global Sa = FieldTimeSeries.(filepath_in, "S") 
    global T = FieldTimeSeries.(filepath_in, "T")

    global xT, yT, zT = nodes(T[1])

    return nothing
end

