#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Bus.jl (c) 2021
Description: A bus is the only moving object in the automaton
Created:  2021-03-20T23:17:16.000Z
Modified: 2021-04-24T06:24:35.126Z
=#

struct Bus <: Object
    id::Id
    position::Ref{Position}
    speed::Ref{Speed}
    intinerary::Intinerary
    passengers::Ref{BusCapacity}
    
    boarded::Ref{Bool}
    waiting::Ref{Bool}

    cycle_iterations::Ref{Stat}
end

Bus(id::Id, intinerary::Intinerary) =
    Bus(id, VOID_POSITION, zero(Speed), intinerary, Ref(zero(BusCapacity)),
        Ref(true), Ref(false), Ref(zero(Stat)))

# Getters and setters
@inline Base.position(bus::Bus) = bus.position[]
@inline position!(bus::Bus, position::Position) = bus.position[] = position

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
@inline boarded!(bus::Bus) = bus.boarded[] = !boarded(bus)

@inline intinerary(bus::Bus) = bus.intinerary

@inline cycle_iterations(bus::Bus) = bus.cycle_iterations[]
@inline cycle_iterations!(bus::Bus, val::Stat) = bus.cycle_iterations[] = val

# Displays
Base.show(io::IO, bus::Bus) = 
    print(io, "Bus(position: $(Int(position(bus))), speed: $(Int(speed(bus)))"*
        ", boarded: $(boarded(bus)), waiting: $(waiting(bus)))")

Base.display(bus::Bus) = 
    print("Bus(position: $(Int(position(bus))), speed: $(Int(speed(bus)))"*
        ", boarded: $(boarded(bus)), waiting: $(waiting(bus)))")