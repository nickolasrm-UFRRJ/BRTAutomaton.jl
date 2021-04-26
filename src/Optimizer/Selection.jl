#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Selection.jl (c) 2021
Description: Genetic algorithm selection function
Created:  2021-04-25T18:33:46.958Z
Modified: 2021-04-25T18:34:46.683Z
=#

function selection!(set::TrainingSet)
    sort!(candidates(set), by=x->fitness(x), rev=true)
end