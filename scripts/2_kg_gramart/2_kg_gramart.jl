"""
    2_kg_gramart.jl

# Description
This script uses START to cluster disease knowledge graph statements.

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
using DataFrames

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

exp_top = "2_kg_gramart"
exp_name = "2_kg_gramart.jl"

# Location of the edge attributes file, formatted for Lerch parsing
edge_file = OAR.results_dir(exp_top, "cmt", "edge_attributes_lerche.txt")

# Output CSV file
output_file = OAR.results_dir(exp_top, "cmt", "cmt-clusters.csv")

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "$(exp_top)/$(exp_name): START for clustering a disease knowledge graph."
)

# -----------------------------------------------------------------------------
# EXPERIMENT
# -----------------------------------------------------------------------------

# Load the KG statements
statements = OAR.get_kg_statements(edge_file)

# Generate a simple subject-predicate-object grammar from the statements
grammar = OAR.SPOCFG(statements)

# Initialize the START module
gramart = OAR.START(
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
OAR.save_dataframe(df, output_file)
