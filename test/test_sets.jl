"""
    test_sets.jl

# Description
The main collection of tests for the OAR.jl package.
This file loads common utilities and aggregates all other unit tests files.
"""

using DrWatson
@quickactivate :OAR

using
    # DrWatson,
    # OAR,
    Logging,
    Test

@testset "Boilerplate" begin
    @assert 1 == 1
    @info "Done testing"
end

@testset "EBNF" begin
    # Declare the IRIS categories and bins
    N = [
        "SL", "SW", "PL", "PW",
    ]
    bins = 10
    # Create a discretized BNF for real-valued data
    bnf = OAR.DescretizedBNF(N)
    # Make a random statement from that grammar
    statement = OAR.random_statement(bnf)

    # Make test assertions about structure
    @assert OAR.BNF <: OAR.Grammar

    # Make test assertions about types
    @assert bnf isa OAR.BNF
    @assert statement isa OAR.Statement
end

