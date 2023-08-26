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
exp_name = "6_lung_cancer.jl"

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
# fs, bnf = OAR.symbolic_lung_cancer()
filename = OAR.data_dir("data-package", "face.csv")
data, grammar = OAR.symbolic_dataset(filename)

# Initialize the GramART module with options
gramart = OAR.GramART(grammar,
    # rho = 0.6,
    rho = 0.3,
    rho_lb = 0.1,
    rho_ub = 0.3,
)

OAR.tt_serial(gramart, data)

# # Process the statements
# @showprogress for ix in eachindex(fs.train_x)
#     statement = fs.train_x[ix]
#     label = fs.train_y[ix]
#     OAR.train!(
#     # OAR.train_dv!(
#         gramart,
#         statement,
#         y=label,
#     )
# end

# # Classify
# clusters = zeros(Int, length(fs.test_y))
# @showprogress for ix in eachindex(fs.test_x)
#     clusters[ix] = OAR.classify(
#     # clusters[ix] = OAR.classify_dv(
#         gramart,
#         fs.test_x[ix],
#         get_bmu=true,
#     )
# end

# # Calculate testing performance
# perf = OAR.AdaptiveResonance.performance(fs.test_y, clusters)

# # Logging
# @info "Final performance: $(perf)"
# @info "n_categories: $(gramart.stats["n_categories"])"
# # @info "n_instance: $(gramart.stats["n_instance"])"
