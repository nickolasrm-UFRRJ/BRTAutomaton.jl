#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Boarding.jl (c) 2021
Description: A set of functions to control the bus flow into the station
Created:  2021-04-22T14:58:48.251Z
Modified: 2021-04-23T18:07:07.949Z
=#

desimbark!(bus::Bus, station::Station) =
    passengers!(bus, 
        BusCapacity(passengers(bus) - min(passengers(bus), desimbark_rate(station))))

function embark!(bus::Bus, station::Station, bus_capacity::BusCapacity)
    number_of_passengers = min(bus_capacity - passengers(bus), 
                                embark_rate(station))
    passengers!(station, passengers(station) - StationCapacity(number_of_passengers))
    passengers!(bus, passengers(bus) + BusCapacity(number_of_passengers))
end

function shift!(bus::Bus, sub::TailSubstation)
    if !next_occupied(sub)
        fill_next!(sub, bus)
        clear!(sub)
    end
end

function shift!(bus::Bus, sub::HeadSubstation, mesh::Vector{Id}, 
        buses_number::Int, exit_looking_distance::Position)
    bus_pos = position(sub)
    if boarded(bus) > zero(Sleep)
        boarded!(bus)
    elseif no_bus(mesh, bus_pos, buses_number, exit_looking_distance)
        waiting!(bus)
        position!(bus, bus_pos)
        clear!(sub)
    end
end

function no_bus(mesh::Vector{Id}, pos::Position, buses_number::Int,
        exit_looking_distance::Position)
    for i in (pos - exit_looking_distance):pos
        if mesh[i] > 0 && mesh[i] <= buses_number
            return false
        end
    end
    return true
end