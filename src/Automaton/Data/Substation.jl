#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
PhantomWall.jl (c) 2021
Description: A substation is an invisble object that makes bus to stop.
Created:  2021-04-18T16:32:25.494Z
Modified: 2021-04-22T09:54:34.300Z
=#

const Occupied = Ref{Union{Bus, Nothing}}

@inline occupied(oc::Occupied) = !(oc[] isa Nothing)
@inline bus(oc::Occupied) = oc[]
@inline fill!(oc::Occupied, bus::Bus) = oc[] = bus
@inline clear!(oc::Occupied) = oc[] = nothing

abstract type AbstractSubstation <: Object end

struct TailSubstation <: AbstractSubstation
    id::Id
    position::Position
    parent::Station
    
    occupied::Occupied
    next_occupied::Occupied
end

struct HeadSubstation <: AbstractSubstation
    id::Id
    position::Position
    parent::Station

    occupied::Occupied
end

TailSubstation(id::Id, parent::Station, 
        position::Position, next_occupied::Occupied) =
    TailSubstation(id, position, parent, Occupied(nothing), next_occupied)

HeadSubstation(id::Id, parent::Station, position::Position) =
    HeadSubstation(id, position, parent, Occupied(nothing))

# Getters and setters
@inline occupied_ref(sub::AbstractSubstation) = sub.occupied
@inline occupied(sub::AbstractSubstation) = occupied(occupied_ref(sub))
@inline bus(sub::AbstractSubstation) = bus(occupied_ref(sub))
@inline fill!(sub::AbstractSubstation, bus::Bus) = fill!(occupied_ref(sub), bus)
@inline clear!(sub::AbstractSubstation) = clear!(occupied_ref(sub))

@inline next_occupied_ref(sub::TailSubstation) = sub.next_occupied
@inline next_occupied(sub::TailSubstation) = occupied(next_occupied_ref(sub))
@inline fill_next!(sub::TailSubstation, bus::Bus) = fill!(next_occupied_ref(sub), bus)

@inline parent(sub::AbstractSubstation) = sub.parent
@inline position(sub::AbstractSubstation) = sub.position
@inline last(sub::AbstractSubstation) = sub.last