
using DrWatson
@quickactivate :OAR

using
    MLDatasets,        # Iris dataset
    MLDataUtils


# We will download the Iris dataset for its small size and benchmark use for clustering algorithms.
iris = Iris()
# Manipulate the features and labels into a matrix of features and a vector of labels
features, labels = Matrix(iris.features)', vec(Matrix{String}(iris.targets))
# Because the MLDatasets package gives us Iris labels as strings, we will use the `MLDataUtils.convertlabel` method with the `MLLabelUtils.LabelEnc.Indices` type to get a list of integers representing each class:
labels = convertlabel(LabelEnc.Indices{Int}, labels)
unique(labels)
# Next, we will create a train/test split with the `MLDataUtils.stratifiedobs` utility:
(X_train, y_train), (X_test, y_test) = stratifiedobs((features, labels))

# Create a discretized symbolic version of the IRIS dataset
N = [
    "SL", "SW", "PL", "PW",
]

bins = 10

# bnf = OAR.DescretizedBNF(N)
bnf = OAR.DescretizedBNF(OAR.quick_symbolset(N), bins=bins)

statement = OAR.random_statement(bnf)

@info statement
