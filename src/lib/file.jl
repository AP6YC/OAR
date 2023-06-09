"""
    file.jl

# Description
File operation utilities, such as for loading simulation options and parsing arguments.
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
Parses the command line for common options in distributed experiments.
"""
function dist_exp_parse()
    # Set up the parse settings
    s = ArgParseSettings(
        description = "A distributed experiment script",
        commands_are_required = false,
        version = string(OAR_VERSION),
        add_version = true
    )

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
