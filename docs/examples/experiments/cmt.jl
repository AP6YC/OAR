# ---
# title: CMT and GramART
# id: cmt-gramart
# date: 2023-7-6
# cover: ../assets/grammar.png
# author: "[Sasha Petrenko](https://github.com/AP6YC)"
# julia: 1.9
# description: This demo demonstrates how to utilize a GramART module on a basic dataset.
# ---

# ## Overview

# This script demonstrates the usage of a GramART module for analyzing biomedical data knowledge graphs.
# Though the `OAR` project contains multiple such knowledge graphs, the Charcot-Marie-Tooth (CMT) dataset is used as an example here with the procedure remaining the same with other datasets.

# ## Setup

# First, we load some dependencies:

## Import the OAR project module
using OAR

# Next, we must should point to the location of the dataset containing the prepro

## Location of the edge attributes file, formatted for Lerch parsing
edge_file = joinpath("..", "assets", "edge_attributes_lerche.txt")

# Load the CMT statements
statements = OAR.get_cmt_statements(edge_file)

# Generate a simple subject-predicate-object grammar from the statements
grammar = OAR.SPOCFG(statements)

# Initialize the GramART module
gramart = OAR.GramART(
    grammar,
    rho=0.1,
    terminated=false,
)

# Process the statements
for statement in statements
    OAR.train!(gramart, statement)
end
