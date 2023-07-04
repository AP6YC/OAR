"""
    gramart.jl

# Description
This script shows how to use a GramART to cluster on the Iris dataset.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

# Location of the edge attributes file, formatted for Lerch parsing
edge_file = OAR.results_dir("2_cmt", "edge_attributes_lerche.txt")

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "2_cmt/gramart.jl: GramART for clustering a Charcot-Marie."
)

# -----------------------------------------------------------------------------
# CMT DATASET
# -----------------------------------------------------------------------------

# Construct the CMT parser
cmt_parser = OAR.get_cmt_parser()

# Set some sample text as the input statement
text = raw"\"Periaxin\" \"is_a\" \"protein\""

# Parse the statement
k = OAR.run_parser(cmt_parser, text)

# Initialize the statements vector
statements = Vector{OAR.CMTStatement}()
# Open the edge attributes file and parse
open(edge_file) do f
    line = 0
    while ! eof(f)
        # Read the line from the file
        s = readline(f)
        line += 1
        # Parse the line into a structured statement
        k = OAR.run_parser(cmt_parser, s)
        push!(statements, k)
        # @info "$line : $k"
    end
end

# Generate a simple subject-predicate-object grammar from the statements
grammar = OAR.SPOCFG(statements)

# # All-in-one function
# fs, bnf = OAR.symbolic_iris()

# # Initialize the GramART module
# gramart = OAR.GramART(bnf)
# gramart.opts.rho = 0.5
# @info gramart

# # Process the statements
# for statement in fs.train_x
#     # OAR.process_statement!(gramart, statement, 1)
#     OAR.train!(gramart, statement)
# end
# # s = fs.train_x[1]
# # OAR.train!(gramart, s)
