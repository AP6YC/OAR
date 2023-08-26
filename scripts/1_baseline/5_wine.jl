"""
    5_wine.jl

# Description
START on the Wine dataset.
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

# -----------------------------------------------------------------------------
# ADDITIONAL DEPENDENCIES
# -----------------------------------------------------------------------------

using Random
Random.seed!(1234)
using ProgressMeter

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

exp_top = "1_baseline"
exp_name = "1_iris.jl"

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "$(exp_top)/$(exp_name): GramART for clustering the real-valued UCI Iris dataset."
)

# -----------------------------------------------------------------------------
# WINE DATASET
# -----------------------------------------------------------------------------

# All-in-one function
# data, grammmar = OAR.symbolic_iris()
data, grammmar = OAR.symbolic_wine()

# Initialize the GramART module with options
gramart = OAR.GramART(
    grammmar,
    rho = 0.15,
    rho_lb = 0.1,
    rho_ub = 0.25,
)

# Process the statements
@showprogress for ix in eachindex(data.train_x)
    statement = data.train_x[ix]
    label = data.train_y[ix]
    # OAR.train!(gramart, statement, y=label)
    OAR.train_dv!(gramart, statement, y=label)
end

# See the statistics of the first protonode
# @info gramart.protonodes[1].stats

# Classify
clusters = zeros(Int, length(data.test_y))
@showprogress for ix in eachindex(data.test_x)
    # clusters[ix] = OAR.classify(gramart, data.test_x[ix], get_bmu=true)
    clusters[ix] = OAR.classify_dv(gramart, data.test_x[ix], get_bmu=true)
end

# Calculate testing performance
perf = OAR.AdaptiveResonance.performance(data.test_y, clusters)

# Logging
@info "Final performance: $(perf)"
@info "n_categories: $(gramart.stats["n_categories"])"
# @info "n_instance: $(gramart.stats["n_instance"])"
