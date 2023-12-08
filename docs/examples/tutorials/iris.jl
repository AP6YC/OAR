# ---
# title: Iris Dataset
# id: iris
# date: 2023-5-15
# cover: ../assets/iris.png
# author: "[Sasha Petrenko](https://github.com/AP6YC)"
# julia: 1.9
# description: This demo provides a quick example of how to load the Iris dataset with existing Julia tools.
# ---

# ## Overview

# This example shows how the Iris dataset is loaded and used with existing Julia tools within the OAR project, which can be adapted for other Julia projects.
# Other scripts within this project utilize higher-level functions for loading, transforming, and splitting the data automatically, and this example shows how this is done at a low-level.

# ## Setup

# First, we load some dependencies:

## Multi-line using statements are permitted in Julia to gather all requirements and compile at once
using
    OAR,                # This project
    MLDatasets,         # Iris dataset
    MLUtils             # Data utilities, splitting, etc.

# ## Loading the Dataset

# We will download the Iris dataset for its small size and benchmark use for clustering algorithms.

iris = Iris()

# Next, we manipulate the features and labels into a matrix of features and a vector of labels

features, labels = Matrix(iris.features)', vec(Matrix{String}(iris.targets))

# Because the MLDatasets package gives us Iris labels as strings, we need to get a list of integers representing each class:

labels = OAR.integer_encoding(labels)
unique(labels)

# Next, we will create a train/test split:

(X_train, y_train), (X_test, y_test) = splitobs((features, labels), at=0.8)

# We now have a train/test split of the features and targets for the Iris dataset.
# This project also defines some low-level data utilities for more easily passing around and transforming this data, so we often see this train/test split as a combined `DataSplit` struct:

data = OAR.DataSplit(X_train, X_test, y_train, y_test)

# We can also turn this `DataSplit` into a vectored variant (where the features are arranged as a vector of samples rather than combined into a matrix like in the `DataSplit`):

data_vec = OAR.VectoredDataSplit(data)
