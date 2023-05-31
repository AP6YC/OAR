using Revise
using Lerche

json_grammar = raw"""
    ?start: value

    ?value: object
            | array
            | string
            | SIGNED_NUMBER      -> number
            | "true"             -> t
            | "false"            -> f
            | "null"             -> null

    array  : "[" [value ("," value)*] "]"
    object : "{" [pair ("," pair)*] "}"
    pair   : string ":" value

    string : ESCAPED_STRING

    %import common.ESCAPED_STRING
    %import common.SIGNED_NUMBER
    %import common.WS

    %ignore WS
"""

# _separated{x, sep}: x (sep x)*

# num_list: "[" _separated{NUMBER, ","} "]"
iris_grammar = raw"""
    ?start: statement

    statement: SL SW PL PW

    SL : /SL[1-9]?[0-9]?/
    SW : /SW[1-9]?[0-9]?/
    PL : /PL[1-9]?[0-9]?/
    PW : /PW[1-9]?[0-9]?/

    %import common.WS
    %ignore WS
"""

struct TreeToJson <: Transformer end

# @inline_rule string(t::TreeToJson, s) = replace(s[2:end-1],"\\\""=>"\"")
# @rule  pair(t::TreeToJson,p) = Tuple(p)

@rule statement(t::TreeToJson, p) = Set(p)

# iris_parser = Lark(iris_grammar, parser="lalr", lexer="standard", transformer=TreeToJson());
iris_parser = Lark(iris_grammar, parser="lalr", lexer="standard", transformer=TreeToJson());
text = raw"SL1 SW3 PL4 PW8"

j = Lerche.parse(iris_parser,text)
# T = [
#     "SL1", "SL2", "SL3", "SL4", "SL5", "SL6", "SL7", "SL8", "SL9", "SL10",
#     "SW1", "SW2", "SW3", "SW4", "SW5", "SW6", "SW7", "SW8", "SW9", "SW10",
#     "PL1", "PL2", "PL3", "PL4", "PL5", "PL6", "PL7", "PL8", "PL9", "PL10",
#     "PW1", "PW2", "PW3", "PW4", "PW5", "PW6", "PW7", "PW8", "PW9", "PW10",
# ]

# statement = Statement("SL", )

# IRIS BNF grammar, Meuth dissertation p.48, Table 4.6
# N = {SL, SW, PL, PW}
# T = {SL1, SL2, SL3, SL4, SL5, SL6, SL7, SL8, SL9, SL10,
# SW1, SW2, SW3, SW4, SW5, SW6, SW7, SW8, SW9, SW10,
# PL1, PL2, PL3, PL4, PL5, PL6, PL7, PL8, PL9, PL10,
# PW1, PW2, PW3, PW4, PW5, PW6, PW7, PW8, PW9, PW10,}
# S = <SL> <SW> <PL> <PW>
# P can be represented as:
# 1. <SL> ::=
# {SL1 | SL2 | SL3 | SL4 | SL5 |
# SL6 | SL7 | SL8 | SL9 | SL10}
# 2. <SW> ::=
# {SW1 | SW2 | SW3 | SW4 | SW5 |
# SW6 | SW7 | SW8 | SW9 | SW10}
# 3. <PL> ::=
# {PL1 | PL2 | PL3 | PL4 | PL5 |
# PL6 | PL7 | PL8 | PL9 | PL10}
# 4. <PW> ::=
# {PW1 | PW2 | PW3 | PW4 | PW5 |
# PW6 | PW7 | PW8 | PW9 | PW10}


# struct TreeToJson <: Transformer end

# @inline_rule string(t::TreeToJson, s) = replace(s[2:end-1],"\\\""=>"\"")

# @rule  array(t::TreeToJson,a) = Array(a)
# @rule  pair(t::TreeToJson,p) = Tuple(p)
# @rule  object(t::TreeToJson,o) = Dict(o)
# @inline_rule number(t::TreeToJson,n) = Base.parse(Float64,n)

# @rule  null(t::TreeToJson,_) = nothing
# @rule  t(t::TreeToJson,_) = true
# @rule  f(t::TreeToJson,_) = false

# json_parser = Lark(json_grammar, parser="lalr", lexer="standard", transformer=TreeToJson());

# text = raw"{\"key\": [\"item0\", \"item1\", 3.14]}"

# j = Lerche.parse(json_parser,text)