"""
    3_iris_dist.jl

# Description
Distributed simulations with START on the Iris dataset.

# Attribution

## Citations
- Fisher, R. A.. (1988). Iris. UCI Machine Learning Repository. https://doi.org/10.24432/C56C76.

## BibTeX
@misc{misc_iris_53,
    author       = {Fisher,R. A.},
    title        = {{Iris}},
    year         = {1988},
    howpublished = {UCI Machine Learning Repository},
    note         = {{DOI}: https://doi.org/10.24432/C56C76}
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

using Distributed
using DrWatson

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

exp_top = "1_baseline"
exp_name = "3_iris_dist"
config_file = "iris_sweep.yml"

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.dist_exp_parse(
    "$(exp_top)/$(exp_name): hyperparameter sweep for clustering the Iris dataset."
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

    # # Load the CMT disease data file
    # df = OAR.load_cmt(input_file)

    # # Load the data definition dictionary
    # df_dict = OAR.load_cmt_dict(data_dict_file)

    # # Turn the statements into TreeNodes
    # ts = OAR.df_to_trees(df, df_dict)

    # # Generate a grammart from the statements
    # grammar = OAR.CMTCFG(ts)

    # All-in-one function
    data, grammmar = OAR.symbolic_iris()

    # Generate a simple subject-predicate-object grammar from the statements
    opts = Dict()
    opts["grammar"] = grammar

    # Define the single-parameter function used for pmap
    local_sim(dict) = OAR.tc_gramart(
        dict,
        data,
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

# -----------------------------------------------------------------------------
# CLEANUP
# -----------------------------------------------------------------------------

# Close the workers after simulation
rmprocs(workers())

println("--- Simulation complete ---")

# -----------------------------------------------------------------------------
# IRIS DATASET
# -----------------------------------------------------------------------------

# All-in-one function
data, grammmar = OAR.symbolic_iris()

# Initialize the START module
gramart = OAR.START(grammmar)

# Set the vigilance parameter and show
# gramart.opts.rho = 0.15
gramart.opts.rho = 0.05

# Process the statements
@showprogress for ix in eachindex(data.train_x)
    statement = data.train_x[ix]
    label = data.train_y[ix]
    OAR.train!(gramart, statement, y=label)
end

# See the statistics of the first protonode
# @info gramart.protonodes[1].stats

# Classify
clusters = zeros(Int, length(data.test_y))
@showprogress for ix in eachindex(data.test_x)
    clusters[ix] = OAR.classify(gramart, data.test_x[ix])
end

# Calculate testing performance
perf = OAR.AdaptiveResonance.performance(data.test_y, clusters)

# Logging
@info "Final performance: $(perf)"
@info "n_categories: $(gramart.stats["n_categories"])"
# @info "n_instance: $(gramart.stats["n_instance"])"
