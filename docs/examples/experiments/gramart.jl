# ---
# title: START
# id: gramart
# date: 2023-5-15
# cover: ../assets/grammar.png
# author: "[Sasha Petrenko](https://github.com/AP6YC)"
# julia: 1.9
# description: This demo demonstrates how to utilize a START module on a basic dataset.
# ---

# ## Overview

# This example demonstrates the usage of a START module.
# This module is tested on a modified symbolic Iris dataset as a proof of concept, but it is capable of working on arbitrary symbolic datasets.

# ## Setup

# First, we load some dependencies:

## Import the OAR project module
using OAR

# Next, we can load the Iris dataset in a modified symbolic form:

## All-in-one function
fs, bnf = OAR.symbolic_iris()

# We can finally initialize the START module using the grammar that we have describing the symbolic Iris dataset:

## Initialize the START module
gramart = OAR.START(bnf)

# ## Training

# Now that we have a START module, we should process the training dataset:

## Cluster the statements
for statement in fs.train_x
    OAR.train!(gramart, statement)
end

# In fact, we can also do a simple supervised version of the training if labels are available.
# Let's do that with another module:

## Initialize the START module
gramart_supervised = OAR.START(bnf)
## Set the vigilance low for generalization
gramart_supervised.opts.rho = 0.05
## Train in supervised mode
for ix in eachindex(fs.train_x)
    sample = fs.train_x[ix]
    label = fs.train_y[ix]
    OAR.train!(gramart_supervised, sample, y=label)
end

# ## Analysis

# Now let's see what's inside the first module:

## Inspect the module
@info "Number of categories: $(length(gramart.protonodes))"

# We can also see how the supervised training went by classifying the test data and computing the performance:

## Classification
y_hat = zeros(Int, length(fs.test_y))
for ix in eachindex(fs.test_x)
    sample = fs.test_x[ix]
    y_hat[ix] = OAR.classify(gramart_supervised, sample, get_bmu=true)
end

## Calculate performance
perf = OAR.AdaptiveResonance.performance(y_hat, fs.test_y)
@info "Supervised testing performance: $(perf)"
