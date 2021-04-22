#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Collision.jl (c) 2021
Description: Functions that estabilish the relation of the bus with other objects
Created:  2021-04-18T16:27:20.526Z
Modified: 2021-04-19T21:20:04.119Z
=#

@inline isntempty(mesh::MVector{N, Id}, i::Id) where {N} = mesh[i] != EMPTY

@inline collision(bus::Bus, objects::SVector{K, Object}, 
    mesh::MVector{N, Id}, i::Id) where {N, K} =
            collision(bus, objects[mesh[i]])

@inline collision(bus0::Bus, bus1::Bus) =
    speed!(bus0, UInt8(position(bus1) - position(bus0) - length(bus1))); true

function collision(bus::Bus, sub::Substation)
    if should_stop(bus, sub)
        if occupied(sub)
            if !waiting(bus)
                #send it to a position it won't affect automaton behaviour
                position!(bus, VOID_POSITION)
                waiting!(bus)
            end
        else
            if next_occupied(sub)
                boarded!(bus)
                waiting!(bus, false)
                occupied!(sub)
            else
                return false
            end
        end
        return true
    else
        return false
    end
end
