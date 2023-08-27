"""
    10_census.jl

# Description
START on the UCI 1990 census dataset.

# Attribution

## Citations
- Meek,Meek, Thiesson,Thiesson, and Heckerman,Heckerman. US Census Data (1990). UCI Machine Learning Repository. https://doi.org/10.24432/C5VP42.

## BibTeX
@misc{misc_us_census_data_(1990)_116,
    author       = {Meek,Meek, Thiesson,Thiesson, and Heckerman,Heckerman},
    title        = {{US Census Data (1990)}},
    howpublished = {UCI Machine Learning Repository},
    note         = {{DOI}: https://doi.org/10.24432/C5VP42}
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
    "census",
    "census1000.csv",
)
data, grammar = OAR.symbolic_cluster_dataset(filename)

# Initialize the GramART module with options
gramart = OAR.GramART(grammar,
    # rho = 0.6,
    rho = 0.3,
    rho_lb = 0.1,
    rho_ub = 0.3,
)

OAR.tt_serial(
    gramart,
    data,
)
