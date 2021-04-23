#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Automaton.jl (c) 2021
Description: General purpose functions for managing Data structures
Created:  2021-03-21T00:53:00.324Z
Modified: 2021-04-23T05:51:11.516Z
=#

#Intinerary
@inline should_stop(intinerary::Intinerary, station::Station) = 
    intinerary[relative_id(station)]

@inline should_stop(bus::Bus, sub::AbstractSubstation) =
    should_stop(intinerary(bus), parent(sub))


#Mesh
@inline isntempty(mesh::Vector{Id}, i::Position) = mesh[i] != EMPTY


#Bus
@inline isboarded(bus::Bus) = boarded(bus) > zero(Sleep)
@inline boarded!(bus::Bus) = boarded!(bus, boarded(bus) - one(Sleep))