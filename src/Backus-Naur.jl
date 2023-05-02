"""
    Backus-Naur.jl

# Description
This file implements the parsing and generation of statements with the Backus-Naur form.
"""

"""
Abstract type for formal grammars.
"""
abstract type Grammar end

"""
A grammar symbol is a String.
"""
const GSymbol = String

"""
A set of GSymbols.
"""
const GSymbolSet = Set{GSymbol}

"""
A production rule is a set of vectors of symbols.
"""
const ProductionRule = Dict{Vector{GSymbol}}
# const ProductionRule = Dict{GSymbol, GSymbolSet}

"""
A production rule set is simply a set of production rules.
"""
const ProductionRuleSet = Set{ProductionRule}

"""
Backus-Naur form grammar.

Consists of a set of terminal symbols, non-terminal symbols, and production rules.
"""
struct BNF <: Grammar
    """
    Non-terminal symbols of the grammar.
    """
    N::GSymbolSet

    """
    Terminal symbols of the grammar.
    """
    T::GSymbolSet

    """
    The set of production rules of the grammar.
    """
    P::Set{ProductionRule}
end

# function incremented_gsymbol(bin::Integer)

# end

function DescretizedBNF(data::RealMatrix, N::Vector{GSymbol} ; bins::Integer=10)
    # Initialize the terminal symbol set
    T = GSymbolSet()
    # Initialize the production rule set
    P = ProductionRuleSet()
    # Iterate over each non-terminal symbol
    for symb in N
        # Iterate over the number of discretized bins that we want
        for ix = 1:bins
            # Create a binned symbol
            new_gsymbol = symb + string(ix)
            # Push a binned symbol to the terminals
            push!(T, new_gsymbol)
        end
    end
end