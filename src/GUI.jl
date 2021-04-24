#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
GUI.jl (c) 2021
Description: GUI module
Created:  2021-04-23T20:21:57.456Z
Modified: 2021-04-23T21:20:16.063Z
=#

module GUI

    using ..BRTAutomaton
    using Blink

    include("GUI/Display.jl")

    export gui

end