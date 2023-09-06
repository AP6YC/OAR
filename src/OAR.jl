"""
    OAR.jl

# Description
Definition of the `OAR` module, which encapsulates experiment driver code.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

"""
A module encapsulating the experimental driver code for the OAR project.

# Imports

The following names are imported by the package as dependencies:
$(IMPORTS)

# Exports

The following names are exported and available when `using` the package:
$(EXPORTS)
"""
module OAR

# -----------------------------------------------------------------------------
# DEPENDENCIES
# -----------------------------------------------------------------------------

# Usings/imports for the whole package declared once
# using Reexport              # @reexport

# Full usings (which supports comma-separated import notation)
using
    AdaptiveResonance,      # ART algorithms
    ArgParse,               # ArgParseSettings
    # CSV,                    # CSV.File(...)
    Clustering,             # randindex
    ClusterValidityIndices,
    DataFrames,             # DataFrame
    DelimitedFiles,         # readdlm
    Distributed,            # myid()
    MLDatasets,             # Iris dataset
    MLUtils,                # Data utilities, splitting, etc.
    DocStringExtensions,    # Docstring utilities
    DrWatson,               # Project directory utilities
    InvertedIndices,        # Not()
    Latexify,
    Lerche,                 # Parsers
    NumericalTypeAliases,   # RealMatrix, IntegerVector, etc.
    # Parameters,             # @with_kw
    Pkg,                    # Version
    Plots,                  # Plot
    ProgressMeter,          # @showprogress
    Random,                 # seed!
    StatsPlots

# Precompile concrete type methods
import PrecompileSignatures: @precompile_signatures

import Statistics: median as statistics_median
import Statistics: mean as statistics_mean

import Parameters: @with_kw

# Imports
import
    CSV,                    # CSV.File(...)
    YAML

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

# Necessary to download data without prompts to custom folders
ENV["DATADEPS_ALWAYS_ACCEPT"] = true
# Suppress display on headless systems
ENV["GKSwstype"] = 100

# -----------------------------------------------------------------------------
# INCLUDES
# -----------------------------------------------------------------------------

# Library code
include("lib/lib.jl")

# -----------------------------------------------------------------------------
# EXPORTS
# -----------------------------------------------------------------------------

# Export all public names
export
    # Grammar names
    GSymbol,

    # START names
    START,
    DVSTART,
    DDVSTART,
    train!,
    classify,
    ProtoNode,
    TreeNode,

    # Version of the package
    OAR_VERSION

# -----------------------------------------------------------------------------
# PRECOMPILE
# -----------------------------------------------------------------------------

# Precompile any concrete-type function signatures
@precompile_signatures(OAR)

end
