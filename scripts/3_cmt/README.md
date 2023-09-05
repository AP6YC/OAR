# `3_cmt/`

This experiment clusters CMT protein data with START.

## Scripts

- `1_start.jl`: a single pass of clustering the flat file protein data with START.
- `2_start_serial.jl`: a hyperparameter sweep simply implemented in serial.
- `3_start_dist.jl`: the same hyperparameter sweep implemented in parallel for faster experimentation.
- `4_analyze_dist.jl`: because of the way that results are saved in distributed experiments in this project, this script analyzes the results from `3_start_dist.jl` and generates metadata, plots, etc.
