# Multi-line using statements are permitted in Julia to gather all requirements and compile at once
using
    OAR,                # This project
    MLDatasets,         # Iris dataset
    MLUtils             # Data utilities, splitting, etc.

iris = Iris()

features, labels = Matrix(iris.features)', vec(Matrix{String}(iris.targets))

labels = OAR.integer_encoding(labels)
unique(labels)

(X_train, y_train), (X_test, y_test) = splitobs((features, labels), at=0.8)

data = OAR.DataSplit(X_train, X_test, y_train, y_test)

data_vec = OAR.VectoredDataSplit(data)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
