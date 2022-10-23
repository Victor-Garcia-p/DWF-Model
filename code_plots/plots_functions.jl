#load drom a file TS variables, grid and position of the variables in the grid
#ir requires an argument, name, with the name of all the files

function load_variable(name_defauld="model_data_sim")
    #define the path of the model data&grid
    grid = joinpath(@__DIR__, "..", "code","grids_generation.jl")
    include(grid)
    filepath_in = joinpath.(@__DIR__, "..", "data", name_defauld.*".jld2")

    global Sa = FieldTimeSeries.(filepath_in, "S") 
    global T = FieldTimeSeries.(filepath_in, "T")
    global νₑ = FieldTimeSeries.(filepath_in, "νₑ")
    global w = FieldTimeSeries.(filepath_in, "w")

    global xT, yT, zT = nodes(T[1])
    global xw, yw, zw = nodes(w[1])

    return nothing
end

#This function loads a variable in a setted location (ex: position x,y of
#the grid). It creates a new variable called "T_plot" with all
#the output of the function
function load_AOI(x,y,z,t,first=1,last=2)
    global T_plot=Any[]
    for i in first:last
        T_interest=T[i].data[x,y,z,t]
    
        #fig = Figure(resolution=(1200, 800))
        #ax = Axis(fig[1, 1], ylabel = "Depth (m)", xlabel = "Temperature(C)")
        #sca=scatter!(ax, T_interest[1], zT)
        push!(T_plot,T_interest)
    end
end

#function to add contours with the name above to create isopicnals, isotermals...
function isovariable_test(ax,S_trans_1,T_trans_1,σ,isopicnals_range=23:0.5:26)
    #Now that we now that the density is correct we can add the isopicnals
    #First we will create the lines, which are contours which are writen each 
    #x interval ("isopicnals_range").
    isopicnals_name=collect(isopicnals_range)

    con=contour!(S_trans_1,T_trans_1,σ,levels=isopicnals_range,linewidth=5,
    colormap=:reds)

    #Now we will create a point above which we will display the text

    beginnings = Point2f[]; colors = RGBAf[]

    # First plot in contour is the line plot, first arguments are the points of the contour
    segments = con.plots[1][1][]
    for (i, p) in enumerate(segments)

        # the segments are separated by NaN, which signals that a new contour starts
        #i-50 indicates that each point will be separated 50 points
        if isnan(p)
            push!(beginnings, segments[i-30])
        end
    end

    sc = scatter!(ax, beginnings, markersize=50, color=1:length(beginnings), colormap =:reds)

    #Prepare the coords to add text
    #we will add xy positions and then convert the object into a matrix wich "float32" types
    coords_unchanged=hcat(beginnings...)'
    coords=convert(Matrix, coords_unchanged)

    #Loop to locate the text
    maxim=size(coords,1)

    for i in 1:maxim
        text!("$(round(isopicnals_name[i];digits=2))",position =(coords[i,1],coords[i,2]),  
        align = (:center, :center))
    end
end

#
function TS_σ(T,S)
    #Change the dimensions of the previous transformation so that they can be used
    #to calculate the density
    T_trans_2 = reverse(T)
    S_trans_2 = transpose(S)

    #Calculate density matrix. This is done using the properties of the multiplication
    #of matrix to achieve the correct dimensions of the matrix.
    Column_1=fill(1, (1,length(T_interest)))
    Row_1=fill(1,(length(S_interest), 1))

    return σ=reverse(transpose(gsw_sigma0.(Row_1*S_trans_2,T_trans_2*Column_1)),dims = 2)
end

##
function range_(variable,sparcing)

    maxi=maximum(variable)
    mini=minimum(variable)

    interval=round(((maxi-mini)/sparcing);digits=4)

    T_interest=round(mini;digits=4):interval:round(maxi;digits=4)
    return convert(StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}, Int64},
    T_interest)
end


#SI function (Stratification Index)
#the function will make the intergral for a defined point
#of the matrix (ex: between the value that has line 1 row 1
#at time 1 and 2)

function SI(σ,Z=σ[end])
    sum(σ[Z].-σ)
end

#Funtion to create the name of the simulation that we want to plot
function name_concatenation(first_simulation,last_simulation)
    for i in first_simulation:last_simulation
        #Define if the data has 2d o 3d dimensions
        if sizeof(dimension)==0
            dim="3D"
        else
            dim="2D"
        end

        #Create the name of the file
        params= name(u₁₀[i],dTdz[i],S[i],dim,end_time[i])
        file=savename("DWF_t",params)
        push!(files,file)
    end
end
