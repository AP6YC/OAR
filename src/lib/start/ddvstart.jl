"""
    ddvstart.jl

# Description
Distributed dual-vigilance START definitions.
"""

"""
DDVSTART options struct as a `Parameters.jl` object.
"""
@with_kw mutable struct opts_DDVSTART @deftype Float
    """
    Lower-bound vigilance parameter: rho_lb ∈ [0, 1].
    """
    rho_lb = 0.7;
    # @assert rho_lb >= 0.0 && rho_lb <= 1.0

    """
    Upper bound vigilance parameter: rho_ub ∈ [0, 1].
    """
    rho_ub = 0.85; @assert rho_lb <= rho_ub
    # @assert rho_ub >= 0.0 && rho_ub <= 1.0

    """
    Choice parameter: alpha > 0.
    """
    alpha = 1e-3; @assert alpha > 0.0

    """
    Learning parameter: beta ∈ (0, 1].
    """
    beta = 1.0; @assert beta > 0.0 && beta <= 1.0

    """
    Pseudo kernel width: gamma >= 1.
    """
    gamma = 3.0; @assert gamma >= 1.0

    """
    Reference gamma for normalization: 0 <= gamma_ref < gamma.
    """
    gamma_ref = 1.0; @assert 0.0 <= gamma_ref && gamma_ref < gamma

    """
    Similarity method (activation and match): similarity ∈ [:single, :average, :complete, :median, :weighted, :centroid].
    """
    similarity::Symbol = :single

    """
    Maximum number of epochs during training: max_epochs ∈ (1, Inf).
    """
    epochs::Int = 1

    """
    Display flag for progress bars.
    """
    display::Bool = false

    """
    Flag to normalize the threshold by the feature dimension.
    """
    gamma_normalization::Bool = true

    # """
    # Flag to use an uncommitted node when learning.

    # If true, new weights are created with ones(dim) and learn on the complement-coded sample.
    # If false, fast-committing is used where the new weight is simply the complement-coded sample.
    # """
    # uncommitted::Bool = false

    # """
    # Selected activation function.
    # """
    # activation::Symbol = :gamma_activation

    # """
    # Selected match function.
    # """
    # match::Symbol = :gamma_match

    # """
    # Selected weight update function.
    # """
    # update::Symbol = :basic_update
end

"""
A DDVSTART module.
"""
mutable struct DDVSTART <: AbstractSTART
    """
    The [`OAR.CFG`](@ref) (Context-Free Grammar) used for processing data (statements).
    """
    grammar::CFG

    """
    DDVSTART options struct.
    """
    opts::opts_DDVSTART
    # opts::opts_DDVFA

    """
    START options struct used for all F2 nodes.
    """
    subopts::opts_START

    # """
    # Operating module threshold value, a function of the vigilance parameter.
    # """
    # threshold::Float

    """
    List of F2 nodes (themselves START modules).
    """
    F2::Vector{START}

    """
    Incremental list of labels corresponding to each F2 node, self-prescribed or supervised.
    """
    labels::Vector{Int}

    """
    Number of total categories.
    """
    n_categories::Int

    """
    Current training epoch.
    """
    epoch::Int

    """
    DDVFA activation values.
    """
    T::Vector{Float}

    """
    DDVFA match values.
    """
    M::Vector{Float}

    """
    Dictionary of mutable statistics for the module.
    """
    stats::STARTStats

    # """
    # Runtime statistics for the module, implemented as a dictionary containing entries at the end of each training iteration.
    # These entries include the best-matching unit index and the activation and match values of the winning node.
    # """
    # stats::ARTStats
end

"""
DDVSTART constructor taking a [`CFG`](@ref) grammart and keyword arguments for its options.

# Arguments
- `grammar:CFG`: the grammar that the module works upon.
"""
function DDVSTART(grammar::CFG; kwargs...)
    opts = opts_DDVSTART(;kwargs...)
    DDVSTART(
        grammar,
        opts,
    )
end

"""
DDVSTART constructor taking a [`CFG`](@ref) grammart and [`opts_DDVSTART`](@ref) options struct.

# Arguments
- `grammar:CFG`: the grammar that the module works upon.
- `opts::opts_DDVSTART`: the options of
"""
function DDVSTART(
    grammar::CFG,
    opts::opts_DDVSTART,
)
    # Init the stats
    stats = gen_STARTStats()

    # Create the suboptions
    subopts = opts_START(
        rho=opts.rho_ub,
    )

    # Initialize the module
    DDVSTART(
        grammar,                # grammar
        opts,
        subopts,
        Vector{START}(),
        Vector{Int}(),
        0,
        0,
        Vector{Float}(),
        Vector{Float}(),
        stats,
    )
