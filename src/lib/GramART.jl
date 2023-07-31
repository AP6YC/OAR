"""
    GramART.jl

# Description
This file implements the structs, methods, and functions for GramART's functionality.

# Attribution

## Authors
- Sasha Petrenko <petrenkos@mst.edu>

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
# METHODS
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
# FUNCTIONS
# -----------------------------------------------------------------------------

"""
Checks if the [`OAR.GSymbol`](@ref) is a terminal grammar symbol.

# Arguments
- `symb::GSymbol`: the [`OAR.GSymbol`](@ref) to check.
"""
function is_terminal(symb::GSymbol)
    # Check the terminal flag attribute of the grammar symbol
    return symb.terminal
end

"""
Checks if the [`OAR.TreeNode`](@ref) contains a terminal symbol.

# Arguments
- `treenode::TreeNode`: the [`OAR.TreeNode`](@ref) to containing the [`OAR.GSymbol`](@ref) to check if terminal.
"""
function is_terminal(treenode::TreeNode)
    # Wrap the GSymbol check function
    return is_terminal(treenode.t)
end

"""
Adds a recursively-generated [`OAR.ProtoNode`](@ref) to the [`OAR.GramART`](@ref) module.

# Arguments
- `gramart::GramART`: the [`OAR.GramART`](@ref) to append a new node to.
"""
function add_node!(gramart::GramART)
    # Create the top node
    top_node = ProtoNode(gramart.grammar.T)
    # Iterate over the production rules
    for (nonterminal, prod_rule) in gramart.grammar.P
        # Add a node for each non-terminal place
        local_node = ProtoNode(gramart.grammar.T)
        if gramart.opts.terminated
            # Add a node for each terminal
            for terminal in prod_rule
                local_node.children[terminal] = ProtoNode(gramart.grammar.T)
            end
        end
        # Add the node with nodes to the top node
        top_node.children[nonterminal] = local_node
    end
    # Append the recursively constructed proto node
    push!(gramart.protonodes, top_node)
end

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
    # Explicit empty return
    return
end

"""
Updates the tree of [`OAR.ProtoNode`](@ref) from a single terminal.

# Arguments
- `pn::ProtoNode`: the top of the [`OAR.ProtoNode`](@ref) tree to update.
- `nonterminal::GramARTSymbol`: the nonterminal symbol of the statement to update at.
- `symb::GramARTSymbol`: the terminal symbol to update everywhere.
"""
function inc_update_symbols!(
    pn::ProtoNode,
    nonterminal::GramARTSymbol,
    symb::GramARTSymbol,
    terminated::Bool
)
    # function inc_update_symbols!(pn::ProtoNode, symb::GSymbol, position::Integer)
    # Update the top node
    update_dist!(pn, symb)
    # Update the middle nodes
    middle_node = pn.children[nonterminal]
    update_dist!(middle_node, symb)
    # Update the corresponding terminal node
    if terminated
        update_dist!(middle_node.children[symb], symb)
    end

    # Explicity empty return
    return
end

"""
Processes a statement for a [`OAR.GramART`](@ref) module.

# Arguments
- `gramart::GramART`: the [`OAR.GramART`](@ref) to update with the statement.
- `statement::Statement{T} where T <: Any`: the grammar [`OAR.Statement`](@ref) to process.
- `index::Integer`: the index of the [`OAR.ProtoNode`](@ref) to update.
"""
function process_statement!(
    gramart::GramART,
    statement::Statement{T},
    index::Integer
) where T <: Any
    # Update each position of the protonode at `index`
    for ix in eachindex(statement)
        inc_update_symbols!(
            gramart.protonodes[index],
            gramart.grammar.S[ix],
            statement[ix],
            gramart.opts.terminated
        )
    end
end

"""
Computes the ART activation of a statement on an [`OAR.ProtoNode`](@ref).

