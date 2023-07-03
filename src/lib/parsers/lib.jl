"""
    lib.jl

# Description
Aggregates all parsers in the `OAR` project.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# INCLUDES
# -----------------------------------------------------------------------------

# Common parsing definitions and functions
include("common.jl")

# The Charcot-Marie-Tooth parser
include("cmt.jl")

# The symbolic IRIS dataset parser
include("iris.jl")
