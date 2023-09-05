"""
    drwatson.jl

# Description
This file extends DrWatson workflow functionality such as by adding additional custom directory functions.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# CUSTOM DRWATSON DIRECTORY DEFINITIONS
# -----------------------------------------------------------------------------

"""
Points to the work directory containing raw datasets, processed datasets, and results.

$DRWATSON_ARGS_DOC
"""
function work_dir(args...)
    newdir(args...) = projectdir("work", args...)
    # mkpath(newdir(args...))
    return newdir(args...)
end

"""
Points to the results directory.

$DRWATSON_ARGS_DOC
"""
function results_dir(args...)
    newdir(args...) = work_dir("results", args...)
    # mkpath(newdir(args...))
    return newdir(args...)
end

"""
Points to the data directory.

$DRWATSON_ARGS_DOC
"""
function data_dir(args...)
    newdir(args...) = work_dir("data", args...)
    # mkpath(newdir(args...))
    return newdir(args...)
end

"""
Points to the configs directory.

$DRWATSON_ARGS_DOC
"""
function config_dir(args...)
    newdir(args...) = work_dir("configs", args...)
    # mkpath(newdir(args...))
    return newdir(args...)
end

"""
`DrWatson`-style paper results directory.

$DRWATSON_ARGS_DOC
"""
function paper_results_dir(args...)
    return joinpath(
        "C:\\",
        "Users",
        "Sasha",
        "Dropbox",
        "Apps",
        "Overleaf",
        "Paper-Biomed-Ontologies-GramART",
        "images",
        "results",
        args...
    )
end
