"""
    4_kg_gramart_dist.jl

# Description
This script is a distributed hyperparameter sweep version of `1_kg_gramart.jl`, which uses GramART to cluster disease knowledge graph statements.

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

N_SWEEP = 10
RHO_LB = 0.1
RHO_UB = 0.3

exp_top = "2_kg_gramart"
exp_name = @__FILE__

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.dist_exp_parse(
    "$(exp_top)/$(exp_name): distributed hyperparameter sweep of GramART for clustering a disease knowledge graph."
)

# Development override
pargs["procs"] = 4

# Start several processes
if pargs["procs"] > 0
    addprocs(pargs["procs"], exeflags="--project=.")
end

# Set the simulation parameters
sim_params = Dict{String, Any}(
    "m" => "GramART",
    "rng_seed" => 1234,
    "rho" => collect(LinRange(
        RHO_LB,
        RHO_UB,
        N_SWEEP
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

    # Location of the edge attributes file, formatted for Lerch parsing
    edge_file = OAR.results_dir(
        "2_kg_gramart",
        "cmt",
        "edge_attributes_lerche.txt"
    )

    # Point to the sweep results
    sweep_results_dir(args...) = OAR.results_dir(
        "2_kg_gramart",
        "cmt",
        "sweep",
        args...
    )

    # Make the path
    mkpath(sweep_results_dir())

    # Load the KG statements
    statements = OAR.get_kg_statements(edge_file)

    # Generate a simple subject-predicate-object grammar from the statements
    opts = Dict()
    opts["grammar"] = OAR.SPOCFG(statements)

    # Define the single-parameter function used for pmap
    local_sim(dict) = OAR.tc_gramart(
        dict,
        statements,
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
