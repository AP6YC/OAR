"""
    gramart_sweep.jl

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

# N_SWEEP = 9
N_SWEEP = 100
RHO_LB = 0.1
RHO_UB = 0.9

exp_top = "3_cmt"
exp_name = "2_gramart_serial.jl"

# Input CSV file and data definition
input_file = OAR.data_dir("cmt", "output_CMT_file.csv")
data_dict_file = OAR.data_dir("cmt", "cmt_data_dict.csv")

# Output file
output_dir(args...) = OAR.results_dir("3_cmt", args...)
mkpath(output_dir())
output_file = output_dir("cmt-clusters-sweep_rho=$(RHO_LB)-$(N_SWEEP)-$(RHO_UB).csv")

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "$(exp_top)/$(exp_name): hyperparameter sweep of GramART for clustering disease protein statements."
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

# Generate a grammart from the statements
grammar = OAR.CMTCFG(ts)

# Create a linrange of rhos to sweep
rhos = collect(LinRange(
    RHO_LB,
    RHO_UB,
    N_SWEEP
))

# Init the cluster assignment matrix
clusters = zeros(Int, length(ts), N_SWEEP)

# Iterate over all rhos
for ix in eachindex(rhos)
    # Initialize the GramART module
    gramart = OAR.GramART(
        grammar,
        rho=rhos[ix],
        terminated=false,
    )

    # Process the statements
    @showprogress for tn in ts
        OAR.train!(gramart, tn)
    end

    # Classify and add the cluster label to the assignment matrix
    for jx in eachindex(ts)
        clusters[jx, ix] = OAR.classify(
            gramart,
            ts[jx],
            get_bmu=true,
        )
    end
end

# Create a copy of the input dataframe for saving corresponding clusters
out_df = deepcopy(df)

# Add the vigilance parameter columns to the dataframe
for ix in eachindex(rhos)
    print_rho = round(rhos[ix]; digits=1)
    out_df[!, "rho=$(print_rho)"] = clusters[:, ix]
end

# Save the clustered statements to a CSV file
OAR.save_dataframe(out_df, output_file)
