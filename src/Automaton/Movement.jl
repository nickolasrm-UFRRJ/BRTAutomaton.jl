#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Automaton.jl (c) 2021
Description: Transition functions for bus movement
Created:  2021-03-21T00:53:00.324Z
Modified: 2021-04-23T17:59:47.026Z
=#

function move!(bus::Bus,
        mesh_i::Vector{Id}, 
        mesh_i1::Vector{Id},
        objects::Vector{Object},
        max_speed::Speed)
    clear!(mesh_i, bus)
    accelerate!(bus, max_speed)
    deaccelerate!(bus, mesh_i, objects)
    move!(bus, mesh_i1)
end

@inline function move!(bus::Bus, mesh::Vector{Id})
    position!(bus, Position(position(bus) + speed(bus)))
    fill!(mesh, bus)
end

@inline clear!(mesh::Vector{Id}, bus::Bus) = fill!(mesh, bus, EMPTY)

@inline function fill!(mesh::Vector{Id}, bus::Bus, value::Id=id(bus))
    mesh[position(bus) - offset1_length(bus)] = value
    mesh[position(bus)] = value
end

@inline function accelerate!(bus::Bus, max_speed::Speed)
    speed!(bus, min(speed(bus) + one(Speed), max_speed))
end

@inline function deaccelerate!(bus::Bus, 
        mesh::Vector{Id},
        objects::Vector{Object})
    for i in Position((position(bus)+1)):Position((position(bus)+speed(bus)))
        if isntempty(mesh, i)
            if collision(bus, objects, mesh, i)
                break
            end
        end
    end
end