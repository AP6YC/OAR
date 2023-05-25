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
const GramARTSymbol = GSymbol{String}
# const GramARTTerminal = String

"""
Terminal Distribution definition that is a dictionary mapping from Terminals to probabilities.
"""
const TerminalDist = Dict{GramARTSymbol, Float}
# const TerminalDist = Dict{GramARTTerminal, Float}

"""
The structure of the counter for symbols in a ProtoNode.
"""
# const SymbolCount = Vector{Int}
const SymbolCount = Dict{GramARTSymbol, Int}

mutable struct ProtoNodeStats
    """
    Convenience counter for the total number of symbols encountered.
    """
    m::Int

    """
    If the ProtoNode is terminal on the graph.
    """
    terminal::Bool
end

"""
ProtoNode struct, used to generate tree prototypes, which are the templates of GramART.
"""
struct ProtoNode <: ARTNode
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
    children::Dict{GramARTSymbol, ProtoNode}
    # children::ProtoChildren
    # children::Vector{ProtoNode}

    """
    The mutable options and stats of the ProtoNode.
    """
    stats::ProtoNodeStats
end

"""
Alias for how ProtoNode children are indexed.
"""
const ProtoChildren = Dict{GramARTSymbol, ProtoNode}

"""
Overload of the show function for [`OAR.ProtoNode`](@ref).

# Arguments
- `io::IO`: the current IO stream.
- `node::ProtoNode`: the [`OAR.ProtoNode`](@ref) to print/display.
"""
function Base.show(io::IO, node::ProtoNode)
    print(io, "$(typeof(node))($(length(node.N)))")
end

"""
Tree node for a GramART module.
"""
mutable struct TreeNode <: ARTNode
    """
    The terminal symbol for the node.
    """
    t::GramARTSymbol

    """
    Children nodes of this node.
    """
    children::Vector{TreeNode}
end

"""
"""
struct GramART
    """
    The [`OAR.ProtoNode`](@ref)s of the GramART module.
    """
    protonodes::ProtoNode

    """
    The [`OAR.TreeNode`](@ref)s of the GramART module.
    """
    treenodes::Vector{TreeNode}

    """
    The [`OAR.BNF`](@ref)-form grammar used for processing data (statements).
    """
    grammar::BNF
end

"""
Constructor for a [`OAR.GramART`](@ref) module that takes a BNF grammar and automatically sets up the [`ProtoNode`](@ref) tree.
"""
function GramART(grammar::BNF)
    # Instantiate the GramART module
    gramart = GramART(
        ProtoNode(grammar.T),
        Vector{TreeNode}(),
        grammar,
    )

    # Iterate over the production rules
    for (nonterminal, prod_rule) in grammar.P
        # Add a node for each non-terminal place
        local_node = ProtoNode(grammar.T)
        # Add a node for each terminal
        for terminal in prod_rule
            # push!(local_node.children, ProtoNode(bnf.T))
            local_node.children[terminal] = ProtoNode(grammar.T)
        end
        # Add the ndoe with nodes to the top node
        # push!(gramart.children, local_node)
        gramart.protonodes.children[nonterminal] = local_node
    end

    return gramart
end

# -----------------------------------------------------------------------------
# METHODS
# -----------------------------------------------------------------------------

function ProtoNodeStats()
    ProtoNodeStats(
        0,
        false,
    )
end

"""
Empty constructor for a GramART Protonode.
"""
function ProtoNode()
    # Construct and return the ProtoNode
    ProtoNode(
        TerminalDist(),
        SymbolCount(),
        ProtoChildren(),
        ProtoNodeStats(),
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
    # Return the zero-initialized protonode
    return pn
end

"""
Empty constructor for a GramART TreeNode.

# Arguments
- `name::String`: the string name of the symbol to instantiate the TreeNode with.
"""
function TreeNode(name::String)
    TreeNode(
        GramARTSymbol(name),
        Vector{TreeNode}(),
    )
end

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

"""
Updates the distribution of a single [`OAR.ProtoNode`](@ref) from one new symbol instance.

# Arguments
- `pn::ProtoNode`: the [`OAR.ProtoNode`](@ref) to update the distribution with.
- `symb::GramARTSymbol`: the symbol instance to update the [`OAR.ProtoNode`](@ref) with.
"""
function update_dist!(pn::ProtoNode, symb::GramARTSymbol)
    # Update the counts
    pn.N[symb] += 1
    pn.stats.m += 1
    # Update the distributions
    ratio = 1 / pn.stats.m
    for (key, _) in pn.dist
        # Repeated multiplication is faster than division
        pn.dist[key] = pn.N[key] * ratio
    end
end

"""
Updates the tree of protonodes from a single terminal.

# Arguments
- `pn::ProtoNode`: the top of the protonode tree to update.
- `nonterminal::GramARTSymbol`: the
"""
function inc_update_symbols!(pn::ProtoNode, nonterminal::GramARTSymbol, symb::GramARTSymbol)
    # function inc_update_symbols!(pn::ProtoNode, symb::GSymbol, position::Integer)
    # Update the top node
    update_dist!(pn, symb)
    # Update the middle nodes
    middle_node = pn.children[nonterminal]
    update_dist!(middle_node, symb)
    # Update the corresponding terminal node
    update_dist!(middle_node.children[symb], symb)
end

"""
Processes a statement for a [`OAR.GramART`](@ref) module.

# Arguments
- `gramart::GramART`: the [`OAR.GramART`](@ref) to update with the statement.
- `statement::Statement`: the grammar statement to process.
"""
function process_statement!(gramart::GramART, statement::Statement)
    for ix in eachindex(statement)
        inc_update_symbols!(gramart.protonodes, gramart.grammar.S[ix], statement[ix])
    end
end


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