"""
    new-grammar.jl

# Description
This file tinkers with using parametric abstract types for the symbol hierarchy
"""

module grm

abstract type GSymbol{T} end

    struct Terminal{T} <: GSymbol{T}
        data::T
    end

    struct NonTerminal{T} <: GSymbol{T}
        data::T
    end

    const SymbUnion{T} = Union{Terminal{T}, NonTerminal{T}}

end

@info grm.GSymbol{String} <: grm.GSymbol
a = grm.Terminal("asdf")
b = grm.NonTerminal("bbb")
@info a b
c = Vector{grm.SymbUnion{String}}()
push!(c, a)
push!(c, b)
@info c
@info a isa grm.Terminal
@info a isa grm.NonTerminal
