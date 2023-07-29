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

    phenotypes = [
        "ataxia",
        "atrophy",
        "auditory",
        "autonomic",
        "behavior",
        "cognitive",
        "cranial_nerve",
        "deformity",
        "dystonia",
        "gait",
        "hyperkinesia",
        "hyperreflexia",
        "hypertonia",
        "hypertrophy",
        "hyporeflexia",
        "hypotonia",
        "muscle",
        "pain",
        "seizure",
        "sensory",
        "sleep",
        "speech",
        "tremor",
        "visual",
        "weakness",
    ]

    # Generate a new column of piped elements
    phenotype_column = Vector{String}()
    for row in eachrow(df)
        element = ""
        for phen in phenotypes
            if row[phen] == 1
                element *= " | " * phen
            end
        end
        push!(phenotype_column, element)
    end

    # Add the phenotypes column to the dataframe
    df.phenotypes = phenotype_column
    # Return the sanitized dataframe
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

function protein_df_to_strings(df::DataFrame)
    columns = [
        "gene_location",
        "disease_MIM",
        "gene",
        "gene_MIM",
        "inheritance",
        "protein",
        "uniprot",
        "chromosome",
        "chromosome_location",
        "protein_class",
        "biologic_process",
        "molecular_function",
        "disease_involvement",
        "MW",
        "domain",
        "motif",
        "protein_location",
        "length",
        "disease_MIM2",
        "weight_tag",
        "length_tag",
        "phenotypes",
    ]

    statements = Vector{String}()

    for row in eachrow(df)
        statement = raw""
        for column in columns
            statement *= "'" * string(row[column]) * "' "
        end
        push!(statements, statement)
    end

    return statements
end

df = load_cmt(input_file)
df_dict = load_cmt_dict(data_dict_file)


statements = protein_df_to_strings(df)

parser = OAR.get_cmt_parser()

OAR.run_parser(parser, statements[1])
