"""
    GramART.jl

# Description
This file implements the structs, methods, and functions for GramART's functionality.

# Attribution

## Authors
- Sasha Petrenko <sap625@mst.edu>

## Citations
- Meuth, Ryan J., "Adaptive multi-vehicle mission planning for search area coverage" (2007). Masters Theses. 44. https://scholarsmine.mst.edu/masters_theses/44
"""

# -----------------------------------------------------------------------------
# STRUCTS
# -----------------------------------------------------------------------------

abstract type ARTNode end

"""
Definition of Terminal symbols used throughtout GramART.
"""
const GramARTTerminal = GSymbol{String}
# const GramARTTerminal = String

"""
Terminal Distribution definition that is a dictionary mapping from Terminals to probabilities.
"""
const TerminalDist = Dict{GramARTTerminal, Float}
# const TerminalDist = Dict{GramARTTerminal, Float}

"""
The structure of the counter for symbols in a ProtoNode.
"""
# const SymbolCount = Vector{Int}
const SymbolCount = Dict{GramARTTerminal, Int}

"""
ProtoNode struct, used to generate tree prototypes, which are the templates of GramART.
"""
mutable struct ProtoNode <: ARTNode
    """
    The distribution over all symbols at this node.
    """
    dist::TerminalDist
    # dist::Vector{Float}

    """
    The update counters for each symbol.
    """
    N::SymbolCount

    """
    The children on this node.
    """
    children::Vector{ProtoNode}
end

"""
Empty constructor for a GramART Protonode.
"""
function ProtoNode()
    ProtoNode(
        TerminalDist(),
        SymbolCount(),
        Vector{ProtoNode}(),
    )
end

"""
Constructor for a zero-initialized Gramart ProtoNode.

# Arguments
- `symbols::SymbolSet`: the terminal symbols to initialize the node with.
"""
function ProtoNode(symbols::SymbolSet)
    # Initialize an empty ProtoNode
    pn = ProtoNode()
    # Init counts and distributions for all terminal symbols
    for terminal in symbols
        pn.N[terminal] = 0
        pn.dist[terminal] = 0.0
    end
    return pn
end

"""
Overload of the show function for [`OAR.ProtoNode`](@ref).

# Arguments
- `io::IO`: the current IO stream.
- `node::ProtoNode`: the [`OAR.ProtoNode`](@ref) to print/display.
"""
function Base.show(io::IO, node::ProtoNode)
    # print(io, node)
    return
    # dim = length(data.train_x[1])
    # n_train = length(data.train_y)
    # n_test = length(data.test_y)
    # print(io, "$(typeof(data)): dim=$(dim), n_train=$(n_train), n_test=$(n_test):\n")
    # # print(io, "$(typeof(data)) with $(dim) features, $(n_train) training samples, and $(n_test) testing samples:\n")
    # print(io, "train_x: $(size(data.train_x)) $(typeof(data.train_x))\n")
    # print(io, "test_x: $(size(data.test_x)) $(typeof(data.test_x))\n")
    # print(io, "train_y: $(size(data.train_y)) $(typeof(data.train_y))\n")
    # print(io, "test_y: $(size(data.test_y)) $(typeof(data.test_y))\n")
end

"""
Tree node for a GramART module.
"""
mutable struct TreeNode <: ARTNode
    """
    The terminal symbol for the node.
    """
    t::GramARTTerminal
    # t::String

    """
    Children nodes of this node.
    """
    children::Vector{TreeNode}
end

"""
Empty constructor for a GramART TreeNode.
"""
function TreeNode(name::String)
    TreeNode(
        GramARTTerminal(name),
        Vector{TreeNode}(),
    )
end

# -----------------------------------------------------------------------------
# METHODS
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

function trace!(A::TreeNode, B::ProtoNode, sum::RealFP, size::Integer)
# function trace!(A::TreeNode, B::ProtoNode)
    sum += B.dist[A.t]
    return
end

function new_weight(dist::TerminalDist, N::SymbolCount)
    return
end

function update_node!(A::TreeNode, B::ProtoNode)
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