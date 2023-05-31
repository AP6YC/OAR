# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using DrWatson
@quickactivate :OAR

using Lerche

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

struct GramARTTree <: Transformer end

@rule iris_symb(t::GramARTTree, p) = OAR.GSymbol(p[1], true)
@rule statement(t::GramARTTree, p) = Set(p)

iris_parser = Lark(iris_grammar, parser="lalr", lexer="standard", transformer=GramARTTree());
text = raw"SL1 SW3 PL4 PW8"

k = Lerche.parse(iris_parser, text)