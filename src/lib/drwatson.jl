"""
    drwatson.jl

# Description
This file extends DrWatson workflow functionality such as by adding additional custom directory functions.

# Authors
- Sasha Petrenko <sap625@mst.edu>
"""

# -----------------------------------------------------------------------------
# COMMON DOCSTRINGS
# -----------------------------------------------------------------------------

const DRWATSON_ARGS_DOC = """
# Arguments
- `args...`: the string directories to append to the directory.
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
    mkpath(newdir())
    return newdir(args...)
end

"""
Points to the results directory.

$DRWATSON_ARGS_DOC
"""
function results_dir(args...)
    newdir(args...) = work_dir("results", args...)
    mkpath(newdir())
    return newdir(args...)
end
