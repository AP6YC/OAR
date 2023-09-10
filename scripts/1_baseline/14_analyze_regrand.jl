"""
    14_analyze_regrand.jl

# Description
Analyzes the results from the regrand experiment.
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

# -----------------------------------------------------------------------------
# ADDITIONAL DEPENDENCIES
# -----------------------------------------------------------------------------

using DrWatson      # collect_results!
using DataFrames

# -----------------------------------------------------------------------------
# OPTIONS
# -----------------------------------------------------------------------------

exp_top = "1_baseline"
from_exp_name = "13_regrand"
exp_name = "14_analyze_regrand"
out_filename = "regrand.tex"

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "$(exp_top)/$(exp_name): analyze distributed results."
)

# Point to the sweep results
sweep_dir = OAR.results_dir(
    exp_top,
    from_exp_name,
    "sweep",
)

# Output file
output_dir(args...) = OAR.results_dir(exp_top, exp_name, args...)
mkpath(output_dir())
output_file = output_dir(out_filename)

# -----------------------------------------------------------------------------
# LOAD RESULTS
# -----------------------------------------------------------------------------

# Collect the results into a single dataframe
df = collect_results!(sweep_dir)