# ---
# title: GramART
# id: gramart
# date: 2023-5-15
# cover: ../assets/grammar.png
# author: "[Sasha Petrenko](https://github.com/AP6YC)"
# julia: 1.9
# description: This demo demonstrates how to utilize a GramART module on a basic dataset.
# ---

# ## Overview

# This example demonstrates the usage of a GramART module.
# This module is tested on a modified symbolic Iris dataset as a proof of concept, but it is capable of working on arbitrary symbolic datasets.

# ## Setup

# First, we load some dependencies:

## Import the OAR project module
using OAR

# Next, we can load the Iris dataset in a modified symbolic form:

## All-in-one function
fs, bnf = OAR.symbolic_iris()

# We can finally initialize the GramART module using the grammar that we have describing the symbolic Iris dataset:

## Initialize the GramART module
gramart = OAR.GramART(bnf)

## Initalize the first node of the module
OAR.add_node!(gramart)

# ## Training

# Now that we have a GramART module, we should process the training dataset:

## Process the statements
for statement in fs.train_x
    OAR.process_statement!(gramart, statement, 1)
end
