#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Automaton.jl (c) 2021
Description: A automaton is a  simulates the BRT traffic
Created:  2021-03-21T00:53:00.324Z
Modified: 2021-04-22T10:36:16.497Z
=#

struct Automaton
    buses::SVector{nBuses, Bus} where{nBuses}

    stations::SVector{nStations, Station} where{nStations}
    head_substation::SVector{nHeadSubs, Substation} where{nHeadSubs}
    tail_substations::SVector{nTailSubs, Substation} where{nTailSubs}

    objects::SVector{nObjects, Object} where {nObjects}

    lines::SVector{nLines, Intinerary} where{nLines}

    padded_mesh_i::MVector{nCells, Id} where {nCells}
    padded_mesh_i1::MVector{nCells, Id} where {nCells}
    mesh_i::Ptr{Id}
    mesh_i1::Ptr{Id}

    corridor_length::Int

    current_mesh::Ref{Bool}
end

function Automaton(corridor_length::Int, station_quantity::Int,
         buses_as_intineraries::Array{Intinerary, 1})
    id = ids(bus_quantity, station_quantity)
    intineraries = generate(Intinerary, buses_as_intineraries)
    buses = generate(Bus, intineraries, id)
    stations = generate(Station, station_quantity, id)
    heads, tails = generate(Substation, stations, id)

    padded_mesh_i, mesh_i = alloc_mesh(corridor_length)
    padded_mesh_i1, mesh_i1 = alloc_mesh(corridor_length)

    automaton = Automaton(buses, stations, heads, tails,
                        vcat(buses, heads, (tails...)...),
                        intineraries,
                        padded_mesh_i, padded_mesh_i1,
                        mesh_i, mesh_i1,
                        corridor_length,
                        Ref(false))
    automaton
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
@inline current_mesh(automaton::Automaton) = automaton.current_mesh[]
@inline current_mesh!(automaton::Automaton) = 
    automaton.current_mesh[] = !automaton.current_mesh[]

@inline buses(automaton::Automaton) = automaton.buses
@inline stations(automaton::Automaton) = automaton.stations