"""
    common.jl

# Description
Common definitions and functions for parser.
"""

"""
Wrapper for running a parser with a given piece of text in the form of a string.
"""
function run_parser(parser::Lerche.Lark, text::AbstractString)
    # Parse the statement and return
    return Lerche.parse(parser, text)
end
