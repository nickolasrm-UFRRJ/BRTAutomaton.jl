@testset "Reset" begin
    i1 = Intinerary(true, false)
    i2 = Intinerary(true, true)
    _buses = [i1, i1, i2, i1, i2, i2]
    a = Automaton(station_quantity=2,
                    buses_as_intineraries=_buses)
    a_backup = deepcopy(a)
    run!(a, 10)
    reset!(a)

    function Base.isequal(r1::Ref{T}, r2::Ref{T}) where T 
        isequal(r1[], r2[])
    end

    function deepcompare(obj1, obj2)
        if !isequal(obj1, obj2)
            @info "Different objects\n"*
                "$(obj1)\n\n$(obj2)"
            return false
        else
            return true
        end
    end

    function deepcompare(obj1::AbstractArray, obj2::AbstractArray)
        for (i, (el1, el2)) in enumerate(zip(obj1, obj2))
            if !deepcompare(el1, el2)
                @info "The element $(i) inside of the array is different\n"*
                    "$(el1)\n\n$(el2)"
                return false
            end
        end
        return true
    end

    function deepcompare(obj1::Union{T, Automaton}, obj2::Union{T, Automaton}) where T <: Object
        f = fieldnames(typeof(obj1))
        for fieldname in f
            field1 = getfield(obj1, fieldname)
            field2 = getfield(obj2, fieldname)
            if !deepcompare(field1, field2)
                @info "The field $(fieldname) inside of the object $(typeof(obj1)) is different\n"*
                    "$(field1)\n\n$(field2)"
                return false
            end
        end
        return true
    end

    @test deepcompare(a, a_backup)
end