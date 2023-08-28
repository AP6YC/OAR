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
using Clustering

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
data, grammar = OAR.symbolic_mushroom()

# Initialize the GramART module with options
art = OAR.GramART(grammar,
    # rho = 0.6,
    rho = 0.1,
    rho_lb = 0.1,
    rho_ub = 0.3,
)

# Process the statements
@showprogress for ix in eachindex(data.train_x)
    statement = data.train_x[ix]
    label = data.train_y[ix]
    OAR.train!(
    # OAR.train_dv!(
        art,
        statement,
        y=label,
    )
end

# Classify
clusters = zeros(Int, length(data.test_y))
@showprogress for ix in eachindex(data.test_x)
    clusters[ix] = OAR.classify(
    # clusters[ix] = OAR.classify_dv(
        art,
        data.test_x[ix],
        get_bmu=true,
    )
end

# Calculate testing performance
perf = OAR.AdaptiveResonance.performance(data.test_y, clusters)

# Logging
@info "Final performance: $(perf)"
@info "n_categories: $(gramart.stats["n_categories"])"
# @info "n_instance: $(gramart.stats["n_instance"])"


# Clustering

# Initialize the GramART module with options
art = OAR.GramART(grammar,
    # rho = 0.6,
    rho = 0.1,
    rho_lb = 0.1,
    rho_ub = 0.3,
)

y_hats = OAR.cluster_serial(art, vcat(data.train_x, data.test_x))
ys = vcat(data.train_y, data.test_y)

ri = randindex(y_hats, ys)

@info ri
@info ri[1]

# ri = OAR.cluster_rand_data(art, data)

# @info ri
# @info ri[1]
