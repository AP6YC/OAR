"""
    gramart.jl

# Description
This script shows how to use a GramART to cluster on the Iris dataset.

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

# Parsing library
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

# SUBJECT     : /[^']+/
# PREDICATE   : /[^']+/
# OBJECT      : /[^']+/

# Declare the rules of the symbolic Iris grammar
cmt_edge_grammar = raw"""
    ?start: statement

    statement: subject predicate object

    subject     : SUBJECT -> cmt_symb
    predicate   : PREDICATE -> cmt_symb
    object      : OBJECT -> cmt_symb

    SUBJECT     : /(\w)+/
    PREDICATE   : /(\w)+/
    OBJECT      : /(\w)+/

    %import common.WS
    %ignore WS
"""

# The grammar tree subtypes from a Lerche Transformer
struct GramARTTree <: Transformer end

# The rules turn the terminals into `OAR` grammar symbols and statements into vectors
# @rule iris_symb(t::GramARTTree, p) = OAR.GSymbol{String}(p[1], true)
# @rule statement(t::GramARTTree, p) = Vector(p)

# Create the parser from these rules
cmt_parser = Lark(
    cmt_edge_grammar,
    parser="lalr",
    lexer="standard",
    transformer=GramARTTree()
)

# Set some sample text as the input statement
text = raw"Periaxin is_a protein"

# Parse the statement
k = Lerche.parse(cmt_parser, text)


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
