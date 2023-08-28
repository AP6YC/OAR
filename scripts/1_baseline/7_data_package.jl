"""
    7_data_package.jl

# Description
This script shows how to use a GramART to cluster on the Lung Cancer dataset.

# Attribution

## Citations
- Ilc, Nejc. (2013). Datasets package.

## BibTeX
@misc{dataset,
    author = {Ilc, Nejc},
    year = {2013},
    month = {06},
    pages = {},
    title = {Datasets package}
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
exp_name = "7_data_package.jl"

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

# Load the symbolic data and grammar
filename = OAR.data_dir(
    "data-package",
    # "face.csv",
    "iris.csv",
)
data, grammar = OAR.symbolic_dataset(filename)

# Initialize the GramART module with options
art = OAR.GramART(grammar,
    # rho = 0.6,
    rho = 0.3,
    rho_lb = 0.1,
    rho_ub = 0.3,
)

# OAR.tt_serial(art, data)

# Process the statements
@showprogress for ix in eachindex(data.train_x)
    statement = data.train_x[ix]
    label = data.train_y[ix]
    OAR.train!(
    # OAR.train_dv!(
        art,
        statement,
        y=label,
        # epochs=5,
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
@info "n_categories: $(art.stats["n_categories"])"

using Clustering

randindex
