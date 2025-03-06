"""
    pluto_init.jl

# Description
Convenience script for loading and running Pluto for the project wrapped in a Revise call.
"""

# -----------------------------------------------------------------------------
# DEPENDENCIES
# -----------------------------------------------------------------------------

# Run Revise first
using Revise

# Load Pluto as a dependency
using Pluto

# -----------------------------------------------------------------------------
# RUN PLUTO
# -----------------------------------------------------------------------------

# Initialize the Pluto kernel
Pluto.run()
