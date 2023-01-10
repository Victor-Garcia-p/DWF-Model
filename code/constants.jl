#=
Info: This file contains all constants that can be changed to define the model
several constants can be defined using [] (ex: u₁₀ = [0,1,2,3] ). This will create multiples files with the 
"model_loop" file.
=#

using Oceananigans
using Oceananigans.Units: minute, minutes, hour

##1) INITIAL CONDITIONS

#Define a salinity (homogeneous) and a gradient of temperature
S = 35
dTdz = 0.01 # K m⁻¹

##Water mases: The model consists on 3 homogeneous water mases:

#Surface Water (0-200) (superficial values) first value is the S and the second T
SW= (37.95,13.18)
SW_lim= 10

#LIW (200-600) (30) (maximum values)
LIW= (38.54,13.38)
LIW_lim= 20

#Deep Water (600-2400) (100) (maximum values)
#DW= (38.51,13.18)
#DW_lim=30

#Estable values
DW= (38.41,12.71)
DW_lim=30

#S=38.41
#T=12.71


##2) FORCING CONDITIONS
#Define the velocity of the wind (m/s)
u₁₀ = [2]


##3)SIMULATION parameters
end_time = 5minutes                    #Runtime for simulation
dimension = (:, 16, :)                 #Position of the simulation at the grid. For a 2D file x or y must be defined (ex: (:,16,:))


#Funtion to make sure that all the variables have the same lenght
function filling(fixed,shifting)
    return x=fill(fixed,size(shifting))
end

S=filling(S,u₁₀)
dTdz=filling(dTdz,u₁₀)
end_time=filling(end_time,u₁₀)
dimension=filling(dimension,u₁₀)

##4)NAMING SIMULATION (a structure that constains what will be on the name of the simulation)
simulation_prefix="TESTOO"

struct simulation_name
    u₁₀
    dTdz
    S
    dim
    run
end