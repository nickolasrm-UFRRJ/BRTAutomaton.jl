#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
runtests.jl (c) 2021
Description: The main caller script for tests
Created:  2021-03-31T17:45:20.213Z
Modified: 2021-04-26T06:17:45.421Z
=#

using BRTAutomaton
using Test

include("./structure.jl")
include("./movement.jl")
include("./boarding.jl")
include("./multiple_data.jl")
include("./reset.jl")
include("./optimizer.jl")
include("./utility.jl")