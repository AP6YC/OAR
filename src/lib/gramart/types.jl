"""
    types.jl

# Description
The structs and constructors of GramART.
"""

# -----------------------------------------------------------------------------
# STRUCTS
# -----------------------------------------------------------------------------

"""
The mutable components of a [`OAR.ProtoNode`](@ref), containing options and statistics of the node.
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
ProtoNode struct, used to generate tree prototypes, which are the templates of [`OAR.GramART`](@ref).
"""
struct ProtoNode <: ARTNode
    """
    The [`TerminalDist`](@ref) distribution over all symbols at this node.
    """
    dist::TerminalDist

    """
    The [`SymbolCount`](@ref) update counters for each symbol.
    """
    N::SymbolCount

    """
    The children of this node (`Dict{`[`GramARTSymbol`](@ref)`, ProtoNode}`).
    """
    children::Dict{GramARTSymbol, ProtoNode}

    """
    The mutable [`ProtoNodeStats`](@ref) options and stats of the ProtoNode.
    """
    stats::ProtoNodeStats
end

"""
Alias for how ProtoNode children are indexed (`ProtoChildren = Dict{`[`GramARTSymbol`](@ref)`, `[`ProtoNode`](@ref)`}`).
"""
const ProtoChildren = Dict{GramARTSymbol, ProtoNode}

"""
Tree node for a [`GramART`](@ref) module.
"""
struct TreeNode <: ARTNode
    """
    The [`GramARTSymbol`](@ref) symbol for the node.
    """
    t::GramARTSymbol

    """
    Children nodes of this node.
    """
    children::Vector{TreeNode}
end

"""
[`GramART`](@ref) options struct as a `Parameters.jl` `@with_kw` object.
"""
@with_kw mutable struct opts_GramART @deftype Float
    """
    Vigilance parameter: ρ ∈ [0, 1]
    """
    rho = 0.7; @assert rho >= 0.0 && rho <= 1.0

    """
    Flag for generating nodes at the terminal distributions below their nonterminal positions.
    """
    terminated::Bool = false
end

"""
Definition of a GramART module.

Contains the [`ProtoNode`](@ref)s and [`CFG`](@ref) grammar that is used for processing statements and generating nodes.
"""
struct GramART
    """
    The [`OAR.ProtoNode`](@ref)s of the GramART module.
    """
    protonodes::Vector{ProtoNode}

    """
    The [`OAR.CFG`](@ref) (Context-Free Grammar) used for processing data (statements).
    """
    grammar::CFG

    """
    The [`OAR.opts_GramART`](@ref) hyperparameters of the GramART module.
    """
    opts::opts_GramART
end

# -----------------------------------------------------------------------------
# DEPENDENT ALIASES
# -----------------------------------------------------------------------------

"""
A `TreeStatement` is simply a [`TreeNode`](@ref).
"""
const TreeStatement = TreeNode

"""
Many `TreeStatements` are a Vector of [`TreeNode`](@ref)s.
"""
const TreeStatements = Vector{TreeStatement}

"""
Alias for arguments in simulations accepting multiple definitions of statement formulations.
"""
const SomeStatements = Union{TreeStatements, Statements}

# -----------------------------------------------------------------------------
# CONSTRUCTORS
# -----------------------------------------------------------------------------

"""
Constructor for an [`OAR.GramART`](@ref) module that takes a [`CFG`](@ref) grammar and automatically sets up the [`ProtoNode`](@ref) tree.

# Arguments
$ARG_CFG
- `opts::opts_GramART`: a custom set of [`OAR.GramART`](@ref) options to use.
"""
function GramART(grammar::CFG, opts::opts_GramART)
    # Instantiate and return the GramART module
    GramART(
        Vector{ProtoNode}(),    # protonodes
        grammar,                # grammar
        opts,                   # opts
    )
end

"""
Constructor for an [`OAR.GramART`](@ref) module that takes a [`OAR.CFG`](@ref) grammar and an optional list of keyword arguments for the options.

# Arguments
$ARG_CFG
- `kwargs...`: a list of keyword arguments for the [`OAR.opts_GramART`](@ref) options struct.
"""
function GramART(grammar::CFG; kwargs...)
    # Construct the GramART options from the keyword arguments
    opts = opts_GramART(;kwargs...)

    # Construct and return the GramART module
    GramART(
        grammar,
        opts,
    )
end

"""
Empty constructor for the mutable options and stats component of a [`OAR.ProtoNode`](@ref).
"""
function ProtoNodeStats()
    # Construct and return the protonode statistics struct
    ProtoNodeStats(
        0,
        false,
    )
end

"""
Empty constructor for a [`OAR.GramART`](@ref) [`OAR.Protonode`](@ref).
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
Constructor for a zero-initialized [`OAR.GramART`](@ref) [`OAR.ProtoNode`](@ref).

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
Constructor for a [`OAR.GramART`](@ref) [`OAR.TreeNode`](@ref) taking an existing [`OAR.GramARTSymbol`](@ref).

# Arguments
- `symb::GramARTSymbol`: the preconstructed GramARTSymbol used for constructing the [`OAR.TreeNode`](@ref).
"""
function TreeNode(symb::GramARTSymbol)
    TreeNode(
        symb,                   # t
        Vector{TreeNode}(),     # children
    )
end

"""
Constructor for a [`OAR.GramART`](@ref) [`OAR.TreeNode`](@ref), taking a string name of the symbol and if it is terminal or not.

# Arguments
- `name::AbstractString`: the string name of the symbol to instantiate the [`OAR.TreeNode`](@ref) with.
- `is_terminal::Bool`: flag for if the symbol in the node is terminal or not.
"""
function TreeNode(name::AbstractString, is_terminal::Bool=true)
    # Construct and return the tree node
    TreeNode(
        GramARTSymbol(
            name,
            is_terminal,
        ),
    )
end

# -----------------------------------------------------------------------------
# SHOW OVERLOADS
# -----------------------------------------------------------------------------

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
Prints a tree string for displaying children of a [`OAR.TreeNode`](@ref), used in the `Base.show` overload.

# Arguments
- `io::IO`: the current IO stream.
- `node::TreeNode`: the [`OAR.TreeNode`](@ref) with children to display
"""
function print_treenode_children(io::IO, node::TreeNode, level::Integer, last::Bool)
    # Get the number of children to display
    n_children = length(node.children)
    # Get the level spacing
    # spacer = last ? "    " : "│   "^level
    spacer = last ? "    " : " │  "^level
    # Append to the printstring for each child
    term = "\n"
    for ix = 1:n_children
        is_last = (ix == n_children)
        local_symb = "\"$(node.children[ix].t.data)\""
        # sep = (is_last ? "└───" : "├───")
        sep = (is_last ? " └──" : " ├──")
        print(io, spacer * sep * local_symb * term)
        # If the node also has children, recursively call this function one level lower
        if !isempty(node.children[ix].children)
            print_treenode_children(io, node.children[ix], level + 1, is_last)
        end
    end
    # Explicitly empty return
    return
end

"""
Overload of the show function for [`OAR.TreeNode`](@ref).

# Arguments
- `io::IO`: the current IO stream.
- `node::TreeNode`: the [`OAR.TreeNode`](@ref) to print/display.
"""
function Base.show(io::IO, node::TreeNode)
    # Set the top of the printstring
    printstring = "$(typeof(node))(\"$(node.t.data)\")"
    print(io, printstring)

    # If the node has children, then display each child
    if !isempty(node.children)
        # Add a newline and the child printstring
        print(io, "\n")
        print_treenode_children(io, node, 0, false)
    end
end
