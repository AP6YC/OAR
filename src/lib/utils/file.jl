"""
    file.jl

# Description
File operation utilities, such as for loading simulation options and parsing arguments.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

"""
Loads the provided options YAML file.

# Arguments
- `file::AbstractString`: the YAML file to load.
"""
function load_opts(file::AbstractString)
    # Point to the default location of the file
    full_path = projectdir("opts", file)
    # Load the YAML options file as a string-keyed dictionary
    file_opts = YAML.load_file(full_path, dicttype=Dict{String, Any})
    # Return the dictionary
    return file_opts
end

"""
Common function for how `ArgParse.ArgParseSettings` are generated in the project.

$ARG_ARGPARSE_DESCRIPTION
"""
function get_argparsesettings(description::AbstractString="")
    # Set up the parse settings
    s = ArgParseSettings(
        description = description,
        commands_are_required = false,
        version = string(OAR_VERSION),
        add_version = true
    )
    return s
end

"""
Parses the command line for common options in serial (non-distributed) experiments.

$ARG_ARGPARSE_DESCRIPTION
"""
function exp_parse(description::AbstractString="An OAR experiment script.")
    # Set up the parse settings
    s = get_argparsesettings(description)

    # Set up the arguments table
    @add_arg_table! s begin
        "--paper", "-p"
            help = "flag for saving results to the paper directory"
            action = :store_true
        "--display", "-d"
            help = "flag for displaying generated figures"
            action = :store_true
        "--verbose", "-v"
            help = "flag for verbose output"
            action = :store_true
    end

    return parse_args(s)
end

"""
Parses the command line for common options in distributed experiments.

$ARG_ARGPARSE_DESCRIPTION
"""
function dist_exp_parse(description::AbstractString="A distributed OAR experiment script.")
    # Set up the parse settings
    s = get_argparsesettings(description)

    # Set up the arguments table
    @add_arg_table! s begin
        "--procs", "-p"
            help = "number of parallel processes"
            arg_type = Int
            default = 0
        "--n_sims", "-n"
            help = "the number of simulations to run"
            arg_type = Int
            default = 1
        "--verbose", "-v"
            help = "verbose output"
            action = :store_true
    end

    return parse_args(s)
end

