#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Automaton.jl (c) 2021
Description: Automaton module
Created:  2021-04-23T13:59:25.269Z
Modified: 2021-04-26T02:26:37.900Z
=#

module Automata

    using StaticArrays

    include("Automaton/Data/Constants.jl")
    include("Automaton/Data/Object.jl")
    include("Automaton/Data/Intinerary.jl")
    include("Automaton/Data/Bus.jl")
    include("Automaton/Data/Station.jl")
    include("Automaton/Data/Substation.jl")
    include("Automaton/Data/LoopWall.jl")
    include("Automaton/Data/AutomatonInits.jl")
    include("Automaton/Data/Automaton.jl")

    include("Automaton/Base.jl")
    include("Automaton/Collision.jl")
    include("Automaton/Movement.jl")
    include("Automaton/Boarding.jl")
    include("Automaton/Iteration.jl")
    include("Automaton/Reset.jl")

    export Automaton, Intinerary, run!, reset!
    export Bus, Station, AbstractSubstation, HeadSubstation, 
        TailSubstation, LoopWall, Object
    export buses, position, speed, objects, waiting, id, lines
    export avg_speed, avg_cycle_iterations, avg_embarking, avg_disembarking
    export Position, Speed, Sleep, BusCapacity, StationCapacity

end