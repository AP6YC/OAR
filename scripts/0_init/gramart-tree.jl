"""
    gramart.jl

# Description
This script is used in the final development of GramART.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

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
