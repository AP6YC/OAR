"""
    data_utils.jl

# Description
This file contains utilities for handling datasets and train/test splits for the `OAR` project.
"""

# -----------------------------------------------------------------------------
# STRUCTS
# -----------------------------------------------------------------------------

"""
Abstract supertype for train/test split datasets
"""
abstract type TTDataset end

"""
Abstract supertype for datasets that have vectored elements.
"""
abstract type VectoredDataset <: TTDataset end

"""
Train/test split dataset.

This struct contains a standardized train/test split of real-valued vectors of samples arranged in a matrix and mapping to integered labels.
"""
struct DataSplit <: TTDataset
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
Generic train/test split dataset.

This struct contains a standardized train/test split of a vector of samples mapping to integered labels.
"""
struct DataSplitGeneric{T, U} <: VectoredDataset
    """
    The training data as a vector of samples.
    """
    train_x::T

    """
    The testing data as a vector of samples.
    """
    test_x::T

    """
    The training labels as a vector of integer labels: `(n_samples,)`.
    """
    train_y::U

    """
    The testing labels as a vector of integer labels: `(n_samples,)`
    """
    test_y::U
end

"""
Vectored train/test split of arbitrary feature types.

This struct contains a standardized train/test split of vectors of vectored samples that map to labels.
"""
struct VectoredDataSplit{T, M} <: VectoredDataset
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
Internal function for handling how to show [`OAR.TTDataset`](@ref)s.
"""
function _show_datasplit(io::IO, data::TTDataset, dim::Int)
    # Get the number of samples in each split
    n_train = length(data.train_y)
    n_test = length(data.test_y)

    # Print
    print(io, "$(typeof(data)): dim=$(dim), n_train=$(n_train), n_test=$(n_test):\n")
    print(io, "train_x: $(size(data.train_x)) $(typeof(data.train_x))\n")
    print(io, "test_x: $(size(data.test_x)) $(typeof(data.test_x))\n")
    print(io, "train_y: $(size(data.train_y)) $(typeof(data.train_y))\n")
    print(io, "test_y: $(size(data.test_y)) $(typeof(data.test_y))\n")

    # Empty return
    return
end

"""
Overload of the show function for [`OAR.DataSplit`](@ref).

# Arguments
- `io::IO`: the current IO stream.
- `data::DataSplit`: the [`OAR.DataSplit`](@ref) to print/display.
"""
function Base.show(io::IO, data::DataSplit)
    # Get the feature dimension for datasplits
    dim = size(data.train_x)[1]

    # Show the common attributes of the datasplit
    _show_datasplit(io, data, dim)

    # Empty return
    return
end

"""
Overload of the show function for [`OAR.VectoredDataSplit`](@ref).

# Arguments
- `io::IO`: the current IO stream.
- `data::VectoredDataSplit`: the [`OAR.VectoredDataSplit`](@ref) to print/display.
"""
function Base.show(io::IO, data::VectoredDataSplit)
    # Get the feature dimension of vectored datasplits
    dim = length(data.train_x[1])

    # Show the common attributes of the datasplit
    _show_datasplit(io, data, dim)

    # Empty return
    return
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
Wrapper for downloading and/or loading a dataset from MLDatasets.

# Arguments
- `mldataest::Symbol`: the symbolic name of the MLDataset to download/load.
- `download_local::Bool=false`: default false, flag to download the dataset to the local cache directory.
"""
function get_mldata(mldataset::Symbol, download_local::Bool=false)
    # Load the Iris dataset from MLDatasets
    if download_local
        local_dir = OAR.data_dir("downloads")
        # iris = Iris(dir=local_dir)
        data = eval(mldataset)(dir=local_dir)
    else
        # iris = Iris()
        data = eval(mldataset)()
    end

    return data
end

function DataSplit(
    features,
    labels;
    p::Float=0.7,
    shuffle::Bool=true,
)
    if shuffle
        ls, ll = shuffleobs((features, labels))
    else
        ls, ll = (features, labels)
    end

    # Create a train/test split
    (X_train, y_train), (X_test, y_test) = splitobs((ls, ll); at=p)


    # Create and return a single container for this train/test split
    return DataSplit(
        X_train,
        X_test,
        y_train,
        y_test,
    )
end

"""
Loads the Iris dataset and returns a [`OAR.DataSplit`](@ref).

