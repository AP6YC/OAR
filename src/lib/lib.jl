"""
    lib.jl

# Description
Aggregates all common types and functions that are used throughout `AdaptiveResonance.jl`.

# Authors
- Sasha Petrenko <sap625@mst.edu>
"""

# -----------------------------------------------------------------------------
# DEPENDENCIES
# -----------------------------------------------------------------------------

# Common docstrings and their templates
include("docstrings.jl")
# DrWatson extensions
include("drwatson.jl")
# Backus-Naur form
include("BNF.jl")
# GramART Julia implementation
include("GramART.jl")
