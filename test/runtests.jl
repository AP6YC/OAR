"""
    runtests.jl

The entry point to unit tests for the `OAR` project.
"""

# -----------------------------------------------------------------------------
# DEPENDENCIES
# -----------------------------------------------------------------------------

# using SafeTestsets
using Test

# -----------------------------------------------------------------------------
# SAFETESTSETS
# -----------------------------------------------------------------------------

# @safetestset "All Test Sets" begin
@testset verbose=true showtiming=true "OAR" begin
    include("test_sets.jl")
end
# end
