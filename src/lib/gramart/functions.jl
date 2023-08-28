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


# function inc_n_categories!(art::GramART)
#     art.stats["n_categories"] += 1
# end

# function create_category!(art::GramART, statement::SomeStatement, label::Integer)
#     art.stats["n_categories"] += 1
#     create_category!(art)
#     learn!(art, statement, 1)
# end



"""
Adds an empty node to the end of the [`OAR.GramART`](@ref) module.

# Arguments
- `art::GramART`: the [`OAR.GramART`](@ref) module to append a node to.
"""
function add_node!(
    art::GramART;
    new_cluster::Bool=true,
)
    # Update the stats counters
    art.stats["n_categories"] += 1

    # If we are creating a new cluster altogether, increment that
    new_cluster && (art.stats["n_clusters"] += 1)

    # Update the instance count with a new entry
    push!(art.stats["n_instance"], 1)

    # Create the top node
    top_node = ProtoNode(art.grammar.T)

    # Iterate over the production rules
    for (nonterminal, prod_rule) in art.grammar.P
        # Add a node for each non-terminal place
        local_node = ProtoNode(art.grammar.T)
        if art.opts.terminated
            # Add a node for each terminal
            for terminal in prod_rule
                local_node.children[terminal] = ProtoNode(art.grammar.T)
            end
        end
        # Add the node with nodes to the top node
        top_node.children[nonterminal] = local_node
    end

    # Append the recursively constructed proto node
    push!(art.protonodes, top_node)

    # Empty return
    return
end

"""
Adds a recursively-generated [`OAR.ProtoNode`](@ref) to the [`OAR.GramART`](@ref) module.

# Arguments
- `art::GramART`: the [`OAR.GramART`](@ref) to append a new node to.
"""
function create_category!(
    art::GramART,
    statement::SomeStatement,
    label::Integer;
    new_cluster::Bool=true,
)
    # Instantiate an empty node
    add_node!(art, new_cluster=new_cluster)

    # Learn upon the sample
    learn!(art, statement, art.stats["n_categories"])

    # Append the label to the cluster labels list
    push!(art.labels, label)

    # Empty return
    return
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
- `art::GramART`: the [`OAR.GramART`](@ref) to update with the statement.
- `statement::Statement`: the grammar [`OAR.Statement`](@ref) to process.
- `index::Integer`: the index of the [`OAR.ProtoNode`](@ref) to update.
"""
function learn!(
    art::GramART,
    statement::Statement,
    index::Integer,
)
    # Update each position of the protonode at `index`
    for ix in eachindex(statement)
        inc_update_symbols!(
            art.protonodes[index],
            art.grammar.S[ix],
            statement[ix],
            art.opts.terminated
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
    # Intialize the sum
    local_sum = 0.0

    # Shallow add the contribution from each weight.
    for symb in statement
        local_sum += node.dist[symb]
    end

    # local_sum /= length(statement)

    # Return the activation sum
    return local_sum
end

"""
Computes the ART match of a statement on an [`OAR.ProtoNode`](@ref).

# Arguments
- `node::ProtoNode`: the [`OAR.ProtoNode`](@ref) node to compute the match for.
- `statement::Statement`: the [`OAR.Statement`](@ref) used for computing the match.
"""
function match(
    node::ProtoNode,
    statement::Statement,
)
    # Initialize the sum
    local_sum = 0.0

    # Shallow add the contribution from each weight.
    for symb in statement
        local_sum += node.dist[symb]
    end

    # local_sum /= length(statement)

    # Return the match sum
    return local_sum
end

# function single_vigilance_check(art)
#     if activations[bmu] >= art.opts.rho
#         # If supervised and the label differed, force mismatch
#         if supervised && (art.labels[bmu] != y)
#             break
#         end
#         y_hat = art.labels[bmu]
#         learn!(art, statement, bmu)
#         art.stats["n_instance"][bmu] += 1
#         mismatch_flag = false
#         break
#     end
# end

# accommodate_vector!(art.T, art.stats["n_categories"])
# accommodate_vector!(art.M, art.stats["n_categories"])

"""
Extends a vector to a goal length with zeros of its element type to accommodate in-place updates.

# Arguments
- `vec::Vector{T}`: a vector of arbitrary element type.
- `goal_len::Integer`: the length that the vector should be.
"""
function accommodate_vector!(vec::Vector{T}, goal_len::Integer) where {T}
    # While the the vector is not the correct length
    while length(vec) < goal_len
        # Push a zero of the type of the vector elements
        push!(vec, zero(T))
    end
end
"""
Trains [`OAR.GramART`](@ref) module on a [`OAR.SomeStatement`](@ref) from the [`OAR.GramART`](@ref)'s grammar.

