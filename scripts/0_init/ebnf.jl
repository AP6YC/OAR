"""
    ebnf.jl

# Description
Demo experiment with an extended Backus-Naur form grammar.

# Authors
- Sasha Petrenko <sap625@mst.edu>
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using DrWatson
@quickactivate :OAR

# -----------------------------------------------------------------------------
# DEPENDENCIES
# -----------------------------------------------------------------------------

using Revise

# -----------------------------------------------------------------------------
# EXPERIMENT
# -----------------------------------------------------------------------------

N = [
    "SL", "SW", "PL", "PW",
]

bnf = OAR.DescretizedBNF(N)

statement = OAR.random_statement(bnf)

@info statement
