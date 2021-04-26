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
#=
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
x = [a, deepcopy(a), deepcopy(a), deepcopy(a)]
#@benchmark run!(a, 10000)
@benchmark for a in x
    run!(a, 1000)
end=#

using BRTAutomaton
    i1 = Intinerary(true, falses(4)...)
    buses = [deepcopy(i1) for i in 1:30]
    a = Automaton(
                    station_quantity=5,
                    buses_as_intineraries=buses)

    set = TrainingSet(a,
            population_size=30, 
            iterations=1000,
            elitism=10,
            mutation_rate=0.1)
    train!(a, set, gen_limit=20)