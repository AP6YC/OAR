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

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

"""
Returns a new [`OAR.GSymbol`](@ref) by adding a suffix.

# Arguments
- `symb::GSymbol{T} where T <: AbstractString`: the original symbol to append a suffix to.
- `num::Integer`: the integer to add as a suffix to the symbol.
- `terminal::Bool=true`: optional (default true), to set the new symbol as terminal.
"""
function join_gsymbol(symb::GSymbol{T}, num::Integer ; terminal::Bool=true) where T <: AbstractString
    return GSymbol{String}(
        symb.data * string(num),
        terminal,
    )
end

"""
Checks if the [`OAR.GSymbol`](@ref) is a terminal grammar symbol.

# Arguments
- `symb::GSymbol`: the [`OAR.GSymbol`](@ref) to check.
"""
function is_terminal(symb::GSymbol)
    # Check the terminal flag attribute of the grammar symbol
    return symb.terminal
end
