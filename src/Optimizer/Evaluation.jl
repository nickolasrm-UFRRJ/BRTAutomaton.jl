#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Evaluation.jl (c) 2021
Description: Evaluation function for multiple automaton
Created:  2021-04-25T18:14:30.291Z
Modified: 2021-04-26T21:58:38.210Z
=#

function evaluate!(env::Automaton)
    run!(env, 1000)
    (10*avg_speed(env) + 4*avg_disembarking(env))
end

function copy!(env::Automaton, cand::Candidate)
    lins = lines(env)
    dat = data(cand)
    for i in 1:length(lins)
        for j in 1:length(lins[i].chunks)
            @inbounds lins[i].chunks[j] = dat[i].chunks[j]
        end
    end
end

function evaluate!(set::TrainingSet)
    cands = candidates(set)
    elit = elitism(set)
    func = evaluation_function(set)

    Threads.@threads for i in (elit+1):length(cands)
        env = envs(set)[Threads.threadid()]
        copy!(env, cands[i])
        fitness!(cands[i], Float32(func(env)))
        reset!(env)
    end
end