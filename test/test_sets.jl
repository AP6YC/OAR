"""
    test_sets.jl

# Description
The main collection of tests for the OAR.jl package.
This file loads common utilities and aggregates all other unit tests files.
"""

# Preamble for all project scripts
using DrWatson
@quickactivate :OAR

using
    Logging,
    Test

@testset "DrWatson Modifications" begin
    # Temp dir for
    test_dir = "testing"
    @info OAR.work_dir(test_dir)
    @info OAR.results_dir(test_dir)
end

@testset "EBNF" begin
    # Declare the IRIS categories and bins
    N = [
        "SL", "SW", "PL", "PW",
    ]
    bins = 10
    # Create a discretized BNF for real-valued data
    bnf = OAR.DescretizedBNF(OAR.quick_symbolset(N), bins=bins)
    # Make a random statement from that grammar
    statement = OAR.random_statement(bnf)

    # Make test assertions about structure
    @assert OAR.BNF <: OAR.Grammar

    # Make test assertions about types
    @assert bnf isa OAR.BNF
    @assert statement isa OAR.Statement
end

@testset "Iris" begin
    # Declare the IRIS categories and bins
    N = [
        "SL", "SW", "PL", "PW",
    ]
    bins = 10

    # Load the real component of the data
    data = OAR.iris_tt_real()

    # Get the symbolic list of statements
    symb_statements = OAR.real_to_symb(data, N)

    # Verify that the statements are a vectored datasplit
    @assert symb_statements isa OAR.VectoredDataSplit
end