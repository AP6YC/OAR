"""
    kg_gramart_sweep.jl

# Description
This script is a hyperparameter sweep version of `kg_gramart.jl`, which uses GramART to cluster disease knowledge graph statements.

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

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.dist_exp_parse(
    "2_kg/kg_gramart_dist.jl: distributed hyperparameter sweep of GramART for clustering a disease knowledge graph."
)

# Development override
pargs["procs"] = 4

# Start several processes
if pargs["procs"] > 0
    addprocs(pargs["procs"], exeflags="--project=.")
end

# Set the simulation parameters
sim_params = Dict{String, Any}(
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
    local_sim(dict) = OAR.tt_gramart(
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

# # Iterate over all rhos
# for ix in eachindex(rhos)
#     # Initialize the GramART module
#     gramart = OAR.GramART(
#         grammar,
#         rho = rhos[ix],
#         terminated=false,
#     )

#     # Process the statements
#     @showprogress for statement in statements
#         OAR.train!(gramart, statement)
#     end

#     # Classify and add the cluster label to the assignment matrix
#     # @showprogress for statement in statements
#     for jx in eachindex(statements)
#         clusters[jx, ix] = OAR.classify(
#             gramart,
#             statements[jx],
#             get_bmu=true,
#         )
#     end
# # end

# # Save the statements and their corresponding clusters to a CSV
# df = DataFrame(
#     subject = String[],
#     predicate = String[],
#     object = String[],
#     # cluster = Int[],
# )

# # Add the vigilance parameter columns to the dataframe
# for ix in eachindex(rhos)
#     print_rho = round(rhos[ix]; digits=1)
#     df[!, "rho=$(print_rho)"] = Int[]
# end

# # Add the statement and resulting clusters to the dataframe as rows
# for jx in eachindex(statements)
#     statement = statements[jx]
#     new_element = Vector{Any}([
#         statement[1].data,
#         statement[2].data,
#         statement[3].data,
#         # clusters[jx, :],
#     ])
#     append!(new_element, clusters[jx, :])
#     push!(df, new_element)
# end

# # Save the clustered statements to a CSV file
# CSV.write(output_file, df)