# Arguments
- `download_local::Bool=false`: optional (default false), to download the Iris dataset to the local datadir.
"""
function tt_real(mldataset::Symbol; download_local::Bool=false)
    # Load the dataset from MLDatasets
    data = get_mldata(mldataset, download_local)

    # Manipulate the features and labels into a matrix of features and a vector of labels
    features = Matrix(data.features)'
    if eltype(data.targets[:, 1]) <: AbstractString
        labels = vec(Matrix{String}(data.targets))
        # labels = convertlabel(LabelEnc.Indices{Int}, labels)
        labels = OAR.integer_encoding(labels)
    else
        labels = data.targets[:, 1]
    end

    return DataSplit(features, labels)
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

    # bnf = OAR.DescretizedCFG(OAR.quick_statement(labels), bins=bins)
    # statements = Vector{Vector{GSymbol{String}}}()
    statements = Statements{String}()

    # Iterate over every sample
    for jx = 1:n_samples
        # Create an empty vector for the statement
        local_st = Vector{GSymbol{String}}()
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
    vs_symbs = VectoredDataSplit{GSymbol{String}, Int}(
        st_train,
        st_test,
        data.train_y,
        data.test_y,
    )

    bnf = OAR.DescretizedCFG(labels, bins=bins)

    # Return the list of samples as a vectored datasplit
    return vs_symbs, bnf
end

"""
Quickly generates a [`OAR.VectoredDataSplit`] of the symbolic Iris dataset.

# Arguments
- `bins::Int=10`: optional, the number of symbols to descretize the real-valued data to.
- `download_local::Bool=false`: optional (default false), to download the Iris dataset to the local datadir.
"""
function symbolic_iris(;bins::Int=10, download_local::Bool=false)
    # Load the Iris DataSplit
    # data = OAR.iris_tt_real(download_local=download_local)
    data = OAR.tt_real(:Iris, download_local=download_local)

    # Declare the names for the nonterminal symbols
    N = [
        "SL", "SW", "PL", "PW",
    ]

    # Create the symbolic version of the data
    statements, grammar = OAR.real_to_symb(data, N, bins=bins)

    # Return the statements and grammar together
    return statements, grammar
end

"""
Quickly generates a [`OAR.VectoredDataSplit`] of the symbolic Wine dataset.

# Arguments
- `bins::Int=10`: optional, the number of symbols to descretize the real-valued data to.
- `download_local::Bool=false`: optional (default false), to download the Wine dataset to the local datadir.
"""
function symbolic_wine(;bins::Int=10, download_local::Bool=false)
    # Load the Iris DataSplit
    data = OAR.tt_real(:Wine, download_local=download_local)

    # Declare the names for the nonterminal symbols
    # N = names(data.features)
    N = [
        "Alcohol"
        "Malic.acid"
        "Ash"
        "Acl"
        "Mg"
        "Phenols"
        "Flavanoids"
        "Nonflavanoid.phenols"
        "Proanth"
        "Color.int"
        "Hue"
        "OD"
        "Proline"
    ]

    # Create the symbolic version of the data
    statements, grammar = OAR.real_to_symb(data, N, bins=bins)

    # Return the statements and grammar together
    return statements, grammar
end

"""
Convert a dataframe into a ordered vector of nonterminals, simple statements in those positions, and their labels.

# Arguments
- `df::DataFrame`: the dataframe containing rows corresponding to simple statements.
- `label::Symbol=:class`: the symbolic name of the column corresponding to the target labels.
"""
function df_to_statements(df::DataFrame, label::Symbol=:class, ignores::Vector{Symbol}=Vector{Symbol}(); stringify::Bool=false)
    # clean_df = df[:, Not(label)]
    clean_df = df[:, Not(label, ignores...)]
    nts = names(clean_df)
    ordered_nonterminals = Vector{GSymbol{String}}()
    for name in nts
        push!(ordered_nonterminals, GSymbol(String(name), false))
    end

    statements = Statements{String}()
    for row in eachrow(clean_df)
        local_statement = Statement{String}()
        # for el in row
        for name in nts
            el = row[name]
            # @info el
            if stringify
                local_string = String(name * string(el))
            else
                local_string = String(el)
            end
            push!(local_statement, GSymbol(local_string, true))
        end
        push!(statements, local_statement)
    end

    labels = df[:, label]

    return ordered_nonterminals, statements, labels
end

"""
Internal implementation of integer encoding.

# Arguments
- `vec`: some iterable collection containing unique elements to turn into a vector of integers.
"""
function integer_encoding(vec)
    n = length(vec)
    uniques = unique(vec)
    new_vec = zeros(Int, n)
    # for un in uniques
    for ix in eachindex(uniques)
        new_vec[findall(x->x==uniques[ix], vec)] .= ix
    end
    return new_vec
end

"""
Constructs a context-free grammar from a dataframe.

