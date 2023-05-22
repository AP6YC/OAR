"""
    gramart.jl

# Description
This script shows how to use a GramART to cluster on the Iris dataset.
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

# All-in-one function
fast_statements = OAR.symbolic_iris()
@info fast_statements
