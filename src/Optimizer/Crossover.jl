#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Crossover.jl (c) 2021
Description: Crossover functions for the genetic algorithm
Created:  2021-04-25T18:38:31.581Z
Modified: 2021-04-26T01:34:46.417Z
=#

function merge!(child_l::BitVector, father_l::BitVector, mother_l::BitVector, point::Int)
    data_c = child_l.chunks
    data_f = father_l.chunks
    data_m = mother_l.chunks

    left_cut = floor(Int, point / sizeof(data_c[1]))
    for i in 1:left_cut
        @inbounds data_c[i] = data_f[i]
    end
    # Since it's using bitarrays, the point can be in a position that cannot be directly indexed
    # Because indexing bits is not possible, it uses bits shifting to do this
    middle_cut = point - left_cut * sizeof(data_c[1])
    if middle_cut > 0
        inv_middle_cut = sizeof(data_c[1]) - middle_cut
        middle_i = left_cut + 1
        # 1010|11 -> 1100|00 -> 0000|11
        data_c[middle_i] = (data_f[middle_i] << inv_middle_cut) >> inv_middle_cut
        # 1110|10 -> 0011|10 -> 1110|00
        data_c[middle_i] += (data_m[middle_i] >> middle_cut) << middle_cut
        # 11110|00 + 0000|11 = 1110|11
    end

    right_cut = ceil(Int, point / sizeof(data_c[1])) + 1
    for i in right_cut:length(data_c)
        @inbounds data_c[i] = data_m[i]
    end
end

merge!(child::Candidate, father::Candidate, mother::Candidate, point::Int) =
    merge!.(data(child), data(father), data(mother), point)

function crossover!(set::TrainingSet)
    cands = candidates(set)
    elit = elitism(set)
    point = crossover_point(set)
    for i in (elit+1):length(cands)
        father = cands[rand(1:elit)]
        mother = cands[rand(1:elit)]
        merge!(cands[i], father, mother, point)
    end
end