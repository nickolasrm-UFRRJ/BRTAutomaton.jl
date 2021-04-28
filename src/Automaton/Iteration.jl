#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Iteration.jl (c) 2021
Description: Contains functions related to the automaton iterations
Created:  2021-04-19T19:50:34.354Z
Modified: 2021-04-28T22:30:08.379Z
=#

function calc_range(tid, len)
    nthread = Threads.nthreads()
    if len > nthread
        return (round(Int, (tid-1)*len/nthread+1)):(round(Int, tid*len/nthread))
    elseif tid <= len
        return tid:tid
    else
        return 1:0
    end
end

function run!(automaton::Automaton, iterations::Int)
    nthread = Threads.nthreads()
    tasks = Vector{Task}(undef, nthread)
    bus_indexes = Vector{UnitRange}(undef, nthread)
    station_indexes = Vector{UnitRange}(undef, nthread)
    for j in 1:nthread
        bus_indexes[j] = calc_range(j, length(buses(automaton)))
        station_indexes[j] = calc_range(j, length(stations(automaton)))
    end

    for i = 1:iterations iterate!(automaton, tasks, 
        bus_indexes, station_indexes) end
end

function iterate!(automaton::Automaton, tasks::Vector{Task},
        buses_indexes::Vector{UnitRange}, station_indexes::Vector{UnitRange})
    arr_buses = buses(automaton)
    arr_objects = objects(automaton)
    mesh_i, mesh_i1 = meshes!(automaton)
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

    parallel_stations(automaton, tasks, station_indexes, 
        mesh_i, mesh_i1, arr_buses, arr_objects, boarded_iters)
    parallel_buses(automaton, tasks, buses_indexes, 
        mesh_i, mesh_i1, arr_buses, arr_objects)

    incr_iteration_counter!(automaton)
end

#Parallel
@inline function parallel_stations(automaton::Automaton, 
        tasks::Vector{Task},
        station_indexes::Vector{UnitRange},
        mesh_i::Vector{Id}, mesh_i1::Vector{Id}, 
        arr_buses::Vector{Bus}, arr_objects::Vector{Object},
        boarded_iters::Sleep)
    station_cap = capacity(Station, automaton)
    arr_stations = stations(automaton)

    arr_heads = head_substations(automaton)
    bus_capacity = capacity(Bus, automaton)
    look = exit_looking_distance(automaton)

    arr_tails = tail_substations(automaton)
    
    for i in eachindex(tasks)
        tasks[i] = @task for j in station_indexes[i]
            iterate!(arr_stations[j], station_cap)
            iterate!(automaton, arr_heads[j], mesh_i, mesh_i1, length(arr_buses), 
                bus_capacity, look, boarded_iters, arr_objects)
            for sub in arr_tails[j]
                iterate!(automaton, sub, mesh_i, mesh_i1,
                    bus_capacity, boarded_iters)
            end
        end
        tasks[i].sticky = true
        ccall(:jl_set_task_tid, Cvoid, (Any, Cint), tasks[i], length(tasks)-i)
        schedule(tasks[i])
    end
    wait.(tasks)
end

@inline function parallel_buses(automaton::Automaton, 
        tasks::Vector{Task}, buses_indexes::Vector{UnitRange},
        mesh_i::Vector{Id}, mesh_i1::Vector{Id},
        arr_buses::Vector{Bus}, arr_objects::Vector{Object})
    len = length(arr_buses)
    maxspeed = max_speed(automaton)
    
    for i in eachindex(tasks)
        tasks[i] = @task begin
            for j in buses_indexes[i]
                iterate!(automaton, arr_buses[j], mesh_i, mesh_i1, arr_objects, maxspeed)
            end
        end
        tasks[i].sticky = true
        ccall(:jl_set_task_tid, Cvoid, (Any, Cint), tasks[i], length(tasks)-i)
        schedule(tasks[i])
    end
    wait.(tasks)
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

function iterate!(station::Station, _station_capacity::StationCapacity)
    passengers!(station, min(generation_rate(station) + passengers(station),
                              _station_capacity))
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
        exit_looking_distance::Position, boarded_iterations::Sleep,
        objects::Vector{Object})
    if occupied(sub)
        _bus = bus(sub)
        station = parent(sub)
        board!(_bus, boarded_iterations, mesh_i, mesh_i1)
        disembark!(automaton, _bus, station)
        embark!(automaton, _bus, station, bus_capacity)
        shift!(_bus, sub, mesh_i, buses_quantity, exit_looking_distance, objects)
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