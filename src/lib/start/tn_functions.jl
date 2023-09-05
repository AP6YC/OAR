"""
    tn_functions.jl

# Description
Implementations of the training and classification functions and subroutines implemented upon TreeNode statements.
"""

"""
Processes a statement for a [`OAR.START`](@ref) module.

# Arguments
- `gramart::START`: the [`OAR.START`](@ref) to update with the statement.
- `statement::TreeNode`: the grammar [`OAR.TreeNode`](@ref) to process.
- `index::Integer`: the index of the [`OAR.ProtoNode`](@ref) to update.
"""
function learn!(
    gramart::START,
    statement::TreeNode,
    index::Integer,
)::Nothing
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

    # Empty return
    return
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
)::Float
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
)::Float
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
