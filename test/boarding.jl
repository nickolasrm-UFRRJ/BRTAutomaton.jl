@testset "Boarding" begin
    @testset "Stuck" begin
        using BRTAutomaton
        i1 = Intinerary(true, false)
        i2 = Intinerary(true, true)
        _buses = [i1, i1, i2, i1, i2, i2]
        a = Automaton(station_quantity=2,
                        buses_as_intineraries=_buses)
        run!(a, 500)

        for (i, bus) in enumerate(buses(a))
            for j in 1:(i-1)
                if position(bus) == position(buses(a)[j])
                    @test false
                end
            end
            for j in (i+1):length(buses(a))
                if position(bus) == position(buses(a)[j])
                    @test false
                end
            end
        end
        @test true
    end
end