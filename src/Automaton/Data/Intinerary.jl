#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Intinerary.jl (c) 2021
Description: An intinerary is set of stations which a bus can stop
Created:  2021-03-21T00:06:30.696Z
Modified: 2021-04-22T15:36:50.178Z
=#

const Intinerary = BitVector

Intinerary(arr::Bool...) = Intinerary(arr)