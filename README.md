# BRT Automaton
[![Build Status](https://travis-ci.com/nickolasrm-UFRRJ/BRTAutomaton.jl.svg?branch=main)](https://travis-ci.com/nickolasrm-UFRRJ/BRTAutomaton.jl)
[![Coverage Status](https://coveralls.io/repos/github/nickolasrm-UFRRJ/BRTAutomaton.jl/badge.svg?branch=main)](https://coveralls.io/github/nickolasrm-UFRRJ/BRTAutomaton.jl?branch=main)

_A study case of Bus Rapid Traffic system modeled with cellular automata._

## About the project
This package contains a Bus Rapid Transit (BRT) system simulator made using a cellular automata model. BRTs are a transport alternative to the regular buses. Instead of letting the buses being driven like cars, they are allocated in an exclusive lane, usually at the margin of a highway, which makes them faster and free of traffic congestion. This project focuses on simulating it to help ML scientists developing solutions to improve the quality of the system.

## Features
- Simulator
- GUI
- Reinforcement learning optimizer

## Simulator
The main simulation consists of five objects, the substations, the buses, the loop wall, and the stations, and their relations. 
### Bus
A bus is the only unit that moves during the simulation. It has three basic rules: accelerating, deaccelerating, and moving. These rules are described as the following sequential steps:
1. Accelerating: `if bus_speed < max_speed, then bus_speed += 1`

2. Deaccelerating: `if bus sees another bus or a substation in range of bus_speed, then bus_speed = object_position - bus_position`

    2.1. Collision: `if the bus saw something, execute the proper relation procedure`

3. Moving: `bus_position += bus_speed`

### Substations
A substation is an object that makes a bus to stop and also let the passengers embark and disembark. Also, when a bus enters a substation, it is removed from the main lane, and it is transported through the substations at its respective station. 

The substation follows the respective algorithm:

1. Embark: `if there is a bus into the substation, then decrease the number of passengers into the parent station, and increase the number of passengers into the bus`

2. Disembark: `if there is a bus into the substation, then decrease the number of passengers into the bus`

3. Shift: `if the substation is the last, then verify if there's no bus at the end of it and then send the bus to the main lane` or `if the substation is not the last, then check if the next substation is free, and send the bus to it`

#### **Substation and a bus**
```
if bus saw a substation
    if bus should stop at it
        if substation is occupied
            set bus to wait
        else if next substation is occupied
            let the bus come in
```
This algorithm makes the bus to drive until it reaches the last not occupied substation, thus making a queue

### Station
A station is a container for the substations. However, some data that is shared between substations, like the number of passengers has to be inside the station. Also, each station is randomly initialized with an embark and disembark quantity of passengers, and when a bus stops on a substation, it uses these values to change the number of passengers (simulating disembarking and embarking).

A station follows the algorithm below:
```
staton_passengers += passenger_generation_per_iteration
```

### Loop Wall
The last, but not less important is the loop wall. A loop wall is the last element in the simulator mesh, and it is responsible for making a bus return to the first station, thus making it circular.

#### **Loop wall and a bus**

Since it is only triggered when colliding with a bus, the only rule for it is described as:
```
enqueue the bus inside of the loop wall
set the bus to waiting state
if possible, dequeue it to the first substation
clear the last position of the bus in the mesh
```

### How to use it?
To use this package, you have to first have to download its dependencies. But don't worry, Julia does this automatically. Just follow these steps and everything will be fine :)

#### **Installing**
1. Open Julia on the project folder
2. When in the the repl, enter the Pkg by typing `]`
3. Type the command `activate .` to set this project as the Pkg working project
4. Type the command `instantiate` to download the libs
5. Once it finished downloading, get back to the main Julia repl by typing backspace
6. Import the project with `using BRTAutomaton`

#### **Running your first simulation**
Once you finished installing the project, you can use the following functions:

##### **Creating a bus**
To start the automaton, you have to first inform how many buses you want and what stations it will stop
>Remember, stopping at the first station is mandatory
```julia
bus_array = [Itinerary(true, false, true),
            Itinerary(true, true, true),
            Itinerary(true, false, false)]
# creates three buses.
## The first bus will stop at the first and the third stations
## The second bus will stop at all three stations
## The third bus will only stop at the first station
```
> Note: The order of the array is the same order the buses are going to leave the first station

##### **Creating an automaton**
After creating your buses its time to create the automaton.
```julia
automaton= Automaton(station_quantity=2,
                buses_as_itineraries=buses_array)
```
These two are the only required parameters, but you can configure the automaton the way you want with the following keyword arguments:
- number_of_substations: DEFAULT=3
- station_spacing: DEFAULT=80
- substation_spacing: DEFAULT=3
- safe_margin: DEFAULT=2
- boarded_iterations: DEFAULT=2
- bus_capacity: DEFAULT=120
- station_capacity: DEFAULT=600
- max_embark: DEFAULT=bus_capacity / 2
- max_disembark: DEFAULT=bus_capacity
- max_generation: DEFAULT=2
- max_speed: DEFAULT=4

##### **Running it**
Simply run: `run!(automaton, <number of iterations>)`

As you will notice, nothing seems to change. That is because this is the simulation backend. Let's move on to the GUI.

> Note: You can always reset your automaton to the initial state by calling: `reset!(automaton)`

## GUI
Nothing better than a gui to see results. 

To use a GUI with your automaton, simply call: `gui(automaton)`. Once the interface opens, you can set the number of iterations you want to run, and the sleep between each of them.

![graphics user interface](https://github.com/nickolasrm-UFRRJ/BRTAutomaton.jl/blob/main/screenshots/gui.gif)

> Note: You can zoom in and out the map to have a larger view of the simulation

## Optimizing the number of passengers with reinforcement learning
Since some stations have less or more embarking and disembarking rates than others (check the station section if you skipped it), and the each bus has to know where to stop, configuring different itineraries can lead to different embarking and disembarking averages when simulating a scenario. Because of that, we can use reinforcement learning to learn the best set of stations for each bus to maximize the passengers flow.

### How do I start?
#### **Simpler example**
Let's first create a simpler automaton example, so that you can see it is really working:
```julia
buses = [Intinerary(true, falses(4)...) for i in 1:20]
# creating 20 buses that only stop at the first station, and not at the other five
a = Automaton(station_quantity=5,
              buses_as_itineraries=buses)
```
> Note: Because it only stops at the first station, the buses won't transport as much passengers as it could, thus making stats lower

#### **Training Set**
After that, you have to create a training set that will contain the required data for the [genetic algorithm](https://en.wikipedia.org/wiki/Genetic_algorithm) used here.
```julia
set = TrainingSet(automaton,
        population_size=50, 
        mutation_rate=0.1)
```
This training set constructor have the following keyword arguments:
- population_size: DEFAULT=200
- iterations: DEFAULT=1000
- elitism: DEFAULT=10
- crossover_point: DEFAULT=round(station_quantity/2)
- mutation_rate: DEFAULT=0.2

Changing any of these parameters will affect the convergence time of the training in a positive or negative way. For example, increasing the mutation rate can help avoiding [local minimums](https://en.wikipedia.org/wiki/Maxima_and_minima), but at the same time it will disturb the propagation of small solutions. Read more about genetic algorithm and its parameters [here](https://www.obitko.com/tutorials/genetic-algorithms/index.php)

> Note: Each of these parameters can be changed after the training set is created by calling its respective functions. e.g: `elitism!(set, 15)`

### Training
After everything is set up, you can finally train your automata by calling: 

`train!(automaton, set, <gen_limit>, <max_fitness>)`

At least one of the two `gen_limit` (maximum number of generations, a Int) or `max_fitness` (maximum fitness value, a Real) parameters should be specified as a stopping criteria for the training.

### Results
You can check the results of the genetic algorithm by multiple ways, but we will first see some numbers:
```julia
automaton = Automaton(station_quantity=5,
              buses_as_itineraries=buses)
run!(automaton, 1000)

avg_speed(automaton)
3.6779

avg_disembarking(automaton)
12.398148148148149
#these numbers may vary because embarking and disembarking are randomly defined for each station
``` 
Before running the training, it is good to see how it was before to compare.
```julia
reset!(automaton)
#resetting is not required before training, but it is a good practice
set = TrainingSet(automaton,
        population_size=50, 
        mutation_rate=0.1)
# creating the training set
train!(automaton, set, gen_limit=20)
#training with 20 generations
[ Info: Best fitness: 171.42255
[ Info: Best fitness: 171.42255
[ Info: Best fitness: 173.38614
[ Info: Best fitness: 173.38614
...
```
The training takes some time to complete, but you can speed it up using parallel computing. Just [set the environment variable](https://docs.julialang.org/en/v1/manual/multi-threading/#Starting-Julia-with-multiple-threads) `JULIA_NUM_THREADS=<number of threads>` before running Julia and magic will happen.

```julia
run!(automaton, 1000)
avg_speed(automaton)
3.4878

avg_disembarking(automaton)
29.51729957805907
```
As you can see, the averaged number of people disembarking almost doubled, thanks to the genetic algorithm.

Lets see the difference before and after with the GUI

![before training](https://github.com/nickolasrm-UFRRJ/BRTAutomaton.jl/blob/main/screenshots/before_training.gif)

Before

![after training](https://github.com/nickolasrm-UFRRJ/BRTAutomaton.jl/blob/main/screenshots/after_training.gif)

After

## Utilitary functions
What if you liked your automaton? How can I save it?

_This is a job for utilitary functions!_

There are three functions in this module:
- **save(::Automaton):** Saves the automaton in a file inside of the current pwd()

- **load():** Loads the automaton of the previously saved file if there is one inside of the current pwd()

- **run_multiple!(iterations, ::Automaton...):** Since a rel BRT has at least two lanes, it does make sense to run more than one automaton. This function does not do anything special, it only executes multiple automatons in parallel. 

## References
[1] Kai Nagel, Michael Schreckenberg. A cellular automaton model for freeway traffic. Journal
de Physique I, EDP Sciences, 1992, 2 (12), pp.2221-2229. <10.1051/jp1:1992277>. <jpa-002466

[2] 
M. A. Uribe-Laverde, & W. F. Oquendo-Patiño. (2019). Improving the bus flow in a Bus Rapid Transit system: an approach based on cellular automata simulations.

## Links

- Starting Julia with multiple threads. https://docs.julialang.org/en/v1/manual/multi-threading/#Starting-Julia-with-multiple-threads

- Introduction to Genetic Algorithms. https://www.obitko.com/tutorials/genetic-algorithms/index.php

- Maxima and minima. https://en.wikipedia.org/wiki/Maxima_and_minima

- Genetic Algorithm. https://en.wikipedia.org/wiki/Genetic_algorithm
