"""
    utils.py

# Description
A collection of common Python utilities for the `2_cmt` experiment.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# IMPORTS
# -----------------------------------------------------------------------------

from pathlib import Path

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------


def results_dir(*args) -> Path:
    """Points to the results directory for the 2_cmt experiment.

    Pass a series of directories as paths (in the form of `pathlib.Path.joinpath(...)`) to point to the desired results file/folder.

    Returns
    -------
    Path
        A `pathlib.Path` pointing to the location of `*args` in the `2_cmt` experiment results directory.
    """

    # Point to the experiment's results path
    results_path = Path("work", "results", "2_cmt")

    # Verirfy that the directory exists
    results_path.mkdir(parents=True, exist_ok=True)

    # Return the results path joined by the arguments
    return results_path.joinpath(*args)


def data_dir(*args) -> Path:
    """Point to the data directory for the `2_cmt` experiment.

    Pass a series of directories as paths (in the form of `pathlib.Path.joinpath(...)`) to point to the desired data file/folder.

    Returns
    -------
    Path
        A `pathlib.Path` pointing to the location of `*args` in the `2_cmt` experiment data directory.
    """

    # Point to the experiment's data path
    data_path = Path("work", "data", "cmt")

    # Return the data path joined by the arguments
    return data_path.joinpath(*args)
