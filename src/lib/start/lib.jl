"""
    lib.jl

# Description
Aggregates all types and functions relevant to the START implementation.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# INCLUDES
# -----------------------------------------------------------------------------

# Constants and aliases
include("constants.jl")

# Common structs, constructors, and functions
include("common.jl")

# Dual-vigilance definitions
include("start.jl")

# Dual-vigilance definitions
include("dv.jl")

# Distributed dual-vigilance definitions
include("ddv.jl")

# Functions for training and classifying with START
include("functions.jl")

# TreeNode-based training and classification functions
include("tn_functions.jl")
