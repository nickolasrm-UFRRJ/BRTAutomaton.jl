#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Automaton.jl (c) 2021
Description: A automaton is a  simulates the BRT traffic
Created:  2021-03-21T00:53:00.324Z
Modified: 2021-04-25T08:19:21.343Z
=#

struct Automaton
    #Structure
    buses::Vector{Bus}
    deploying_queue::Vector{Bus}
    loop_wall::LoopWall

    stations::Vector{Station}
    head_substations::Vector{HeadSubstation}
    tail_substations::Vector{Vector{TailSubstation}}
    first_substation::Union{HeadSubstation, TailSubstation}

    objects::Vector{Object}

    lines::Vector{Intinerary}

    mesh_i::Vector{Id}
    mesh_i1::Vector{Id}

    current_mesh::Ref{Bool}

    #Environment
    number_of_substations::Int
    station_spacing::Position
    substation_spacing::Position
    exit_looking_distance::Position
    boarded_iterations::Sleep
    
    bus_capacity::BusCapacity
    station_capacity::StationCapacity
    
    max_embark::BusCapacity
    max_disembark::BusCapacity
    max_generation::BusCapacity
    
    max_speed::Speed
    
    #Stats
    speed_sum::Ref{Stat}
    iteration_counter::Ref{Stat}
    cycle_iterations_sum::Ref{Stat}
    cycle_counter::Ref{Stat}
    embark_sum::Ref{Stat}
    disembark_sum::Ref{Stat}
    boarded_counter::Ref{Stat}
end

function Automaton(;station_quantity::Int,
         buses_as_intineraries::Vector{Intinerary},
         number_of_substations::Integer=3,
         station_spacing::Integer=80,
         substation_spacing::Integer=3,
         safe_margin::Integer=2,
         boarded_iterations::Integer=2,
         bus_capacity::Integer=120,
         station_capacity::Integer=600,
         max_embark::Integer= Int(bus_capacity / 2),
         max_disembark::Integer=bus_capacity,
         max_generation::Integer=2,
         max_speed::Integer=4)
    asserts(station_quantity, buses_as_intineraries, number_of_substations,
            station_spacing, substation_spacing, safe_margin, 
            boarded_iterations, bus_capacity, station_capacity, 
            max_embark, max_disembark, max_generation, max_speed)
            
    #Converting types
    station_spacing, substation_spacing, safe_margin, 
    bus_capacity, station_capacity, max_embark, 
    max_disembark, max_generation, max_speed,
    boarded_iterations =
    Position(station_spacing), Position(substation_spacing), Position(safe_margin),
    BusCapacity(bus_capacity), StationCapacity(station_capacity), BusCapacity(max_embark), 
    BusCapacity(max_disembark), BusCapacity(max_generation), Speed(max_speed),
    Sleep(boarded_iterations)
    
    #Allocating data
    id = ids(length(buses_as_intineraries), station_quantity, number_of_substations)
    buses = generate(Bus, buses_as_intineraries, id)
    stations = generate(Station, station_quantity, id, 
        station_spacing, number_of_substations, substation_spacing,
        max_embark, max_disembark, max_generation)
    heads, tails = generate(AbstractSubstation, stations, id, 
        number_of_substations, substation_spacing)
    wall = generate(LoopWall, id, station_quantity, station_spacing, 
            number_of_substations, substation_spacing)

    #Allocating meshes
    mesh_i = mesh(heads, tails, wall, station_spacing, number_of_substations, substation_spacing)
    mesh_i1 = mesh(heads, tails, wall, station_spacing, number_of_substations, substation_spacing)

    Automaton(buses, [bus for bus in buses], wall,
                        stations, heads, tails,
                        !isempty(tails) ? tails[1][end] : heads[1],
                        vcat(buses, stations, 
                            [[h,t...] for (h,t) in zip(heads, tails)]..., wall),
                        buses_as_intineraries,
                        mesh_i, mesh_i1,
                        Ref(false),
                        #Env
                        number_of_substations,
                        station_spacing,
                        substation_spacing,
                        safe_margin + BUS_LENGTH,
                        boarded_iterations,
                        bus_capacity,
                        station_capacity,
                        max_embark,
                        max_disembark,
                        max_generation,
                        max_speed,
                        #Stats
                        Ref(zero(Stat)),
                        Ref(zero(Stat)),
                        Ref(zero(Stat)),
                        Ref(zero(Stat)),
                        Ref(zero(Stat)),
                        Ref(zero(Stat)),
                        Ref(zero(Stat))
                    )
end

#Specific
@inline meshes(automaton::Automaton) = 
    current_mesh(automaton) ? (automaton.mesh_i, automaton.mesh_i1) :
                              (automaton.mesh_i1, automaton.mesh_i)
@inline function meshes!(automaton::Automaton)
    current_mesh!(automaton)
    meshes(automaton)
end
    
#Getters and setters
@inline head_substations(automaton::Automaton) = automaton.head_substations
@inline tail_substations(automaton::Automaton) = automaton.tail_substations

@inline current_mesh(automaton::Automaton) = automaton.current_mesh[]
@inline current_mesh!(automaton::Automaton) = 
    automaton.current_mesh[] = !automaton.current_mesh[]

@inline exit_looking_distance(automaton::Automaton) = automaton.exit_looking_distance

@inline capacity(::Type{Bus}, automaton::Automaton) = automaton.bus_capacity
@inline capacity(::Type{Station}, automaton::Automaton) = automaton.station_capacity

@inline boarded_iterations(automaton::Automaton) = automaton.boarded_iterations

@inline max_speed(automaton::Automaton) = automaton.max_speed

@inline buses(automaton::Automaton) = automaton.buses
@inline stations(automaton::Automaton) = automaton.stations

@inline objects(automaton::Automaton) = automaton.objects

@inline deploying_queue(automaton::Automaton) = automaton.deploying_queue
@inline loop_wall(automaton::Automaton) = automaton.loop_wall

@inline first_substation(automaton::Automaton) = automaton.first_substation

@inline speed_sum(automaton::Automaton) = automaton.speed_sum[]
@inline speed_sum!(automaton::Automaton, val::Stat) = automaton.speed_sum[] = val

@inline iteration_counter(automaton::Automaton) = automaton.iteration_counter[]
@inline iteration_counter!(automaton::Automaton, val::Stat) = 
    automaton.iteration_counter[] = val

@inline cycle_iterations_sum(automaton::Automaton) = automaton.cycle_iterations_sum[]
@inline cycle_iterations_sum!(automaton::Automaton, val::Stat) = 
    automaton.cycle_iterations_sum[] = val

@inline cycle_counter(automaton::Automaton) = automaton.cycle_counter[]
@inline cycle_counter!(automaton::Automaton, val::Stat) = automaton.cycle_counter[] = val

@inline embark_sum(automaton::Automaton) = automaton.embark_sum[]
@inline embark_sum!(automaton::Automaton, val::Stat) = automaton.embark_sum[] = val

@inline disembark_sum(automaton::Automaton) = automaton.disembark_sum[]
@inline disembark_sum!(automaton::Automaton, val::Stat) = automaton.disembark_sum[] = val

@inline boarded_counter(automaton::Automaton) = automaton.boarded_counter[]
@inline boarded_counter!(automaton::Automaton, val::Stat) = automaton.boarded_counter[] = val

# Displays
Base.show(io::IO, automaton::Automaton) = 
    print(io, "Automaton(buses: $(length(buses(automaton))), stations: $(length(stations(automaton))))")

Base.display(automaton::Automaton) =
    print("Automaton(buses: $(length(buses(automaton))), stations: $(length(stations(automaton))))")