module Optimizer

    using Random
    using ..Automata

    include("Optimizer/Base.jl")
    include("Optimizer/Evaluation.jl")
    include("Optimizer/Crossover.jl")
    include("Optimizer/Mutation.jl")
    include("Optimizer/Selection.jl")
    include("Optimizer/Run.jl")

    export TrainingSet, train!
    export elitism, elitism!, iterations, iterations!,
        crossover_point, crossover_point!, mutation_rate, mutation_rate!

end