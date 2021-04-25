#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Collision.jl (c) 2021
Description: Functions that estabilish the relation of the bus with other objects
Created:  2021-04-18T16:27:20.526Z
Modified: 2021-04-25T04:08:19.087Z
=#

@inline collision(bus::Bus, objects::Vector{Object}, mesh::Vector{Id}, i::Position) =
    collision(bus, objects[mesh[i]])

@inline function collision(bus::Bus, wall::LoopWall)
    enqueue!(wall, bus)
    waiting!(bus)
    speed!(bus, Speed(position(wall) - 1 - position(bus)))
    true
end

@inline function collision(bus0::Bus, bus1::Bus)
    speed!(bus0, Speed(position(bus1) - position(bus0) - length(bus1))) 
    true
end

function collision(bus::Bus, sub::AbstractSubstation)
    if should_stop(bus, sub)
        if occupied(sub)
            if !waiting(bus)
                speed!(bus, Speed((position(sub) - one(Position)) - position(bus)))
                waiting!(bus)
            end
        else
            if next_occupied(sub)
                boarded!(bus, FLAG_JUST_BOARDED)
                waiting!(bus, false)
                fill!(sub, bus)
                speed!(bus, Speed((position(sub) - one(Position)) - position(bus)))
            else
                return false
            end
        end
        return true
    else
        return false
    end
end
