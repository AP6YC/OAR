"""
    4_mushroom_dist.jl

# Description
This script shows how to use a START to cluster on the Mushroom dataset.

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
using Random
Random.seed!(1234)
using ProgressMeter

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

exp_top = "1_baseline"
exp_name = "4_mushroom_dist"

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "$(exp_top)/$(exp_name): START for clustering the categorical UCI Mushroom dataset."
)

# -----------------------------------------------------------------------------
# MUSHROOM DATASET
# -----------------------------------------------------------------------------

# All-in-one function
fs, bnf = OAR.symbolic_mushroom()

# Initialize the START module
gramart = OAR.START(bnf)

# Set the vigilance parameter and show
gramart.opts.rho = 0.05

# Process the statements
@showprogress for ix in eachindex(fs.train_x)
    statement = fs.train_x[ix]
    label = fs.train_y[ix]
    OAR.train!(gramart, statement, y=label)
end

# Classify
clusters = zeros(Int, length(fs.test_y))
@showprogress for ix in eachindex(fs.test_x)
    clusters[ix] = OAR.classify(gramart, fs.test_x[ix])
end

# Calculate testing performance
perf = OAR.AdaptiveResonance.performance(fs.test_y, clusters)

# Logging
@info "Final performance: $(perf)"
@info "n_categories: $(gramart.stats["n_categories"])"
# @info "n_instance: $(gramart.stats["n_instance"])"
