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

using ProgressMeter
using DataFrames
using CSV

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

N_SWEEP = 9

# Location of the edge attributes file, formatted for Lerch parsing
edge_file = OAR.results_dir("2_kg_gramart", "cmt", "edge_attributes_lerche.txt")

# Output CSV file
output_dir(args...) = OAR.results_dir("2_kg_gramart", "cmt", "sweep", args...)
mkpath(output_dir())
output_file = output_dir("cmt-clusters_sweep.csv")

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "2_kg/kg_gramart_sweep.jl: hyperparameter sweep of GramART for clustering a disease knowledge graph."
)

# -----------------------------------------------------------------------------
# EXPERIMENT
# -----------------------------------------------------------------------------

# Load the KG statements
statements = OAR.get_kg_statements(edge_file)

# Generate a simple subject-predicate-object grammar from the statements
grammar = OAR.SPOCFG(statements)

rhos = collect(LinRange(0.1, 0.9, N_SWEEP))

clusters = zeros(Int, length(statements), N_SWEEP)
for ix in eachindex(rhos)
    # Initialize the GramART module
    gramart = OAR.GramART(
        grammar,
        rho = rhos[ix],
        terminated=false,
    )
    @info gramart

    # Process the statements
    @showprogress for statement in statements
        OAR.train!(gramart, statement)
    end

    # Classify and push each statement back into a CSV
    # @showprogress for statement in statements
    for jx in eachindex(statements)
        clusters[jx, ix] = OAR.classify(gramart, statements[jx], get_bmu=true)
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
    print_rho = round(rhos[ix]; digits=1)
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
CSV.write(output_file, df)
