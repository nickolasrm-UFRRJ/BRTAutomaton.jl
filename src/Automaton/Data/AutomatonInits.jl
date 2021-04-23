#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
AutomatonInits.jl (c) 2021
Description: Initializers for the automaton struct
Created:  2021-04-22T07:53:07.405Z
Modified: 2021-04-23T19:25:29.714Z
=#

function asserts(station_quantity::Int,
         buses_as_intineraries::Vector{Intinerary},
         number_of_substations::Int,
         station_spacing::Integer,
         substation_spacing::Integer,
         safe_margin::Integer,
         bus_capacity::Integer,
         station_capacity::Integer,
         boarded_iterations::Integer,
         max_embark::Integer,
         max_desimbark::Integer,
         max_generation::Integer,
         max_speed::Integer)
    @assert station_quantity > 0 "At least one station is required"
    @assert length(buses_as_intineraries) > 0 "At least one bus is required"
    for bus in buses_as_intineraries
        @assert bus[1] == true "Stopping on the first station is mandatory"
    end
    @assert number_of_substations > 0 "A station must have at least one substation"
    @assert station_spacing > 0 "The station spacing must be higher than 0"
    @assert substation_spacing > 0 "The substation spacing must be higher than 0"
    @assert safe_margin >= 0 "Safe distance cannot be negative"
    @assert bus_capacity > 0 "Bus capacity should be higher than 0 and lesser than $(typemax(BusCapacity))"
    @assert station_capacity > 0 "Station capacity should be higher than 0 and lesser than $(typemax(Sleep))"
    @assert boarded_iterations > 0 "The buses need to be on station for at least one iteration"
    @assert max_embark >= 0 "It can't have a negative number of embarking passengers"
    @assert max_desimbark >= 0 "It can't have a negative number of desimbarking passengers"
    @assert max_generation > 0 "Stations needs to produce at least a passenger"
    @assert max_speed > 0 "Max speed cannot be lesser than 1, otherwise, the bus won't move"
end




ids(bus_quantity::Int, station_quantity::Int, number_of_substations::Int) = 
    ids(START_ID:(
        START_ID + bus_quantity + station_quantity +
        station_quantity * number_of_substations + 1 #loopwall
    ))

ids(interval::UnitRange) = 
    Channel{Id}() do x
        for i in interval
            put!(x, Id(i))
        end
    end



#Ids already sorted (beware when parallelizing)
generate(::Type{Bus}, intineraries::Vector{Intinerary}, id::Channel{Id}) =
    [Bus(take!(id), intinerary) for intinerary in intineraries]



    
@inline rand_embark(max_embark::BusCapacity) = rand(one(BusCapacity):max_embark)
@inline rand_desimbark(max_desimbark::BusCapacity) =  rand(one(BusCapacity):max_desimbark)
@inline rand_generation(max_generation::BusCapacity) = rand(one(BusCapacity):max_generation)

Base.length(::Type{Station}, number_of_substations::Int, substation_spacing::Position) =
    number_of_substations * SUBSTATION_LENGTH + (number_of_substations-1) * substation_spacing

#Ids already sorted (beware when paralellizing)
function generate(::Type{Station}, number_of_stations::Int, id::Channel{Id}, 
        station_spacing::Position, number_of_substations::Int, substation_spacing::Position,
        max_embark::BusCapacity, max_desimbark::BusCapacity, max_generation::BusCapacity)
    station_position(i::Int) = Position(FIRST_STATION_POSITION + 
        i * length(Station, number_of_substations, substation_spacing) + 
        i * station_spacing)
        
    [Station(take!(id), Id(i),
        station_position(offseted_i),
        rand_embark(max_embark), rand_desimbark(max_desimbark), 
        rand_generation(max_generation)) for (i, offseted_i) in enumerate(0:offset1(number_of_stations))]
end




#Ids already sorted (beware when paralellizing)
function generate(::Type{AbstractSubstation}, stations::Vector{Station}, id::Channel{Id},
        number_of_substations::Int, substation_spacing::Position)
    heads = Vector{HeadSubstation}(undef, length(stations))
    tails = Vector{Vector{TailSubstation}}(undef, length(stations))
    for (i, station) in enumerate(stations)
        heads[i], tails[i] = generate(AbstractSubstation, station, id,
            number_of_substations, substation_spacing)
    end
    heads, tails
end

function generate(::Type{AbstractSubstation}, parent::Station, id::Channel{Id}, 
        number_of_substations::Int, substation_spacing::Position)
    substation_position(subindex::Int) =
        Position(position(parent) + subindex * substation_spacing + 
                SUBSTATION_LENGTH * subindex)

    head = HeadSubstation(take!(id), parent,
        substation_position(offset1(number_of_substations)))

    next_ref = occupied_ref(head)
    tail = Vector{TailSubstation}(undef, number_of_substations-1)
    for (i, subindex) in enumerate(reverse(1:length(tail)))
        tail[i] = TailSubstation(take!(id), parent, 
                            substation_position(offset1(subindex)), next_ref)
        next_ref = occupied_ref(tail[i])
    end

    head, tail
end




generate(::Type{LoopWall}, id::Channel{Id}) = LoopWall(take!(id))




function mesh(heads::Vector{HeadSubstation}, 
        tails::Vector{Vector{TailSubstation}}, wall::LoopWall,
        station_spacing::Position, 
        number_of_substations::Int, substation_spacing::Position)
    m = fill(Id(EMPTY), mesh_length(length(heads), station_spacing,
                                number_of_substations, substation_spacing))
    initialize!(m, heads, tails, wall)
    m
end

mesh_length(station_quantity::Int, station_spacing::Position, 
        number_of_substations::Int, substation_spacing::Position) =
    station_quantity*station_spacing + 
    station_quantity*length(Station, number_of_substations, substation_spacing) +
    2 #loop wall and station exit margin for buses

function initialize!(mesh::Vector{Id}, heads::Vector{HeadSubstation}, 
        tails::Vector{Vector{TailSubstation}}, wall::LoopWall)
    for head in heads
        write!(mesh, head)
    end
    for tail in tails
        for sub in tail
            write!(mesh, sub)
        end
    end
    mesh[end] = id(wall)
end

@inline write!(mesh::Vector{Id}, sub::AbstractSubstation) =
    mesh[position(sub)] = id(sub)
