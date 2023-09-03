"""
    constants.jl

# Description
The constants and type aliases of START.
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
Definition of symbols used throughtout [`START`](@ref).
"""
const STARTSymbol = GSymbol{String}
# const STARTTerminal = String

"""
Definition of one statement used throughout [`START`](@ref).
"""
const STARTStatement = Statement{String}

"""
Definition of statements used throughout [`START`](@ref).
"""
const STARTStatements = Statements{String}

"""
Terminal Distribution definition that is a dictionary mapping from terminal symbols to probabilities (`TerminalDist = Dict{`[`STARTSymbol`](@ref)`, Float}`).
"""
const TerminalDist = Dict{STARTSymbol, Float}
# const TerminalDist = Dict{STARTTerminal, Float}

"""
The structure of the counter for symbols in a ProtoNode (`SymbolCount = Dict{`[`STARTSymbol`](@ref)`, Int}`).
"""
const SymbolCount = Dict{STARTSymbol, Int}
# const SymbolCount = Vector{Int}
