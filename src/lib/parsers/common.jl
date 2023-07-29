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

"""
Overload of the show function for Lerche.Lark parsers to reduce terminal output noise.

# Arguments
- `io::IO`: the current IO stream.
- `parser::Lerche.Lark`: the Lerche.Lark parser to print/display.
"""
function Base.show(io::IO, parser::Lerche.Lark)
    print(io, "$(parser.rules)")
end