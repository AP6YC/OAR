# ---
# title: Clustering on Knowledge Graphs
# id: kg
# date: 2023-7-6
# cover: ../assets/node.png
# author: "[Sasha Petrenko](https://github.com/AP6YC)"
# julia: 1.9
# description: This demo demonstrates how to utilize a START module on knowledge graph dataset.
# ---

# ## Overview

# This script demonstrates the usage of a START module for analyzing biomedical data knowledge graphs.
# Though the `OAR` project contains multiple such knowledge graphs, the Charcot-Marie-Tooth (CMT) dataset is used as an example here with the procedure remaining the same with other datasets.

# ## Setup

# First, we load some dependencies:

## Import the OAR project module
using OAR

# Next, we must should point to the location of the dataset containing the preprocessed knowledge graph statements

## Location of the edge attributes file, formatted for Lerch parsing
edge_file = joinpath("..", "assets", "edge_attributes_lerche.txt")

# Load the KG statements
statements = OAR.get_kg_statements(edge_file)

# Generate a simple subject-predicate-object grammar from the statements
grammar = OAR.SPOCFG(statements)

# Initialize the START module
gramart = OAR.START(
    grammar,
    rho=0.05,
    terminated=false,
)

# ## Train

# Now we are ready to cluster the statements.
# We do this with the `train!` function without supervised labels, indicating that we are learning on the samples alone.

## Process the statements
for statement in statements
    OAR.train!(gramart, statement)
end

# ## Analysis

# We can see how the clustering went by inspecting how many clusters we generated:

@info "Number of categories: $(length(gramart.protonodes))"
