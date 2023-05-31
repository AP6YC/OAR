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

# -----------------------------------------------------------------------------
# STRUCTS
# -----------------------------------------------------------------------------


"""
The mutable components of a [`ProtoNode`](@ref), containing options and statistics of the node.
"""
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
Definition of a GramART module.

Contains the proto nodes, tree nodes, and grammar that is used.
"""
struct GramART
    """
    The [`OAR.ProtoNode`](@ref)s of the GramART module.
    """
    protonodes::Vector{ProtoNode}

    """
    The [`OAR.TreeNode`](@ref)s of the GramART module.
    """
    treenodes::Vector{TreeNode}

    """
    The [`OAR.CFG`](@ref) (Context-Free Grammar) used for processing data (statements).
    """
    grammar::CFG
end

# -----------------------------------------------------------------------------
# METHODS
# -----------------------------------------------------------------------------

"""
Constructor for a [`OAR.GramART`](@ref) module that takes a CFG grammar and automatically sets up the [`ProtoNode`](@ref) tree.
"""
function GramART(grammar::CFG)
    # Instantiate the GramART module
    gramart = GramART(
        # ProtoNode(grammar.T),
        Vector{ProtoNode}(),
        Vector{TreeNode}(),
        grammar,
    )

    # # Iterate over the production rules
    # for (nonterminal, prod_rule) in grammar.P
    #     # Add a node for each non-terminal place
    #     local_node = ProtoNode(grammar.T)
    #     # Add a node for each terminal
    #     for terminal in prod_rule
    #         local_node.children[terminal] = ProtoNode(grammar.T)
    #     end
    #     # Add the node with nodes to the top node
    #     gramart.protonodes.children[nonterminal] = local_node
    # end

    # Return the initialized GramART module
    return gramart
end

"""
Empty constructor for the mutable options and stats component of a ProtoNode.
"""
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
        TerminalDist(),     # dict
        SymbolCount(),      # N
        ProtoChildren(),    # children
        ProtoNodeStats(),   # stats
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
        GramARTSymbol(name),    # t
        Vector{TreeNode}(),     # children
    )
end

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

"""
Adds a recursively-generated [`OAR.ProtoNode`](@ref) to the [`OAR.GramART`](@ref) module.

# Arguments
- `gramart::GramART`: the [`OAR.GramART`](@ref) to append a new node to.
"""
function add_node!(gramart::GramART)
    # Create the top node
    top_node = ProtoNode(grammar.T)
    # Iterate over the production rules
    for (nonterminal, prod_rule) in grammar.P
        # Add a node for each non-terminal place
        local_node = ProtoNode(grammar.T)
        # Add a node for each terminal
        for terminal in prod_rule
            local_node.children[terminal] = ProtoNode(grammar.T)
        end
        # Add the node with nodes to the top node
        top_node.children[nonterminal] = local_node
    end
    # Append the recursively constructed proto node
    push!(gramart.protonodes, top_node)
end

# """

# """
# function statement_to_tree(statement::Statement)

# end

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
- `nonterminal::GramARTSymbol`: the nonterminal symbol of the statement to update at.
- `symb::GramARTSymbol`: the terminal symbol to update everywhere.
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

    # Explicity empty return
    return
end

"""
Processes a statement for a [`OAR.GramART`](@ref) module.

# Arguments
- `gramart::GramART`: the [`OAR.GramART`](@ref) to update with the statement.
- `statement::Statement`: the grammar statement to process.
"""
function process_statement!(gramart::GramART, statement::Statement, index::Int)
    for ix in eachindex(statement)
        inc_update_symbols!(gramart.protonodes[index], gramart.grammar.S[ix], statement[ix])
    end
end

"""
Processes a statement for a [`OAR.GramART`](@ref) module.

# Arguments
- `gramart::GramART`: the [`OAR.GramART`](@ref) to update with the statement.
- `statement::Statement`: the grammar statement to process.
"""
function train!(gramart::GramART, statement::Statement)
    # If this is the first sample, then fast commit
    if isempty(gramart.protonodes)
        add_node!(gramart)
        process_statement!(gramart, statement, 1)
    end
    # for ix in eachindex(statement)
    #     inc_update_symbols!(gramart.protonodes, gramart.grammar.S[ix], statement[ix])
    # end
end


"""
"""
function trace!(A::TreeNode, B::ProtoNode, sum::RealFP, size::Integer)
# function trace!(A::TreeNode, B::ProtoNode)
    sum += B.dist[A.t]
    @warn "UNIMPLEMENTED"
    return
end

"""
"""
function new_weight(dist::TerminalDist, N::SymbolCount)
    @warn "UNIMPLEMENTED"
    return
end

"""
"""
function update_node!(A::TreeNode, B::ProtoNode)
    @warn "UNIMPLEMENTED"
    return
end

# IRIS CFG grammar, Meuth dissertation p.48, Table 4.6
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
