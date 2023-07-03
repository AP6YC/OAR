"""
    cmt.jl

# Description
Implements the parser used for the CMT edge attributes data.
"""

# The grammar tree subtypes from a Lerche Transformer
struct CMTGramARTTree <: Transformer end

# The rules turn the terminals into `OAR` grammar symbols and statements into vectors
const CMTSymbol = GSymbol{String}

# Turn statements into Julia Vectors
@rule statement(t::CMTGramARTTree, p) = Vector{CMTSymbol}(p)
# Remove backslashes in escaped strings
@inline_rule string(t::CMTGramARTTree, s) = replace(s[2:end-1],"\\\""=>"\"")
# Define the datatype for the strings themselves
@rule cmt_symb(t::CMTGramARTTree, p) = CMTSymbol(p[1], true)

"""
Constructs and returns a parser for the CMT edge attributes data.
"""
function get_cmt_parser()
    # Declare the rules of the symbolic Iris grammar
    cmt_edge_grammar = raw"""
        ?start: statement

        statement: subject predicate object

        subject     : string -> cmt_symb
        predicate   : string -> cmt_symb
        object      : string -> cmt_symb

        string      : ESCAPED_STRING

        %import common.ESCAPED_STRING
        %import common.WS
        %ignore WS
    """

    # Create the parser from these rules
    cmt_parser = Lark(
        cmt_edge_grammar,
        parser="lalr",
        lexer="standard",
        transformer=CMTGramARTTree()
    )

    return cmt_parser
end
