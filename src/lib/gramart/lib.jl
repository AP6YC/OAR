"""
    lib.jl

# Description
Aggregates all types and functions relevant to the GramART implementation.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# INCLUDES
# -----------------------------------------------------------------------------

# Constants and aliases
include("constants.jl")

# Structs and their constructors
include("types.jl")

# Functions for training and classifying with GramART
include("functions.jl")

# TreeNode-based training and classification functions
include("tn_functions.jl")
