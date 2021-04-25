#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Boarding.jl (c) 2021
Description: A set of functions to control the bus flow into the station
Created:  2021-04-22T14:58:48.251Z
Modified: 2021-04-25T08:11:13.414Z
=#

function board!(bus::Bus, boarded_counter::Sleep,
        mesh_i::Vector{Id}, mesh_i1::Vector{Id})
    if boarded(bus) == FLAG_JUST_BOARDED
        boarded!(bus, boarded_counter)
        clear!(mesh_i, bus)
        clear_last!(mesh_i1, bus)
    end
end

function disembark!(automaton::Automaton, bus::Bus, station::Station)
    number_of_passengers = min(passengers(bus), disembark_rate(station))
    passengers!(bus, BusCapacity(passengers(bus) - number_of_passengers))
    add_to_disembark_sum!(automaton, number_of_passengers)
end

function embark!(automaton::Automaton, bus::Bus, station::Station, bus_capacity::BusCapacity)
    number_of_passengers = min(bus_capacity - passengers(bus), 
                                embark_rate(station))
    passengers!(station, passengers(station) - StationCapacity(number_of_passengers))
    passengers!(bus, passengers(bus) + BusCapacity(number_of_passengers))
    add_to_embark_sum!(automaton, number_of_passengers)
end

function shift!(bus::Bus, sub::TailSubstation)
    if !next_occupied(sub)
        fill_next!(sub, bus)
        clear!(sub)
    end
end

function shift!(bus::Bus, sub::HeadSubstation, mesh::Vector{Id}, 
        buses_quantity::Int, exit_looking_distance::Position)
    if isboarded(bus)
        decr_boarded!(bus)
    end
    if !isboarded(bus)
        bus_pos = position(sub) + BUS_LENGTH
        if no_bus(mesh, bus_pos, buses_quantity, exit_looking_distance)
            position!(bus, bus_pos)
            speed!(bus, zero(Speed))
            clear!(sub)
        else
            incr_boarded!(bus)
        end
    end
end

function no_bus(mesh::Vector{Id}, pos::Position, buses_quantity::Int,
        exit_looking_distance::Position)
    for i in (pos - exit_looking_distance):pos
        if mesh[i] > EMPTY && mesh[i] <= buses_quantity
            return false
        end
    end
    return true
end