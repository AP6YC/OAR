"""
    kg.jl

# Description
Implements the parser used for the knowledge graph edge attributes data.
"""

"""
The KG grammar tree subtypes from a Lerche Transformer.
"""
struct KGGramARTTree <: Transformer end

"""
Alias stating that a KG grammar symbol is a string (`KGSymbol = `[`GSymbol`](@ref)`{String}`).
"""
const KGSymbol = GSymbol{String}

"""
Alias stating that KG statements are vectors of KG grammar symbols (`KGStatement = Vector{[`KGSymbol`](@ref)`}`).
"""
const KGStatement = Vector{KGSymbol}

# The rules turn the terminals into `OAR` grammar symbols and statements into vectors
# Turn statements into Julia Vectors
@rule statement(t::KGGramARTTree, p) = Vector{KGSymbol}(p)
# Remove backslashes in escaped strings
@inline_rule gstring(t::KGGramARTTree, s) = replace(s[2:end-1],"\\\""=>"\"")
# Define the datatype for the strings themselves
@rule kg_symb(t::KGGramARTTree, p) = KGSymbol(p[1], true)

"""
Constructs and returns a parser for the KG edge attributes data.
"""
function get_kg_parser()
    # Declare the rules of the symbolic Iris grammar
    kg_edge_grammar = raw"""
        ?start: statement

        statement: subject predicate object

        subject     : gstring -> kg_symb
        predicate   : gstring -> kg_symb
        object      : gstring -> kg_symb

        gstring      : ESCAPED_STRING

        %import common.ESCAPED_STRING
        %import common.WS
        %ignore WS
    """

    # Create the parser from these rules
    kg_parser = Lark(
        kg_edge_grammar,
        parser="lalr",
        lexer="standard",
        transformer=KGGramARTTree()
    )

    return kg_parser
end

"""
Loads the KG edge data file, parses the lines, and returns a vector of statements for GramART.

# Arguments
- `file::AbstractString`: the location of the edge data file.
"""
function get_kg_statements(file::AbstractString)
    # Construct the KG parser
    kg_parser = OAR.get_kg_parser()

    # Initialize the statements vector
    statements = Vector{OAR.KGStatement}()

    # Open the edge attributes file and parse
    open(file) do f
        while ! eof(f)
            # Read the line from the file
            s = readline(f)
            # Parse the line into a structured statement
            k = OAR.run_parser(kg_parser, s)
            # Push the statement to the vector of statements
            push!(statements, k)
        end
    end

    # Return the vector of parsed statements
    return statements
end