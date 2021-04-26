#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Evaluation.jl (c) 2021
Description: Evaluation function for multiple automaton
Created:  2021-04-25T18:14:30.291Z
Modified: 2021-04-26T02:22:16.390Z
=#

function evaluate!(env::Automaton, iters::Int)
    run!(env, iters)
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
    iters = iterations(set)

    Threads.@threads for ti in 1:Threads.nthreads()
        ntds = Threads.nthreads()
        tid = Threads.threadid()
        pad = elit+1
        dif = length(cands) - elit
        st = round(Int, (tid-1) * dif / ntds + pad)
        fn = round(Int, (tid) * dif / ntds + pad - 1)
        
        for i in st:fn
            env = envs(set)[Threads.threadid()]
            copy!(env, cands[i])
            fitness!(cands[i], Float32(evaluate!(env, iters)))
            reset!(env)
        end
    end
end