# Arguments
- `art::GramART`: the [`OAR.GramART`](@ref) to update with the [`OAR.SomeStatement`](@ref).
- `statement::SomeStatement`: the grammar [`OAR.SomeStatement`](@ref) to train upon.
- `y::Integer=0`: optional supervised label as an integer.
"""
function train!(
    art::GramART,
    statement::SomeStatement;
    y::Integer=0,
    # epochs::Integer=1,
)
    # Flag for if the sample is supervised
    supervised = !iszero(y)

    # If this is the first sample, then fast commit
    if isempty(art.protonodes)
        y_hat = supervised ? y : 1
        create_category!(art, statement, y_hat)
        return y_hat
    end

    # If the label is new, break to make a new category
    if supervised && !(y in art.labels)
        create_category!(art, statement, y)
        return y
    end

    for _ = 1:art.opts.epochs
        # Compute the activations
        accommodate_vector!(art.T, art.stats["n_categories"])
        accommodate_vector!(art.M, art.stats["n_categories"])
        for ix = 1:art.stats["n_categories"]
            art.T[ix] = activation(art.protonodes[ix], statement)
        end

        # Sort by highest activation
        index = sortperm(art.T, rev=true)
        mismatch_flag = true
        for jx = 1:art.stats["n_categories"]
            # Get the best-matching unit
            bmu = index[jx]
            if art.T[bmu] >= art.opts.rho
                # If supervised and the label differed, force mismatch
                if supervised && (art.labels[bmu] != y)
                    break
                end
                # @info "Match!"
                y_hat = art.labels[bmu]
                learn!(art, statement, bmu)
                art.stats["n_instance"][bmu] += 1
                mismatch_flag = false
                break
            end
        end

        # If we triggered a mismatch, add a node
        if mismatch_flag
            # @info "Mismatch!"
            # bmu = n_nodes + 1
            y_hat = supervised ? y : art.stats["n_categories"] + 1
            create_category!(art, statement, y_hat)
        end
    end

    # Return the training label
    return y_hat
end

"""
Classifies the [`OAR.Statement`](@ref) into one of [`OAR.GramART`](@ref)'s internal categories.

# Arguments
- `art::GramART`: the [`OAR.GramART`](@ref) to use in classification/inference.
- `statement::SomeStatement`: the [`OAR.SomeStatement`](@ref) to classify.
- `get_bmu::Bool=false`: optional, whether to get the best matching unit in the case of complete mismatch.
"""
function classify(
    art::GramART,
    statement::SomeStatement ;
    get_bmu::Bool=false,
)
    # Compute the activations
    accommodate_vector!(art.T, art.stats["n_categories"])
    accommodate_vector!(art.M, art.stats["n_categories"])
    for ix = 1:art.stats["n_categories"]
        art.T[ix] = activation(art.protonodes[ix], statement)
    end

    # Sort by highest activation
    index = sortperm(art.T, rev=true)

    # Default is mismatch
    mismatch_flag = true
    y_hat = -1
    for jx in 1:art.stats["n_categories"]
        bmu = index[jx]
        # Vigilance check - pass
        if art.T[bmu] >= art.opts.rho
            # Current winner
            y_hat = art.labels[bmu]
            mismatch_flag = false
            break
        end
    end

    # If we did not find a match
    if mismatch_flag
        # Report either the best matching unit or the mismatch label -1
        bmu = index[1]
        y_hat = get_bmu ? art.labels[bmu] : -1
    end

    return y_hat
end

"""
GramART utility: gets the positive distribution.

# Arguments
- `art::GramART`: the [`OAR.GramART`](@ref) module to analyze.
- `nonterminal::AbstractString`: the string name of the nonterminal position to analyze.
- `index::Integer`: the index of the [`OAR.ProtoNode`](@ref) to analyze.
"""
function get_positive_dist(
    art::GramART,
    nonterminal::AbstractString,
    index::Integer,
)
    # Filter the elements of each distribution that are greater than zero
    pos_dist = filter(
        p -> p.second > 0.0,
        art.protonodes[index].children[GSymbol{String}(nonterminal, false)].dist
    )

    # Return a new distribution that doesn't contain zero elements
    return pos_dist
end

"""
GramART utility: returns a list of the instance counts for each [`OAR.GramART`](@ref) prototype.

# Arguments
- `art::GramART`: the [`OAR.GramART`](@ref) module to analyze.
"""
function get_gramart_instance_counts(art::GramART)
    # Return the instance counts for each of the top nodes
    return [node.stats.m for node in art.protonodes]
end
