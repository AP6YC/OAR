using OAR       # The OAR project module
using Lerche    # Parsing library

# Statements in this grammar are simply four nonterminal positions with four bins of terminals.
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

# Create the Lark parser from the grammar, transformer, and additional settings
iris_parser = Lark(
    iris_grammar,
    parser="lalr",
    lexer="standard",
    transformer=STARTTree()
);

text = raw"SL1 SW3 PL4 PW8"

k = Lerche.parse(iris_parser, text)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
