module BRTAutomaton

    using StaticArrays
    using PointerArithmetic

    include("Automaton/Data/Constants.jl")
    include("Automaton/Data/Object.jl")
    include("Automaton/Data/Intinerary.jl")
    include("Automaton/Data/Bus.jl")
    include("Automaton/Data/Station.jl")
    include("Automaton/Data/Substation.jl")
    include("Automaton/Data/AutomatonInits.jl")
    include("Automaton/Data/Automaton.jl")

    include("Automaton/Base.jl")
    include("Automaton/Collision.jl")
    include("Automaton/Movement.jl")

end