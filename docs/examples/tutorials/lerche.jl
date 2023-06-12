# ---
# title: Lerche Parsing
# id: lerche
# date: 2023-6-12
# cover: ../assets/parse.png
# author: "[Sasha Petrenko](https://github.com/AP6YC)"
# julia: 1.9
# description: This demo provides a quick example of how to load the Iris dataset with existing Julia tools.
# ---

# ## Overview

# This example shows how the the `Lerche.jl` parsing library works, which provides the necessary machinery to define `lark`-like grammars and parse statements into arbitrary Julia structures to interface with the GramART tools in this project.
# These tools are demonstrated on the how to parse approximate symbolic statements of the real-valued Iris dataset back into a tree that can be used in GramART.

# ## Setup

# First, we load some dependencies:

using OAR       # The OAR project module
using Lerche    # Parsing library

# Next, we declare the rules of the symbolic Iris grammar using the syntax and format provided by the `Leche` library and the `lark` Python library that it is inspired by.

## Statements in this grammar are simply four nonterminal positions with four bins of terminals.
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

# Next, we set up the parsing transformer and its rules for transforming the symbols that the parser encounters into Julia datatypes.

## The grammar tree subtypes from a Lerche Transformer
struct GramARTTree <: Transformer end

## The rules turn the terminals into `OAR` grammar symbols and statements into vectors
@rule iris_symb(t::GramARTTree, p) = OAR.GSymbol{String}(p[1], true)
@rule statement(t::GramARTTree, p) = Vector(p)

# Finally, we create the parser from these rules:

## Create the Lark parser from the grammar, transformer, and additional settings
iris_parser = Lark(
    iris_grammar,
    parser="lalr",
    lexer="standard",
    transformer=GramARTTree()
);

# We can then set some sample text as the input statement:

text = raw"SL1 SW3 PL4 PW8"

# And we parse the statement, seeing that we indeed get a vector of of `OAR.GSymbol`s:

k = Lerche.parse(iris_parser, text)
