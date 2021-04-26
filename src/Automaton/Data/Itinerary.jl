#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Itinerary.jl (c) 2021
Description: An itinerary is set of stations which a bus can stop
Created:  2021-03-21T00:06:30.696Z
Modified: 2021-04-22T15:36:50.178Z
=#

const Itinerary = BitVector

Itinerary(arr::Bool...) = Itinerary(arr)