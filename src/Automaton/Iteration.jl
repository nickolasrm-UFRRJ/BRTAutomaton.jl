#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Iteration.jl (c) 2021
Description: Contains functions related to the automaton iterations
Created:  2021-04-19T19:50:34.354Z
Modified: 2021-04-25T04:57:07.870Z
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
    boarded_iters = boarded_iterations(automaton)
    
    deploy_bus!(
        automaton,
        deploying_queue(automaton),
        loop_wall(automaton),
        mesh_i,
        mesh_i1,
        first_substation(automaton),
        length(arr_buses),
        boarded_iters
    )

    for station in arr_stations iterate!(station, 
        capacity(Station, automaton)) end
    for sub in heads iterate!(automaton, sub, mesh_i, mesh_i1, length(arr_buses), 
        bus_capacity, exit_looking_distance(automaton), boarded_iters) end
    #because they are sequentially allocated, substations will 
    #be sorted in decrescent order 
    for tail in tails for sub in tail iterate!(automaton, sub, mesh_i, mesh_i1,
        bus_capacity, boarded_iters) end end
    for bus in arr_buses iterate!(automaton, bus, mesh_i, mesh_i1, 
        arr_objects, max_speed(automaton)) end

    incr_iteration_counter!(automaton)
end

function deploy_bus!(automaton::Automaton, queue::Vector{Bus}, 
        wall::LoopWall, mesh_i::Vector{Id}, mesh_i1::Vector{Id}, 
        first_sub::AbstractSubstation, buses_quantity::Int,
        boarded_iterations::Sleep)
    enqueue!(automaton, queue, wall)

    if !isempty(queue)
        if !occupied(first_sub)
            if next_occupied(first_sub)
                bus = dequeue!(queue, mesh_i, mesh_i1)
                boarded!(bus, boarded_iterations)
                fill!(first_sub, bus)
            elseif no_bus(mesh_i, BUS_STARTING_POSITION, 
                    buses_quantity, OFFSET1_BUS_STARTING_POSITION)
                bus = dequeue!(queue, mesh_i, mesh_i1)
                position!(bus, BUS_STARTING_POSITION)
                fill!(mesh_i1, bus)   
            end
        end
    end
end

function dequeue!(queue::Vector{Bus}, mesh_i::Vector{Id}, mesh_i1::Vector{Id})
    bus = popfirst!(queue)
    waiting!(bus, false)
    boarded!(bus, zero(Sleep))
    if position(bus) != BUS_STARTING_POSITION 
        clear!(mesh_i, bus)
        clear_last!(mesh_i1, bus) 
    end
    bus
end

enqueue!(automaton::Automaton, queue::Vector{Bus}, wall::LoopWall) =
    if !isempty(wall) 
        _bus = bus(wall)
        
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
    if !waiting(bus) && !isboarded(bus)
        move!(bus, mesh_i, mesh_i1, objects, max_speed)
    elseif waiting(bus)
        wait!(bus, mesh_i1)
    end
    add_to_speed_sum!(automaton, speed(bus))
    incr_cycle_iterations!(bus)
end

function iterate!(automaton::Automaton, sub::HeadSubstation, 
        mesh_i::Vector{Id}, mesh_i1::Vector{Id},
        buses_quantity::Int, bus_capacity::BusCapacity, 
        exit_looking_distance::Position, boarded_iterations::Sleep)
    if occupied(sub)
        _bus = bus(sub)
        station = parent(sub)
        board!(_bus, boarded_iterations, mesh_i, mesh_i1)
        disembark!(automaton, _bus, station)
        embark!(automaton, _bus, station, bus_capacity)
        shift!(_bus, sub, mesh_i, buses_quantity, exit_looking_distance)
        incr_boarded_counter!(automaton)
    end
    write!(mesh_i, sub)
end

function iterate!(automaton::Automaton, sub::TailSubstation, 
        mesh_i::Vector{Id}, mesh_i1::Vector{Id}, bus_capacity::BusCapacity,
        boarded_iterations::Sleep)
    if occupied(sub)
        _bus = bus(sub)
        station = parent(sub)
        board!(_bus, boarded_iterations, mesh_i, mesh_i1)
        disembark!(automaton, _bus, station)
        embark!(automaton, _bus, station, bus_capacity)
        shift!(_bus, sub)
        incr_boarded_counter!(automaton)
    end
    write!(mesh_i, sub)
end