end

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
- `F2::START`: the DDVSTART START F2 node to compute the linkage method within.
"""

# Argument docstring for the F2 field, includes the argument header
const FIELD_DOCSTRING = """
# Arguments
- `field::RealVector`: the DDVSTART START F2 node field (F2.T or F2.M) to compute the linkage for.
"""

# Argument docstring for the activation flag
const ACTIVATION_DOCSTRING = """
- `activation::Bool`: flag to use the activation function. False uses the match function.
"""

"""
Computes the similarity of the selected linkage method.

# Arguments
- `method::Symbol`: the linkage method function name as a Julia Symbol.
- `F2::START`: the F2 module to compute the similarity for.
- `activation::Bool`: flag for if the computed similarity is the activation or match.
"""
function similarity(method::Symbol, F2::START, activation::Bool)
    # Handle :weighted usage
    if method === :weighted
        value = eval(method)(F2, activation)
    # Handle common usage
    else
        value = eval(method)(activation ? F2.T : F2.M)
    end

    # Return the simlarity metric
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
function weighted(F2::START, activation::Bool)
    if activation
        value = F2.T' * (F2.n_instance ./ sum(F2.n_instance))
    else
        value = F2.M' * (F2.n_instance ./ sum(F2.n_instance))
    end

    return value
end

"""
Create a new category in a DDVSTART module, initiated on [`SomeStatement`](@ref) and a corresponding integer label.

# Arguments
- `art::DDVSTART`: the [`DDVSTART`](@ref) module to append a new local F2 category to.
- `statement::SomeStatement`: the statement to initialize the new category on.
- `label::Integer`: the global label for the new category.
"""
function create_category!(art::DDVSTART, statement::SomeStatement, label::Integer)
    # Update the stats counters
    art.stats["n_categories"] += 1

    push!(art.labels, label)
    new_node = START(
        art.grammar,
        art.subopts,
    )
    train!(new_node, statement, y=label)
    push!(art.F2, new_node)
    return
end

"""
Trains a [`DDVSTART`](@ref) module on [`SomeStatement`](@ref) and an optional supervisory label.

# Arguments
- `art::DDVSTART`: the [`DDVSTART`](@ref) module to train.
- `statement::SomeStatement`: the statement sample to train upon.
- `y::Integer=0`: optional supervisory label for the sample.
"""
function train!(
    art::DDVSTART,
    statement::SomeStatement;
    y::Integer=0,
)
    # Flag for if the sample is supervised
    supervised = !iszero(y)

    # If this is the first sample, then fast commit
    if isempty(art.F2)
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
            activation_match!(art.F2[ix], statement)
            art.T[ix] = similarity(
                art.opts.similarity,
                art.F2[ix],
                true,
            )
        end

        # Sort by highest activation
        index = sortperm(art.T, rev=true)
        mismatch_flag = true
        for jx = 1:art.stats["n_categories"]
            # Get the best-matching unit
            bmu = index[jx]
            if art.T[bmu] >= art.opts.rho_lb
                # If supervised and the label differed, force mismatch
                if supervised && (art.labels[bmu] != y)
                    break
                end
                y_hat = art.labels[bmu]
                train!(art.F2[bmu], statement)
                # learn!(art, statement, bmu)
                # learn!(art.F2[bmu], statement, bmu)
                # art.stats["n_instance"][bmu] += 1
                # art.F2[bmu].stats["n_instance"][bmu] += 1
                mismatch_flag = false
                break
            end
        end

        # If we triggered a mismatch, add a node
        if mismatch_flag
            y_hat = supervised ? y : art.stats["n_categories"] + 1
            create_category!(art, statement, y_hat)
        end
    end

    # Return the training label
    return y_hat
end

"""
Classifies [`SomeStatement`](@ref) with the provided [`DDVSTART`](@ref) module with an optional flag to get the best-matching unit in the case of a complete mismatch.

# Arguments
- `art::DDVSTART`: the [`DDVSTART`](@ref) module to classify with.
- `statement::SomeStatment`: the sample as [`SomeStatment`](@ref) to classify.
- `get_bmu`: optional flag to get the best-matching unit in the case of complete mismatch.
"""
function classify(
    art::DDVSTART,
    statement::SomeStatement ;
    get_bmu::Bool=false,
)
    # accommodate_vector!(art.T, art.stats["n_categories"])
    # accommodate_vector!(art.M, art.stats["n_categories"])
    # for ix = 1:art.stats["n_categories"]
    #     art.T[ix] = activation(art.protonodes[ix], statement)
    # end

    # Compute the activations
    accommodate_vector!(art.T, art.stats["n_categories"])
    accommodate_vector!(art.M, art.stats["n_categories"])
    for ix = 1:art.stats["n_categories"]
        activation_match!(art.F2[ix], statement)
        art.T[ix] = similarity(
            art.opts.similarity,
            art.F2[ix],
            true,
        )
    end

    # Sort by highest activation
    index = sortperm(art.T, rev=true)

    # Default is mismatch
    mismatch_flag = true
    y_hat = -1
    for jx in 1:art.stats["n_categories"]
        bmu = index[jx]
        # Vigilance check - pass
        if art.T[bmu] >= art.opts.rho_lb
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
