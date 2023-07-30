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
data_dict_file = OAR.data_dir("cmt", "cmt_data_dict.csv")

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "3_cmt/gramart.jl: GramART for clustering disease protein statements."
)

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

df = OAR.load_cmt(input_file)
df_dict = OAR.load_cmt_dict(data_dict_file)

statements = OAR.protein_df_to_strings(df)

# parser = OAR.get_cmt_parser()

# OAR.run_parser(parser, statements[1])

text_1 = "asdf | poiu | jkl"
text_2 = "bbbb"
text_3 = "asdf|poiu"
parser = OAR.get_piped_parser()
x1 = OAR.run_parser(parser, text_1)
x2 = OAR.run_parser(parser, text_2)
x3 = OAR.run_parser(parser, text_3)
t1 = OAR.vector_to_tree(x1, "1")
t2 = OAR.vector_to_tree(x2, "2")
t3 = OAR.vector_to_tree(x3, "3")

ts = OAR.df_to_trees(df, df_dict)
