# Multi-line using statements are permitted in Julia to gather all requirements and compile at once
using
    OAR,                # This project
    MLDatasets,         # Iris dataset
    MLDataUtils         # Data utilities, splitting, etc.

iris = Iris()

features, labels = Matrix(iris.features)', vec(Matrix{String}(iris.targets))

labels = convertlabel(LabelEnc.Indices{Int}, labels)
unique(labels)

(X_train, y_train), (X_test, y_test) = stratifiedobs((features, labels))

data = OAR.DataSplit(X_train, X_test, y_train, y_test)

data_vec = OAR.VectoredDataSplit(data)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

