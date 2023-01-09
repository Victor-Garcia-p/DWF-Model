#info: This file contains all the rang of variables that will be used to create the 
#data of the simulacions

using Oceananigans
using Oceananigans.Units: minute, minutes, hour

#function to fill the variables that does not change
function filling(fixed,shifting)
    return x=fill(fixed,size(shifting))
end

##INITIAL CONDITIONS
#Define a salinity (homogeneous) and a gradient of temperature
S = 35
dTdz = 0.01 # K m⁻¹

##Water mases    

#Surface water (0-200) (superficial values)
SW= (37.95,13.18)
SW_lim= 10

#LIW (200-600) (30) (maximum values)
LIW= (38.54,13.38)
LIW_lim= 20

#Deep Water (600-2400) (100) (maximum values)
DW= (38.51,13.18)
DW_lim=30

#Estable values
DW= (38.41,12.71)
DW_lim=30

#S=38.41
#T=12.71


##FORCING CONDITIONS
#Define the velocity of the wind
u₁₀ = [0]

#RUNNING FILES
#Define the parameters of the simulation (at the future this will be opened from a file)
end_time = 5minutes                    #Runtime for simulation
dimension = (:, 16, :)      #used to create 3D files or 2D (a x or y must be setted)

#Make sure that all the variables have the same leght
S=filling(S,u₁₀)
dTdz=filling(dTdz,u₁₀)
end_time=filling(end_time,u₁₀)
dimension=filling(dimension,u₁₀)

struct name
    u₁₀
    dTdz
    S
    dim
    run
end