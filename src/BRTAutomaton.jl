module BRTAutomaton

    using Reexport

    include("Automata.jl")
    @reexport using .Automata

end