#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Iteration.jl (c) 2021
Description: Contains functions related to the automaton iterations
Created:  2021-04-19T19:50:34.354Z
Modified: 2021-04-22T11:47:32.770Z
=#

function run(automaton::Automaton, iterations::Int)
    for i = 1:iterations iterate(automaton) end
end

function iterate(automaton::Automaton)
    buses = buses(automaton)
    heads = head_substations(automaton)
    tails = tail_substations(automaton)
    
    for sub in heads iterate(sub, buses) end
    #because they are sequentially allocated, substations will 
    #be sorted in decrescent order 
    for tail in tails for sub in tail iterate(sub) end end
    for bus in buses iterate(bus) end
end

function iterate(bus::Bus, mesh_i::MVector{N, Id}, 
        mesh_i1::MVector{N, Id}, objects::SVector{K, Object}) where{N,K}
    if !waiting(bus) && !boarded(bus)
        move!(bus, mesh_i, mesh_i1, objects)
    end
end

function iterate(sub::HeadSubstation, mesh::MVector{N, Id}, 
        buses_number::Int) where{N}
    if occupied(sub)
        bus = bus(sub)
        station = parent(sub)
        desimbark(bus, station)
        embark(bus, station)
        shift(bus, sub, mesh, buses_number)
    end
end

function iterate(sub::TailSubstation) 
    if occupied(sub)
        bus = bus(sub)
        station = parent(sub)
        desimbark(bus, station)
        embark(bus, station)
        shift(bus, sub)
    end
end

function desimbark(bus::Bus, station::Station)
    passengers!(parent(station), 
        passengers(bus) - min(passengers(bus), desimbark_rate(station)))
end

function embark(bus::Bus, station::Station)
    remaining = capacity(bus) - passengers(bus)
    passengers!(station, 
        passengers(bus) + min(remaining, embark_rate(station)))
end

function shift(bus::Bus, sub::TailSubstation)
    if !next_occupied(sub)
        fill_next!(sub, bus)
        clear!(sub)
    end
end

function shift(bus::Bus, sub::HeadSubstation, mesh::MVector{N, Id},
        buses_number::Int) where {N}
    bus_pos = position(sub) + one(Position)
    if checkbus(mesh, bus_pos, buses_number)
        position!(bus, bus_pos)
        boarded!(bus)
    end
end

function checkbus(mesh::MVector{N, Id}, pos::Position, buses_number::Int)
    for i in (pos - SAFE_LOOKING_DISTANCE):pos
        if mesh[i] > 0 && mesh[i] <= buses_number
            return false
        end
    end
    return true
end