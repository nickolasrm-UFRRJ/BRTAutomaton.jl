@testset "Movement" begin
    station = BRTAutomaton.Station(UInt16(0), UInt8(3))
    intinerary = BRTAutomaton.Intinerary([station])
    bus = BRTAutomaton.Bus(1, 1, 2, Ref(false), intinerary)
    mesh_i, mesh_i1 = MVector(fill(BRTAutomaton.EMPTY, 10)...), 
                      MVector(fill(BRTAutomaton.EMPTY, 10)...)
                      
    mesh_i[1] = BRTAutomaton.id(bus)
    BRTAutomaton.move!(bus, mesh_i, mesh_i1)

    @test BRTAutomaton.position(bus) == UInt16(4)
    @test mesh_i1[BRTAutomaton.position(bus)] == BRTAutomaton.id(bus)

    mesh_i[7] = BRTAutomaton.id(bus)
    BRTAutomaton.move!(bus, mesh_i, mesh_i1)
    @test BRTAutomaton.position(bus) == UInt16(6)
end
