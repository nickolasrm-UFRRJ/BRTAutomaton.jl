#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Automaton.jl (c) 2021
Description: General purpose functions for managing Data structures
Created:  2021-03-21T00:53:00.324Z
Modified: 2021-04-22T03:56:51.506Z
=#

@inline should_stop(intinerary::Intinerary, station::Station) = 
    haskey(intinerary, id(station))

@inline should_stop(bus::Bus, sub::Substation)
    should_stop(intinerary(bus), parent(sub))
