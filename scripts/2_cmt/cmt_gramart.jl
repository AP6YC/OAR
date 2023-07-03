"""
    gramart.jl

# Description
This script shows how to use a GramART to cluster on the Iris dataset.

# Authors
- Sasha Petrenko <sap625@mst.edu>
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

# -----------------------------------------------------------------------------
# ADDITIONAL DEPENDENCIES
# -----------------------------------------------------------------------------

using Lerche

# -----------------------------------------------------------------------------
# PARSE ARGS
# -----------------------------------------------------------------------------

# Parse the arguments provided to this script
pargs = OAR.exp_parse(
    "2_cmt/gramart.jl: GramART for clustering a Charcot-Marie."
)

# -----------------------------------------------------------------------------
# CMT DATASET
# -----------------------------------------------------------------------------

"""
    lerche-iris-symb.jl

# Description
This script uses the Lerche parsing library for parsing Iris dataset statements into symbolic trees.

# Authors
- Sasha Petrenko <sap625@mst.edu>
"""
# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using DrWatson
@quickactivate :OAR

# -----------------------------------------------------------------------------
# DEPENDENCIES
# -----------------------------------------------------------------------------

# Parsing library
using Lerche

# -----------------------------------------------------------------------------
# EXPERIMENT
# -----------------------------------------------------------------------------

# Declare the rules of the symbolic Iris grammar
cmt_edge_grammar = raw"""
    ?start: statement

    statement: sl sw pl pw

    sl : SL -> iris_symb
    sw : SW -> iris_symb
    pl : PL -> iris_symb
    pw : PW -> iris_symb

    SL : /SL[1-9]?[0-9]?/
    SW : /SW[1-9]?[0-9]?/
    PL : /PL[1-9]?[0-9]?/
    PW : /PW[1-9]?[0-9]?/

    %import common.WS
    %ignore WS
"""

# The grammar tree subtypes from a Lerche Transformer
struct GramARTTree <: Transformer end

# The rules turn the terminals into `OAR` grammar symbols and statements into vectors
@rule iris_symb(t::GramARTTree, p) = OAR.GSymbol{String}(p[1], true)
@rule statement(t::GramARTTree, p) = Vector(p)

# Create the parser from these rules
iris_parser = Lark(
    iris_grammar,
    parser="lalr",
    lexer="standard",
    transformer=GramARTTree()
)

# Set some sample text as the input statement
text = raw"SL1 SW3 PL4 PW8"

# Parse the statement
k = Lerche.parse(iris_parser, text)


# # All-in-one function
# fs, bnf = OAR.symbolic_iris()

# # Initialize the GramART module
# gramart = OAR.GramART(bnf)
# gramart.opts.rho = 0.5
# @info gramart

# # Process the statements
# for statement in fs.train_x
#     # OAR.process_statement!(gramart, statement, 1)
#     OAR.train!(gramart, statement)
# end
# # s = fs.train_x[1]
# # OAR.train!(gramart, s)
