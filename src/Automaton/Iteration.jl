#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Iteration.jl (c) 2021
Description: Contains functions related to the automaton iterations
Created:  2021-04-19T19:50:34.354Z
Modified: 2021-04-23T20:15:05.688Z
=#

function run!(automaton::Automaton, iterations::Int)
    for i = 1:iterations iterate!(automaton) end
end

function iterate!(automaton::Automaton)
    arr_buses = buses(automaton)
    heads = head_substations(automaton)
    tails = tail_substations(automaton)
    arr_stations = stations(automaton)
    arr_objects = objects(automaton)
    mesh_i, mesh_i1 = meshes!(automaton)
    bus_capacity = capacity(Bus, automaton)
    
    deploy_bus!(
        deploying_queue(automaton),
        loop_wall(automaton),
        mesh_i,
        first_substations(automaton)
    )

    for station in arr_stations iterate!(station, 
        capacity(Station, automaton)) end
    for sub in heads iterate!(sub, mesh_i1, length(arr_buses), 
        bus_capacity, exit_looking_distance(automaton)) end
    #because they are sequentially allocated, substations will 
    #be sorted in decrescent order 
    for tail in tails for sub in tail iterate!(sub, mesh_i1,
        bus_capacity) end end
    for bus in arr_buses iterate!(bus, mesh_i, mesh_i1, 
        arr_objects, max_speed(automaton)) end
end

function deploy_bus!(queue::Vector{Bus}, wall::LoopWall, mesh::Vector{Id},
        first_subs::Vector{AbstractSubstation})
    enqueue!(queue, wall, mesh)

    if !isempty(queue)
        look_next = true

        while look_next
            look_next = false
            for sub in first_subs
                if !occupied(sub)
                    bus = popfirst!(queue)
                    boarded!(bus, one(Sleep))
                    fill!(sub, bus)
                    if !isempty(queue)
                        look_next = true
                    end
                    break
                end
            end
        end
    end
end

enqueue!(queue::Vector{Bus}, wall::LoopWall, mesh_i::Vector{Id}) =
    if !isempty(wall) 
        clear!(mesh_i, bus(wall))
        position!(bus(wall), VOID_POSITION)
        push!(queue, bus!(wall)) 
    end

function iterate!(station::Station, station_capacity::StationCapacity)
    passengers!(station, min(generation_rate(station) + passengers(station),
                              station_capacity))
end

function iterate!(bus::Bus, mesh_i::Vector{Id}, 
        mesh_i1::Vector{Id}, objects::Vector{Object}, 
        max_speed::Speed)
    if !waiting(bus) && !isboarded(bus)
        move!(bus, mesh_i, mesh_i1, objects, max_speed)
    end
end

function iterate!(sub::HeadSubstation, mesh::Vector{Id}, 
        buses_number::Int, bus_capacity::BusCapacity, 
        exit_looking_distance::Position)
    if occupied(sub)
        _bus = bus(sub)
        station = parent(sub)
        desimbark!(_bus, station)
        embark!(_bus, station, bus_capacity)
        shift!(_bus, sub, mesh, buses_number, exit_looking_distance)
        write!(mesh, sub)
    end
end

function iterate!(sub::TailSubstation, mesh::Vector{Id},
        bus_capacity::BusCapacity)
    if occupied(sub)
        _bus = bus(sub)
        station = parent(sub)
        desimbark!(_bus, station)
        embark!(_bus, station, bus_capacity)
        shift!(_bus, sub)
        write!(mesh, sub)
    end
end