#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Reset.jl (c) 2021
Description: Resets the automaton to the initial state
Created:  2021-04-24T00:36:03.651Z
Modified: 2021-04-25T22:55:38.173Z
=#

function reset!(automaton::Automaton)
    reset!.(buses(automaton))
    reset!.(stations(automaton))
    reset!.(head_substations(automaton))
    for tail in tail_substations(automaton)
        reset!.(tail)
    end

    reset_meshes!(automaton)
    reset_stats!(automaton)
    reset_queue!(automaton)
    nothing
end

function reset_stats!(automaton::Automaton)
    speed_sum!(automaton, zero(Stat))
    iteration_counter!(automaton, zero(Stat))
    cycle_iterations_sum!(automaton, zero(Stat))
    cycle_counter!(automaton, zero(Stat))
    embark_sum!(automaton, zero(Stat))
    disembark_sum!(automaton, zero(Stat))
    boarded_counter!(automaton, zero(Stat))
end

function reset_meshes!(automaton::Automaton)
    clear_mesh!(mesh::Vector{Id}) = mesh .= EMPTY
    function rewrite_substations!(mesh::Vector{Id}) 
        for sub in head_substations(automaton) write!(mesh, sub) end
        for tail in tail_substations(automaton) for sub in tail write!(mesh, sub) end end
    end
    rewrite_loopwall!(mesh::Vector{Id}) = mesh[end] = id(loop_wall(automaton))

    m1,m2 = meshes(automaton)
    clear_mesh!(m1); clear_mesh!(m2)
    rewrite_substations!(m1); rewrite_substations!(m2)    
    rewrite_loopwall!(m1); rewrite_loopwall!(m2)
end

function reset_queue!(automaton::Automaton)
    empty!(deploying_queue(automaton))
    append!(deploying_queue(automaton), buses(automaton))
end

function reset!(bus::Bus)
    position!(bus, BUS_LENGTH)
    last_position!(bus, BUS_LENGTH)
    speed!(bus, zero(Speed))
    passengers!(bus, zero(BusCapacity))
    boarded!(bus, one(Sleep))
    waiting!(bus, false)
    cycle_iterations!(bus, zero(Stat))
end

function reset!(wall::LoopWall)
    clear!(wall)
end

function reset!(sub::AbstractSubstation)
    clear!(sub)
end

function reset!(station::Station)
    passengers!(station, zero(StationCapacity))
end
