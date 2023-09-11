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
using Latexify
using Statistics

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

# -----------------------------------------------------------------------------
# GENERATE TABLE
# -----------------------------------------------------------------------------

pretty_rows = Dict(
    "CBB-Aggregation" => "Aggregation",
    "CBB-Compound" => "Compound",
    "CBB-R15" => "R15",
    "CBB-jain" => "Jain",
    "CBB-flame" => "Flame",
    "CBB-pathbased" => "PathBased",
    "CBB-spiral" => "Spiral",
    "face" => "Face",
    "flag" => "Flag",
    "halfring" => "Halfring",
    "iris" => "Iris",
    "moon" => "Moon",
    "ring" => "Ring",
    "spiral" => "Spiral",
    "wave" => "Wave",
    "wine" => "Wine",
)

modules = [
    "start",
    "dvstart",
    "ddvstart",
]

# modules = unique(df[:, :m])
datasets = unique(df[:, :data])

out_df = DataFrame(
    Dataset = String[],
    START = String[],
    DVSTART = String[],
    DDVSTART = String[],
)

for dataset in datasets
    new_entry = String[]
    # First entry is the dataset name
    push!(new_entry, pretty_rows[dataset])
    # Iterate over every module
    for m in modules
        local_df = df[(df.m .== m), :]
        push!(new_entry, "$(mean(local_df[:, :p])) ± $(var(local_df[:, :p]))")
    end
    push!(out_df, new_entry)
end

new_df_tex = latexify(out_df, env=:table, fmt="%.5f")

open(output_file, "w") do f
    write(f, new_df_tex)
end
