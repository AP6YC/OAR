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

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

# Location of the edge attributes file, formatted for Lerch parsing
edge_file = OAR.results_dir("2_kg_gramart", "cmt", "edge_attributes_lerche.txt")

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "2_cmt/gramart.jl: GramART for clustering a Charcot-Marie."
)

# -----------------------------------------------------------------------------
# KNOWLEDGE GRAPH DATASET
# -----------------------------------------------------------------------------

# Load the KG statements
statements = OAR.get_kg_statements(edge_file)

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
