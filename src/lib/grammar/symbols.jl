"""
    symbols.jl

# Description
This file describes the structure of grammar symbols.
"""

# -----------------------------------------------------------------------------
# STRUCTS
# -----------------------------------------------------------------------------

"""
Definition of a grammar symbol with arbitrary datatype and a boolean flag for if the symbol is terminal or not.
"""
struct GSymbol{T}
    """
    The grammar symbol of type T.
    """
    data::T

    """
    Boolean flag if the symbol is terminal (true) or nonterminal (false).
    """
    terminal::Bool
end

# -----------------------------------------------------------------------------
# METHODS
# -----------------------------------------------------------------------------

"""
Common argument docstring for GSymbol consruction.
"""
const GSYMBOL_DATA_ARG = """
# Arguments
- `data::T where T <: Any`: the piece of data comprising the grammar symbol of any type.
"""

"""
Constructor for a grammar symbol from just the provided data (defaults to being terminal).

$GSYMBOL_DATA_ARG
"""
function GSymbol{T}(data::T) where T <: Any
    GSymbol{T}(
        data,
        true,
    )
end

"""
Convenience constructor for a terminal grammar symbol.

$GSYMBOL_DATA_ARG
"""
function Terminal(data::T) where T <: Any
    return GSymbol{T}(
        data,
        true,
    )
end

"""
Convenience consructor for a nonterminal grammar symbol.

$GSYMBOL_DATA_ARG
"""
function NonTerminal(data::T) where T <: Any
    return GSymbol{T}(
        data,
        false,
    )
end
