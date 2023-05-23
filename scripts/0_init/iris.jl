"""
    iris.jl

# Description
This script is a place to develop the symbolic version of the Iris dataset for validating GramART.
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

# Load the datasplit
data = OAR.iris_tt_real()

# Make a vectored version for fun
dv = OAR.VectoredDataSplit(data)

# Create a discretized symbolic version of the IRIS dataset
N = [
    "SL", "SW", "PL", "PW",
]

bins = 10

# bnf = OAR.DescretizedBNF(N)
bnf = OAR.DescretizedBNF(OAR.quick_statement(N), bins=bins)

# Make a random statement from the grammar
statement = OAR.random_statement(bnf)
@info statement

# Make a symbolic version of the Iris data
statements = OAR.real_to_symb(data, N)
@info statements

# All-in-one function
fast_statements = OAR.symbolic_iris()
@info fast_statements
