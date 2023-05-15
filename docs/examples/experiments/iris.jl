# ---
# title: Iris Dataset
# id: iris
# date: 2023-5-15
# author: "[Sasha Petrenko](https://github.com/AP6YC)"
# julia: 1.8
# description: This demo provides a quick example of how to load the Iris dataset with existing Julia tools.
# ---

# ## Overview

# This example shows how the Iris dataset is loaded and used with existing Julia tools within the OAR project, which can be adapted for other Julia projects.
# Other scripts within this project utilize higher-level functions for loading, transforming, and splitting the data automatically, and this example shows how this is done at a low-level.

# ## Setup

# First, we load some dependencies:

## Multi-line using statements are permitted in Julia to gather all requirements and compile at once
using
    MLDatasets,         # Iris dataset
    MLDataUtils         # Data utilities, splitting, etc.


# We will download the Iris dataset for its small size and benchmark use for clustering algorithms.

iris = Iris()

# Next, we manipulate the features and labels into a matrix of features and a vector of labels

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
