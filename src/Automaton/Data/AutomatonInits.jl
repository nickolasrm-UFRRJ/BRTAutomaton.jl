#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
AutomatonInits.jl (c) 2021
Description: Initializers for the automaton struct
Created:  2021-04-22T07:53:07.405Z
Modified: 2021-04-22T11:34:10.473Z
=#

ids(bus_quantity::Int, station_quantity::Int) =
    Channel{Id}() do x 
        stop = START_ID + bus_quantity + station_quantity + 
                station_quantity * SUBSTATION_TAIL_LENGTH
        for i in START_ID:stop
            put!(x, Id(i))
        end
    end




generate(::Type{Intinerary}, intineraries::Array{Intinerary, 1}) =    
    SVector(intineraries...)




#Ids already sorted (beware when parallelizing)
generate(::Type{Bus}, intineraries::SVector{N, Intinerary}, id::Channel{Id}) where N =
    SVector((Bus(take!(id), intinerary) for intinerary in intineraries)...)



    
@inline rand_embark() = rand(BusCapacity, 1:MAX_EMBARK_RATE)
@inline rand_desimbark() =  rand(BusCapacity, 1:MAX_DESIMBARK_RATE)
#Ids already sorted (beware when paralellizing)
function generate(::Type{Station}, number_of_stations::Int, id::Channel{Id})
    station_position(i::Int) = 1 + i * STATION_SPACING + i * STATION_LENGTH
        
    SVector((
            Station(take!(id), 
                station_position(offset1(i)),
                rand_embark(), rand_desimbark()) for i in 1:number_of_stations
        )...)
end




#Ids already sorted (beware when paralellizing)
generate(::Type{Substation}, stations::SVector{N, Station}, id::Channel{Id}) where N =
    heads, tails .= generate(Substation, stations, id)

function generate(::Type{Substation}, station::Station, id::Channel{Id})
    substation_position(station::Station, subindex::Int) =
        Position(position(station) + subindex * SUBSTATION_SPACING)

    head = HeadSubstation(take!(id), parent,
        substation_position(parent, offset1(NUMBER_OF_SUBSTATIONS)))

    next_ref = occupied_ref(head)
    tail = MVector{SUBSTATION_TAIL_LENGTH, Substation}(undef)
    for i in 1:length(tail)
        tail[i] = TailSubstation(take!(id), parent, 
                            substation_position(parent, offset1(i)), next_ref)
        next_ref = occupied_ref(tail[i])
    end

    head, tail
end



alloc_mesh(mesh_length) = 
    (m = MVector{mesh_length, Object}(undef); p = Pointer(m); m, p)