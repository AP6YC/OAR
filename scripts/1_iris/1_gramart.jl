"""
    gramart.jl

# Description
This script shows how to use a GramART to cluster on the Iris dataset.
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

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

# Set the vigilance parameter and show
gramart.opts.rho = 0.5
@info gramart

# Process the statements
for statement in fs.train_x
    OAR.train!(gramart, statement)
end

# See the statistics fo the first protonode
@info gramart.protonodes[1].stats
