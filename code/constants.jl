#=
Info: This file contains all constants that can be changed to define the model
several constants can be defined using [] (ex: u₁₀ = [0,1,2,3] ). This will create multiples files with the 
"model_loop" file.
=#

using Oceananigans
using Oceananigans.Units: minute, minutes, hour

##0) Setting the simulation
number_simulations=1
run_simulation=true            #Is the model running? Or it's just a test?

simulation_prefix="3WM_"
struct simulation_name              #Parameters used to make the name of the file
    u₁₀
    S
    dTdz
    T
    dim
    run
end

##1) INITIAL CONDITIONS
dTdz = 0.01       # Gradient of temperature (K m⁻¹)

#Water mases: The model consists on 3 homogeneous water mases 
#Surface Water (0-200) (superficial values) 
#LIW (200-600) (maximum values)
#Deep Water (600-2400) (100) (maximum values)

T_WM=(13.18, 13.38, 12.71)                        #To write more simulations do it [(SW1,LIW1,DW1),(SW2,LIW2,DW2)]                   
S_WM=(37.95,38.54,38.41)

SW_lim, LIW_lim = 10, 20                          #limits between water masses


##2) FORCING CONDITIONS
u₁₀ = 10                                         #Velocity of the wind (m/s)


##3)SIMULATION parameters
end_time = 1140minutes                  #Runtime for simulation
dimension = (:, 16, :)                             #Position of the simulation at the grid. For a 2D file x or y must be defined (ex: (:,16,:))


#Funtion to make sure that all the variables have the same lenght. If the variable has the same lenght, do nothing
function filling(fixed,n_simulations=number_simulations)
    if size(fixed,1)==n_simulations
        return fixed
    else 
        return x=fill(fixed,n_simulations)
    end
end

#u₁₀=filling(u₁₀)
#S_WM=filling(S_WM)
#dTdz=filling(dTdz)
#T_WM=filling(T_WM)
#end_time=filling(end_time)
#dimension=filling(dimension)

#Transform the variables from tuples to matrix, so that is possible to make operations with them
#u₁₀=hcat(collect.(u₁₀)...)
#S_WM=hcat(collect.(S_WM)...)
#dTdz=hcat(collect.(dTdz)...)
#T_WM=hcat(collect.(T_WM)...)

