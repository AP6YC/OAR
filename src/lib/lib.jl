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

# Version of the package as a constant
include("version.jl")

# Common docstrings and their templates
include("docstrings.jl")

# DrWatson extensions
include("drwatson.jl")

# Grammars and the Backus-Naur form
# include("grammar.jl")
include("grammar/lib.jl")

# GramART Julia implementation
include("GramART.jl")

# Data utilities
include("data_utils.jl")

# File and options utilities
include("file.jl")
