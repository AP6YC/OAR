"""
    iris.jl

# Description
This script is a place to develop the symbolic version of the Iris dataset for validating GramART.
"""

using Revise

using DrWatson
@quickactivate :OAR

# Load the datasplit
data = OAR.iris_tt_real()

dv = OAR.VectoredDataSplit(data)

# Create a discretized symbolic version of the IRIS dataset
N = [
    "SL", "SW", "PL", "PW",
]

bins = 10

# bnf = OAR.DescretizedBNF(N)
bnf = OAR.DescretizedBNF(OAR.quick_symbolset(N), bins=bins)

statement = OAR.random_statement(bnf)

@info statement
