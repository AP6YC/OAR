"""
    file.jl

# Description
File operation utilities, such as for loading simulation options and parsing arguments.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

"""
Definition of a configuration dictionary loaded from a config file.
"""
const ConfigDict = Dict{Any, Any}

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

"""
Loads the provided configuration YAML file.

# Arguments
$(ARG_CONFIG_FILE)
"""
function load_config(config_file::AbstractString)
    # Load and return the config file
    return YAML.load_file(
        config_dir(config_file);
        dicttype=ConfigDict
    )
end

# function get_sim_config(config_file::AbstractString)
#     return load_config(config_file)
# end

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
    # Return the common parser settings
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

    # Parse and return the args
    return parse_args(s)
end

"""
Parses the command line for common options in distributed experiments.

$ARG_ARGPARSE_DESCRIPTION
"""
function dist_exp_parse(description::AbstractString="A distributed OAR experiment script.")
    # Set up the parse settings
    s = get_argparsesettings(description)

    # Pick the default number of distributed processes
    default_n_procs = if Sys.iswindows()
        DEFAULT_N_PROCS_WINDOWS
    else
        DEFAULT_N_PROCS_UNIX
    end

    # Set up the arguments table
    @add_arg_table! s begin
        "--procs", "-p"
            help = "number of parallel processes"
            arg_type = Int
            default = default_n_procs
        # "--n_sims", "-n"
        #     help = "the number of simulations to run"
        #     arg_type = Int
        #     default = 1
        "--verbose", "-v"
            help = "verbose output"
            action = :store_true
    end

    # Parse and return the args
    return parse_args(s)
end

"""
Wrapper for how to save DataFrames in the `OAR` project.

# Arguments
- `df::DataFrame`: the dataframe to save.
- `savename::AbstractString`: the location to save the dataframe.
"""
function save_dataframe(df::DataFrame, savename::AbstractString)
    # Save the clustered statements to a CSV file
    CSV.write(savename, df)

    # Empty return
    return
end
