#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Iteration.jl (c) 2021
Description: Contains functions related to the automaton iterations
Created:  2021-04-19T19:50:34.354Z
Modified: 2021-04-24T07:20:56.309Z
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
        automaton,
        deploying_queue(automaton),
        loop_wall(automaton),
        mesh_i,
        first_substations(automaton)
    )

    for station in arr_stations iterate!(station, 
        capacity(Station, automaton)) end
    for sub in heads iterate!(automaton, sub, mesh_i, mesh_i1, length(arr_buses), 
        bus_capacity, exit_looking_distance(automaton)) end
    #because they are sequentially allocated, substations will 
    #be sorted in decrescent order 
    for tail in tails for sub in tail iterate!(automaton, sub, mesh_i, mesh_i1,
        bus_capacity) end end
    for bus in arr_buses iterate!(automaton, bus, mesh_i, mesh_i1, 
        arr_objects, max_speed(automaton)) end

    incr_iteration_counter!(automaton)
end

function deploy_bus!(automaton::Automaton, queue::Vector{Bus}, 
        wall::LoopWall, mesh::Vector{Id}, first_subs::Vector{AbstractSubstation})
    enqueue!(automaton, queue, wall, mesh)

    if !isempty(queue)
        look_next = true

        while look_next
            look_next = false
            for sub in first_subs
                if !occupied(sub)
                    bus = popfirst!(queue)
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

enqueue!(automaton::Automaton, queue::Vector{Bus}, wall::LoopWall, mesh_i::Vector{Id}) =
    if !isempty(wall) 
        _bus = bus(wall)
        clear!(mesh_i, _bus) 
        position!(_bus, VOID_POSITION)
        
        waiting!(_bus)
        boarded!(_bus)

        incr_cycle_counter!(automaton)
        add_to_cycle_iterations_sum!(automaton, cycle_iterations(_bus))
        reset_cycle_iterations!(_bus)

        push!(queue, bus!(wall)) 
    end

function iterate!(station::Station, station_capacity::StationCapacity)
    passengers!(station, min(generation_rate(station) + passengers(station),
                              station_capacity))
end

function iterate!(automaton::Automaton, bus::Bus, mesh_i::Vector{Id}, 
        mesh_i1::Vector{Id}, objects::Vector{Object}, 
        max_speed::Speed)
    if !waiting(bus) && !boarded(bus)
        move!(bus, mesh_i, mesh_i1, objects, max_speed)
    end
    add_to_speed_sum!(automaton, speed(bus))
    incr_cycle_iterations!(bus)
end

function iterate!(automaton::Automaton, sub::HeadSubstation, 
        mesh_i::Vector{Id}, mesh_i1::Vector{Id},
        buses_number::Int, bus_capacity::BusCapacity, 
        exit_looking_distance::Position)
    if occupied(sub)
        _bus = bus(sub)
        station = parent(sub)
        if position(_bus) != VOID_POSITION clear!(mesh_i, _bus) end
        disembark!(automaton, _bus, station)
        embark!(automaton, _bus, station, bus_capacity)
        shift!(_bus, sub, mesh_i, buses_number, exit_looking_distance)
        write!(mesh_i1, sub)
        incr_boarded_counter!(automaton)
    end
end

function iterate!(automaton::Automaton, sub::TailSubstation, 
        mesh_i::Vector{Id}, mesh_i1::Vector{Id}, bus_capacity::BusCapacity)
    if occupied(sub)
        _bus = bus(sub)
        station = parent(sub)
        if position(_bus) != VOID_POSITION clear!(mesh_i, _bus) end
        disembark!(automaton, _bus, station)
        embark!(automaton, _bus, station, bus_capacity)
        shift!(_bus, sub)
        write!(mesh_i1, sub)
        incr_boarded_counter!(automaton)
    end
end