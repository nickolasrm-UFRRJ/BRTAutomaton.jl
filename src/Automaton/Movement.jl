#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Automaton.jl (c) 2021
Description: Transition functions for bus movement
Created:  2021-03-21T00:53:00.324Z
Modified: 2021-04-25T03:14:05.027Z
=#

function move!(bus::Bus,
        mesh_i::Vector{Id}, 
        mesh_i1::Vector{Id},
        objects::Vector{Object},
        max_speed::Speed)
    clear_last!(mesh_i1, bus)
    accelerate!(bus, max_speed)
    deaccelerate!(bus, mesh_i, objects)
    move!(bus, mesh_i1)
end

@inline function wait!(bus::Bus, mesh::Vector{Id})
    clear_last!(mesh, bus)
    last_position!(bus, position(bus))
    speed!(bus, zero(Speed))
    fill!(mesh, bus)
end

@inline function move!(bus::Bus, mesh::Vector{Id})
    position!(bus, Position(position(bus) + speed(bus)))
    fill!(mesh, bus)
end

@inline clear!(mesh::Vector{Id}, bus::Bus) = fill!(mesh, bus, EMPTY)

@inline clear_last!(mesh::Vector{Id}, bus::Bus) = 
    fill!(Bus, mesh, last_position(bus), EMPTY)

@inline fill!(mesh::Vector{Id}, bus::Bus, value::Id=id(bus)) =
    fill!(Bus, mesh, position(bus), value)

@inline function fill!(::Type{Bus}, mesh::Vector{Id}, position::Position, value::Id)
    mesh[position - OFFSET1_BUS_LENGTH] = value
    mesh[position] = value
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