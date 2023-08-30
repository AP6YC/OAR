"""
    11_grand.jl

# Description
All the training.

# Attribution

## Citations
- Ilc, Nejc. (2013). Datasets package.

## BibTeX
@misc{dataset,
    author = {Ilc, Nejc},
    year = {2013},
    month = {06},
    pages = {},
    title = {Datasets package}
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
exp_name = "11_grand.jl"
config_file = "grand_sweep.yml"

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.dist_exp_parse(
    "$(exp_top)/$(exp_name): GramART for clustering...everything."
)

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

# Point to the top of the data package directory
topdir =  OAR.data_dir("data-package")
# data_names = Dict{String, Any}()
data_names = []
# Walk the directory
for (root, dirs, files) in walkdir(topdir)
    # Iterate over all of the files
    for file in files
        # Load the symbolic data and grammar
        filename = splitext(file)[1]
        push!(data_names, filename)
    end
end
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

    # Point to the top of the data package directory
    topdir =  OAR.data_dir("data-package")

    # Generate a simple subject-predicate-object grammar from the statements
    opts = Dict{String, Any}()
    opts["data"] = Dict{String, Any}()
    opts["grammar"] = Dict{String, Any}()
    # Walk the directory
    for (root, dirs, files) in walkdir(topdir)
        # Iterate over all of the files
        for file in files
            # Get the full filename for the current data file
            filename = joinpath(root, file)

            # Load the symbolic data and grammar
            data_name = splitext(file)[1]
            opts["data"][data_name], opts["grammar"][data_name] = OAR.symbolic_dataset(filename)
        end
    end

    # Point to the sweep results
    sweep_results_dir(args...) = OAR.results_dir(
        "1_baseline",
        "11_grand",
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

# -----------------------------------------------------------------------------
# ALL REAL DATASETS
# -----------------------------------------------------------------------------

# # Point to the top of the data package directory
# topdir =  OAR.data_dir("data-package")

# # Walk the directory
# for (root, dirs, files) in walkdir(topdir)
#     # Iterate over all of the files
#     for file in files
#         # Get the full filename for the current data file
#         filename = joinpath(root, file)

#         # Load the symbolic data and grammar
#         data, grammar = OAR.symbolic_dataset(filename)

#         # Initialize the GramART module with options
#         gramart = OAR.GramART(grammar,
#             # rho = 0.6,
#             # rho = 0.3,
#             rho = 0.1,
#             rho_lb = 0.1,
#             rho_ub = 0.3,
#             epochs=5,
#         )

#         @info "---------- $(file) ----------"
#         OAR.tt_serial(
#             gramart,
#             data,
#         )
#     end
# end
