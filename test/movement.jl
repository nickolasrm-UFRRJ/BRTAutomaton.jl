@testset "Movement" begin
    _buses = [Itinerary(true)]
    a = Automaton(station_quantity=1,
                    buses_as_itineraries=_buses)

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
        run!(a, 24)
        @test waiting(buses(a)[1])
        run!(a, 500)
        @test true
    end

    @testset "Bus deacceleration" begin
        i = Itinerary(true)
        _buses = [i, i]
        a = Automaton(station_quantity=1,
                        buses_as_itineraries=_buses,
                        station_spacing=100,
                        max_speed=4)
        bs = buses(a)
        run!(a, 20)
        m1, m2 = Automata.meshes!(a)
        objs = objects(a)
        Automata.position!(bs[1], Position(43))
        Automata.position!(bs[2], Position(49))
        Automata.fill!(m1, bs[1])
        Automata.fill!(m1, bs[2])
        Automata.speed!(bs[1], Speed(4))
        Automata.speed!(bs[2], Speed(1))
        Automata.move!(bs[1], m1, m2, objs, Speed(4))
        Automata.move!(bs[2], m1, m2, objs, Speed(4))
        @test position(bs[1]) == 45
        @test speed(bs[1]) == 2
        @test position(bs[2]) == 51
        @test speed(bs[1]) == 2
    end
end
