"""
    grammar.jl

# Description
This file implements grammars and the parsing and generation of statements with the Backus-Naur form.
"""

# -----------------------------------------------------------------------------
# ABSTRACT TYPES
# -----------------------------------------------------------------------------

"""
Abstract type for formal grammars.
"""
abstract type Grammar{T} end

# -----------------------------------------------------------------------------
# TYPE ALIASES
# -----------------------------------------------------------------------------

"""
Type alias (`SymbolSet{T} = Set{[OAR.GSymbol{T}](@ref)}`), a set of grammar symbols is implemented as a Julia set.
"""
const SymbolSet{T} = Set{GSymbol{T}}

"""
Type alias (`Statement{T} = Vector{[OAR.GSymbol{T}](@ref)}`), a statement is a vector of grammar symbols.
"""
const Statement{T} = Vector{GSymbol{T}}

"""
Type alias (`Statements{T} = Vector{[Statement{T}](@ref)}`), statements are a vector of the statement type.
"""
const Statements{T} = Vector{Statement{T}}

"""
Type alias (`ProductionRule{T} = [OAR.SymbolSet{T}](@ref)`), a grammar production rule is a set of symbols.
"""
const ProductionRule{T} = SymbolSet{T}

"""
Type alias (`ProductionRuleSet{T} = Dict{[OAR.GSymbol{T}](@ref), [OAR.ProductionRule{T}](@ref)}`), a production rule set is a dictionary mapping grammar symbols to production rules.
"""
const ProductionRuleSet{T} = Dict{GSymbol{T}, ProductionRule{T}}


# """
# Type alias (`SymbolSet = Set{[OAR.GSymbol](@ref)}`), a set of grammar symbols is implemented as a Julia set.
# """
# const SymbolSet = Set{GSymbol}

# """
# Type alias (`Statement = Vector{[OAR.GSymbol](@ref)}`), a statement is a vector of grammar symbols.
# """
# const Statement = Vector{GSymbol}

# """
# Type alias (`ProductionRule = [OAR.SymbolSet](@ref)`), a grammar production rule is a set of symbols.
# """
# const ProductionRule = SymbolSet

# """
# Type alias (`ProductionRuleSet = Dict{[OAR.GSymbol](@ref), [OAR.ProductionRule](@ref)}`), a production rule set is a dictionary mapping grammar symbols to production rules.
# """
# const ProductionRuleSet = Dict{GSymbol, ProductionRule}

# -----------------------------------------------------------------------------
# STRUCTS
# -----------------------------------------------------------------------------

"""
Context-Free [`Grammar`](@ref OAR.Grammar).

Consists of a set of terminal symbols, non-terminal symbols, and production rules of Backus-Naur Form.
"""
struct CFG{U} <: Grammar{U}
    """
    Non-terminal symbols of the grammar.
    """
    N::SymbolSet{U}

    """
    Terminal symbols of the grammar.
    """
    T::SymbolSet{U}

    """
    Definition of a statement in this grammar.
    """
    S::Statement{U}

    """
    The set of production rules of the grammar of the Backus-Naur Form (CFG).
    """
    P::ProductionRuleSet{U}
end

# -----------------------------------------------------------------------------
# METHODS
# -----------------------------------------------------------------------------

"""
Constructor for a Context-Free Grammer with an initial statement of non-terminal symbols.

# Arguments
- `N::Statement`: an initial set of non-terminal grammar symbols.
"""
function CFG(S::Statement{T}) where T <: Any
    return CFG(
        Set{T}(S),
        S,
        Statement{T}(),
        ProductionRuleSet{T}(),
    )
end

"""
Default constructor for a Context-Free Grammar.
"""
function CFG()
    return CFG(Statement{String}())
end

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

"""
Generates a set of unique terminal symbols from a list of statements.

# Arguments
- `statements::Statements{T} where T <: Any`: the statements to dissect into a set of terminals.
"""
function get_terminals(statements::Statements{T}) where T <: Any
    # Collect the unique terminals in the dataset
    # terminals = Set{OAR.CMTSymbol}()
    terminals = Set{GSymbol{T}}()
    for statement in statements
        for symb in statement
            push!(terminals, symb)
        end
    end
    return terminals
end

"""
Generates simple production rules from a vector of statements and the nonterminals corresponding to them.

# Arguments
- `N:Statement{T} where T <: Any`: the ordered nonterminals corresponding to the columns of the statement.
- `statements::Statements{T} where`: the list of statements used for generating the production rules.
"""
function get_production_rules(N::Statement{T}, statements::Statements{T}) where T <: Any
    # Intialize the production rule set
    P = ProductionRuleSet{T}()
    # Add the nonterminal keys to P
    for n in N
        P[n] = ProductionRule{T}()
    end

    # Iterate over all statements to append terminals in the nonterminal positions
    n_N = length(N)
    for statement in statements
        for ix = 1:n_N
            # Append the symbol in position ix to the production rule corresponding
            # to N[ix]. Because this is implemented as a set, redundant terminals
            # are not added to the production rule.
            push!(P[N[ix]], statement[ix])
        end
    end

    return
end

"""
Constructs a context-free grammar that uses only simple subject-predicate-object statements.

# Arguments
- `statements::Statements{T} where T <: Any`: the statements generated by the grammar, used to generate production rules, etc.
"""
function SPOCFG(statements::Statements{T}) where T <: Any
    ordered_nonterminals = [
        GSymbol("subject", false),
        GSymbol("predicate", false),
        GSymbol("object", false),
    ]
    N = Set(ordered_nonterminals)
    Term = get_terminals(statements)
    P = get_production_rules(ordered_nonterminals, statements)

    grammar = CFG(
        N,
        Term,
        ordered_nonterminals,
        P,
    )

    return grammar
