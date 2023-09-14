"""
    15_grand_cat.jl

# Description
All the categorical training.
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

# -----------------------------------------------------------------------------
# ADDITIONAL DEPENDENCIES
# -----------------------------------------------------------------------------

# using DataFrames
using Random
Random.seed!(1234)
# using ProgressMeter
using DrWatson
using Distributed

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

exp_top = "1_baseline"
exp_name = "15_grand_cat.jl"
config_file = "grand_sweep_cat.yml"

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.dist_exp_parse(
    "$(exp_top)/$(exp_name): hyperparameter sweep to find the top-performing settings for each method and categorical dataset."
)

# pargs["procs"] = 0

# Start several processes
if pargs["procs"] > 0
    addprocs(pargs["procs"], exeflags="--project=.")
end

# Load the simulation configuration file
config = OAR.load_config(config_file)

# datasets = ["mushroom", "lung-cancer"]
data_names = OAR.get_data_package_names(OAR.data_dir("categorical"))

VD = Vector{Dict{String, Any}}

start_params = VD()
dvstart_params = VD()
ddvstart_params = VD()

for dataset in data_names
    push!(start_params, Dict{String, Any}(
        "m" => "start",
        "data" => dataset,
        "rng_seed" => collect(range(
            1,
            config["n_sweep"]["start"],
            step = 1,
        )),
        "rho" => collect(range(
            config[dataset]["rho_lb"],
            config[dataset]["rho_ub"],
            step = config[dataset]["increment"],
        )),
    ))

    push!(dvstart_params, Dict{String, Any}(
        "m" => "dvstart",
        "data" => dataset,
        "rng_seed" => collect(range(
            1,
            config["n_sweep"]["dvstart"],
            step = 1,
        )),
        "rho_lb" => collect(range(
            config[dataset]["rho_lb"],
            config[dataset]["rho_ub"],
            step = config[dataset]["increment"],
        )),
        "rho_ub" => collect(range(
            config[dataset]["rho_lb"],
            config[dataset]["rho_ub"],
            step = config[dataset]["increment"],
        )),
    ))

    push!(ddvstart_params, Dict{String, Any}(
        "m" => "ddvstart",
        "data" => dataset,
        "similarity" => config["similarity"],
        "rng_seed" => collect(range(
            1,
            config["n_sweep"]["ddvstart"],
            step = 1,
        )),
        "rho_lb" => collect(range(
            config[dataset]["rho_lb"],
            config[dataset]["rho_ub"],
            step = config[dataset]["increment"],
        )),
        "rho_ub" => collect(range(
            config[dataset]["rho_lb"],
            config[dataset]["rho_ub"],
            step = config[dataset]["increment"],
        )),
    ))
end

start_dicts = VD()
dvstart_dicts = VD()
ddvstart_dicts = VD()
# Turn the dictionary of lists into a list of dictionaries
for ix = 1:length(data_names)
    push!(start_dicts, dict_list(start_params[ix]))
    push!(dvstart_dicts, dict_list(dvstart_params[ix]))
    push!(ddvstart_dicts, dict_list(ddvstart_params[ix]))
end

# Remove impermissible sim options
filter!(d -> d["rho_ub"] > d["rho_lb"], dvstart_dicts)
filter!(d -> d["rho_ub"] > d["rho_lb"], ddvstart_dicts)

# -----------------------------------------------------------------------------
# PARALLEL DEFINITIONS
# -----------------------------------------------------------------------------

@everywhere begin
    # Activate the project in case
    using Pkg
    Pkg.activate(".")

    # Modules
    using OAR

    # # Point to the top of the data package directory
    # topdir =  OAR.data_dir("data-package")
    opts = OAR.load_data_package(OAR.data_dir("categorical"))

    # Point to the sweep results
    sweep_results_dir(args...) = OAR.results_dir(
        "1_baseline",
        "15_grand_cat",
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
@info "START: $(dict_list_count(start_params)) simulations across $(nprocs()) processes."
@info "DVSTART: $(dict_list_count(dvstart_params)) simulations across $(nprocs()) processes."
@info "DDVSTART: $(dict_list_count(ddvstart_params)) simulations across $(nprocs()) processes."

# Parallel map the sims
pmap(local_sim, start_dicts)
pmap(local_sim, dvstart_dicts)
pmap(local_sim, ddvstart_dicts)

# -----------------------------------------------------------------------------
# CLEANUP
# -----------------------------------------------------------------------------

# Close the workers after simulation
rmprocs(workers())

println("--- Simulation complete ---")
