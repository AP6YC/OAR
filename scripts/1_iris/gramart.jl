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
# IRIS DATASET
# -----------------------------------------------------------------------------

# All-in-one function
fs, bnf = OAR.symbolic_iris()

# Initialize the GramART module
gramart = OAR.GramART(bnf)

@info gramart

# Process the statements
for statement in fs.train_x
    OAR.process_statement!(gramart, statement)
end
