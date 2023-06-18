-----------Files in this folder-----------

This folder contains all the data of the code
Lion_mooring: Data of the buoy
10.17882/44411

Taylor: Contains the data frames with the statistics to plot a Taylor diagram. It opens with Phyton code. "Sigma_simulations" is the statistics using sigma (sigma at the buoy, 6 valid layers, vs the value of sigma in those depths in the simulations). T simulation is the same but using the T, instead of Sigma

Variables: Contains the simulation data but in .dat format. This way it's easier to open for Julia. It only contains T and S of the simulations, to reduce processing time.

"buoi_condition" & "sim_condition" are the simulations used to generate the section for the conditioning phase (fig 6)

"convection_sigma_sim" contains the sigma used to create Fig6 and 
"convection_sigma_buoy" the buoy sigma, using DIVA, for convection phase (Fig6a)

"Taylor_buoi" is the reference simulation to plot the Taylor plot and "Taylor_sim_data" are all the simulation TS that are represented on the plot.

"SI_data_v0_v50" are the values of TS for all simulations used to calculate SI (same initial conditions, and only change wind speed)
