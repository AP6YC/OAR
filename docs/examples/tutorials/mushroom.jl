# ---
# title: Mushroom Dataset
# id: mushroom
# date: 2023-5-15
# cover: ../assets/mushroom.png
# author: "[Sasha Petrenko](https://github.com/AP6YC)"
# julia: 1.9
# description: This demo provides an example of how to do simple supervised training and testing on the UCI Mushroom dataset.
# ---

# ## Overview

# This example shows how to do supervised training and testing with START on the UCI Mushroom dataset.
# The Mushroom dataset is a purely categorical dataset where each feature has entries that are members of different discrete categories.
# Where this is normally a challenge for other machine learning models due to encoding schemes and considerations, START learns directly on the symbols of the dataset itself.
# Furthermore, START can use a simple supervised mode to map clusters to supervised categories to allow for training and performance testing.

# ## Setup

# First, we load some dependencies:

## Just load this project
using OAR

# ## Loading the Dataset

# The OAR project has an all-in-one function for loading the dataset, parsing it into statements, and inferring the resulting grammar:

## Point to the relative file location
filename = joinpath("..", "assets", "mushrooms.csv")
## All-in-one function
fs, bnf = OAR.symbolic_mushroom(filename)

# ## Intializing START

# We use the grammar and keyword arguments to set the options of the module during initialization:

## Initialize the module with options
art = OAR.GramART(bnf,
    rho = 0.6,
)

# We could also set or change the options after initialization with `art.opts.rho = 0.7`.

# ## Training and Testing

# To train the model we will use the training statements portion of the dataset that we loaded earlier along with their corresponding supervisory labels:

## Iterate over the training data
for ix in eachindex(fs.train_x)
    statement = fs.train_x[ix]
    label = fs.train_y[ix]
    OAR.train!(
        art,
        statement,
        y=label,
    )
end

# To test the model, we use the testing data and extract the prescribed label for each sample by the model:

## Create a container for the output labels
clusters = zeros(Int, length(fs.test_y))
## Iterate over the testing data
for ix in eachindex(fs.test_x)
    clusters[ix] = OAR.classify(
        art,
        fs.test_x[ix],
        get_bmu=true,
    )
end

# We can finally test the performance of the module by seeing the percentage of testing samples that are incorrectly labeled:

## Calculate testing performance
perf = OAR.AdaptiveResonance.performance(fs.test_y, clusters)

## Logging
@info "Final performance: $(perf)"
@info "n_categories: $(art.stats["n_categories"])"
