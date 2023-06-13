"""
    gramart.jl

# Description
This script shows how to use a GramART to cluster on the Iris dataset.
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using DrWatson
@quickactivate :OAR

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "1_iris/gramart.jl: GramART for clustering the real-valued Iris dataset."
)

# -----------------------------------------------------------------------------
# IRIS DATASET
# -----------------------------------------------------------------------------

# All-in-one function
fs, bnf = OAR.symbolic_iris()

# Initialize the GramART module
gramart = OAR.GramART(bnf)

# Initalize the first node of the module
# OAR.add_node!(gramart)

@info gramart
gramart.opts.rho = 0.5

# Process the statements
for statement in fs.train_x
    # OAR.process_statement!(gramart, statement, 1)
    OAR.train!(gramart, statement)
end
# s = fs.train_x[1]
# OAR.train!(gramart, s)

@info gramart.protonodes[1].stats
