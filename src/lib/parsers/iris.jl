"""
    iris.jl

# Description
Implements the parser used for the IRIS dataset.
"""


# The grammar tree subtypes from a Lerche Transformer
struct IRISGramARTTree <: Transformer end

const IRISSymbol = GSymbol{String}

# The rules turn the terminals into `OAR` grammar symbols and statements into vectors
@rule iris_symb(t::IRISGramARTTree, p) = IRISSymbol(p[1], true)
@rule statement(t::IRISGramARTTree, p) = Vector{IRISSymbol}(p)

"""
Constructs and returns a Lerche parser for the symbolic IRIS dataset.
"""
function get_iris_parser()
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

    # Create the parser from these rules
    iris_parser = Lark(
        iris_grammar,
        parser="lalr",
        lexer="standard",
        transformer=IRISGramARTTree()
    )

    return iris_parser
end
