"""
    gramart.jl

# Description
This script uses GramART to cluster CMT protein data.

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

# Input CSV file
input_file = OAR.data_dir("cmt", "output_CMT_file.csv")
data_dict = OAR.data_dir("cmt", "cmt_data_dict.csv")

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "2_kg/gramart.jl: GramART for clustering a disease knowledge graph."
)

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------


df = DataFrame(CSV.File(input_file))

function out_grammar()

end