# Arguments
- `node::ProtoNode`: the [`OAR.ProtoNode`](@ref) node to compute the activation for.
- `statement::Statement`: the [`OAR.Statement`](@ref) used for computing the activation.
"""
function activation(node::ProtoNode, statement::Statement)
    local_sum = 0.0
    for symb in statement
        local_sum += node.dist[symb]
    end
    return local_sum
end

"""
Trains [`OAR.GramART`](@ref) module on a [`OAR.Statement`](@ref) from the [`OAR.GramART`](@ref)'s grammar.

# Arguments
- `gramart::GramART`: the [`OAR.GramART`](@ref) to update with the [`OAR.Statement`](@ref).
- `statement::Statement`: the grammar [`OAR.Statement`](@ref) to process.
"""
function train!(gramart::GramART, statement::Statement)
    # If this is the first sample, then fast commit
    if isempty(gramart.protonodes)
        add_node!(gramart)
        process_statement!(gramart, statement, 1)
        return
    end

    # Compute the activations
    n_nodes = length(gramart.protonodes)
    activations = zeros(n_nodes)
    for ix = 1:n_nodes
        activations[ix] = activation(gramart.protonodes[ix], statement)
    end

    # Sort by highest activation
    index = sortperm(activations, rev=true)
    mismatch_flag = true
    for jx = 1:n_nodes
        # Get the best-matching unit
        bmu = index[jx]
        if activations[bmu] >= gramart.opts.rho
            process_statement!(gramart, statement, bmu)
            mismatch_flag = false
            break
        end
    end

    # If we triggered a mismatch, add a node
    if mismatch_flag
        bmu = n_nodes + 1
        add_node!(gramart)
        process_statement!(gramart, statement, bmu)
    end
end

"""
Classifies the [`OAR.Statement`](@ref) into one of [`OAR.GramART`](@ref)'s internal categories.

# Arguments
- `gramart::GramART`: the [`OAR.GramART`](@ref) to use in classification/inference.
- `statement::Statement`: the [`OAR.Statement`](@ref) to classify.
- `get_bmu::Bool=false`: optional, whether to get the best matching unit in the case of complete mismatch.
"""
function classify(
    gramart::GramART,
    statement::Statement ;
    get_bmu::Bool=false
)
    # Compute the activations
    n_nodes = length(gramart.protonodes)
    activations = zeros(n_nodes)
    for ix = 1:n_nodes
        activations[ix] = activation(gramart.protonodes[ix], statement)
    end

    # Sort by highest activation
    index = sortperm(activations, rev=true)

    # Default is mismatch
    mismatch_flag = true
    y_hat = -1
    for jx in 1:n_nodes
        bmu = index[jx]
        # Vigilance check - pass
        if activations[bmu] >= gramart.opts.rho
            # Current winner
            y_hat = bmu
            mismatch_flag = false
            break
        end
    end

    # If we did not find a match
    if mismatch_flag
        # Report either the best matching unit or the mismatch label -1
        bmu = index[1]
        y_hat = get_bmu ? bmu : -1
    end

    return y_hat
end

"""
GramART utility: gets the positive distribution.

# Arguments
- `gramart::GramART`: the [`OAR.GramART`](@ref) module to analyze.
- `nonterminal::AbstractString`: the string name of the nonterminal position to analyze.
- `index::Integer`: the index of the [`OAR.ProtoNode`](@ref) to analyze.
"""
function get_positive_dist(
    gramart::GramART,
    nonterminal::AbstractString,
    index::Integer
)
    # Filter the elements of each distribution that are greater than zero
    pos_dist = filter(
        p -> p.second > 0.0,
        gramart.protonodes[index].children[GSymbol{String}(nonterminal, false)].dist
    )

    # Return a new distribution that doesn't contain zero elements
    return pos_dist
end

"""
GramART utility: returns a list of the instance counts for each [`OAR.GramART`](@ref) prototype.

# Arguments
- `gramart::GramART`: the [`OAR.GramART`](@ref) module to analyze.
"""
function get_gramart_instance_counts(gramart::GramART)
    # Return the instance counts for each of the top nodes
    return [node.stats.m for node in gramart.protonodes]
end
