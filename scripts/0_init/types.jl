# assets_folder = joinpath("src", "assets")

abstract type AbstractType{T} end

struct FieldedType{T} <: AbstractType{T}
    val::T
end

struct ValueType{T} <: AbstractType{T}
end

ValueType(x) = ValueType{x}()

a = FieldedType(1)
@info a.val

b = ValueType(1)
d = ValueType(1)

@info b == d

# e = ValueType([1,2,3])
# @info e
# struct
# @info a.val

const SubFielded{T} = FieldedType{T}
const AnotherFielded = SubFielded

e = AnotherFielded(1)

const SetFielded{T} = Set{T}

my_set = SetFielded([1,2,3])

another_set = SetFielded()