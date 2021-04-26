module Utility

    using JLD2
    using ..Automata

    export load, save, run_multiple!

    const FILENAME = "automaton.jld2"

    function load()
        automaton = :automaton
        @load FILENAME automaton
        automaton
    end

    save(automaton::Automaton) = @save FILENAME automaton

    function run_multiple!(iters::Int, automata::Automaton...)
        Threads.@threads for automaton in automata
            run!(automaton, iters)
        end
    end

end