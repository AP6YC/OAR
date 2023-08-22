"""
    dv.jl

# Description
All dual-vigilance and distributed dual-vigilance definitions.
"""

"""
A list of all distributed dual-vigilance similarity linkage methods.
"""
const LINKAGE_METHODS = [
    :single,
    :average,
    :complete,
    :median,
    :weighted,
    :centroid,
]


"""
Trains [`OAR.GramART`](@ref) module on a [`OAR.SomeStatement`](@ref) from the [`OAR.GramART`](@ref)'s grammar.

# Arguments
- `gramart::GramART`: the [`OAR.GramART`](@ref) to update with the [`OAR.SomeStatement`](@ref).
- `statement::SomeStatement`: the grammar [`OAR.SomeStatement`](@ref) to process.
- `y::Integer=0`: optional supervised label as an integer.
"""
function train_dv!(
    gramart::GramART,
    statement::SomeStatement;
    y::Integer=0,
)
    # Flag for if the sample is supervised
    supervised = !iszero(y)

    # If this is the first sample, then fast commit
    if isempty(gramart.protonodes)
        y_hat = supervised ? y : 1
        create_category!(gramart, statement, y_hat)
        # add_node!(gramart)
        # learn!(gramart, statement, 1)
        return y_hat
    end

    # If the label is new, break to make a new category
    if supervised && !(y in gramart.labels)
        create_category!(gramart, statement, y)
        return y
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
        # If supervised and the label differed, force mismatch
        if supervised && (gramart.labels[bmu] != y)
            break
        end
        # if activations[bmu] >= gramart.opts.rho
        # Vigilance test upper bound
        if activations[bmu] >= gramart.opts.rho_ub
            y_hat = gramart.labels[bmu]
            learn!(gramart, statement, bmu)
            gramart.stats["n_instance"][bmu] += 1
            mismatch_flag = false
            break
        elseif activations[bmu] >= gramart.opts.rho_lb
            # Update sample labels
            y_hat = supervised ? y : gramart.labels[bmu]
            # Create a new category in the same cluster
            create_category!(gramart, statement, y_hat, new_cluster=false)
        end
    end

    # If we triggered a mismatch, add a node
    if mismatch_flag
        # bmu = n_nodes + 1
        y_hat = supervised ? y : gramart.stats["n_categories"] + 1
        create_category!(gramart, statement, y_hat)
        # learn!(gramart, statement, bmu)
    end

    # Return the training label
    return y_hat
end


"""
Classifies the [`OAR.Statement`](@ref) into one of [`OAR.GramART`](@ref)'s internal categories.

# Arguments
- `gramart::GramART`: the [`OAR.GramART`](@ref) to use in classification/inference.
- `statement::Statement`: the [`OAR.Statement`](@ref) to classify.
- `get_bmu::Bool=false`: optional, whether to get the best matching unit in the case of complete mismatch.
"""
function classify_dv(
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
        # if activations[bmu] >= gramart.opts.rho
        if activations[bmu] >= gramart.opts.rho_ub
            # Current winner
            # y_hat = bmu
            y_hat = gramart.labels[bmu]
            mismatch_flag = false
            break
        end
    end

    # If we did not find a match
    if mismatch_flag
        # Report either the best matching unit or the mismatch label -1
        bmu = index[1]
        # y_hat = get_bmu ? bmu : -1
        y_hat = get_bmu ? gramart.labels[bmu] : -1
    end

    return y_hat
end