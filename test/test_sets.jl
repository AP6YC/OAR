"""
    test_sets.jl

# Description
The main collection of tests for the OAR.jl package.
This file loads common utilities and aggregates all other unit tests files.
"""

using
    Logging,
    Test

@testset "Boilerplate" begin
    @assert 1 == 1
    @info "Done testing"
end