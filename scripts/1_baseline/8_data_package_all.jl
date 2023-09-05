"""
    8_data_package_all.jl

# Description
All datasets from the Datasets package.

# Attribution

## Citations
- Ilc, Nejc. (2013). Datasets package.

## BibTeX
@misc{dataset,
    author = {Ilc, Nejc},
    year = {2013},
    month = {06},
    pages = {},
    title = {Datasets package}
}
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

# -----------------------------------------------------------------------------
# ADDITIONAL DEPENDENCIES
# -----------------------------------------------------------------------------

# using DataFrames
using Random
# Random.seed!(1234)
Random.seed!(1235)
using ProgressMeter

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

exp_top = "1_baseline"
exp_name = "8_data_package_all.jl"

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "$(exp_top)/$(exp_name): START for clustering all Dataset package datasets."
)

# -----------------------------------------------------------------------------
# ALL REAL DATASETS
# -----------------------------------------------------------------------------

# Point to the top of the data package directory
topdir =  OAR.data_dir("data-package")

# Walk the directory
for (root, dirs, files) in walkdir(topdir)
    # Iterate over all of the files
    for file in files
        # Get the full filename for the current data file
        filename = joinpath(root, file)

        # Load the symbolic data and grammar
        data, grammar = OAR.symbolic_dataset(filename)

        # Initialize the START modules with options
        start = OAR.START(grammar,
            rho = 0.1,
            epochs=1,
        )
        dvstart = OAR.DVSTART(grammar,
            rho_lb = 0.1,
            rho_ub = 0.3,
            epochs=1,
        )
        ddvstart = OAR.DDVSTART(grammar,
            rho_lb = 0.1,
            rho_ub = 0.3,
            epochs=1,
        )

        # Run all serial simulations
        @info "---------- $(file) - START ----------"
        OAR.tt_serial(
            start,
            data,
            display=true,
        )
        @info "---------- $(file) - DVSTART ----------"
        OAR.tt_serial(
            dvstart,
            data,
            display=true,
        )
        @info "---------- $(file) - DDVSTART ----------"
        OAR.tt_serial(
            ddvstart,
            data,
            display=true,
        )
    end
end
