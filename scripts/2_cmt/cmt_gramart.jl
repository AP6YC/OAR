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

# Open the edge attributes file
open(edge_file) do f
    line = 0
    while ! eof(f)
        s = readline(f)
        line += 1
        k = OAR.run_parser(cmt_parser, s)
        @info "$line : $k"
    end
end



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
