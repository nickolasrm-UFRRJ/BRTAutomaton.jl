#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Run.jl (c) 2021
Description: Main functions for running genetic algorithm
Created:  2021-04-25T18:16:35.535Z
Modified: 2021-04-26T00:57:07.773Z
=#

unsafe_best(set::TrainingSet) =
    candidates(set)[1]

best!(set::TrainingSet) =
    (selection!(set); unsafe_best(set))

function copy!(automaton::Automaton, set::TrainingSet)
    best_cand = unsafe_best(set)
    copy!(automaton, best_cand)
end

function train!(automaton::Automaton, set::TrainingSet; 
        gen_limit::Int=typemax(Int), max_fitness::Float32 =typemax(Float32))
    @assert gen_limit < typemax(Int) || max_fitness < typemax(Float32) "Stopping criteriea not defined"
    i = 0
    while i < gen_limit && fitness(unsafe_best(set)) < max_fitness
        evaluate!(set)
        selection!(set)
        crossover!(set)
        mutation!(set)
        @info "Best fitness: $(fitness(unsafe_best(set)))"
        i += 1
    end
    reset!(automaton)
    copy!(automaton, set)
end