# Multi-line using statements are permitted in Julia to gather all requirements and compile at once
using
    MLDatasets,         # Iris dataset
    MLDataUtils         # Data utilities, splitting, etc.

iris = Iris()

features, labels = Matrix(iris.features)', vec(Matrix{String}(iris.targets))

labels = convertlabel(LabelEnc.Indices{Int}, labels)
unique(labels)

(X_train, y_train), (X_test, y_test) = stratifiedobs((features, labels))

N = [
    "SL", "SW", "PL", "PW",
]

bins = 10

bnf = OAR.DescretizedBNF(OAR.quick_symbolset(N), bins=bins)

statement = OAR.random_statement(bnf)

@info statement

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

