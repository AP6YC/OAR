"""
    mushroom.jl

# Description
This script shows how to use a GramART to cluster on the Iris dataset.

# Attribution

## Citations
- Mushroom. (1987). UCI Machine Learning Repository. https://doi.org/10.24432/C5959T.

## BibTeX
@misc{misc_mushroom_73,
    title        = {{Mushroom}},
    year         = {1987},
    howpublished = {UCI Machine Learning Repository},
    note         = {{DOI}: https://doi.org/10.24432/C5959T}
}
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

# -----------------------------------------------------------------------------
# ADDITIONAL DEPENDENCIES
# -----------------------------------------------------------------------------

# using DataFrames
using ProgressMeter

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

exp_top = "1_baseline"
exp_name = "2_mushroom.jl"

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "$(exp_top)/$(exp_name): GramART for clustering the categorical UCI Mushroom dataset."
)

# -----------------------------------------------------------------------------
# MUSHROOM DATASET
# -----------------------------------------------------------------------------

fs, bnf = OAR.symbolic_mushroom()

# # All-in-one function
# fs, bnf = OAR.symbolic_iris()

# Initialize the GramART module
gramart = OAR.GramART(bnf)

# Set the vigilance parameter and show
gramart.opts.rho = 0.07
@info gramart

# Process the statements
# for statement in fs.train_x
@showprogress for statement in fs
    OAR.train!(gramart, statement)
end

# See the statistics of the first protonode
# @info gramart.protonodes[1].stats
@info gramart.protonodes
