@testset "Utility" begin
    i1 = Itinerary(true, false)
    i2 = Itinerary(true, true)
    _buses = [i1, i1, i2, i1, i2, i2]
    a = Automaton(station_quantity=2,
                    buses_as_itineraries=_buses)
    run!(a, 100)
    save(a)
    @test isfile(joinpath(pwd(), "automaton.jld2"))
    b = load()
    @test a.buses[1].position == a.buses[1].position
    rm(joinpath(pwd(), "automaton.jld2"))

    run_multiple!(100, a, b)
    @test a.buses[1].position == a.buses[1].position
end