using
    MLDatasets,        # Iris dataset
    MLDataUtils


struct DataSplit
    train_x::Matrix{Float}
    test_x::Matrix{Float}
    train_y::Vector{Int}
    test_y::Vector{Int}
end

function iris_tt_real()
    # We will download the Iris dataset for its small size and benchmark use for clustering algorithms.
    iris = Iris()
    # Manipulate the features and labels into a matrix of features and a vector of labels
    features, labels = Matrix(iris.features)', vec(Matrix{String}(iris.targets))
    # Because the MLDatasets package gives us Iris labels as strings, we will use the `MLDataUtils.convertlabel` method with the `MLLabelUtils.LabelEnc.Indices` type to get a list of integers representing each class:
    labels = convertlabel(LabelEnc.Indices{Int}, labels)
    unique(labels)
    # Next, we will create a train/test split with the `MLDataUtils.stratifiedobs` utility:
    (X_train, y_train), (X_test, y_test) = stratifiedobs((features, labels))

    return DataSplit(
        X_train,
        X_test,
        y_train,
        y_test,
    )
end

