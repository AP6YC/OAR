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
    # :centroid,
]

# Argument docstring for the F2 docstring
const F2_DOCSTRING = """
- `F2::GramART`: the DDVSTART GramART F2 node to compute the linkage method within.
"""

# Argument docstring for the F2 field, includes the argument header
const FIELD_DOCSTRING = """
# Arguments
- `field::RealVector`: the DDVSTART GramART F2 node field (F2.T or F2.M) to compute the linkage for.
"""

# Argument docstring for the activation flag
const ACTIVATION_DOCSTRING = """
- `activation::Bool`: flag to use the activation function. False uses the match function.
"""

"""
Trains [`OAR.GramART`](@ref) module on a [`OAR.SomeStatement`](@ref) from the [`OAR.GramART`](@ref)'s grammar.

# Arguments
- `art::GramART`: the [`OAR.GramART`](@ref) to update with the [`OAR.SomeStatement`](@ref).
- `statement::SomeStatement`: the grammar [`OAR.SomeStatement`](@ref) to process.
- `y::Integer=0`: optional supervised label as an integer.
"""
function train_dv!(
    art::GramART,
    statement::SomeStatement;
    y::Integer=0,
)
    # Flag for if the sample is supervised
    supervised = !iszero(y)

    # If this is the first sample, then fast commit
    if isempty(art.protonodes)
        y_hat = supervised ? y : 1
        create_category!(art, statement, y_hat)
        # add_node!(art)
        # learn!(art, statement, 1)
        return y_hat
    end

    # If the label is new, break to make a new category
    if supervised && !(y in art.labels)
        create_category!(art, statement, y)
        return y
    end

    # Compute the activations
    # n_nodes = length(art.protonodes)
    # activations = zeros(n_nodes)
    accommodate_vector!(art.T, art.stats["n_categories"])
    accommodate_vector!(art.M, art.stats["n_categories"])
    # for ix = 1:n_nodes
    for ix = 1:art.stats["n_categories"]
        # activations[ix] = activation(art.protonodes[ix], statement)
        art.T[ix] = activation(art.protonodes[ix], statement)
    end

    # Sort by highest activation
    # index = sortperm(activations, rev=true)
    index = sortperm(art.T, rev=true)
    mismatch_flag = true
    # for jx = 1:n_nodes
    for jx = 1:art.stats["n_categories"]
        # Get the best-matching unit
        bmu = index[jx]
        # If supervised and the label differed, force mismatch
        if supervised && (art.labels[bmu] != y)
            break
        end
        # if activations[bmu] >= art.opts.rho
        # Vigilance test upper bound
        # if activations[bmu] >= art.opts.rho_ub
        if art.T[bmu] >= art.opts.rho_ub
            y_hat = art.labels[bmu]
            learn!(art, statement, bmu)
            art.stats["n_instance"][bmu] += 1
            mismatch_flag = false
            break
        # elseif activations[bmu] >= art.opts.rho_lb
        elseif art.T[bmu] >= art.opts.rho_lb
            # Update sample labels
            y_hat = supervised ? y : art.labels[bmu]
            # Create a new category in the same cluster
            create_category!(art, statement, y_hat, new_cluster=false)
        end
    end

    # If we triggered a mismatch, add a node
    if mismatch_flag
        # bmu = n_nodes + 1
        y_hat = supervised ? y : art.stats["n_categories"] + 1
        create_category!(art, statement, y_hat)
        # learn!(art, statement, bmu)
    end

    # Return the training label
    return y_hat
end


"""
Classifies the [`OAR.Statement`](@ref) into one of [`OAR.GramART`](@ref)'s internal categories.

# Arguments
- `art::GramART`: the [`OAR.GramART`](@ref) to use in classification/inference.
- `statement::Statement`: the [`OAR.Statement`](@ref) to classify.
- `get_bmu::Bool=false`: optional, whether to get the best matching unit in the case of complete mismatch.
"""
function classify_dv(
    art::GramART,
    statement::Statement ;
    get_bmu::Bool=false,
)
    # Compute the activations
    # n_nodes = length(art.protonodes)
    # activations = zeros(n_nodes)
    # for ix = 1:n_nodes
    accommodate_vector!(art.T, art.stats["n_categories"])
    accommodate_vector!(art.M, art.stats["n_categories"])
    for ix = 1:art.stats["n_categories"]
        # activations[ix] = activation(art.protonodes[ix], statement)
        art.T[ix] = activation(art.protonodes[ix], statement)
    end

    # Sort by highest activation
    index = sortperm(art.T, rev=true)

    # Default is mismatch
    mismatch_flag = true
    y_hat = -1
    # for jx in 1:n_nodes
    for jx in 1:art.stats["n_categories"]
        bmu = index[jx]
        # Vigilance check - pass
        # if activations[bmu] >= art.opts.rho
        if activations[bmu] >= art.opts.rho_ub
            # Current winner
            # y_hat = bmu
            y_hat = art.labels[bmu]
            mismatch_flag = false
            break
        end
    end

    # If we did not find a match
    if mismatch_flag
        # Report either the best matching unit or the mismatch label -1
        bmu = index[1]
        # y_hat = get_bmu ? bmu : -1
        y_hat = get_bmu ? art.labels[bmu] : -1
    end

    return y_hat
