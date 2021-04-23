@testset "Structure" begin
    _buses = [Intinerary(true, true), Intinerary(true, true)]
    a = Automaton(station_quantity=2, buses_as_intineraries=_buses)
    @test sum([id(obj) == i 
        for (i,obj) in enumerate(objects(a))]) == length(objects(a))
end