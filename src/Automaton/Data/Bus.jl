#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Bus.jl (c) 2021
Description: A bus is the only moving object in the automaton
Created:  2021-03-20T23:17:16.000Z
Modified: 2021-04-19T21:32:00.454Z
=#

struct Bus <: Object
    id::Id
    position::Ref{Position}
    speed::Ref{Speed}
    intinerary::Intinerary
    passengers::Ref{Capacity}
    
    boarded::Ref{Bool}
    waiting::Ref{Bool}
end

Bus(id::Id, intinerary::Intinerary) =
    Bus(id, one(Position), zero(Speed), intinerary, Ref(zero(Capacity)),
        Ref(false), Ref(false))

# Getters and setters
@inline position(bus::Bus) = bus.position[]
@inline position!(bus::Bus, position::Position) = bus.position[] = position
@inline move!(bus::Bus) = position!(bus, speed(bus) + position(bus))

@inline speed(bus::Bus) = bus.speed[]
@inline speed!(bus::Bus, speed::Speed) = bus.speed[] = speed

@inline offset1_length(bus::Bus) = OFFSET1_BUS_LENGTH
@inline length(bus::Bus) = BUS_LENGTH
@inline capacity(bus::Bus) = BUS_CAPACITY

@inline passengers(bus::Bus) = bus.passengers[]
@inline passengers!(bus::Bus, val::Capacity) = bus.passengers[] = add

@inline waiting(bus::Bus) = bus.waiting[]
@inline waiting!(bus::Bus) = bus.waiting[] = !waiting(bus)
@inline waiting!(bus::Bus, val::Bool) = bus.waiting[] = val

@inline boarded(bus::Bus) = bus.boarded[]
@inline boarded!(bus::Bus) = bus.boarded[] = !boarded(bus)