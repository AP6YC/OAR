"""
    2_mushroom.jl

# Description
This script shows how to use a GramART to cluster on the Mushroom dataset.

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

# All-in-one function
fs, bnf = OAR.symbolic_mushroom()

# Initialize the GramART module with options
gramart = OAR.GramART(bnf,
    rho = 0.1,
    rho_lb = 0.1,
    rho_ub = 0.3,
)

# Process the statements
@showprogress for ix in eachindex(fs.train_x)
    statement = fs.train_x[ix]
    label = fs.train_y[ix]
    # OAR.train!(
    OAR.train_dv!(
        gramart,
        statement,
        y=label,
    )
end

# Classify
clusters = zeros(Int, length(fs.test_y))
@showprogress for ix in eachindex(fs.test_x)
    # clusters[ix] = OAR.classify(
    clusters[ix] = OAR.classify_dv(
        gramart,
        fs.test_x[ix],
        get_bmu=true,
    )
end

# Calculate testing performance
perf = OAR.AdaptiveResonance.performance(fs.test_y, clusters)

# Logging
@info "Final performance: $(perf)"
@info "n_categories: $(gramart.stats["n_categories"])"
# @info "n_instance: $(gramart.stats["n_instance"])"
