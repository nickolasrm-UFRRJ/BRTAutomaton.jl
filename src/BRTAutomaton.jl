module BRTAutomaton

    using Reexport

    include("Automata.jl")
    @reexport using .Automata
    include("GUI.jl")
    @reexport using .GUI
    include("Optimizer.jl")
    @reexport using .Optimizer

end