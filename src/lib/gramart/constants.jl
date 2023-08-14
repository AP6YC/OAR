"""
    constants.jl

# Description
The constants and type aliases of GramART.
"""

# -----------------------------------------------------------------------------
# ABSTRACT TYPES
# -----------------------------------------------------------------------------

"""
Definition of the ARTNode supertype.
"""
abstract type ARTNode end

# -----------------------------------------------------------------------------
# ALIASES
# -----------------------------------------------------------------------------

"""
Definition of symbols used throughtout [`GramART`](@ref).
"""
const GramARTSymbol = GSymbol{String}
# const GramARTTerminal = String

"""
Definition of one statement used throughout [`GramART`](@ref).
"""
const GramARTStatement = Statement{String}

"""
Definition of statements used throughout [`GramART`](@ref).
"""
const GramARTStatements = Statements{String}

"""
Terminal Distribution definition that is a dictionary mapping from terminal symbols to probabilities (`TerminalDist = Dict{`[`GramARTSymbol`](@ref)`, Float}`).
"""
const TerminalDist = Dict{GramARTSymbol, Float}
# const TerminalDist = Dict{GramARTTerminal, Float}

"""
The structure of the counter for symbols in a ProtoNode (`SymbolCount = Dict{`[`GramARTSymbol`](@ref)`, Int}`).
"""
const SymbolCount = Dict{GramARTSymbol, Int}
# const SymbolCount = Vector{Int}
