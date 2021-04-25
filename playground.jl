#=using BRTAutomaton
i1 = Intinerary(true, false, true)
i2 = Intinerary(true, true, true)
i3 = Intinerary(true, true, false)
_buses = [i1, i3, i2, i2, i1, i3, i1, i1, i3, i2, i1, i1, i2, i2, i2, i2, i2]
a = Automaton(station_quantity=3,
                buses_as_intineraries=_buses,
                station_spacing=60,
                boarded_iterations=4,
                max_embark=120,
                max_disembark=120,
                max_speed=6)

w = gui(a)
=#
using BRTAutomaton
using Random
using BenchmarkTools
_buses = [BitVector([true, bitrand(99)...]) for i in 1:500]
a = Automaton(station_quantity=100,
                buses_as_intineraries=_buses,
                station_spacing=60,
                boarded_iterations=4,
                max_embark=120,
                max_disembark=120,
                max_speed=6)
@benchmark run!(a, 10000)