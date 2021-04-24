#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Automaton.jl (c) 2021
Description: General purpose functions for managing Data structures
Created:  2021-03-21T00:53:00.324Z
Modified: 2021-04-24T04:33:06.033Z
=#

#Intinerary
@inline should_stop(intinerary::Intinerary, station::Station) = 
    intinerary[relative_id(station)]

@inline should_stop(bus::Bus, sub::AbstractSubstation) =
    should_stop(intinerary(bus), parent(sub))


#Mesh
@inline isntempty(mesh::Vector{Id}, i::Position) = mesh[i] != EMPTY


#Bus
@inline incr_cycle_iterations!(bus::Bus) = 
    cycle_iterations!(bus, cycle_iterations(bus) + one(Stat))
@inline reset_cycle_iterations!(bus::Bus) =
    cycle_iterations!(bus, zero(Stat))
    


#Automaton
@inline add_to_speed_sum!(automaton::Automaton, val::Integer) = 
    speed_sum!(automaton, speed_sum(automaton) + Stat(val))
@inline add_to_cycle_iterations_sum!(automaton::Automaton, val::Integer) =
    cycle_iterations_sum!(automaton, cycle_iterations_sum(automaton) + Stat(val))
@inline add_to_embark_sum!(automaton::Automaton, val::Integer) =
    embark_sum!(automaton, embark_sum(automaton) + Stat(val))
@inline add_to_disembark_sum!(automaton::Automaton, val::Integer) =
    disembark_sum!(automaton, disembark_sum(automaton) + Stat(val))

@inline incr_iteration_counter!(automaton::Automaton) = 
    iteration_counter!(automaton, iteration_counter(automaton) + one(Stat))
@inline incr_cycle_counter!(automaton::Automaton) =
    cycle_counter!(automaton, cycle_counter(automaton) + one(Stat))
@inline incr_boarded_counter!(automaton::Automaton) =
    boarded_counter!(automaton, boarded_counter(automaton) + one(Stat))

#Stats
@inline avg_speed(automaton::Automaton) = 
    speed_sum(automaton) / (iteration_counter(automaton) * length(buses(automaton)))
@inline avg_cycle_iterations(automaton::Automaton) = 
    cycle_iterations_sum(automaton) / cycle_counter(automaton)
@inline avg_embarking(automaton::Automaton) =
    embark_sum(automaton) / boarded_counter(automaton)
@inline avg_disembarking(automaton::Automaton) = 
    disembark_sum(automaton) / boarded_counter(automaton)