"""
    cmt.jl

# Description
Implements the parser used for the CMT protein data.
"""

"""
The CMT grammar tree subtypes from a Lerche Transformer.
"""
struct CMTGramARTTree <: Transformer end

"""
Alias stating that a CMT grammar symbol is a string (`CMTSymbol = `[`GSymbol`](@ref)`{String}`).
"""
const CMTSymbol = GSymbol{String}

# The rules turn the terminals into `OAR` grammar symbols and statements into vectors
# Turn statements into Julia Vectors
@rule statement(t::CMTGramARTTree, p) = Vector{CMTSymbol}(p)
# Remove backslashes in escaped strings
@inline_rule gstring(t::CMTGramARTTree, s) = replace(s[2:end-1],"\\\""=>"\"")
# Define the datatype for the strings themselves
@rule cmt_symb(t::CMTGramARTTree, p) = CMTSymbol(p[1], true)

"""
Constructs and returns a parser for the KG edge attributes data.
"""
function get_cmt_parser()
    # Declare the rules of the CMT protein data parser
    cmt_grammar = raw"""
        ?start: statement

        statement: gene_location disease_mim gene gene_mim inheritance protein uniprot chromosome chromosome_location protein_class biologic_process molecular_function disease_involvement mw domain motif protein_location length disease_mim2 weight_tag length_tag phenotypes

        gene_location       : quoted_string
        disease_mim         : quoted_string
        gene                : quoted_string
        gene_mim            : quoted_string
        inheritance         : quoted_string
        protein             : quoted_string
        uniprot             : quoted_string
        chromosome          : quoted_string
        chromosome_location : quoted_string
        protein_class       : quoted_string
        biologic_process    : quoted_string
        molecular_function  : quoted_string
        disease_involvement : quoted_string
        mw                  : quoted_string
        domain              : quoted_string
        motif               : quoted_string
        protein_location    : quoted_string
        length              : quoted_string
        disease_mim2        : quoted_string
        weight_tag          : quoted_string
        length_tag          : quoted_string
        phenotypes          : quoted_string

        quoted_string       : "'" inner_string "'"
        inner_string        : gstring -> cmt_symb
        gstring             : ESCAPED_STRING

        %import common.ESCAPED_STRING
        %import common.WS
        %ignore WS
    """

    # Create the parser from these rules
    cmt_parser = Lark(
        cmt_grammar,
        parser="lalr",
        lexer="standard",
        transformer=CMTGramARTTree()
    )

    return cmt_parser
end
