module Utility

    using JLD2
    using ..Automata
    using ..Optimizer

    export load, save, run_multiple!

    const AUTOMATON_FILENAME = "automaton.jld2"
    const TRAININGSET_FILENAME = "trainingset.jld2"

    function load(::Type{Automaton})
        automaton = :automaton
        @load AUTOMATON_FILENAME automaton
        automaton
    end

    function load(::Type{TrainingSet})
        set = :set
        @load TRAININGSET_FILENAME set
        set
    end

    save(automaton::Automaton) = @save AUTOMATON_FILENAME automaton
    save(set::TrainingSet) = @save TRAININGSET_FILENAME set

    function run_multiple!(iters::Int, automata::Automaton...)
        Threads.@threads for automaton in automata
            run!(automaton, iters)
        end
    end

end