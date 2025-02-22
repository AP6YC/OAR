"""
    lib.jl

# Description
Aggregates all common types and functions that are used throughout the `OAR` project.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# INCLUDES
# -----------------------------------------------------------------------------

# Constants regarding internal functionality of the project
include("constants.jl")

# Version of the package as a constant
include("version.jl")

# Common docstrings and their templates
include("docstrings.jl")

# DrWatson extensions
include("drwatson.jl")

# Data utilities
include("data_utils.jl")

# File and options utilities
include("file.jl")

# Plotting functions and recipes
include("plot.jl")
