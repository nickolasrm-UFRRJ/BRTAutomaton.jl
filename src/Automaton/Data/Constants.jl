#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Constants.jl (c) 2021
Description: Contains all constants used by the automaton
Created:  2021-03-21T15:19:19.485Z
Modified: 2021-04-22T11:47:12.184Z
=#

#Typedefs
const Id = UInt16
const StationIndex = UInt16
const Speed = UInt8
const Position = UInt16
const BusCapacity = UInt8
const StationCapacity = UInt16
const Sleep = UInt8

#Automaton environment
const NUMBER_OF_SUBSTATIONS = 3
const STATION_SPACING = Position(80)
const SUBSTATION_SPACING = Position(3)
const SAFE_DISTANCE = Position(2)

const BUS_CAPACITY = BusCapacity(120)
const STATION_CAPACITY = StationCapacity(600)

const BOARDED_TICK = Sleep(2)
const STATION_TICK = Sleep(2)

const MAX_EMBARK_RATE = BusCapacity(BUS_CAPACITY / 8)
const MAX_DESIMBARK_RATE = BusCapacity(BUS_CAPACITY)
const MAX_SPEED = Speed(4)

const BUS_LENGTH = Position(4)
const SUBSTATION_LENGTH = Position(BUS_LENGTH + 1)
const STATION_LENGTH = Position(NUMBER_OF_SUBSTATIONS*SUBSTATION_LENGTH +
                                (NUMBER_OF_SUBSTATIONS-1)*SUBSTATION_SPACING)

const SAFE_LOOKING_DISTANCE = SAFE_DISTANCE + BUS_LENGTH

#Offsetted Lenghts
const OFFSET1_BUS_LENGTH = offset1(BUS_LENGTH)
const OFFSET1_SUBSTATION_LENGTH = offset1(SUBSTATION_LENGTH)
const OFFSET1_STATION_LENGTH = offset1(STATION_LENGTH)

#Automaton sensitive data
const SUBSTATION_TAIL_LENGTH = NUMBER_OF_SUBSTATIONS - 1
const MESH_PADDING = max(BUS_LENGTH, SUBSTATION_LENGTH, STATION_LENGTH)
const VOID_POSITION = zero(Position)
const EMPTY = zero(Id)
const START_ID = one(Id)

#Auxiliar functions
offset1(val::Integer) = val - one(typeof(val))
