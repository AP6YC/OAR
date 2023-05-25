"""
    gramart.jl

# Description
This script is used in the development of GramART.
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
n_positions = length(bnf.S)
for statement in fs.train_x
    OAR.process_statement!(gramart, statement)
end
