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
exp_name = "13_grand"
config_file = "regrand_sweep.yml"

# Experiment dependency names
from_exp_name = "12_select_params"
from_filename = "best_params.csv"
# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.dist_exp_parse(
    "$(exp_top)/$(exp_name): for clustering...everything."
)

pargs["procs"] = 0

# Start several processes
if pargs["procs"] > 0
    addprocs(pargs["procs"], exeflags="--project=.")
end

# # Experiment dependency names
# @everywhere begin
#     from_exp_name = "12_select_params"
#     from_filename = "best_params.csv"
# end

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

# sim_params = Dict{String, Any}(

# )

# start_params = Dict{String, Any}(
#     "m" => "start",
#     "rng_seed" => collect(range(
#         1,
#         config["start"]["n_sweep"],
#         step = 1,
#     )),
#     # "rho" => ,
# )

# dvstart_params = Dict{String, Any}(
#     "m" => "dvstart",
#     "rng_seed" => collect(range(
#         1,
#         config["dvstart"]["n_sweep"],
#         step = 1,
#     )),
#     "rho_lb" => collect(range(
#         config["dvstart"]["rho_lb_lb"],
#         config["dvstart"]["rho_lb_ub"],
#         step = config["start"]["increment"],
#     )),
#     "rho_ub" => collect(range(
#         config["dvstart"]["rho_ub_lb"],
#         config["dvstart"]["rho_ub_ub"],
#         step = config["dvstart"]["increment"],
#     )),
# )

# ddvstart_params = Dict{String, Any}(
#     "m" => "ddvstart",
#     "similarity" => config["ddvstart"]["similarity"],
#     "rng_seed" => collect(range(
#         1,
#         config["ddvstart"]["n_sweep"],
#         step = 1,
#     )),
#     "rho_lb" => collect(range(
#         config["ddvstart"]["rho_lb_lb"],
#         config["ddvstart"]["rho_lb_ub"],
#         step = config["start"]["increment"],
#     )),
#     "rho_ub" => collect(range(
#         config["ddvstart"]["rho_ub_lb"],
#         config["ddvstart"]["rho_ub_ub"],
#         step = config["ddvstart"]["increment"],
#     )),
# )

# # Point to the top of the data package directory
# topdir =  OAR.data_dir("data-package")
# # data_names = Dict{String, Any}()
# data_names = []
# # Walk the directory
# for (root, dirs, files) in walkdir(topdir)
#     # Iterate over all of the files
#     for file in files
#         # Load the symbolic data and grammar
#         filename = splitext(file)[1]
#         push!(data_names, filename)
#     end
# end
data_names = OAR.get_data_package_names()

# for dict in (start_params, dvstart_params, ddvstart_params)
#     dict["data"] = data_names
# end

# # Turn the dictionary of lists into a list of dictionaries
# start_dicts = dict_list(start_params)
# dvstart_dicts = dict_list(dvstart_params)
# ddvstart_dicts = dict_list(ddvstart_params)

# # Remove impermissible sim options
# filter!(d -> d["rho_ub"] > d["rho_lb"], dvstart_dicts)
# filter!(d -> d["rho_ub"] > d["rho_lb"], ddvstart_dicts)

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

#     # Point to the top of the data package directory
#     topdir =  OAR.data_dir("data-package")

#     # Generate a simple subject-predicate-object grammar from the statements
#     opts = Dict{String, Any}()
#     opts["data"] = Dict{String, Any}()
#     opts["grammar"] = Dict{String, Any}()
#     # Walk the directory
#     for (root, dirs, files) in walkdir(topdir)
#         # Iterate over all of the files
#         for file in files
#             # Get the full filename for the current data file
#             filename = joinpath(root, file)

#             # Load the symbolic data and grammar
#             data_name = splitext(file)[1]
#             opts["data"][data_name], opts["grammar"][data_name] = OAR.symbolic_dataset(filename)
#         end
#     end

#     # Point to the sweep results
#     sweep_results_dir(args...) = OAR.results_dir(
#         "1_baseline",
#         "11_grand",
#         "sweep",
#         args...
#     )

#     # Make the path
#     mkpath(sweep_results_dir())

#     # Define the single-parameter function used for pmap
#     local_sim(dict) = OAR.sim_tt_serial(
#         dict,
#         sweep_results_dir,
#         opts,
#     )
end

# # -----------------------------------------------------------------------------
# # EXPERIMENT
# # -----------------------------------------------------------------------------

# # Log the simulation scale
# @info "START: $(dict_list_count(start_params)) simulations across $(nprocs()) processes."
# @info "DVSTART: $(dict_list_count(dvstart_params)) simulations across $(nprocs()) processes."
# @info "DDVSTART: $(dict_list_count(ddvstart_params)) simulations across $(nprocs()) processes."

# # Parallel map the sims
# pmap(local_sim, start_dicts)
# pmap(local_sim, dvstart_dicts)
# pmap(local_sim, ddvstart_dicts)

# # -----------------------------------------------------------------------------
# # CLEANUP
# # -----------------------------------------------------------------------------

# # Close the workers after simulation
# rmprocs(workers())

# println("--- Simulation complete ---")
