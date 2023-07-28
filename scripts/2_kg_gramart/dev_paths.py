from utils import (
    results_dir,
    # data_dir,
)

local_results_dir = results_dir("2_kg_gramart", "cmt")


def my_dir(file): return local_results_dir.joinpath(file)


print(my_dir("asdf"))
