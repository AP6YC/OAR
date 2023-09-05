"""
    dv.jl

# Description
Dual-vigilance definitions.
"""

"""
[`DVSTART`](@ref) options struct as a `Parameters.jl` `@with_kw` object.
"""
@with_kw mutable struct opts_DVSTART @deftype Float
    """
    Lower-bound vigilance parameter: rho_lb ∈ [0, 1].
    """
    rho_lb = 0.55;
    # @assert rho_lb >= 0.0 && rho_lb <= 1.0

    """
    Upper bound vigilance parameter: rho_ub ∈ [0, 1].
    """
    rho_ub = 0.75; @assert rho_lb <= rho_ub
    # @assert rho_ub >= 0.0 && rho_ub <= 1.0 && rho_ub > rho_lb

    """
    Choice parameter: alpha > 0.
    """
    alpha = 1e-3; @assert alpha > 0.0

    """
    Learning parameter: beta ∈ (0, 1].
    """
    beta = 1.0; @assert beta > 0.0 && beta <= 1.0

    """
    Maximum number of epochs during training.
    """
    epochs::Int = 1

    """
    Flag for generating nodes at the terminal distributions below their nonterminal positions.
    """
    terminated::Bool = false
end

"""
Definition of a DVSTART module.

Contains the [`ProtoNode`](@ref)s and [`CFG`](@ref) grammar that is used for processing statements and generating nodes.
"""
struct DVSTART <: SingleSTART
    """
    The [`OAR.ProtoNode`](@ref)s of the DVSTART module.
    """
    protonodes::Vector{ProtoNode}

    """
    The [`OAR.CFG`](@ref) (Context-Free Grammar) used for processing data (statements).
    """
    grammar::CFG

    """
    The [`OAR.opts_DVSTART`](@ref) hyperparameters of the DVSTART module.
    """
    opts::opts_DVSTART

    """
    Incremental list of labels corresponding to each F2 node, self-prescribed or supervised.
    """
    labels::Vector{Int}

    """
    Activation values for every weight for a given sample.
    """
    T::Vector{Float}

    """
    Match values for every weight for a given sample.
    """
    M::Vector{Float}

    """
    Dictionary of mutable statistics for the module.
    """
    stats::STARTStats
end

# -----------------------------------------------------------------------------
# CONSTRUCTORS
# -----------------------------------------------------------------------------

"""
Constructor for an [`OAR.DVSTART`](@ref) module that takes a [`CFG`](@ref) grammar and automatically sets up the [`ProtoNode`](@ref) tree.

# Arguments
$ARG_CFG
- `opts::opts_DVSTART`: a custom set of [`OAR.DVSTART`](@ref) options to use.
"""
function DVSTART(
    grammar::CFG,
    opts::opts_DVSTART
)::DVSTART
    # Init the stats
    stats = gen_STARTStats()

    # Instantiate and return the DVSTART module
    return DVSTART(
        Vector{ProtoNode}(),    # protonodes
        grammar,                # grammar
        opts,                   # opts
        Vector{Int}(),          # labels
        Vector{Float}(),        # T
        Vector{Float}(),        # M
        stats,                  # stats
    )
end

"""
Constructor for an [`OAR.DVSTART`](@ref) module that takes a [`OAR.CFG`](@ref) grammar and an optional list of keyword arguments for the options.

# Arguments
$ARG_CFG
- `kwargs...`: a list of keyword arguments for the [`OAR.opts_DVSTART`](@ref) options struct.
"""
function DVSTART(grammar::CFG; kwargs...)::DVSTART
    # Construct the DVSTART options from the keyword arguments
    opts = opts_DVSTART(;kwargs...)

    # Construct and return the DVSTART module
    return DVSTART(
        grammar,
        opts,
    )
end

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

"""
Trains [`OAR.DVSTART`](@ref) module on a [`OAR.SomeStatement`](@ref) from the [`OAR.DVSTART`](@ref)'s grammar.

# Arguments
- `art::DVSTART`: the [`OAR.DVSTART`](@ref) to update with the [`OAR.SomeStatement`](@ref).
- `statement::SomeStatement`: the grammar [`OAR.SomeStatement`](@ref) to process.
- `y::Integer=0`: optional supervised label as an integer.
"""
function train!(
    art::DVSTART,
    statement::SomeStatement;
    y::Integer=0,
)::Int
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

    # Compute the activations
    accommodate_vector!(art.T, art.stats["n_categories"])
    accommodate_vector!(art.M, art.stats["n_categories"])
    for ix = 1:art.stats["n_categories"]
        art.T[ix] = activation(art.protonodes[ix], statement)
        art.M[ix] = match(art.protonodes[ix], statement)
    end

    # Sort by highest activation
    index = sortperm(art.T, rev=true)
    mismatch_flag = true
    for jx = 1:art.stats["n_categories"]
        # Get the best-matching unit
        bmu = index[jx]
        # If supervised and the label differed, force mismatch
        if supervised && (art.labels[bmu] != y)
            break
        end
        # Vigilance test upper bound
        if art.T[bmu] >= art.opts.rho_ub
            y_hat = art.labels[bmu]
            learn!(art, statement, bmu)
            art.stats["n_instance"][bmu] += 1
            mismatch_flag = false
            break
        elseif art.T[bmu] >= art.opts.rho_lb
            # Update sample labels
            y_hat = supervised ? y : art.labels[bmu]
            # Create a new category in the same cluster
            create_category!(art, statement, y_hat, new_cluster=false)
        end
    end

    # If we triggered a mismatch, add a node
    if mismatch_flag
        y_hat = supervised ? y : art.stats["n_categories"] + 1
        create_category!(art, statement, y_hat)
    end

    # Return the training label
    return y_hat
end

"""
Classifies the [`OAR.Statement`](@ref) into one of [`OAR.DVSTART`](@ref)'s internal categories.

# Arguments
- `art::DVSTART`: the [`OAR.DVSTART`](@ref) to use in classification/inference.
- `statement::Statement`: the [`OAR.Statement`](@ref) to classify.
- `get_bmu::Bool=false`: optional, whether to get the best matching unit in the case of complete mismatch.
"""
function classify(
    art::DVSTART,
    statement::Statement ;
    get_bmu::Bool=false,
)::Int
    # Compute the activations
    # n_nodes = length(art.protonodes)
    # activations = zeros(n_nodes)
    # for ix = 1:n_nodes
    accommodate_vector!(art.T, art.stats["n_categories"])
    accommodate_vector!(art.M, art.stats["n_categories"])
    for ix = 1:art.stats["n_categories"]
        # activations[ix] = activation(art.protonodes[ix], statement)
        art.T[ix] = activation(art.protonodes[ix], statement)
        art.M[ix] = match(art.protonodes[ix], statement)
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
        if art.T[bmu] >= art.opts.rho_ub
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
