"""
TODO

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
    # ExprTools,
    NumericalTypeAliases,
    Reexport

# Precompile concrete type methods
using PrecompileSignatures: @precompile_signatures

# -----------------------------------------------------------------------------
# INCLUDES
# -----------------------------------------------------------------------------

include("lib.jl")
include("version.jl")

# -----------------------------------------------------------------------------
# EXPORTS
# -----------------------------------------------------------------------------

export OAR_VERSION

# -----------------------------------------------------------------------------
# PRECOMPILE
# -----------------------------------------------------------------------------

# Precompile any concrete-type function signatures
@precompile_signatures(AdaptiveResonance)

end
