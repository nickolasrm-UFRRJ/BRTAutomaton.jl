#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Station.jl (c) 2021
Description: A station is a place where a bus can stop to leave or to pick passengers
Created:  2021-03-21T00:12:34.104Z
Modified: 2021-04-24T17:42:16.155Z
=#

struct Station <: Object
    id::Id
    relative_id::Id #relative to the number of stations, and not the objects anymore
    position::Position
    embark_rate::BusCapacity
    disembark_rate::BusCapacity
    generation_rate::BusCapacity
    passengers::Ref{StationCapacity}
end

Station(id::Id, relative_id::Id, position::Position, embark_rate::BusCapacity, 
        disembark_rate::BusCapacity, generation_rate::BusCapacity) =
    Station(id, relative_id, position, embark_rate, disembark_rate, 
        generation_rate, Ref(zero(StationCapacity)))

# Getters and setters
@inline passengers(station::Station) = station.passengers[]

@inline passengers!(station::Station, value::StationCapacity) = station.passengers[] = value

@inline embark_rate(station::Station) = station.embark_rate
@inline disembark_rate(station::Station) = station.disembark_rate
@inline generation_rate(station::Station) = station.generation_rate

@inline Base.position(station::Station) = station.position

@inline relative_id(station::Station) = station.relative_id

# Displays
Base.show(io::IO, st::Station) =
    print(io, "Station(id: $(id(st)), position: $(position(st)), "*
        "embark_rate: $(embark_rate(st)), disembark_rate: $(disembark_rate(st)), "*
        "passengers: $(passengers(st)))")

Base.display(st::Station) =
    print("Station(id: $(id(st)), position: $(position(st)), "*
        "embark_rate: $(embark_rate(st)), disembark_rate: $(disembark_rate(st)), "*
        "passengers: $(passengers(st)))")