end

function similarity(method::Symbol, F2::GramART, sample::SomeStatement, activation::Bool)
    # Handle :centroid usage
    # if method === :centroid
    #     value = eval(method)(F2, sample, activation)
    # Handle :weighted usage
    # elseif method === :weighted
    if method === :weighted
        value = eval(method)(F2, activation)
    # Handle common usage
    else
        value = eval(method)(activation ? F2.T : F2.M)
    end

    return value
end

"""
Single linkage DDVFA similarity function.

$FIELD_DOCSTRING
"""
function single(field::RealVector)
    return maximum(field)
end

"""
Average linkage DDVFA similarity function.

$FIELD_DOCSTRING
"""
function average(field::RealVector)
    return statistics_mean(field)
end

"""
Complete linkage DDVFA similarity function.

$FIELD_DOCSTRING
"""
function complete(field::RealVector)
    return minimum(field)
end

"""
Median linkage DDVFA similarity function.

$FIELD_DOCSTRING
"""
function median(field::RealVector)
    return statistics_median(field)
end

"""
Weighted linkage DDVFA similarity function.

# Arguments:
$F2_DOCSTRING
$ACTIVATION_DOCSTRING
"""
function weighted(F2::GramART, activation::Bool)
    if activation
        value = F2.T' * (F2.n_instance ./ sum(F2.n_instance))
    else
        value = F2.M' * (F2.n_instance ./ sum(F2.n_instance))
    end

    return value
end

function train!(
    art::DDVSTART,
    statement::SomeStatement;
    y::Integer=0,
)

    # Flag for if the sample is supervised
    supervised = !iszero(y)

    # If this is the first sample, then fast commit
    if isempty(art.protonodes)
        y_hat = supervised ? y : 1
        create_category!(art, statement, y_hat)
        # add_node!(art)
        # learn!(art, statement, 1)
        return y_hat
    end

    # If the label is new, break to make a new category
    if supervised && !(y in art.labels)
        create_category!(art, statement, y)
        return y
    end

    # Compute the activations
    # n_nodes = length(art.protonodes)
    # activations = zeros(n_nodes)
    # for ix = 1:n_nodes
    for ix = 1:art.stats["n_categories"]
        # activations[ix] = activation(art.protonodes[ix], statement)
        art.T[ix] = activation(art.protonodes[ix], statement)
    end

    # Sort by highest activation
    # index = sortperm(activations, rev=true)
    index = sortperm(art.T, rev=true)
    mismatch_flag = true
    for jx = 1:n_nodes
        # Get the best-matching unit
        bmu = index[jx]
        # If supervised and the label differed, force mismatch
        if supervised && (art.labels[bmu] != y)
            break
        end
        # if activations[bmu] >= art.opts.rho
        # Vigilance test upper bound
        # if activations[bmu] >= art.opts.rho_ub
        if art.T[bmu] >= art.opts.rho_ub
            y_hat = art.labels[bmu]
            learn!(art, statement, bmu)
            art.stats["n_instance"][bmu] += 1
            mismatch_flag = false
            break
        # elseif activations[bmu] >= art.opts.rho_lb
        elseif art.T[bmu] >= art.opts.rho_lb
            # Update sample labels
            y_hat = supervised ? y : art.labels[bmu]
            # Create a new category in the same cluster
            create_category!(art, statement, y_hat, new_cluster=false)
        end
    end

    # If we triggered a mismatch, add a node
    if mismatch_flag
        # bmu = n_nodes + 1
        y_hat = supervised ? y : art.stats["n_categories"] + 1
        create_category!(art, statement, y_hat)
        # learn!(art, statement, bmu)
    end

    # Return the training label
    return y_hat

end

function classify(
    art::DDVSTART,
    statement::Statement ;
    get_bmu::Bool=false,
)
    # Compute the activations
    # n_nodes = length(art.protonodes)
    n_nodes = length(art.F2)
    activations = zeros(n_nodes)
    for ix = 1:n_nodes
        activations[ix] = activation(art.protonodes[ix], statement)
    end

    # Sort by highest activation
    index = sortperm(activations, rev=true)

    # Default is mismatch
    mismatch_flag = true
    y_hat = -1
    for jx in 1:n_nodes
        bmu = index[jx]
        # Vigilance check - pass
        # if activations[bmu] >= art.opts.rho
        if activations[bmu] >= art.opts.rho_ub
            # Current winner
            # y_hat = bmu
            y_hat = art.labels[bmu]
            mismatch_flag = false
            break
        end
    end

    # If we did not find a match
    if mismatch_flag
        # Report either the best matching unit or the mismatch label -1
        bmu = index[1]
        # y_hat = get_bmu ? bmu : -1
        y_hat = get_bmu ? art.labels[bmu] : -1
    end

    return y_hat
end
