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

    N = [
        "SL", "SW", "PL", "PW",
    ]

    bins = 10

    bnf = OAR.DescretizedBNF(N)

    statement = OAR.random_statement(bnf)
end

