# Modelization of the deep water formation

Victor Garcia (@Victor-Garcia-p), 2023-03-17

## Content

* [Install the model](#install-the-model)
* [Create a model](#creating-a-model)
* ...

## Install the model

1. Download [Julia](https://julialang.org/downloads/)
2. Make a copy of the repository

      ```julia
    $git clone https://github.com/Victor-Garcia-p/TFG.git
   ```

3. Install [DrWatson](https://github.com/JuliaDynamics/DrWatson.jl) package

    ```julia
    julia> using Pkg

    julia> Pkg.add("DrWatson")
   ```

4. Load the project environment

    ```julia
    julia> using DrWatson

    julia> @quickactivate
   ```

## Creating a model

To create a simulation use `model_execution.jl` following this steps:

1. Load the required packages (located in 'model_functions.jl')

   ```julia
   julia> include("model_functions.jl")
   ```

2. Set the layers of the model
    * Define properties of each layer using  `WaterLayer()`. For each of them, enter values of maximum depth, T and S
    * Add all layers in an [Array]  
  
    ---

    **Example**  
        A model with 3 layers, each of 10 m and different TS

    ```julia
   SW_layer = WaterLayer(10.0, 37.95, 13.18)
    LIW_layer = WaterLayer(20.0, 38.54, 13.38)
    WMDW_layer = WaterLayer(grid.Lz, 38.41, 12.71)

    layers = [SW_layer,LIW_layer,WMDW_layer]
   ```

    _Note: `grid.Lz` is the maximum depth of the grid_

3. Set the constants of models and simulations in separated `Dict()`. If not defined, taken as [default](#default-values)

    **Example**

    Define a single run with u₁₀ = 10m/s, dTdz =0.01 °C/m that last 1440 minutes.
  
    ```julia
    model_arguments = [Dict(:u₁₀=>0, :dTdz=>0.01)]

    simulation_arguments= [Dict(:t=>1440minutes)]
   ```

   More info: [multiples_runs](#multiples-runs)

4. Run the model using a loop that gives the parameters to the functions of the model. See [`model_functions.jl`](#model_functionsjl) for more info

    ```julia
   for kwargs in model_arguments, kwargs2 in simulation_arguments
    build_model(layers;kwargs...,kwargs2...)
    prepare_simulation!(params,model;kwargs2...)
    
    run!(simulation)
    end
   ```

## Ploting a simulation

There are

Open a file  
load a file  

## Documentation of the files

### `model_execution.jl`

Funcionalitat/descripció:
imput: Batimetry from EMODNET (Batimetry_D5_2020.nc)
output: The map, printed in "plot" section
comments: Some parts of the code are adapted from other authors, please
see the references at the main work pdf.

### `grid_generation.jl`

### `model_functions.jl`

#### **Default values**

v=0m/s

#### Multiples runs

a

## References and contributions

a
