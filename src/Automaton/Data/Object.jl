#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
AbstractTypes.jl (c) 2021
Description: Abstract types for this module
Created:  2021-03-31T03:17:15.913Z
Modified: 2021-04-22T10:59:57.300Z
=#

abstract type Object end

id(obj::Object) = obj.id