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
# ADDITIONAL DEPENDENCIES
# -----------------------------------------------------------------------------

using Lerche

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "2_cmt/gramart.jl: GramART for clustering a Charcot-Marie."
)

# -----------------------------------------------------------------------------
# CMT DATASET
# -----------------------------------------------------------------------------



# # All-in-one function
# fs, bnf = OAR.symbolic_iris()

# # Initialize the GramART module
# gramart = OAR.GramART(bnf)
# gramart.opts.rho = 0.5
# @info gramart

# # Process the statements
# for statement in fs.train_x
#     # OAR.process_statement!(gramart, statement, 1)
#     OAR.train!(gramart, statement)
# end
# # s = fs.train_x[1]
# # OAR.train!(gramart, s)
