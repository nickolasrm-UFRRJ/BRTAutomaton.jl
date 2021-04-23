#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Collision.jl (c) 2021
Description: Functions that estabilish the relation of the bus with other objects
Created:  2021-04-18T16:27:20.526Z
Modified: 2021-04-23T14:24:20.752Z
=#

@inline collision(bus::Bus, objects::Vector{Object}, mesh::Vector{Id}, i::Position) =
    collision(bus, objects[mesh[i]])

@inline collision(bus::Bus, wall::LoopWall) = 
    (enqueue!(wall, bus); waiting!(bus); speed!(bus, zero(Speed)); true)

@inline collision(bus0::Bus, bus1::Bus) =
    speed!(bus0, Speed(position(bus1) - position(bus0) - length(bus1))); true

function collision(bus::Bus, sub::AbstractSubstation)
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
                fill!(sub, bus)
            else
                return false
            end
        end
        return true
    else
        return false
    end
end
