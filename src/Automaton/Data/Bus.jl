#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Bus.jl (c) 2021
Description: A bus is the only moving object in the automaton
Created:  2021-03-20T23:17:16.000Z
Modified: 2021-04-25T04:48:16.907Z
=#

struct Bus <: Object
    id::Id
    position::Ref{Position}
    last_position::Ref{Position}
    speed::Ref{Speed}
    itinerary::Itinerary
    passengers::Ref{BusCapacity}
    
    boarded::Ref{Sleep}
    waiting::Ref{Bool}

    cycle_iterations::Ref{Stat}
end

Bus(id::Id, itinerary::Itinerary) =
    Bus(id, Ref(BUS_STARTING_POSITION), Ref(Position(BUS_STARTING_POSITION)), 
        zero(Speed), itinerary, Ref(zero(BusCapacity)), Ref(one(Sleep)), 
        Ref(false), Ref(zero(Stat)))

# Getters and setters
@inline last_position(bus::Bus) = bus.last_position[]
@inline last_position!(bus::Bus, val::Position) = bus.last_position[] = val

@inline Base.position(bus::Bus) = bus.position[]
@inline function position!(bus::Bus, _position::Position)
    last_position!(bus, position(bus))
    bus.position[] = _position
end

@inline speed(bus::Bus) = bus.speed[]
@inline speed!(bus::Bus, speed::Speed) = bus.speed[] = speed

@inline offset1_length(bus::Bus) = OFFSET1_BUS_LENGTH
@inline Base.length(bus::Bus) = BUS_LENGTH

@inline passengers(bus::Bus) = bus.passengers[]
@inline passengers!(bus::Bus, val::BusCapacity) = bus.passengers[] = val

@inline waiting(bus::Bus) = bus.waiting[]
@inline waiting!(bus::Bus) = bus.waiting[] = !waiting(bus)
@inline waiting!(bus::Bus, val::Bool) = bus.waiting[] = val

@inline boarded(bus::Bus) = bus.boarded[]
@inline boarded!(bus::Bus, val::Sleep) = bus.boarded[] = val

@inline itinerary(bus::Bus) = bus.itinerary

@inline cycle_iterations(bus::Bus) = bus.cycle_iterations[]
@inline cycle_iterations!(bus::Bus, val::Stat) = bus.cycle_iterations[] = val

# Displays
Base.show(io::IO, bus::Bus) = 
    print(io, "Bus(position: $(Int(position(bus))), speed: $(Int(speed(bus)))"*
        ", boarded: $(boarded(bus)), waiting: $(waiting(bus)))")

Base.display(bus::Bus) = 
    print("Bus(position: $(Int(position(bus))), speed: $(Int(speed(bus)))"*
        ", boarded: $(boarded(bus)), waiting: $(waiting(bus)))")