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
Docstring prefix denoting that the constant is used as a common docstring element for other docstrings.
"""
const COMMON_DOC = "Common docstring:"

"""
$COMMON_DOC the arguments to `DrWatson`-style directory functions.
"""
const DRWATSON_ARGS_DOC = """
# Arguments
- `args...`: the string directories to append to the directory.
"""

"""
$COMMON_DOC the arguments to argparse functions taking a description.
"""
const ARG_ARGPARSE_DESCRIPTION = """
# Arguments
- `description::AbstractString`: optional positional, the script description for the parser
"""

"""
$COMMON_DOC a CFG grammar argument.
"""
const ARG_CFG = """
- `grammar::CFG`: the [`OAR.CFG`] context-free grammar to use.
"""

"""
$COMMON_DOC argument for a directory function
"""
const ARG_SIM_DIR_FUNC = """
- `dir_func::Function`: the function that provides the correct file path with provided strings.
"""

"""
$COMMON_DOC argument for the simulation options dictionary.
"""
const ARG_SIM_D = """
- `d::AbstractDict`: the simulation options dictionary.
"""

"""
$COMMON_DOC argument for the simulation statements to train upon and cluster.
"""
const ARG_SIM_TS = """
- `ts::SomeStatements`: a set of statements of type `Union{TreeStatements, Statements}`.
"""

"""
$COMMON_DOC argument for additional simulation options.
"""
const ARG_SIM_OPTS = """
- `opts::AbstractDict`: additional options for the simulation.
"""

"""
$COMMON_DOC config filename argument.
"""
const ARG_CONFIG_FILE = """
- `config_file::AbstractString`: the config file name as a string.
"""
