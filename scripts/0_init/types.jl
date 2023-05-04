# assets_folder = joinpath("src", "assets")

abstract type abt{T} end

struct AB{T} <: abt{T}
    val::T

    # function stuff()
    #     return
    # end
end

struct AC{T} <: abt{T}
end
AC(x) = AC{x}()

a = AB(1)

b = AC(1)

d = AC(1)

b == d



# @info a.val