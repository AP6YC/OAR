"""
    tn_functions.jl

# Description
Implementations of the training and classification functions and subroutines implemented upon TreeNode statements.
"""

"""
Processes a statement for a [`OAR.GramART`](@ref) module.

# Arguments
- `gramart::GramART`: the [`OAR.GramART`](@ref) to update with the statement.
- `statement::TreeNode`: the grammar [`OAR.TreeNode`](@ref) to process.
- `index::Integer`: the index of the [`OAR.ProtoNode`](@ref) to update.
"""
function learn!(
    gramart::GramART,
    statement::TreeNode,
    index::Integer,
)
    # Update each position of the protonode at `index`
    for ix in eachindex(statement.children)
        local_tn = statement.children[ix]
        if is_terminal(local_tn)
            inc_update_symbols!(
                gramart.protonodes[index],
                gramart.grammar.S[ix],
                # statement[ix],
                local_tn.t,
                gramart.opts.terminated,
            )
        else
            for jx in eachindex(local_tn.children)
                sub_tn = local_tn.children[jx]
                inc_update_symbols!(
                    gramart.protonodes[index],
                    gramart.grammar.S[ix],
                    # statement[ix],
                    sub_tn.t,
                    gramart.opts.terminated,
                )
            end
        end
    end
end

"""
Computes the ART activation of a statement on an [`OAR.ProtoNode`](@ref).

# Arguments
- `node::ProtoNode`: the [`OAR.ProtoNode`](@ref) node to compute the activation for.
- `statement::TreeNode`: the [`OAR.TreeNode`](@ref) used for computing the activation.
"""
function activation(
    node::ProtoNode,
    statement::TreeNode,
)
    # Intialize the sum
    local_sum = 0.0

    # Deep add the contribution from each weight.
    for ix in eachindex(statement.children)
        local_tn = statement.children[ix]
        if is_terminal(local_tn)
            local_sum += node.dist[local_tn.t]
        else
            for jx in eachindex(local_tn.children)
                sub_tn = local_tn.children[jx]
                local_sum += node.dist[sub_tn.t]
            end
        end
    end

    # Return the activation sum
    return local_sum
end

"""
Computes the ART match of a statement on an [`OAR.ProtoNode`](@ref).

# Arguments
- `node::ProtoNode`: the [`OAR.ProtoNode`](@ref) node to compute the match for.
- `statement::TreeNode`: the [`OAR.TreeNode`](@ref) used for computing the match.
"""
function match(
    node::ProtoNode,
    statement::TreeNode,
)
    # Initialize the sum
    local_sum = 0.0

    # Deep add the contribution from each weight.
    for ix in eachindex(statement.children)
        local_tn = statement.children[ix]
        if is_terminal(local_tn)
            local_sum += node.dist[local_tn.t]
        else
            for jx in eachindex(local_tn.children)
                sub_tn = local_tn.children[jx]
                local_sum += node.dist[sub_tn.t]
            end
        end
    end

    # Return the match sum
    return local_sum
end

"""
Classifies the [`OAR.TreeNode`](@ref) into one of [`OAR.GramART`](@ref)'s internal categories.

# Arguments
- `gramart::GramART`: the [`OAR.GramART`](@ref) to use in classification/inference.
- `statement::TreeNode`: the [`OAR.TreeNode`](@ref) to classify.
- `get_bmu::Bool=false`: optional, whether to get the best matching unit in the case of complete mismatch.
"""
function classify(
    gramart::GramART,
    statement::TreeNode ;
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
