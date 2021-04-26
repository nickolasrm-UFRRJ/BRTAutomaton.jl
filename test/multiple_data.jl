@testset "Multiple data" begin
    @testset "Multiple buses" begin
        i1 = Intinerary(true)
        buses = fill(i1, 5)
        a = Automaton(
                        station_quantity=1,
                        buses_as_intineraries=buses)
        run!(a, 100)
        @test true
    end

    @testset "Multiple stations" begin
        using BRTAutomaton
        i1 = Intinerary(true, true)
        i2 = Intinerary(true, false)
        buses = [i1, i2]
        a = Automaton(
                        station_quantity=2,
                        buses_as_intineraries=buses)
        run!(a, 100)
        @test true
    end
end