# Arguments
- `df::DataFrame`: the dataframe to turn into a [`OAR.CFG`](@ref) grammar, statements, and their labels.
- `label::Symbol=:class`: the symbolic name of the column of the DataFrame belonging to the target labels.
"""
function CFG_from_df(df::DataFrame, label::Symbol=:class, ignores::Vector{Symbol} = Vector{Symbol}(); stringify::Bool=false)
    # Declare that the SPO CFG grammar has only the following nonterminals
    ordered_nonterminals, statements, labels = df_to_statements(df, label, ignores, stringify=stringify)

    # Create a set of the ordered nonterminals
    N = Set(ordered_nonterminals)
    # Gather a set of the terminals from all of the statements
    Term = get_terminals(statements)
    # Generate the production rules from the statements and their corresponding
    # ordered nonterminal symbols
    P = get_production_rules(ordered_nonterminals, statements)

    # Construct the CFG grammar
    grammar = CFG(
        N,
        Term,
        ordered_nonterminals,
        P,
    )

    # Encode the column of strings into integer labels
    int_labels = integer_encoding(labels)

    # Return the constructed CFG grammar
    return grammar, statements, int_labels
end

function DataSplitGeneric(
    statements,
    labels;
    p::Float=0.7,
    shuffle::Bool=true,
)

    if shuffle
        ls, ll = shuffleobs((statements, labels))
    else
        ls, ll = (statements, labels)
    end

    # Create a train/test split
    (X_train, y_train), (X_test, y_test) = splitobs((ls, ll); at=p)

    # Create a container for the train/test split
    return DataSplitGeneric(
        X_train,
        X_test,
        y_train,
        y_test,
    )
end

"""
Generates a [`OAR.DataSplitGeneric`](@ref) and [`OAR.CFG`](@ref) grammart from the Mushroom dataset.

# Arguments
- `filename::AbstractString=data_dir("mushroom", "mushrooms.csv")`: the location of the file to load with a default value.
"""
function symbolic_mushroom(filename::AbstractString=data_dir("mushroom", "mushrooms.csv"))
    # Load the data and cast to a dataframe
    # filename = data_dir("mushroom", "mushrooms.csv")
    df = DataFrame(CSV.File(filename))

    # Create a grammar, set of statements, and target labels from the dataframe
    grammar, statements, labels = CFG_from_df(df, :class)

    # Create a container for the train/test split
    data = DataSplitGeneric(statements, labels)

    # Return the statements and grammar together
    return data, grammar
end

"""
Generates a [`OAR.DataSplitGeneric`](@ref) and [`OAR.CFG`](@ref) grammart from the Lung Cancer dataset.

# Arguments
- `filename::AbstractString=data_dir("lung-cancer", "lung-cancer.csv")`: the location of the file to load with a default value.
"""
function symbolic_lung_cancer(filename::AbstractString=data_dir("lung-cancer", "lung-cancer.csv"))
    # Load the data and cast to a dataframe
    # filename = data_dir("mushroom", "mushrooms.csv")
    df = DataFrame(CSV.File(filename))

    # Create a grammar, set of statements, and target labels from the dataframe
    grammar, statements, labels = CFG_from_df(df, :Level, [:index, :PatientId], stringify=true)

    # Create a container for the train/test split
    data = DataSplitGeneric(statements, labels)

    # Return the statements and grammar together
    return data, grammar
end

"""
Vector of alphabetical letters as Strings for discretized feature labels.
"""
const letter_vec = string.(collect('A':'Z'))

"""
Generates a [`OAR.DataSplitGeneric`](@ref) and [`OAR.CFG`](@ref) grammart from the provided CSV dataset.

# Arguments
- `filename::AbstractString=data_dir("mushroom", "mushrooms.csv")`: the location of the file to load with a default value.
"""
function symbolic_dataset(filename::AbstractString, bins::Int=10)
    # Load the data
    data = readdlm(filename, ',', header=false)

    n_features = size(data)[2] - 1

    # Declare the names for the nonterminal symbols
    N = letter_vec[1:n_features]

    # Get the features and labels
    features = data[:, 1:n_features]'
    labels = Vector{Int}(data[:, end])

    # Create a DataSplit
    ds = DataSplit(features, labels)

    # Create the symbolic version of the data
    statements, grammar = OAR.real_to_symb(ds, N, bins=bins)

    # Return the statements and grammar
    return statements, grammar
end
