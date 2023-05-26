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

# Full usings (which supports comma-separated import notation)
using
    AdaptiveResonance,
    DocStringExtensions,    # Docstring utilities
    DrWatson,
    NumericalTypeAliases,
    Reexport

# Precompile concrete type methods
using PrecompileSignatures: @precompile_signatures

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
# Version for the package
include("version.jl")

# -----------------------------------------------------------------------------
# EXPORTS
# -----------------------------------------------------------------------------

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
