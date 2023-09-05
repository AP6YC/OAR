"""
    4_analyze_dist.jl

# Description
This script takes the results of `3_start_dist.jl` and compiles it for visualization, etc.

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
exp_name = "4_analyze_dist"
out_filename = "cmt-clusters-sweep.csv"
clusters_plot_filename = "clusters-vs-rho.png"
column_digits = 6

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "$(exp_top)/$(exp_name): analyze START distributed results."
)

# Point to the sweep results
sweep_dir = OAR.results_dir(
    exp_top,
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

# -----------------------------------------------------------------------------
# BULK SAVE
# -----------------------------------------------------------------------------

# Create an output dataframe from the clusters elements
out_df = DataFrame()
for ix in eachindex(df.rho)
    print_rho = round(df.rho[ix]; digits=column_digits)
    out_df[:, "rho=$(print_rho)"] = df.clusters[ix]
end

# Save the clustered statements to a CSV file
OAR.save_dataframe(out_df, output_file)

# -----------------------------------------------------------------------------
# PLOT CATEGORIES
# -----------------------------------------------------------------------------

# Generate the categories plot
p1 = OAR.cluster_stats_plot(
    # Custom options
    df,
    avg=true,
    err=true,
    n=50,
    fontsize=10,
    # Pass-through plots kwargs
    xlim=(0.4, 1.0),
    size = (1000, 500),
    margin= 5Plots.mm,
    xlabel = "Vigilance Parameter ρ",
    ylabel = "Count",
    legend = :topright,
)

# Save the plot
OAR.save_plot(p1, clusters_plot_filename, exp_top, exp_name)
