#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Run.jl (c) 2021
Description: Structures for the genetic simulation
Created:  2021-04-25T18:15:04.665Z
Modified: 2021-04-26T00:57:34.060Z
=#

struct Candidate
    fitness::Ref{Float32}
    data::Vector{BitVector}
end

Candidate(automaton::Automaton) =
    Candidate(
            Ref(0.0f0), 
            [BitVector(undef, length(line)) for line in lines(automaton)]
        )

function randomize!(cand::Candidate)
    @inbounds for line in data(cand)
        newdata = bitrand(length(line))
        newdata[1] = true
        line.chunks .= newdata.chunks
    end
end


#Getters and setters
@inline fitness(cand::Candidate) = cand.fitness[]
@inline fitness!(cand::Candidate, val::Float32) = cand.fitness[] = val

@inline data(cand::Candidate) = cand.data

#Displays
Base.show(io::IO, candidate::Candidate) = 
    print(io, "Candidate(fitness: $(fitness(candidate)))")

Base.display(candidate::Candidate) = 
    print("Candidate(fitness: $(fitness(candidate)))")



struct TrainingSet
    envs::Vector{Automaton}
    candidates::Vector{Candidate}

    iterations::Ref{Int}
    elitism::Ref{Int}
    crossover_point::Ref{Int}
    mutation_rate::Ref{Float32}
end

function TrainingSet(automaton::Automaton; 
        population_size::Int=200,
        iterations::Int=1000,
        elitism::Int=10,
        crossover_point::Int=round(Int, length(lines(automaton)[1])/2),
        mutation_rate::Real=0.2f0)
    mutation_rate = Float32(mutation_rate)
    @assert(crossover_point > 0 && crossover_point < length(lines(automaton)[1]),
        "Crossover point has to be greater than 0 and lesser than the number of stations")
    @assert(elitism > 0 && elitism < population_size,
        "Elitism cannot be nagative and neither greater than population size")
    @assert population_size > 1 "At least two candidates are needed to train the automaton"
    @assert mutation_rate >= 0 && mutation_rate <= 1 "Mutation rate is out of bounds"
    @assert iterations > 0 "At least one iteration is needed to evaluate the automaton"

    reset!(automaton)
    threads_quantity = Threads.nthreads()
    envs = [deepcopy(automaton) for i in 1:threads_quantity]

    cands = Vector{Candidate}(undef, population_size)
    for i in 1:population_size
        cands[i] = Candidate(automaton)
        randomize!(cands[i])
    end

    TrainingSet(
        envs,
        cands,
        Ref(iterations),
        Ref(elitism),
        Ref(crossover_point),
        Ref(mutation_rate)
    )
end

#Getters and setters
envs(set::TrainingSet) = set.envs
candidates(set::TrainingSet) = set.candidates

elitism(set::TrainingSet) = set.elitism[]
elitism(set::TrainingSet, val::Int) = set.elitism[] = val

crossover_point(set::TrainingSet) = set.crossover_point[]
crossover_point!(set::TrainingSet, val::Int) = set.crossover_point[] = val

mutation_rate(set::TrainingSet) = set.mutation_rate[]
mutation_rate!(set::TrainingSet, val::Real) = set.mutation_rate[] = Float32(val)

iterations(set::TrainingSet) = set.iterations[]
iterations!(set::TrainingSet, val::Int) = set.iterations[] = val


#Displays
Base.show(io::IO, set::TrainingSet) = 
    print(io, "TrainingSet("*
                "\n\tNumber of candidates: $(length(candidates(set)))"*
                "\n\tBest fitness: $(fitness(candidates(set)[1]))"*
                "\n\tElitism: $(elitism(set))"*
                "\n\tCrossover point: $(crossover_point(set))"*
                "\n\tMutation rate: $(mutation_rate(set))"*
                "\n\tAutomaton iterations: $(iterations(set))"*
                "\n)")

Base.display(set::TrainingSet) = 
    print("TrainingSet("*
                "\n\tNumber of candidates: $(length(candidates(set)))"*
                "\n\tBest fitness: $(fitness(candidates(set)[1]))"*
                "\n\tElitism: $(elitism(set))"*
                "\n\tCrossover point: $(crossover_point(set))"*
                "\n\tMutation rate: $(mutation_rate(set))"*
                "\n\tAutomaton iterations: $(iterations(set))"*
                "\n)")