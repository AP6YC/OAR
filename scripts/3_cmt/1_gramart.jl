"""
    gramart.jl

# Description
This script uses GramART to cluster CMT protein data.

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

using ProgressMeter
using DataFrames

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

exp_top = "3_cmt"
exp_name = "1_gramart.jl"

# Input CSV file
input_file = OAR.data_dir("cmt", "output_CMT_file.csv")
data_dict_file = OAR.data_dir("cmt", "cmt_data_dict.csv")
output_file = OAR.results_dir("3_cmt", "cmt_clusters.csv")

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "$(exp_top)/$(exp_name): GramART for clustering disease protein statements."
)

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Load the cmt file
df = OAR.load_cmt(input_file)

# Load the data definition dictionary
df_dict = OAR.load_cmt_dict(data_dict_file)

# -----------------------------------------------------------------------------
# EXPERIMENT
# -----------------------------------------------------------------------------

# Turn the statements into TreeNodes
ts = OAR.df_to_trees(df, df_dict)
# @info ts[1]

# Generate a grammart from the statements
grammar = OAR.CMTCFG(ts)

# Initialize the GramART module
gramart = OAR.GramART(
    grammar,
    rho=0.7,    # ~12GB
    terminated=false,
)
# @info gramart

# Process the statements
@showprogress for tn in ts
    OAR.train!(gramart, tn)
end

# Create a copy of the input dataframe for saving corresponding clusters
out_df = deepcopy(df)

# Classify and push the results to a list of cluster assignments
clusters = Vector{Int}()
@showprogress for tn in ts
    cluster = OAR.classify(gramart, tn, get_bmu=true)
    push!(clusters, cluster)
end

# Add the vector as a column to the output dataframe
out_df.cluster = clusters

# Save the clustered statements to a CSV file
OAR.save_dataframe(out_df, output_file)