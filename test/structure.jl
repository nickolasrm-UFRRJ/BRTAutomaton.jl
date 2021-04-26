@testset "Structure" begin
    _buses = [Itinerary(true, true), Itinerary(true, true)]
    a = Automaton(station_quantity=2, buses_as_itineraries=_buses)
    @test sum([id(obj) == i 
        for (i,obj) in enumerate(objects(a))]) == length(objects(a))
end