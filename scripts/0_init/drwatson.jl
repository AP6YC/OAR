"""
    drwatson.jl

# Description
This script tinkers with the various DrWatson.jl directory locations as well as

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using DrWatson
@quickactivate :OAR

# -----------------------------------------------------------------------------
# DRWATSON BASE DIR COMMANDS
# -----------------------------------------------------------------------------

@info datadir()
@info srcdir()
@info plotsdir()
@info scriptsdir()
@info papersdir()

# -----------------------------------------------------------------------------
# CUSTOM DRWATSON DIR COMMANDS
# -----------------------------------------------------------------------------

exp_name = "0_init"

@info OAR.work_dir(exp_name)
@info OAR.results_dir(exp_name)
