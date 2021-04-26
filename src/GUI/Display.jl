#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Display.jl (c) 2021
Description: Drawing functions for displaying the automaton
Created:  2021-04-23T20:29:06.663Z
Modified: 2021-04-26T05:13:13.011Z
=#

const BUS_COLOR = "#000"
const SUBSTATION_COLOR = "#00ff00"
const OCCUPIED_SUBSTATION_COLOR = "#0000ff"
const LOOP_WALL_COLOR = "#ff0000"

function start()
    if Sys.iswindows()
        html = "file:///" * joinpath(@__DIR__, "index.html")
    else
        html = "file://" * joinpath(@__DIR__, "index.html")
    end
    global app = Application()
    Window(app, URI(html))
end

function block_input(w::Window)
    run(w, "block_input()")
end

function unblock_input(w::Window)
    run(w, "unblock_input()")
end

function initialize(w::Window, automaton::Automaton)
    m1, m2 = Automata.meshes(automaton)
    run(w, "draw_structure($(length(m1)))")
end

from(pos::Integer, length::Integer) = Int(pos - length + 1)
from(pos::Integer) = Int(pos)
to(pos::Integer) = Int(pos)
to(pos::Integer, length::Integer) = Int(pos + length - 1)

function draw(w::Window, bus::Bus)
    if !Automata.isboarded(bus)
        lpos = Automata.last_position(bus)
        run(w, "clear($(from(lpos, Automata.BUS_LENGTH)), $(to(lpos)))")
        pos = position(bus)
        run(w, "draw($(from(pos, Automata.BUS_LENGTH)), $(to(pos)), '$(BUS_COLOR)')")
    elseif Automata.boarded(bus) == Automata.FLAG_JUST_BOARDED
        lpos = Automata.last_position(bus)
        run(w, "clear($(from(lpos, Automata.BUS_LENGTH)), $(to(lpos)))")
    end
end

function draw_stats(w::Window, automaton::Automaton)
    run(w, "write_stats($(avg_speed(automaton)), $(avg_cycle_iterations(automaton)), "*
            "$(avg_embarking(automaton)), $(avg_disembarking(automaton)))")
end

function draw(w::Window, sub::AbstractSubstation)
    pos = position(sub)
    if Automata.occupied(sub)
        run(w, "draw($(from(pos)), $(to(pos, Automata.SUBSTATION_LENGTH)), "*
                "'$(OCCUPIED_SUBSTATION_COLOR)')")
    else
        run(w, "draw($(from(pos)), $(to(pos, Automata.SUBSTATION_LENGTH)), "*
                "'$(SUBSTATION_COLOR)')")
    end
end

function draw(w::Window, wall::LoopWall)
    pos = position(wall)
    run(w, "clear($(from(pos, Automata.BUS_LENGTH+1)), $(to(pos)))")
    run(w, "draw($(from(pos)), $(to(pos)), '$(LOOP_WALL_COLOR)')")
end

function draw(w::Window, automaton::Automaton)
    draw(w, Automata.loop_wall(automaton))
    for bus in buses(automaton) draw(w, bus) end
    for sub in Automata.head_substations(automaton) draw(w, sub) end
    for tail in Automata.tail_substations(automaton) 
        for sub in tail draw(w, sub) end end
    draw_stats(w, automaton)
end

function iterate(w, automaton::Automaton, iters::Int, sl::Float64)
    block_input(w)
    for i in 1:iters
        run!(automaton, 1)
        draw(w, automaton)
        sleep(sl)
    end
    unblock_input(w)
end

function input(w::Window, automaton::Automaton)
    ch = msgchannel(w)
    msg = split(take!(ch), ":")
    if msg[1] == "iterate"
        iterate(w, automaton, parse(Int, msg[2]), parse(Float64, msg[3]))
    end
end

function gui(a::Automaton)
    w = start()
    initialize(w, a)
    draw(w, a)
    try
        while(w.exists)
            input(w, a)
        end
    catch
        @info "Window closed"
    end
end