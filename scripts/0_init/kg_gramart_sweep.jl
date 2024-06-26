"""
    kg_gramart_monosweep.jl

# Description
This script is a hyperparameter sweep version of `kg_gramart.jl`, which uses START to cluster disease knowledge graph statements.
This script saves all of the results to one file.

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

# Location of the edge attributes file, formatted for Lerch parsing
edge_file = OAR.results_dir("2_kg_gramart", "cmt", "edge_attributes_lerche.txt")

# Output CSV file
output_dir(args...) = OAR.results_dir("2_kg_gramart", "cmt", "sweep", args...)
mkpath(output_dir())

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "2_kg/kg_gramart_sweep.jl: hyperparameter sweep of START for clustering a disease knowledge graph."
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

for rho in rhos
    # Initialize the START module
    gramart = OAR.START(
        grammar,
        # rho=0.1,    # ~12GB
        rho = rho,
        terminated=false,
    )
    @info gramart

    # Process the statements
    @showprogress for statement in statements
        OAR.train!(gramart, statement)
    end

    # Save the statements and their corresponding clusters to a CSV
    df = DataFrame(
        subject = String[],
        predicate = String[],
        object = String[],
        cluster = Int[],
    )

    # Classify and push each statement back into a CSV
    @showprogress for statement in statements
        cluster = OAR.classify(gramart, statement, get_bmu=true)
        new_element = [
            statement[1].data,
            statement[2].data,
            statement[3].data,
            cluster,
        ]
        push!(df, new_element)
    end

    # Save the clustered statements to a CSV file
    print_rho = round(rho; digits=1)
    output_file = output_dir("cmt-clusters_rho=$(print_rho).csv")
    OAR.save_dataframe(df, output_file)
end
