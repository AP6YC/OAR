"""
    9_combined.jl

# Description
This script generates and save a table of the training and testing performances of the method on the Iris and Mushroom datasets.

# Attribution

## Citations
- Fisher, R. A.. (1988). Iris. UCI Machine Learning Repository. https://doi.org/10.24432/C56C76.
- Mushroom. (1987). UCI Machine Learning Repository. https://doi.org/10.24432/C5959T.

## BibTeX

### Iris
@misc{misc_iris_53,
    author       = {Fisher,R. A.},
    title        = {{Iris}},
    year         = {1988},
    howpublished = {UCI Machine Learning Repository},
    note         = {{DOI}: https://doi.org/10.24432/C56C76}
}

### Mushroom
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
exp_name = "3_combined.jl"

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "$(exp_top)/$(exp_name): train/test on the UCI Mushroom and Iris datasets."
)

# -----------------------------------------------------------------------------
# MUSHROOM DATASET
# -----------------------------------------------------------------------------

# All-in-one function
mushroom_data, mushroom_grammar = OAR.symbolic_mushroom()

# Initialize the START module
gramart = OAR.START(mushroom_grammar)

# Set the vigilance parameter and show
gramart.opts.rho = 0.05

# Process the statements
@showprogress for ix in eachindex(mushroom_data.train_x)
    statement = mushroom_data.train_x[ix]
    label = mushroom_data.train_y[ix]
    OAR.train!(gramart, statement, y=label)
end

# Classify
clusters = zeros(Int, length(mushroom_data.test_y))
@showprogress for ix in eachindex(mushroom_data.test_x)
    clusters[ix] = OAR.classify(gramart, mushroom_data.test_x[ix])
end

# Calculate testing performance
perf = OAR.AdaptiveResonance.performance(mushroom_data.test_y, clusters)

# Logging
@info "Final performance: $(perf)"
@info "n_categories: $(gramart.stats["n_categories"])"
# @info "n_instance: $(gramart.stats["n_instance"])"


# All-in-one function
iris_data, iris_grammmar = OAR.symbolic_iris()

# Initialize the START module
gramart = OAR.START(iris_grammmar)

# Set the vigilance parameter and show
# gramart.opts.rho = 0.15
gramart.opts.rho = 0.05

# Process the statements
@showprogress for ix in eachindex(iris_data.train_x)
    statement = iris_data.train_x[ix]
    label = iris_data.train_y[ix]
    OAR.train!(gramart, statement, y=label)
end

# See the statistics of the first protonode
# @info gramart.protonodes[1].stats

# Classify
clusters = zeros(Int, length(iris_data.test_y))
@showprogress for ix in eachindex(iris_data.test_x)
    clusters[ix] = OAR.classify(gramart, iris_data.test_x[ix])
end

# Calculate testing performance
perf = OAR.AdaptiveResonance.performance(iris_data.test_y, clusters)

# Logging
@info "Final performance: $(perf)"
@info "n_categories: $(gramart.stats["n_categories"])"
# @info "n_instance: $(gramart.stats["n_instance"])"


# df = DataFrame(F2 = n_F2, Total = n_categories)
# table = latexify(df, env=:table)
