"""
    1_iris.jl

# Description
This script shows how to use a GramART to cluster on the Iris dataset.

# Attribution

## Citations
- Fisher,R. A.. (1988). Iris. UCI Machine Learning Repository. https://doi.org/10.24432/C56C76.

## BibTeX
@misc{misc_iris_53,
    author       = {Fisher,R. A.},
    title        = {{Iris}},
    year         = {1988},
    howpublished = {UCI Machine Learning Repository},
    note         = {{DOI}: https://doi.org/10.24432/C56C76}
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

using Random
Random.seed!(1234)

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
# IRIS DATASET
# -----------------------------------------------------------------------------

# All-in-one function
fs, bnf = OAR.symbolic_iris()

# Initialize the GramART module
gramart = OAR.GramART(bnf)

# Set the vigilance parameter and show
gramart.opts.rho = 0.15
@info gramart

# Process the statements
for statement in fs.train_x
    OAR.train!(gramart, statement)
end

# See the statistics fo the first protonode
@info gramart.protonodes[1].stats

clusters = zeros(Int, length(fs.test_y))
# for statement in fs.test_x
for ix in eachindex(fs.test_x)
    clusters[ix] = OAR.classify(gramart, fs.test_x[ix])
end

perf = OAR.AdaptiveResonance.performance(fs.test_y, clusters)

@info perf
