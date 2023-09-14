"""
    16_select_params_cat.jl

# Description
Selects and saves the best-performing hyperparameters for each module and dataset from 12_grand_cat.jl.
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
from_exp_name = "15_grand_cat"
exp_name = "16_select_params_cat"
out_filename = "best_params.csv"

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

# Get the names of each dataset
datasets = unique(df[:, :data])

# Get the methods names
methods = unique(df[:, :m])

# Create a quick local function for getting the most performant parameter set for a method and dataset combination
function get_top_params(df::DataFrame, method::AbstractString, dataset::AbstractString)
    # Select the rows corresponding to the method and dataset
    local_df = df[(df.m .== method) .& (df.data .== dataset), :]
    # Sort by the performance, high to low
    sorted_df = sort(local_df, :p, rev=true)
    # Get the best-performing hyperparameter row
    top_1 = sorted_df[1, :]
    # Return the row
    return top_1
end

d = Dict()
for method in methods
    d[method] = Dict()
end

# Create a new empty dataframe with the same columns
new_df = similar(df, 0)
# Get the top parameters for each dataset and method combination
for dataset in datasets
    for method in methods
        d[method][dataset] = get_top_params(df, method, dataset)
        push!(new_df, d[method][dataset])
    end
end

# Save the top hyperparameter combos
OAR.save_dataframe(new_df, output_file)
