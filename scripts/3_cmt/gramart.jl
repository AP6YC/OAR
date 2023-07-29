"""
    gramart.jl

# Description
This script uses GramART to cluster CMT protein data.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

# -----------------------------------------------------------------------------
# ADDITIONAL DEPENDENCIES
# -----------------------------------------------------------------------------

using ProgressMeter
using DataFrames
using CSV

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

# Input CSV file
input_file = OAR.data_dir("cmt", "output_CMT_file.csv")
data_dict_file = OAR.data_dir("cmt", "cmt_data_dict.csv")

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "3_cmt/gramart.jl: GramART for clustering disease protein statements."
)

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

function load_cmt(file::AbstractString)
    df = DataFrame(CSV.File(file))

    # ataxia
    # atrophy
    # auditory
    # autonomic
    # behavior
    # cognitive
    # cranial_nerve
    # deformity
    # dystonia
    # gait
    # hyperkinesia
    # hyperreflexia
    # hypertonia
    # hypertrophy
    # hyporeflexia
    # hypotonia
    # muscle
    # pain
    # seizure
    # sensory
    # sleep
    # speech
    # tremor
    # visual
    # weakness

    return df
end

function load_cmt_dict(file::AbstractString)
    df_dict = DataFrame(CSV.File(file))
    # Sanitize
    df_dict.pipes = replace(df_dict.pipes, "yes" => true)
    df_dict.pipes = replace(df_dict.pipes, missing => false)
    df_dict.pipes = Bool.(df_dict.pipes)
    return df_dict
end

df = load_cmt(input_file)
df_dict = load_cmt_dict(data_dict_file)
