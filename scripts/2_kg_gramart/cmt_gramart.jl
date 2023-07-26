"""
    gramart.jl

# Description
This script shows how to use a GramART to cluster on the Iris dataset.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

# -----------------------------------------------------------------------------
# ADDITIONAL DEPENDENCIES
# -----------------------------------------------------------------------------

using ProgressMeter
# using DelimitedFiles
using DataFrames
using CSV

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

# Location of the edge attributes file, formatted for Lerch parsing
edge_file = OAR.results_dir("2_kg_gramart", "cmt", "edge_attributes_lerche.txt")

# Output CSV file
output_file = OAR.results_dir("2_kg_gramart", "cmt", "cmt-clusters.csv")

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "2_kg/gramart.jl: GramART for clustering a disease knowledge graph."
)

# -----------------------------------------------------------------------------
# CMT DATASET
# -----------------------------------------------------------------------------

# Load the CMT statements
statements = OAR.get_cmt_statements(edge_file)

# Generate a simple subject-predicate-object grammar from the statements
grammar = OAR.SPOCFG(statements)

# Initialize the GramART module
gramart = OAR.GramART(
    grammar,
    rho=0.1,    # ~12GB
    terminated=false,
)
@info gramart

# Process the statements
@showprogress for statement in statements
    OAR.train!(gramart, statement)
end

# Save the statements and their corresponding clusters to a CSV
df = DataFrame(
    subject = String[],
    predicate = String[],
    object = String[],
    cluster = Int[],
)

# Classify and push each statement back into a CSV
@showprogress for statement in statements
    cluster = OAR.classify(gramart, statement, get_bmu=true)
    new_element = [
        statement[1].data,
        statement[2].data,
        statement[3].data,
        cluster,
    ]
    push!(df, new_element)
end

# Save the clustered statements to a CSV file
CSV.write(output_file, df)
