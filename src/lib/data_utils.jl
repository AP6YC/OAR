"""
    data_utils.jl

# Description
This file contains utilities for handling datasets and train/test splits for the `OAR` project.
"""

# -----------------------------------------------------------------------------
# IMPORTS
# -----------------------------------------------------------------------------

using
    MLDatasets,         # Iris dataset
    MLDataUtils         # Data utilities, splitting, etc.

# -----------------------------------------------------------------------------
# STRUCTS
# -----------------------------------------------------------------------------

"""
Train/test split dataset.

This struct contains a standardized train/test split of real-valued vectors of samples arranged in a matrix and mapping to integered labels.
"""
struct DataSplit
    """
    The training data as a matrix of floating-point feature vectors: `(n_features, n_samples)`.
    """
    train_x::Matrix{Float}

    """
    The testing data as a matrix of floating-point feature vectors: `(n_features, n_samples)`.
    """
    test_x::Matrix{Float}

    """
    The training labels as a vector of integer labels: `(n_samples,)`.
    """
    train_y::Vector{Int}

    """
    The testing labels as a vector of integer labels: `(n_samples,)`
    """
    test_y::Vector{Int}
end

"""
Vectored train/test split of arbitrary feature types.

This struct contains a standardized train/test split of vectors of vectored samples that map to labels.
"""
struct VectoredDataSplit{T, M}
    """
    Training data as a vector of feature vectors of type `T`.
    """
    train_x::Vector{Vector{T}}

    """
    Testing data as a vector of feature vectors of type `T`.
    """
    test_x::Vector{Vector{T}}

    """
    Training labels as a vector of type `M`.
    """
    train_y::Vector{M}

    """
    Testing labels as a vector of type `M`.
    """
    test_y::Vector{M}
end

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

"""
Overload of the show function for [`OAR.DataSplit`](@ref).

# Arguments
- `io::IO`: the current IO stream.
- `data::DataSplit`: the `DataSplit` to print/display.
"""
function Base.show(io::IO, data::DataSplit)
    dim = size(data.train_x)[1]
    n_train = length(data.train_y)
    n_test = length(data.test_y)
    print(io, "$(typeof(data)): dim=$(dim), n_train=$(n_train), n_test=$(n_test):\n")
    print(io, "train_x: $(size(data.train_x)) $(typeof(data.train_x))\n")
    print(io, "test_x: $(size(data.test_x)) $(typeof(data.test_x))\n")
    print(io, "train_y: $(size(data.train_y)) $(typeof(data.train_y))\n")
    print(io, "test_y: $(size(data.test_y)) $(typeof(data.test_y))\n")
end

"""
Overload of the show function for [`OAR.VectoredDataSplit`](@ref).

# Arguments
- `io::IO`: the current IO stream.
- `data::VectoredDataSplit`: the [`OAR.VectoredDataSplit`](@ref) to print/display.
"""
function Base.show(io::IO, data::VectoredDataSplit)
    dim = length(data.train_x[1])
    n_train = length(data.train_y)
    n_test = length(data.test_y)
    print(io, "$(typeof(data)): dim=$(dim), n_train=$(n_train), n_test=$(n_test):\n")
    # print(io, "$(typeof(data)) with $(dim) features, $(n_train) training samples, and $(n_test) testing samples:\n")
    print(io, "train_x: $(size(data.train_x)) $(typeof(data.train_x))\n")
    print(io, "test_x: $(size(data.test_x)) $(typeof(data.test_x))\n")
    print(io, "train_y: $(size(data.train_y)) $(typeof(data.train_y))\n")
    print(io, "test_y: $(size(data.test_y)) $(typeof(data.test_y))\n")
end

"""
Convenience constructor, turning a [`OAR.DataSplit`](@ref) into its vectored variant.

# Arguments
- `data::DataSplit`: the original [`OAR.DataSplit`](@ref) to transform into a vectored data ssplit.
"""
function VectoredDataSplit(data::DataSplit)
    # Assume that the number of samples is the length of the label vectors
    n_train = length(data.train_y)
    n_test = length(data.test_y)

    # Create the vectored version with list comprehensions
    return VectoredDataSplit{Float, Int}(
        [data.train_x[:, ix] for ix in 1:n_train],
        [data.test_x[:, ix] for ix in 1:n_test],
        data.train_y,
        data.test_y,
    )
end

