using
    AdaptiveResonance,
    DrWatson,
    NumericalTypeAliases

# -----------------------------------------------------------------------------
# CUSTOM DRWATSON DIRECTORY DEFINITIONS
# -----------------------------------------------------------------------------

work_dir(args...) = projectdir("work", args...)

# results_dir(args...) = projectdir("work", "results", experiment_top, args...)

# -----------------------------------------------------------------------------
# STRUCTS
# -----------------------------------------------------------------------------

abstract type ARTNode end

"""
ProtoNode struct, used to generate tree prototypes, which are the templates of GramART.
"""
mutable struct ProtoNode <: ARTNode
    """
    The distribution over all symbols at this node.
    """
    dist::Vector{Float}

    """
    The update counters for each symbol.
    """
    N::Vector{Int}

    """
    The children on this node.
    """
    children::Vector{ProtoNode}
end

mutable struct TreeNode <: ARTNode
    t::String
    children::Vector{TreeNode}
end

# -----------------------------------------------------------------------------
# METHODS
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

greet() = print("Hello World!")

function Trace(A::TreeNode, B::ProtoNode, sum::RealFP, size::Integer)
    return
end

function UpdateNode(A::TreeNode, B::ProtoNode)
    return
end

# IRIS BNF grammar, Meuth dissertation p.48, Table 4.6
# N = {SL, SW, PL, PW}
# T = {SL1, SL2, SL3, SL4, SL5, SL6, SL7, SL8, SL9, SL10,
# SW1, SW2, SW3, SW4, SW5, SW6, SW7, SW8, SW9, SW10,
# PL1, PL2, PL3, PL4, PL5, PL6, PL7, PL8, PL9, PL10,
# PW1, PW2, PW3, PW4, PW5, PW6, PW7, PW8, PW9, PW10,}
# S = <SL> <SW> <PL> <PW>
# P can be represented as:
# 1. <SL> ::=
# {SL1 | SL2 | SL3 | SL4 | SL5 |
# SL6 | SL7 | SL8 | SL9 | SL10}
# 2. <SW> ::=
# {SW1 | SW2 | SW3 | SW4 | SW5 |
# SW6 | SW7 | SW8 | SW9 | SW10}
# 3. <PL> ::=
# {PL1 | PL2 | PL3 | PL4 | PL5 |
# PL6 | PL7 | PL8 | PL9 | PL10}
# 4. <PW> ::=
# {PW1 | PW2 | PW3 | PW4 | PW5 |
# PW6 | PW7 | PW8 | PW9 | PW10}