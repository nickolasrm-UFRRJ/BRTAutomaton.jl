#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Constants.jl (c) 2021
Description: Contains all constants used by the automaton
Created:  2021-03-21T15:19:19.485Z
Modified: 2021-04-25T04:45:00.945Z
=#

#Auxiliar functions
offset1(val::Integer) = val - one(typeof(val))

#Typedefs
const Id = UInt16
const StationIndex = UInt16
const Speed = UInt8
const Position = UInt16
const BusCapacity = UInt8
const StationCapacity = UInt16
const Sleep = UInt8
const Stat = Int64

#Automaton environment
const BUS_LENGTH = Position(4)
const SUBSTATION_LENGTH = Position(BUS_LENGTH + 1)

#Automaton sensitive data
const VOID_POSITION = zero(Position)
const BUS_STARTING_POSITION = BUS_LENGTH
const EMPTY = zero(Id)
const START_ID = one(Id)
const FIRST_STATION_POSITION = Position(1)

#Offsetted Data
const OFFSET1_BUS_LENGTH = offset1(BUS_LENGTH)
const OFFSET1_SUBSTATION_LENGTH = offset1(SUBSTATION_LENGTH)
const OFFSET1_BUS_STARTING_POSITION = offset1(BUS_STARTING_POSITION)

#Flags
FLAG_JUST_BOARDED = typemax(Sleep)