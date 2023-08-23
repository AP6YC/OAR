# `3_cmt/`

This experiment clusters CMT protein data with GramART.

## Scripts

- `1_gramart.jl`: a single pass of clustering the flat file protein data with GramART.
- `2_gramart_serial.jl`: a hyperparameter sweep simply implemented in serial.
- `3_gramart_dist.jl`: the same hyperparameter sweep implemented in parallel for faster experimentation.
- `4_analyze_dist.jl`: because of the way that results are saved in distributed experiments in this project, this script analyzes the results from `3_gramart_dist.jl` and generates metadata, plots, etc.

## TODO

1. Number of clusters
2. Maximum membership
3. Number with one member
