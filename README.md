# TFG
How to run the model?
Use model_execution.jl to perform simulations. To do so specify the values of the constants at a Dictionary (Dict(:u₁₀=>0, :dTdz=>0.00)).

If a constant is not defined it will be used as a default value

How to plot the results?
There are different types of plots available

-Movie.jl: Create a mp4 of the simulation that is saved at "DWF_model\Plots_out\Simulations" folder. To open a simulation write its name at "load_file" function without ".jld2". 

Example load_file(
    "3WM__u₁₀=15_S=35.0-35.0-35.0_dTdz=0.04_T=13.18-13.38-12.71_dim=2D_t=720.0"
)
