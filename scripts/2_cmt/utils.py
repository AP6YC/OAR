"""
    utils.py

# Description
A collection of common Python utilities for the 2_cmt experiment.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

from pathlib import Path


def results_dir(*args) -> Path:
    results_path = Path("work", "results", "2_cmt")
    results_path.mkdir(parents=True, exist_ok=True)
    return results_path.joinpath(*args)


def data_dir(*args) -> Path:
    data_path = Path("work", "data", "cmt")
    return data_path.joinpath(*args)
