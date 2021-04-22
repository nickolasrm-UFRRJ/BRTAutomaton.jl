#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Automaton.jl (c) 2021
Description: Transition functions for bus movement
Created:  2021-03-21T00:53:00.324Z
Modified: 2021-04-22T11:39:24.213Z
=#

function move!(bus::Bus,
        mesh_i::MVector{N, Id}, 
        mesh_i1::MVector{N, Id},
        objects::SVector{K, Object}) where {N, K}
    clear!(bus, mesh_i1)
    accelerate!(bus)
    deaccelerate!(bus, mesh_i, objects)
    move!(bus, mesh_i1)
end

@inline function move!(bus::Bus,
        mesh::MVector{N, Id}) where {N}
    position!(bus, Position(position(bus) + speed(bus)))
    fill!(bus, id(bus), mesh)
end

@inline clear!(bus::Bus,
        mesh::MVector{N, Id}) where {N} = 
    fill!(bus, EMPTY, mesh)

@inline function fill!(bus::Bus, value::Id,
        mesh::MVector{N, Id}) where {N}
    mesh[position(bus) - offset1_length(bus)] = value
    mesh[position(bus)] = value
end

@inline function accelerate!(bus::Bus)
    speed!(bus, min(speed(bus) + one(UInt8), MAX_SPEED))
end

@inline function deaccelerate!(bus::Bus, 
        mesh::MVector{N, Id},
        objects::SVector{K, Object}) where {N, K}
    for i = (position(bus)+1):(position(bus)+speed(bus))
        if isntempty(mesh, i)
            if collision(bus, objects, mesh, i)
                break
            end
        end
    end
end