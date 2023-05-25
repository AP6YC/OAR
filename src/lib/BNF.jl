"""
    BNF.jl

# Description
This file implements the parsing and generation of statements with the Backus-Naur form.
"""

# -----------------------------------------------------------------------------
# ABSTRACT TYPES
# -----------------------------------------------------------------------------

"""
Abstract type for formal grammars.
"""
abstract type Grammar end

# -----------------------------------------------------------------------------
# TYPE ALIASES
# -----------------------------------------------------------------------------

struct GSymbol{T}
    """
    The grammar symbol of type T.
    """
    data::T

    """
    Boolean flag if the symbol is terminal (true) or nonterminal (false).
    """
    terminal::Bool
end

function GSymbol{T}(data::T) where T <: Any
    GSymbol{T}(
        data,
        true,
    )
end
# function GSymbol{String}(name::String)
#     GSymbol{String}(
#         name,
#         true,
#     )
# end

function Terminal(data::T) where T <: Any
    return GSymbol{T}(
        data,
        true,
    )
end

function NonTerminal(data::T) where T <: Any
    return GSymbol{T}(
        data,
        false,
    )
end

const SymbolSet = Set{GSymbol}

# const Statement = SymbolSet
const Statement = Vector{GSymbol}

const ProductionRule = SymbolSet

const ProductionRuleSet = Dict{GSymbol, ProductionRule}

function quick_statement(data::Vector{T} ; terminal::Bool=false) where T <: Any
    new_data = [GSymbol{T}(datum, terminal) for datum in data]
    # return SymbolSet(new_data)
    return Statement(new_data)
end

# -----------------------------------------------------------------------------
# STRUCTS
# -----------------------------------------------------------------------------

"""
Backus-Naur form of [`Grammar`](@ref OAR.Grammar).

Consists of a set of terminal symbols, non-terminal symbols, and production rules.
"""
struct BNF <: Grammar
    """
    Non-terminal symbols of the grammar.
    """
    N::SymbolSet
    # N::SymbolSet{NonTerminal}
    # N::GSymbolSet

    """
    Terminal symbols of the grammar.
    """
    T::SymbolSet
    # T::SymbolSet{Terminal}
    # T::GSymbolSet

    """
    Definition of a statement in this grammar.
    """
    S::Statement

    """
    The set of production rules of the grammar.
    """
    P::ProductionRuleSet
end

# -----------------------------------------------------------------------------
# METHODS
# -----------------------------------------------------------------------------

"""
Constructor for a Backus-Naur Form grammer with an initial statement of non-terminal symbols.

# Arguments
- `N::Statement`: an initial set of non-terminal grammar symbols.
"""
function BNF(S::Statement)
    return BNF(
        Set(S),
        S,
        Statement(),
        ProductionRuleSet(),
    )
end

"""
Default constructor for the Backus-Naur Form.
"""
function BNF()
    return BNF(Statement())
end

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

"""
Overload of the show function for [`OAR.BNF`](@ref).

# Arguments
- `io::IO`: the current IO stream.
- `bnf::BNF`: the [`OAR.BNF`](@ref) grammar to print/display.
"""
function Base.show(io::IO, bnf::BNF)
    # print(io, "$(typeof(node))($(length(node.N)))")
    n_N = length(bnf.N)
    n_S = length(bnf.S)
    n_P = length(bnf.P)
    n_T = length(bnf.T)
    print(io, "$(typeof(bnf))(N:$(n_N), S:$(n_S), P:$(n_P), T:$(n_T))")
end

"""
Returns a new GSymbol by adding a suffix.
"""
function join_gsymbol(symb::GSymbol, num::Integer ; terminal::Bool=true)
    return GSymbol{String}(
        symb.data * string(num),
        terminal,
    )
end

function DescretizedBNF(N::Vector{String} ; bins::Integer=10)
    return DescretizedBNF(quick_statement(N), bins=bins)
end

"""
Creates a grammer for discretizing a set of symbols into a number of bins.

# Arguments
- `N::Statement`: the set of non-terminal grammar symbols to use for binning.
- `bins::Integer=10`: optional, the granularity/number of bins.
"""
function DescretizedBNF(S::Statement ; bins::Integer=10)
    # Initialize the terminal symbol set
    # T = GSymbolSet()
    # T = SymbolSet{Terminal}()
    T = SymbolSet()
    # Initialize the production rule set
    P = ProductionRuleSet()
    # Iterate over each non-terminal symbol
    for symb in S
        # Create a new production rule with the non-terminal as the start
        P[symb] = ProductionRule()
        # Iterate over the number of discretized bins that we want
        for ix = 1:bins
            # Create a binned symbol
            new_gsymbol = join_gsymbol(symb, ix)
            # Push a binned symbol to the terminals
            push!(T, new_gsymbol)
            # alt = Alternative()
            # push!(alt, new_gsymbol)
            push!(P[symb], new_gsymbol)
        end
    end

    # Return a constructed BNF struct
    return BNF(
        Set(S),     # N
        T,          # T
        S,          # S
        P,          # P
    )
end

"""
Parses and checks that a statement is permissible under a grammer.
"""
function parse_grammar(grammar::Grammar, statement::Statement)
    return
end

"""
Produces a random terminal from the non-terminal using the corresponding production rule.
"""
function random_produce(grammar::Grammar, symb::GSymbol)
# function random_produce(grammar::Grammar, symb::AbstractSymbol)
    return rand(grammar.P[symb])
end

"""
Checks if a symbol is terminal in the grammar.
"""
function is_terminal(grammar::Grammar, symb::GSymbol)
# function is_terminal(grammar::Grammar, symb::AbstractSymbol)
    return symb in grammar.T
end

"""
Checks if a symbol is non-terminal in the grammar.
"""
function is_nonterminal(grammar::Grammar, symb::GSymbol)
# function is_nonterminal(grammar::Grammar, symb::AbstractSymbol)
    return symb in grammar.N
end

"""
Generates a random statement from a grammar.
"""
function random_statement(grammar::Grammar)
    # rand_N = rand(grammar.N)
    statement = Statement()
    for el in grammar.S
        rand_symb = random_produce(grammar, el)
        if is_terminal(grammar, rand_symb)
            push!(statement, random_produce(grammar, el))
        end
    end

    return statement
end
