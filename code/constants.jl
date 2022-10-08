#info: This file contains all the rang of variables that will be used to create the 
#data of the simulacions

using Oceananigans

#INITIAL
#Define a salinity (homogeneous) and a gradient of temperature
S = 35
const dTdz = 0.01 # K m⁻¹

#FORCING
#Define the velocity of the wind
const u₁₀ = 10 

#RUNNING
#Define the parameters of the simulation (at the future this will be opened from a file)
end_time=20minutes          #Runtime for simulation
dimensions = (:, 2, :)      #used to create 3D files or 2D (a x or y must be setted)