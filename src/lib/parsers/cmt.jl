"""
    cmt.jl

# Description
Implements the parser used for the CMT edge attributes data.
"""

"""
The CMT grammar tree subtypes from a Lerche Transformer.
"""
struct CMTGramARTTree <: Transformer end

"""
Alias stating that a CMT grammar symbol is a string.
"""
const CMTSymbol = GSymbol{String}

"""
Alias stating that CMT statements are vectors of CMT grammar symbols.
"""
const CMTStatement = Vector{CMTSymbol}

# The rules turn the terminals into `OAR` grammar symbols and statements into vectors
# Turn statements into Julia Vectors
@rule statement(t::CMTGramARTTree, p) = Vector{CMTSymbol}(p)
# Remove backslashes in escaped strings
@inline_rule gstring(t::CMTGramARTTree, s) = replace(s[2:end-1],"\\\""=>"\"")
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

        subject     : gstring -> cmt_symb
        predicate   : gstring -> cmt_symb
        object      : gstring -> cmt_symb

        gstring      : ESCAPED_STRING

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

# function