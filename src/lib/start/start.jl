"""
    start.jl

# Description
The structs and constructors of START.
"""

# -----------------------------------------------------------------------------
# STRUCTS
# -----------------------------------------------------------------------------

"""
[`START`](@ref) options struct as a `Parameters.jl` `@with_kw` object.
"""
@with_kw mutable struct opts_START @deftype Float
    """
    Vigilance parameter: ρ ∈ [0, 1]
    """
    rho = 0.7;
    # @assert rho >= 0.0 && rho <= 1.0

    # """
    # Lower-bound vigilance parameter: rho_lb ∈ [0, 1].
    # """
    # rho_lb = 0.55;
    # # @assert rho_lb >= 0.0 && rho_lb <= 1.0

    # """
    # Upper bound vigilance parameter: rho_ub ∈ [0, 1].
    # """
    # rho_ub = 0.75; @assert rho_lb <= rho_ub
    # # @assert rho_ub >= 0.0 && rho_ub <= 1.0 && rho_ub > rho_lb

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
Definition of a START module.

Contains the [`ProtoNode`](@ref)s and [`CFG`](@ref) grammar that is used for processing statements and generating nodes.
"""
struct START <: SingleSTART
    """
    The [`OAR.ProtoNode`](@ref)s of the START module.
    """
    protonodes::Vector{ProtoNode}

    """
    The [`OAR.CFG`](@ref) (Context-Free Grammar) used for processing data (statements).
    """
    grammar::CFG

    """
    The [`OAR.opts_START`](@ref) hyperparameters of the START module.
    """
    opts::opts_START

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
Constructor for an [`OAR.START`](@ref) module that takes a [`CFG`](@ref) grammar and automatically sets up the [`ProtoNode`](@ref) tree.

# Arguments
$ARG_CFG
- `opts::opts_START`: a custom set of [`OAR.START`](@ref) options to use.
"""
function START(
    grammar::CFG,
    opts::opts_START,
)::START
    # Init the stats
    stats = gen_STARTStats()

    # Instantiate and return the START module
    return START(
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
Constructor for an [`OAR.START`](@ref) module that takes a [`OAR.CFG`](@ref) grammar and an optional list of keyword arguments for the options.

# Arguments
$ARG_CFG
- `kwargs...`: a list of keyword arguments for the [`OAR.opts_START`](@ref) options struct.
"""
function START(
    grammar::CFG;
    kwargs...
)::START
    # Construct the START options from the keyword arguments
    opts = opts_START(;kwargs...)

    # Construct and return the START module
    return START(
        grammar,
        opts,
    )
end

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

"""
Trains [`OAR.START`](@ref) module on a [`OAR.SomeStatement`](@ref) from the [`OAR.START`](@ref)'s grammar.

# Arguments
- `art::START`: the [`OAR.START`](@ref) to update with the [`OAR.SomeStatement`](@ref).
- `statement::SomeStatement`: the grammar [`OAR.SomeStatement`](@ref) to train upon.
- `y::Integer=0`: optional supervised label as an integer.
"""
function train!(
    art::START,
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

    for _ = 1:art.opts.epochs
        # Compute the activations
        activation_match!(art, statement)

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
                y_hat = art.labels[bmu]
                learn!(art, statement, bmu)
                art.stats["n_instance"][bmu] += 1
                mismatch_flag = false
                break
            end
        end

        # If we triggered a mismatch, add a node
        if mismatch_flag
            # bmu = n_nodes + 1
            y_hat = supervised ? y : art.stats["n_categories"] + 1
            create_category!(art, statement, y_hat)
        end
    end

    # Return the training label
    return y_hat
end

"""
Classifies the [`OAR.Statement`](@ref) into one of [`OAR.START`](@ref)'s internal categories.

# Arguments
- `art::START`: the [`OAR.START`](@ref) to use in classification/inference.
- `statement::SomeStatement`: the [`OAR.SomeStatement`](@ref) to classify.
- `get_bmu::Bool=false`: optional, whether to get the best matching unit in the case of complete mismatch.
"""
function classify(
    art::START,
    statement::SomeStatement ;
    get_bmu::Bool=false,
)::Int
    # Compute the activations
    activation_match!(art, statement)

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
