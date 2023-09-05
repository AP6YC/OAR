"""
    6_lung_cancer.jl

# Description
This script shows how to use a START to cluster on the Lung Cancer dataset.

# Attribution

## Citations
- Ahmad AS, Mayya AM. A new tool to predict lung cancer based on risk factors. Heliyon. 2020 Feb 26;6(2):e03402. doi: 10.1016/j.heliyon.2020.e03402. PMID: 32140577; PMCID: PMC7044659.
- https://www.cell.com/heliyon/fulltext/S2405-8440(20)30247-4?_returnURL=https%3A%2F%2Flinkinghub.elsevier.com%2Fretrieve%2Fpii%2FS2405844020302474%3Fshowall%3Dtrue

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
exp_name = "6_lung_cancer.jl"

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
data, grammar = OAR.symbolic_lung_cancer()

# Initialize the START module with options
gramart = OAR.START(grammar,
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
