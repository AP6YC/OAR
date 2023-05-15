using
    MLDatasets,         # Iris dataset
    MLDataUtils         # Data utilities, splitting, etc.

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

"""
Convenience constructor, turning a DataSplit into its vectored variant.
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
Loads the Iris dataset and returns a DataSplit.
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
# Arguments
- `data::DataSplit`: the [`OAR.DataSplit`](@ref) to convert to symbols.
- `labels::Vector{String}`: the labels corresponding to the non-terminal symbol names for the feature categories and their subsequent terminal variants.
"""
function real_to_symb(data::DataSplit, labels::Vector{String})


    return
end