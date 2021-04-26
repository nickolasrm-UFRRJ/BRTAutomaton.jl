@testset "Boarding" begin
    @testset "Stuck" begin
        i1 = Itinerary(true, false)
        i2 = Itinerary(true, true)
        _buses = [i1, i1, i2, i1, i2, i2]
        a = Automaton(station_quantity=2,
                        buses_as_itineraries=_buses)
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