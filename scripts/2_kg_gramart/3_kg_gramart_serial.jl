"""
    3_kg_gramart_serial.jl

# Description
This script is a serial hyperparameter sweep version of `2_kg_gramart.jl`, which uses GramART to cluster disease knowledge graph statements.

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

N_SWEEP = 100
RHO_LB = 0.1
RHO_UB = 0.3

exp_top = "2_kg_gramart"
exp_name = @__FILE__

# Location of the edge attributes file, formatted for Lerch parsing
edge_file = OAR.results_dir(exp_top, "cmt", "edge_attributes_lerche.txt")

# Output CSV file
output_dir(args...) = OAR.results_dir(exp_top, "cmt", "sweep", args...)
mkpath(output_dir())
output_file = output_dir("cmt-kg-clusters-sweep_rho=$(RHO_LB)-$(N_SWEEP)-$(RHO_UP).csv")

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "$(exp_top)/$(exp_name): hyperparameter sweep of GramART for clustering a disease knowledge graph."
)

# -----------------------------------------------------------------------------
# EXPERIMENT
# -----------------------------------------------------------------------------

# Load the KG statements
statements = OAR.get_kg_statements(edge_file)

# Generate a simple subject-predicate-object grammar from the statements
grammar = OAR.SPOCFG(statements)

# Create a linrange of rhos to sweep
rhos = collect(LinRange(
    RHO_LB,
    RHO_UB,
    N_SWEEP
))

# Init the cluster assignment matrix
clusters = zeros(Int, length(statements), N_SWEEP)

# Iterate over all rhos
for ix in eachindex(rhos)
    # Initialize the GramART module
    gramart = OAR.GramART(
        grammar,
        rho = rhos[ix],
        terminated=false,
    )

    # Process the statements
    @showprogress for statement in statements
        OAR.train!(gramart, statement)
    end

    # Classify and add the cluster label to the assignment matrix
    # @showprogress for statement in statements
    for jx in eachindex(statements)
        clusters[jx, ix] = OAR.classify(
            gramart,
            statements[jx],
            get_bmu=true,
        )
    end
end

# Save the statements and their corresponding clusters to a CSV
df = DataFrame(
    subject = String[],
    predicate = String[],
    object = String[],
    # cluster = Int[],
)

# Add the vigilance parameter columns to the dataframe
for ix in eachindex(rhos)
    print_rho = round(rhos[ix]; digits=6)
    df[!, "rho=$(print_rho)"] = Int[]
end

# Add the statement and resulting clusters to the dataframe as rows
for jx in eachindex(statements)
    statement = statements[jx]
    new_element = Vector{Any}([
        statement[1].data,
        statement[2].data,
        statement[3].data,
        # clusters[jx, :],
    ])
    append!(new_element, clusters[jx, :])
    push!(df, new_element)
end

# Save the clustered statements to a CSV file
OAR.save_dataframe(df, output_file)