end

"""
Creates a [`OAR.Statement`](@ref) from a vector of elements of arbitrary type.

# Arguments
- `data::Vector{T} where T <: Any`: a vector of any type for creating a [`OAR.Statement`](@ref) of symbols of that type.
- `terminal::Bool=false`: optional, if the symbols of the statement are terminal.
"""
function quick_statement(data::Vector{T} ; terminal::Bool=false) where T <: Any
    new_data = [GSymbol{T}(datum, terminal) for datum in data]
    # return SymbolSet(new_data)
    return Statement{T}(new_data)
end

"""
Overload of the show function for [`OAR.CFG`](@ref).

# Arguments
- `io::IO`: the current IO stream.
- `cfg::CFG`: the [`OAR.CFG`](@ref) [`OAR.Grammar`](@ref) to print/display.
"""
function Base.show(io::IO, cfg::CFG)
    n_N = length(cfg.N)
    n_S = length(cfg.S)
    n_P = length(cfg.P)
    n_T = length(cfg.T)
    print(io, "$(typeof(cfg))(N:$(n_N), S:$(n_S), P:$(n_P), T:$(n_T))")
end

"""
Wrapper for creating a DescretizedCFG from just a vector of nonterminal symbol names as strings.

This function turns the vector of strings in to a statement and passes it to the actual constructor.

# Arguments
- `N::Vector{String}`: the nonterminal symbol names as a vector of strings.
- `bins::Integer=10`: optional, the granularity/number of bins.
"""
function DescretizedCFG(N::Vector{String} ; bins::Integer=10)
    return DescretizedCFG(quick_statement(N), bins=bins)
end

"""
Creates a grammer for discretizing a set of symbols into a number of bins.

# Arguments
- `N::Statement{T} where T <: Any`: the set of non-terminal grammar symbols to use for binning.
- `bins::Integer=10`: optional, the granularity/number of bins.
"""
function DescretizedCFG(S::Statement{T} ; bins::Integer=10) where T <: Any
    # Initialize the terminal symbol set
    Term = SymbolSet{T}()
    # Initialize the production rule set
    P = ProductionRuleSet{T}()
    # Iterate over each non-terminal symbol
    for symb in S
        # Create a new production rule with the non-terminal as the start
        P[symb] = ProductionRule{T}()
        # Iterate over the number of discretized bins that we want
        for ix = 1:bins
            # Create a binned symbol
            new_gsymbol = join_gsymbol(symb, ix)
            # Push a binned symbol to the terminals
            push!(Term, new_gsymbol)
            # alt = Alternative()
            # push!(alt, new_gsymbol)
            push!(P[symb], new_gsymbol)
        end
    end

    # Return a constructed CFG struct
    return CFG{T}(
        Set(S),     # N
        Term,          # T
        S,          # S
        P,          # P
    )
end

"""
Common docstring argument for grammars.
"""
const GRAMMAR_ARG = """
- `grammar::Grammar{T} where T <: Any`: a subtype of the abstract [`OAR.Grammar{T}`](@ref) type.
"""

"""
Common docstring for functions using a grammar and a grammar symbol.
"""
const GRAMMAR_SYMB_ARG = """
# Arguments
$GRAMMAR_ARG
- `symb::GSymbol`: the grammar symbol to use.
"""

"""
Parses and checks that a statement is permissible under a grammer.

# Arguments
$GRAMMAR_ARG
- `statement::Statement{T} where T <: Any`: a grammar [`OAR.Statement`] to check the validity of.s
"""
function parse_grammar(grammar::Grammar{T}, statement::Statement{T}) where T <: Any
    @warn "UNIMPLEMENTED"
    return
end

"""
Produces a random terminal from the non-terminal using the corresponding production rule.

$GRAMMAR_SYMB_ARG
"""
function random_produce(grammar::Grammar{T}, symb::GSymbol{T}) where T <: Any
# function random_produce(grammar::Grammar, symb::AbstractSymbol)
    return rand(grammar.P[symb])
end

"""
Checks if a symbol is terminal in the grammar.

$GRAMMAR_SYMB_ARG
"""
function is_terminal(grammar::Grammar{T}, symb::GSymbol{T}) where T <: Any
# function is_terminal(grammar::Grammar, symb::AbstractSymbol)
    return symb in grammar.T
end

"""
Checks if a symbol is non-terminal in the grammar.

$GRAMMAR_SYMB_ARG
"""
function is_nonterminal(grammar::Grammar{T}, symb::GSymbol{T}) where T <: Any
# function is_nonterminal(grammar::Grammar, symb::AbstractSymbol)
    return symb in grammar.N
end

"""
Generates a random statement from a grammar.

# Arguments
$GRAMMAR_ARG
"""
function random_statement(grammar::Grammar{T}) where T <: Any
    # Create an empty statement
    statement = Statement{T}()
    # For each element of what the grammar constitutes a statement
    for el in grammar.S
        # Get a random element from nonterminal
        rand_symb = random_produce(grammar, el)
        # If the symbol is terminal, then push it to the new random statement
        if is_terminal(grammar, rand_symb)
            # push!(statement, random_produce(grammar, el))
            push!(statement, rand_symb)
        end
    end
    # Return the populated random statement of terminal symbols
    return statement
end
