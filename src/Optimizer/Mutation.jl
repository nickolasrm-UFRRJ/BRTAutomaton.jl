#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Mutation.jl (c) 2021
Description: Genetic algorithm mutation function
Created:  2021-04-25T18:34:53.110Z
Modified: 2021-04-26T01:34:52.055Z
=#

@inline rand_mutation(mutation_rate::Float32, current::Bool) = 
    rand() < mutation_rate ? rand(Bool) : current

function mutation!(set::TrainingSet)
    cands = candidates(set)
    elit = elitism(set)
    mut_rate = mutation_rate(set)
    for i in (elit+1):length(cands)
        lines = data(cands[i])
        for line in lines
            for j in 2:length(line)
                @inbounds line[j] = rand_mutation(mut_rate, line[j])
            end
        end
    end
end