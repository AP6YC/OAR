"""
    lib.jl

# Description
Aggregates all types and functions that are used throughout the `OAR` project.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# INCLUDES
# -----------------------------------------------------------------------------

# Common experiment utilities, docstrings, and functions
include("utils/lib.jl")

# Grammars definitions
include("grammar/lib.jl")

# GramART Julia implementation
include("gramart/lib.jl")

# Lerche parsers
include("parsers/lib.jl")
