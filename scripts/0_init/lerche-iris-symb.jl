"""
    lerche-iris-symb.jl

# Description
This script uses the Lerche parsing library for parsing Iris dataset statements into symbolic trees.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

# -----------------------------------------------------------------------------
# DEPENDENCIES
# -----------------------------------------------------------------------------

# Parsing library
using Lerche

# -----------------------------------------------------------------------------
# EXPERIMENT
# -----------------------------------------------------------------------------

# Declare the rules of the symbolic Iris grammar
iris_grammar = raw"""
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
struct STARTTree <: Transformer end

# The rules turn the terminals into `OAR` grammar symbols and statements into vectors
@rule iris_symb(t::STARTTree, p) = OAR.GSymbol{String}(p[1], true)
@rule statement(t::STARTTree, p) = Vector(p)

# Create the parser from these rules
iris_parser = Lark(
    iris_grammar,
    parser="lalr",
    lexer="standard",
    transformer=STARTTree()
)

# Set some sample text as the input statement
text = raw"SL1 SW3 PL4 PW8"

# Parse the statement
k = Lerche.parse(iris_parser, text)
