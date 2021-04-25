@testset "Movement" begin
    using BRTAutomaton
    _buses = [Intinerary(true)]
    a = Automaton(station_quantity=1,
                    buses_as_intineraries=_buses)

    @testset "Basic Movement" begin
        run!(a, 2)
        @test position(buses(a)[1]) == Position(7)
        run!(a, 1)
        @test position(buses(a)[1]) == Position(10)
        run!(a, 1)
        @test speed(buses(a)[1]) == Speed(4)
        @test position(buses(a)[1]) == Position(14)
    end

    @testset "Cyclic" begin
        run!(a, 25)
        @test waiting(buses(a)[1])
        run!(a, 500)
        @test true
    end
end
