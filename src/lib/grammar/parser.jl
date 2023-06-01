"""
    parser.jl

# Description
This file implements parsers for statements.
"""

function hello_world()
    println("parser.jl hello world")
end

# module Parser

    # abstract type GSymbol{T} end

    # struct Terminal{T} <: GSymbol{T}
    #     data::T
    # end

    # struct NonTerminal{T} <: GSymbol{T}
    #     data::T
    # end

    # struct MonoRule
    #     data::
    # end

    # const ProductionSequence = Vector{MonoRule}

    # production_types = [
    #     :
    # ]

    # struct ProductionNonTerminal{T}
    #     symb::NonTerminal{T}
    #     type::Symbol
    # end

    # const ProductionRule =
    # const ProductionSequence = Vector{}

    # # struct ProductionSymbol{T}
    # #     data::Set{NonTerminal}
    # # end

    # const SymbUnion{T} = Union{Terminal{T}, NonTerminal{T}}
    # const TerminalSet{T} = Set{Terminal{T}}
    # const NonTerminalSet{T} = Set{NonTerminal{T}}

    # struct ExtendedCFG{T} <: Grammar
    #     T::Dict{NonTerminal{T}, TerminalSet{T}}
    #     N::Set{NonTerminal{T}}
    #     P::Dict{NonTerminal{T}, NonTerminal{T}}
    # end
# end


