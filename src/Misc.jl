#=
Author: Nickolas da Rocha Machado 
Emails: nickolas123full@gmail.com
Misc.jl (c) 2021
Description: Auxiliar functions set
Created:  2021-04-15T02:56:32.934Z
Modified: 2021-04-15T03:06:45.520Z
=#

function slice(arr::AbstractArray, interval::UnitRange)
    unsafe_wrap(typeof(arr), 
                pointer(arr) + (interval.start - 1) * sizeof(eltype(arr)),
                interval.stop - interval.start + 1,
                own = false
    )
end

function slice_getindex()
    
end

function slice_setindex()
    
end