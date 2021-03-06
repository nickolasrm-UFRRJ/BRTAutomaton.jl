#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
LoopWall.jl (c) 2021
Description: Object that represents the end of a corridor, and sends the bus
            back to the start
Created:  2021-04-22T22:44:24.692Z
Modified: 2021-04-25T02:11:50.556Z
=#

struct LoopWall <: Object
    id::Id
    position::Position
    to_enqueue::Ref{Union{Bus, Nothing}}
end

LoopWall(id::Id, position::Position) = 
    LoopWall(id, position, Ref{Union{Bus, Nothing}}(nothing))

@inline clear!(wall::LoopWall) = wall.to_enqueue[] = nothing
@inline Base.isempty(wall::LoopWall) = wall.to_enqueue[] isa Nothing
@inline enqueue!(wall::LoopWall, bus::Bus) = wall.to_enqueue[] = bus
@inline bus(wall::LoopWall) = wall.to_enqueue[]
@inline Base.position(wall::LoopWall) = wall.position
@inline bus!(wall::LoopWall) = (tmp = bus(wall); clear!(wall); tmp)