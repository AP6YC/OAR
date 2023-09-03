"""
    3_gramart_sweep.jl

# Description
This script uses START to cluster CMT protein data.

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

using Distributed
using DrWatson

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

exp_top = "3_cmt"
exp_name = "3_gramart_dist.jl"
config_file = "flat_sweep.yml"

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.dist_exp_parse(
    "$(exp_top)/$(exp_name): hyperparameter sweep of START for clustering disease protein statements."
)

# Start several processes
if pargs["procs"] > 0
    addprocs(pargs["procs"], exeflags="--project=.")
end

# Load the simulation configuration file
config = OAR.load_config(config_file)

# Set the simulation parameters
sim_params = Dict{String, Any}(
    "m" => "START",
    "rng_seed" => config["rng_seed"],
    "rho" => collect(LinRange(
        config["rho_lb"],
        config["rho_ub"],
        config["n_sweep"],
    ))
)

# -----------------------------------------------------------------------------
# PARALLEL DEFINITIONS
# -----------------------------------------------------------------------------

@everywhere begin
    # Activate the project in case
    using Pkg
    Pkg.activate(".")

    # Modules
    using OAR

    # Point to the CSV data file and data definition
    input_file = OAR.data_dir(
        "cmt",
        "output_CMT_file.csv",
    )
    data_dict_file = OAR.data_dir(
        "cmt",
        "cmt_data_dict.csv",
    )

    # Point to the sweep results
    sweep_results_dir(args...) = OAR.results_dir(
        "3_cmt",
        "sweep",
        args...
    )

    # Make the path
    mkpath(sweep_results_dir())

    # Load the CMT disease data file
    df = OAR.load_cmt(input_file)

    # Load the data definition dictionary
    df_dict = OAR.load_cmt_dict(data_dict_file)

    # Turn the statements into TreeNodes
    ts = OAR.df_to_trees(df, df_dict)

    # Generate a grammart from the statements
    grammar = OAR.CMTCFG(ts)

    # Generate a simple subject-predicate-object grammar from the statements
    opts = Dict()
    opts["grammar"] = grammar

    # Define the single-parameter function used for pmap
    local_sim(dict) = OAR.tc_gramart(
        dict,
        ts,
        sweep_results_dir,
        opts,
    )
end

# -----------------------------------------------------------------------------
# EXPERIMENT
# -----------------------------------------------------------------------------

# Log the simulation scale
@info "START: $(dict_list_count(sim_params)) simulations across $(nprocs()) processes."

# Turn the dictionary of lists into a list of dictionaries
dicts = dict_list(sim_params)

# Parallel map the sims
pmap(local_sim, dicts)
# progress_pmap(local_sim, dicts)

# -----------------------------------------------------------------------------
# CLEANUP
# -----------------------------------------------------------------------------

# Close the workers after simulation
rmprocs(workers())

println("--- Simulation complete ---")
