"""
    13_regrand.jl

# Description
Runs the full training suite from the parameters selected by 12_select_params.jl.
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
using DrWatson
using Distributed

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

# This experiment's names and configs
exp_top = "1_baseline"
exp_name = "17_regrand"
config_file = "regrand_sweep_cat.yml"

# Experiment dependency names
from_exp_name = "16_select_params_cat"
from_filename = "best_params.csv"

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.dist_exp_parse(
    "$(exp_top)/$(exp_name): for clustering...everything."
)

# pargs["procs"] = 0

# Start several processes
if pargs["procs"] > 0
    addprocs(pargs["procs"], exeflags="--project=.")
end

# Load the simulation configuration file
config = OAR.load_config(config_file)

# Point to the file containing the best parameters for each method and dataset
from_file = OAR.results_dir(exp_top, from_exp_name, from_filename)

# Load the parameters as a DataFrame
df = OAR.load_dataframe(from_file)

# Turn the dataframe into a vector of dictionaries
dicts = OAR.df_to_dicts(df)

# Expand the dictionaries for the number of
sim_dicts = Vector{Dict{String, Any}}()
for d in dicts
    for n = 1:config["n_sweep"]
        local_d = deepcopy(d)
        local_d["rng_seed"] = n
        push!(sim_dicts, local_d)
    end
end

# -----------------------------------------------------------------------------
# PARALLEL DEFINITIONS
# -----------------------------------------------------------------------------

@everywhere begin
    # Activate the project in case
    using Pkg
    Pkg.activate(".")

    # Modules
    using OAR

    # Get the datasets and grammars from the data package
    opts = OAR.load_data_package()

    # Point to the sweep results
    sweep_results_dir(args...) = OAR.results_dir(
        "1_baseline",
        "17_regrand_cat",
        "sweep",
        args...
    )

    # Make the path
    mkpath(sweep_results_dir())

    # Define the single-parameter function used for pmap
    local_sim(dict) = OAR.sim_tt_serial(
        dict,
        sweep_results_dir,
        opts,
    )
end

# -----------------------------------------------------------------------------
# EXPERIMENT
# -----------------------------------------------------------------------------

# Log the simulation scale
@info "$(length(sim_dicts)) simulations across $(nprocs()) processes."

# Parallel map the sims
pmap(local_sim, sim_dicts)

# -----------------------------------------------------------------------------
# CLEANUP
# -----------------------------------------------------------------------------

# Close the workers after simulation
rmprocs(workers())

println("--- Simulation complete ---")
