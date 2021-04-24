#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Display.jl (c) 2021
Description: Drawing functions for displaying the automaton
Created:  2021-04-23T20:29:06.663Z
Modified: 2021-04-24T00:34:06.146Z
=#

function start()
    w = Window(async=false)
    f = open(joinpath(@__DIR__, "index.html")) do file
        read(file, String)
    end
    body!(w, f)
    w
end

function input(w::Window)
    handle(w, "iterate") do args
        @js w "block_input()"
        print(args)
    end
end

function draw()
end

function gui(a::Automaton)
    w = start()
    input(w)
    w
end