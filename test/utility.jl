@testset "Utility" begin
    i1 = Itinerary(true, false)
    i2 = Itinerary(true, true)
    _buses = [i1, i1, i2, i1, i2, i2]
    a = Automaton(station_quantity=2,
                    buses_as_itineraries=_buses)
    run!(a, 100)
    save(a)
    @test isfile(joinpath(pwd(), Utility.AUTOMATON_FILENAME))
    b = load(Automaton)
    @test a.buses[1].position == a.buses[1].position
    rm(joinpath(pwd(), Utility.AUTOMATON_FILENAME))

    set = TrainingSet(a,
            population_size=2, 
            elitism=1,
            mutation_rate=0.1)
    save(set)
    @test isfile(joinpath(pwd(), Utility.TRAININGSET_FILENAME))
    b = load(TrainingSet)
    @test elitism(b) == elitism(set)
    rm(joinpath(pwd(), Utility.TRAININGSET_FILENAME))

    run_multiple!(100, a, deepcopy(a))
    @test a.buses[1].position == a.buses[1].position
end