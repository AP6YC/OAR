"""
    types.jl

# Description
The structs and constructors of START.
"""

# -----------------------------------------------------------------------------
# ABSTRACT TYPES
# -----------------------------------------------------------------------------

"""
Abstract type for all START-type modules.
"""
abstract type AbstractSTART end

"""
Abstract type for all START-type modules.
"""
abstract type SingleSTART end

"""
Abstract type for all START-type modules.
"""
abstract type DistributedSTART end

"""
Definition of the ARTNode supertype.
"""
abstract type ARTNode end

# -----------------------------------------------------------------------------
# ALIASES
# -----------------------------------------------------------------------------

"""
Type alias for the [`OAR.START`](@ref) dictionary containing module stats.
"""
const STARTStats = Dict{String, Any}

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
ProtoNode struct, used to generate tree prototypes, which are the templates of [`OAR.START`](@ref).
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
    The children of this node (`Dict{`[`STARTSymbol`](@ref)`, ProtoNode}`).
    """
    children::Dict{STARTSymbol, ProtoNode}

    """
    The mutable [`ProtoNodeStats`](@ref) options and stats of the ProtoNode.
    """
    stats::ProtoNodeStats
end

"""
Alias for how ProtoNode children are indexed (`ProtoChildren = Dict{`[`STARTSymbol`](@ref)`, `[`ProtoNode`](@ref)`}`).
"""
const ProtoChildren = Dict{STARTSymbol, ProtoNode}

"""
Tree node for a [`START`](@ref) module.
"""
struct TreeNode <: ARTNode
    """
    The [`STARTSymbol`](@ref) symbol for the node.
    """
    t::STARTSymbol

    """
    Children nodes of this node.
    """
    children::Vector{TreeNode}
end

# -----------------------------------------------------------------------------
# DEPENDENT ALIASES
# -----------------------------------------------------------------------------

"""""
A `TreeStatement` is simply a [`TreeNode`](@ref).
"""
const TreeStatement = TreeNode

"""
Many `TreeStatements` are a Vector of [`TreeNode`](@ref)s.
"""
const TreeStatements = Vector{TreeStatement}

"""
Alias for arguments accepting multiple definitions of a statement formulation.
"""
const SomeStatement = Union{TreeStatement, Statement}

"""
Alias for arguments accepting multiple definitions of statement formulations.
"""
const SomeStatements = Union{TreeStatements, Statements}

# -----------------------------------------------------------------------------
# CONSTRUCTORS
# -----------------------------------------------------------------------------

"""
Constructor for prepopulating the stats dictionary.
"""
function gen_STARTStats()
    # Init the stats
    stats = STARTStats()
    stats["n_categories"] = 0
    stats["n_clusters"] = 0
    stats["n_instance"] = Vector{Int}()
    return stats
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
Empty constructor for a [`OAR.START`](@ref) [`OAR.ProtoNode`](@ref).
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
Constructor for a zero-initialized [`OAR.START`](@ref) [`OAR.ProtoNode`](@ref).

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
Constructor for a [`OAR.START`](@ref) [`OAR.TreeNode`](@ref) taking an existing [`OAR.STARTSymbol`](@ref).

# Arguments
- `symb::STARTSymbol`: the preconstructed STARTSymbol used for constructing the [`OAR.TreeNode`](@ref).
"""
function TreeNode(symb::STARTSymbol)
    TreeNode(
        symb,                   # t
        Vector{TreeNode}(),     # children
    )
end

"""
Constructor for a [`OAR.START`](@ref) [`OAR.TreeNode`](@ref), taking a string name of the symbol and if it is terminal or not.

# Arguments
- `name::AbstractString`: the string name of the symbol to instantiate the [`OAR.TreeNode`](@ref) with.
- `is_terminal::Bool`: flag for if the symbol in the node is terminal or not.
"""
function TreeNode(name::AbstractString, is_terminal::Bool=true)
    # Construct and return the tree node
    TreeNode(
        STARTSymbol(
            name,
            is_terminal,
        ),
    )
end

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

"""
Checks if the [`OAR.TreeNode`](@ref) contains a terminal symbol.

# Arguments
- `treenode::TreeNode`: the [`OAR.TreeNode`](@ref) to containing the [`OAR.GSymbol`](@ref) to check if terminal.
"""
function is_terminal(treenode::TreeNode)
    # Wrap the GSymbol check function
    return is_terminal(treenode.t)
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
function Base.show(io::IO, node::ProtoNode)::Nothing
    # Show the protonode info
    print(io, "$(typeof(node))($(length(node.N)))")

    # Empty return
    return
end

"""
Prints a tree string for displaying children of a [`OAR.TreeNode`](@ref), used in the `Base.show` overload.

# Arguments
- `io::IO`: the current IO stream.
- `node::TreeNode`: the [`OAR.TreeNode`](@ref) with children to display
"""
function print_treenode_children(io::IO, node::TreeNode, level::Integer, last::Bool)::Nothing
    # Get the number of children to display
    n_children = length(node.children)
    # Get the level spacing
    spacer = last ? "    " : " │  "^level
    # Append to the printstring for each child
    term = "\n"
    for ix = 1:n_children
        is_last = (ix == n_children)
        local_symb = "\"$(node.children[ix].t.data)\""
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
function Base.show(io::IO, node::TreeNode)::Nothing
    # Set the top of the printstring
    printstring = "$(typeof(node))(\"$(node.t.data)\")"
    print(io, printstring)

    # If the node has children, then display each child
    if !isempty(node.children)
        # Add a newline and the child printstring
        print(io, "\n")
        print_treenode_children(io, node, 0, false)
    end

    # Empty return
    return
end
