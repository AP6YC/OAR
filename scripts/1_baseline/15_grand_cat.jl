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
config_file = "grand_sweep.yml"

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

start_params = Dict{String, Any}(
    "m" => "start",
    "rng_seed" => collect(range(
        1,
        config["start"]["n_sweep"],
        step = 1,
    )),
    "rho" => collect(range(
        config["start"]["rho_lb"],
        config["start"]["rho_ub"],
        step = config["start"]["increment"],
    )),
)

dvstart_params = Dict{String, Any}(
    "m" => "dvstart",
    "rng_seed" => collect(range(
        1,
        config["dvstart"]["n_sweep"],
        step = 1,
    )),
    "rho_lb" => collect(range(
        config["dvstart"]["rho_lb_lb"],
        config["dvstart"]["rho_lb_ub"],
        step = config["start"]["increment"],
    )),
    "rho_ub" => collect(range(
        config["dvstart"]["rho_ub_lb"],
        config["dvstart"]["rho_ub_ub"],
        step = config["dvstart"]["increment"],
    )),
)

ddvstart_params = Dict{String, Any}(
    "m" => "ddvstart",
    "similarity" => config["ddvstart"]["similarity"],
    "rng_seed" => collect(range(
        1,
        config["ddvstart"]["n_sweep"],
        step = 1,
    )),
    "rho_lb" => collect(range(
        config["ddvstart"]["rho_lb_lb"],
        config["ddvstart"]["rho_lb_ub"],
        step = config["start"]["increment"],
    )),
    "rho_ub" => collect(range(
        config["ddvstart"]["rho_ub_lb"],
        config["ddvstart"]["rho_ub_ub"],
        step = config["ddvstart"]["increment"],
    )),
)

data_names = OAR.get_data_package_names(OAR.data_dir("categorical"))

for dict in (start_params, dvstart_params, ddvstart_params)
    dict["data"] = data_names
end

# Turn the dictionary of lists into a list of dictionaries
start_dicts = dict_list(start_params)
dvstart_dicts = dict_list(dvstart_params)
ddvstart_dicts = dict_list(ddvstart_params)

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
