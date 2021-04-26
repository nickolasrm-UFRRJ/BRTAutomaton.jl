@testset "Optimizer" begin
    using BRTAutomaton
    i1 = Intinerary(true, falses(4)...)
    buses = [deepcopy(i1) for i in 1:20]
    a = Automaton(
                    station_quantity=5,
                    buses_as_intineraries=buses)
    run!(a, 1000)
    as = avg_speed(a)
    ds = avg_disembarking(a)
    reset!(a)

    set = TrainingSet(a,
            population_size=100, 
            iterations=1000,
            elitism=10,
            mutation_rate=0.1)
    train!(a, set, gen_limit=20)
    
    run!(a, 1000)

    @test as < avg_speed(a) || ds < avg_disembarking(a)
end