"""
Loads the Iris dataset and returns a [`OAR.DataSplit`](@ref).
"""
function iris_tt_real()
    # Load the Iris dataset from MLDatasets
    iris = Iris()
    # Manipulate the features and labels into a matrix of features and a vector of labels
    features, labels = Matrix(iris.features)', vec(Matrix{String}(iris.targets))
    # Because the MLDatasets package gives us Iris labels as strings, we will use the `MLDataUtils.convertlabel` method with the `MLLabelUtils.LabelEnc.Indices` type to get a list of integers representing each class:
    labels = convertlabel(LabelEnc.Indices{Int}, labels)
    unique(labels)
    # Next, we will create a train/test split with the `MLDataUtils.stratifiedobs` utility:
    (X_train, y_train), (X_test, y_test) = stratifiedobs((features, labels))

    # Create and return a single container for this train/test split
    return DataSplit(
        X_train,
        X_test,
        y_train,
        y_test,
    )
end

"""
Turns a [`OAR.DataSplit`](@ref) into a binned symbolic variant for use with GramART.

# Arguments
- `data::DataSplit`: the [`OAR.DataSplit`](@ref) to convert to symbols.
- `labels::Vector{String}`: the labels corresponding to the non-terminal symbol names for the feature categories and their subsequent terminal variants.
- `bins::Int=10`: optional, the number of symbols to descretize the real-valued data to.
"""
function real_to_symb(data::DataSplit, labels::Vector{String} ; bins::Int=10)
    # Capture the statistics of all of the data
    data_x = [data.train_x data.test_x]

    # Get the dimensionality of the data
    dim, n_samples = size(data_x)

    # Get the mins and maxes of the data for linear normalization
    mins = zeros(dim)
    maxs = zeros(dim)
    for ix = 1:dim
        mins[ix] = minimum(data_x[ix, :])
        maxs[ix] = maximum(data_x[ix, :])
    end

    # Create a destination for the normalized values
    x_ln = zeros(dim, n_samples)

    # Iterate over each dimension
    for ix = 1:dim
        # NOTE: minor adjustment of denominator here to make max values floor down
        # denominator = maxs[ix] - mins[ix] + eps()*10
        denominator = maxs[ix] - mins[ix]
        if denominator != 0
            # If the denominator is not zero, normalize
            x_ln[ix, :] = (data_x[ix, :] .- mins[ix]) ./ denominator
        else
            # Otherwise, the feature is zeroed because it contains no useful information
            x_ln[ix, :] = zeros(length(x_ln[ix, :]))
        end
    end

    # Bin and get the index for each datum
    symb_ind = zeros(Int, dim, n_samples)
    for ix = 1:dim
        for jx = 1:n_samples
            # Get an floored integer index
            local_ind = Int(floor(x_ln[ix, jx] * bins)) + 1
            # Correction for if we have a max value so that it is binned one down
            if local_ind > bins
                local_ind = Int(bins)
            end
            symb_ind[ix, jx] = local_ind
        end
    end

    # bnf = OAR.DescretizedBNF(OAR.quick_statement(labels), bins=bins)
    statements = Vector{Vector{GSymbol}}()

    # Iterate over every sample
    for jx = 1:n_samples
        # Create an empty vector for the statement
        local_st = Vector{GSymbol}()
        for ix = 1:dim
            # Get the symbol for the feature dimension
            label = GSymbol{String}(labels[ix], true)
            # TODO: this manually creates the symbol, but should be grabbed from the grammar
            #   that would look like this (once a vectored grammar with indexing is implemented):
            #   local_symb = bnf.T[label][symb_ind[ix, jx]]
            local_symb = join_gsymbol(label, symb_ind[ix, jx])
            # Add the symbol to the statement
            push!(local_st, local_symb)
        end
        # Add the statement to the list
        push!(statements, local_st)
    end

    # Recreate the split
    n_train = length(data.train_y)
    st_train = statements[1:n_train]
    st_test = statements[n_train + 1:end]

    # Create the split struct
    vs_symbs = VectoredDataSplit{GSymbol, Int}(
        st_train,
        st_test,
        data.train_y,
        data.test_y,
    )

    # Return the list of samples as a vectored datasplit
    return vs_symbs
end

"""
Quickly generates a [`OAR.VectoredDataSplit`] of the symbolic Iris dataset.

# Arguments
- `bins::Int=10`: optional, the number of symbols to descretize the real-valued data to.
"""
function symbolic_iris(;bins::Int=10)
    # Load the Iris DataSplit
    data = OAR.iris_tt_real()

    # Declare the names for the nonterminal symbols
    N = [
        "SL", "SW", "PL", "PW",
    ]

    # Create the symbolic version of the data
    statements = OAR.real_to_symb(data, N, bins=bins)

    return statements
end
