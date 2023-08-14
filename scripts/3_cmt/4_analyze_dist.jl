"""
    4_analyze_dist.jl

# Description
This script takes the results of `3_gramart_dist.jl` and compiles it for visualization, etc.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
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

exp_top = "3_cmt"
exp_name = @__FILE__

# Point to the sweep results
sweep_dir = OAR.results_dir(
    "3_cmt",
    "sweep",
)

# Output file
output_dir(args...) = OAR.results_dir("3_cmt", args...)
mkpath(output_dir())
output_file = output_dir("cmt-clusters-sweep.csv")

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "$(exp_top)/$(exp_name): analyze GramART distributed results."
)

# -----------------------------------------------------------------------------
# LOAD RESULTS
# -----------------------------------------------------------------------------

# Collect the results into a single dataframe
df = collect_results!(sweep_dir)

# -----------------------------------------------------------------------------
# BULK SAVE
# -----------------------------------------------------------------------------

# Create an output dataframe from the clusters elements
out_df = DataFrame()
for ix in eachindex(df.rho)
    print_rho = round(df.rho[ix]; digits=4)
    out_df[:, "rho=$(print_rho)"] = df.clusters[ix]
end

# Save the clustered statements to a CSV file
OAR.save_dataframe(out_df, output_file)
