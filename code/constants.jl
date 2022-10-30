#info: This file contains all the rang of variables that will be used to create the 
#data of the simulacions

using Oceananigans
using Oceananigans.Units: minute, minutes, hour

#function to fill the variables that does not change
function filling(fixed,shifting)
    return x=fill(fixed,size(shifting))
end

#INITIAL
#Define a salinity (homogeneous) and a gradient of temperature
S = 35
dTdz = 0.01 # K m⁻¹

#FORCING
#Define the velocity of the wind
u₁₀ = [1,2,3,4,5,6,7,8,9,10]

#RUNNING
#Define the parameters of the simulation (at the future this will be opened from a file)
end_time = 40minutes                    #Runtime for simulation
dimension = (:, 2, :)      #used to create 3D files or 2D (a x or y must be setted)

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