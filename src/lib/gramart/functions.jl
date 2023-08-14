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
Updates the distribution of a single [`OAR.ProtoNode`](@ref) from one new symbol instance.

# Arguments
- `pn::ProtoNode`: the [`OAR.ProtoNode`](@ref) to update the distribution with.
- `symb::GramARTSymbol`: the symbol instance to update the [`OAR.ProtoNode`](@ref) with.
"""
function update_dist!(
    pn::ProtoNode,
    symb::GramARTSymbol,
)
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
    terminated::Bool,
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
- `statement::Statement`: the grammar [`OAR.Statement`](@ref) to process.
- `index::Integer`: the index of the [`OAR.ProtoNode`](@ref) to update.
"""
function learn!(
    gramart::GramART,
    statement::Statement,
    index::Integer,
)
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
function activation(
    node::ProtoNode,
    statement::Statement,
)
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
function train!(
    gramart::GramART,
    statement::Statement,
)
    # If this is the first sample, then fast commit
    if isempty(gramart.protonodes)
        add_node!(gramart)
        learn!(gramart, statement, 1)
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
            learn!(gramart, statement, bmu)
            mismatch_flag = false
            break
        end
    end

    # If we triggered a mismatch, add a node
    if mismatch_flag
        bmu = n_nodes + 1
        add_node!(gramart)
        learn!(gramart, statement, bmu)
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
    get_bmu::Bool=false,
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
    index::Integer,
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
