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
function START(grammar::CFG, opts::opts_START)
    # Init the stats
    stats = gen_STARTStats()

    # Instantiate and return the START module
    START(
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
function START(grammar::CFG; kwargs...)
    # Construct the START options from the keyword arguments
    opts = opts_START(;kwargs...)

    # Construct and return the START module
    START(
        grammar,
        opts,
    )
end
