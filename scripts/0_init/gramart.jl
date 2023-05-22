"""
    gramart.jl

# Description
This script is used in the development of GramART.
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using DrWatson
@quickactivate :OAR

# -----------------------------------------------------------------------------
# IRIS DATASET
# -----------------------------------------------------------------------------

N = [
    "SL", "SW", "PL", "PW",
]
bins = 10
bnf = OAR.DescretizedBNF(OAR.quick_symbolset(N), bins=bins)


# All-in-one function
fs = OAR.symbolic_iris()
# @info fs

# Make a protonode
pn = ProtoNode()
@info pn

# Make a treenode
tn = TreeNode("testing")
@info tn
