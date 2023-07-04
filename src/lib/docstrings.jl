"""
    docstrings.jl

# Description
A collection of common docstrings and docstring templates for the package.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# DOCSTRING TEMPLATES
#   These templates tell `DocStringExtensions.jl` how to customize docstrings of various types.
# -----------------------------------------------------------------------------

# Constants template
@template CONSTANTS =
"""
$(FUNCTIONNAME)

# Description
$(DOCSTRING)
"""

# Types template
@template TYPES =
"""
$(TYPEDEF)

# Summary
$(DOCSTRING)

# Fields
$(TYPEDFIELDS)
"""

# Template for functions, macros, and methods (i.e., constructors)
@template (FUNCTIONS, METHODS, MACROS) =
"""
$(TYPEDSIGNATURES)

# Summary
$(DOCSTRING)

# Method List / Definition Locations
$(METHODLIST)
"""

# -----------------------------------------------------------------------------
# DOCSTRING CONSTANTS
#   This location is a collection of variables used for injecting into other docstrings.
# This is useful when many functions utilize the same arguments, etc.
# -----------------------------------------------------------------------------

"""
Common docstring, the arguments to `DrWatson`-style directory functions.
"""
const DRWATSON_ARGS_DOC = """
# Arguments
- `args...`: the string directories to append to the directory.
"""

"""
Common docstring, the arguments to argparse functions taking a description.
"""
const ARG_ARGPARSE_DESCRIPTION = """
# Arguments
- `description::AbstractString`: optional positional, the script description for the parser
"""

"""
Common docstring, a CFG grammar argument.
"""
const ARG_CFG = """
- `grammar::CFG`: the [`OAR.CFG`] context-free grammar to use.
"""
