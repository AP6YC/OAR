"""
    OAR.jl

# Description
Definition of the `OAR` module, which encapsulates experiment driver code.
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
using Reexport              # @reexport

# Full usings (which supports comma-separated import notation)
using
    AdaptiveResonance,      # ART algorithms
    ArgParse,
    DocStringExtensions,    # Docstring utilities
    DrWatson,
    NumericalTypeAliases,   # RealMatrix, IntegerVector, etc.
    Pkg                    # Version

# Precompile concrete type methods
using PrecompileSignatures: @precompile_signatures

# Imports
import YAML

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

# Necessary to download data without prompts to custom folders
ENV["DATADEPS_ALWAYS_ACCEPT"] = true

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
    # GramART
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
