"""
    test_sets.jl

# Description
The main collection of tests for the OAR.jl package.
This file loads common utilities and aggregates all other unit tests files.
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

# Preamble for all project scripts
# using DrWatson
# @quickactivate :OAR
using OAR

# -----------------------------------------------------------------------------
# DEPENDENCIES
# -----------------------------------------------------------------------------

using
    Logging,
    Test

# -----------------------------------------------------------------------------
# DrWatson tests
# -----------------------------------------------------------------------------

@testset "DrWatson Modifications" begin
    # Temp dir for
    test_dir = "testing"
    @info OAR.work_dir(test_dir)
    @info OAR.results_dir(test_dir)
end

# -----------------------------------------------------------------------------
# Grammar tests
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Iris grammar tests
# -----------------------------------------------------------------------------

@testset "IRIS" begin
    # Declare the IRIS categories and bins
    N = [
        "SL", "SW", "PL", "PW",
    ]
    bins = 10
    # Create a discretized CFG for real-valued data
    bnf = OAR.DescretizedCFG(OAR.quick_statement(N), bins=bins)
    # Make a random statement from that grammar
    statement = OAR.random_statement(bnf)

    # Make test assertions about structure
    @assert OAR.CFG <: OAR.Grammar

    # Make test assertions about types
    @assert bnf isa OAR.CFG
    @assert statement isa OAR.Statement
end

# -----------------------------------------------------------------------------
# GramART tests
# -----------------------------------------------------------------------------

@testset "GramART" begin
    # Get the symbolic IRIS dataset
    fs, bnf = OAR.symbolic_iris()

    # Test the constructors

    # Just the grammar
    art = OAR.GramART(bnf)

    # With preconstructed options
    opts = OAR.opts_GramART()
    art = OAR.GramART(bnf, opts)

    # With keyword arguments
    art = OAR.GramART(bnf, rho=0.8)
end

# -----------------------------------------------------------------------------
# Data utility tests
# -----------------------------------------------------------------------------

@testset "data_utils" begin
    # Declare the IRIS categories and bins
    N = [
        "SL", "SW", "PL", "PW",
    ]
    bins = 10

    # Load the real component of the data
    data = OAR.iris_tt_real()

    # Get the symbolic list of statements
    statements, bnf = OAR.real_to_symb(data, N)

    # Verify that the statements are a vectored datasplit
    @assert statements isa OAR.VectoredDataSplit
    @assert bnf isa OAR.CFG
end

@testset "GramART" begin
    # All-in-one function
    fs, bnf = OAR.symbolic_iris()

    # Initialize the GramART module
    gramart = OAR.GramART(bnf)

    @assert gramart isa OAR.GramART

    # Process the statements
    n_positions = length(bnf.S)
    # for statement in fs.train_x
    #     OAR.process_statement!(gramart, statement)
    # end
end
