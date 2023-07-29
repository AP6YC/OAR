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

# The knowledge graph (e.g., Charcot-Marie-Tooth) parser
include("kg.jl")

# The symbolic IRIS dataset parser
include("iris.jl")

# The CMT protein data parser
include("cmt.jl")
