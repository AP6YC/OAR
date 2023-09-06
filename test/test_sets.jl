"""
    test_sets.jl

# Description
The main collection of tests for the `OAR` project.
This file loads common utilities and aggregates all other unit tests files.
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using OAR

# -----------------------------------------------------------------------------
# ADDITIONAL DEPENDENCIES
# -----------------------------------------------------------------------------

using
    Aqua,
    Logging,
    Test

# -----------------------------------------------------------------------------
# COMMON VARIABLES SETUP
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# AQUA
# -----------------------------------------------------------------------------

# @testset "Aqua.jl" begin
#     Aqua.test_all(
#         OAR;
#     #   ambiguities=(exclude=[SomePackage.some_function], broken=true),
#         ambiguities=false,
#         unbound_args=true,
#         undefined_exports=true,
#         project_extras=true,
#         stale_deps=(ignore=[
#             :PlutoUI,
#             :Revise,
#             :Pluto,
#         ],),
#         # deps_compat=(ignore=[:SomeOtherPackage],),
#         project_toml_formatting=true,
#         piracy=false,
#         # piracy=true,
#     )
#   end

# -----------------------------------------------------------------------------
# DRWATSON MODIFICATIONS TESTS
# -----------------------------------------------------------------------------

@testset "DrWatson Modifications" begin
    # Temp dir for testing
    # asdf
    test_dir = "testing"
    @info OAR.work_dir(test_dir)
    @info OAR.results_dir(test_dir)
end

# -----------------------------------------------------------------------------
# GRAMMAR TESTS
# -----------------------------------------------------------------------------

@testset "Symbols" begin
    @assert OAR.Terminal("a") isa OAR.GSymbol
    @assert OAR.NonTerminal("b") isa OAR.GSymbol
end

@testset "IRIS Parser" begin
    # Construct the symbolic IRIS dataset parser
    iris_parser = OAR.get_iris_parser()

    # Set some sample text as the input statement
    text = raw"SL1 SW3 PL4 PW8"

    # Parse the statement
    k = OAR.run_parser(iris_parser, text)
end

@testset "KG Parser" begin
    # Construct the CMT dataset parser
    kg_parser = OAR.get_kg_parser()

    # Set some sample text as the input statement
    text = raw"\"Periaxin\" \"is_a\" \"protein\""

    # Parse the statement
    k = OAR.run_parser(kg_parser, text)
end

# -----------------------------------------------------------------------------
# IRIS GRAMMAR TESTS
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
# GRAMART TESTS
# -----------------------------------------------------------------------------

@testset "START" begin
    # Get the symbolic IRIS dataset
    fs, bnf = OAR.symbolic_iris()

    # Test the constructors

    # Just the grammar
    art = OAR.START(bnf)

    @assert art isa OAR.START

    # With preconstructed options
    opts = OAR.opts_START()
    art = OAR.START(bnf, opts)

    # With keyword arguments
    art = OAR.START(bnf, rho=0.8)
end

# -----------------------------------------------------------------------------
# DATA UTILITY TESTS
# -----------------------------------------------------------------------------

@testset "data_utils" begin
    # Declare the IRIS categories and bins
    N = [
        "SL", "SW", "PL", "PW",
    ]
    bins = 10

    # Load the real component of the data
    # data = OAR.iris_tt_real()
    data = OAR.tt_real(:Iris)

    # Get the symbolic list of statements
    statements, bnf = OAR.real_to_symb(data, N)

    # Verify that the statements are a vectored datasplit
    @assert statements isa OAR.VectoredDataSplit
    @assert bnf isa OAR.CFG
end
