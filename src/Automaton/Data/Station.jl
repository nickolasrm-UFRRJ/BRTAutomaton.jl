#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Station.jl (c) 2021
Description: A station is a place where a bus can stop to leave or to pick passengers
Created:  2021-03-21T00:12:34.104Z
Modified: 2021-04-22T11:00:27.099Z
=#

struct Station <: Object
    id::Id
    position::Position
    embark_rate::BusCapacity
    desimbark_rate::BusCapacity
    passengers::Ref{StationCapacity}
end

Station(id::Id, position::Position, embark_rate::BusCapacity, desimbark_rate::BusCapacity) =
    Station(id, position, embark_rate, desimbark_rate, Ref(zero(StationCapacity)))

# Getters and setters
@inline passengers(station::Station) = station.passengers[]

@inline passengers!(station::Station, value::StationCapacity) = station.passengers[] = value

@inline embark_rate(station::Station) = station.embark_rate
@inline desimbark_rate(station::Station) = station.desimbark_rate

@inline position(station::Station) = station.position