"""
    cmt.jl

# Description
Implements the parser used for the CMT protein data.
"""

# -----------------------------------------------------------------------------
# CONSTANTS
# -----------------------------------------------------------------------------

"""
A list of the feature columns used in clustering the CMT dataset
"""
const CMT_CLUSTERING_COLUMNS = [
    "gene_location",
    "disease_MIM",
    "gene",
    "gene_MIM",
    "inheritance",
    "protein",
    "uniprot",
    "chromosome",
    "chromosome_location",
    "protein_class",
    "biologic_process",
    "molecular_function",
    "disease_involvement",
    "MW",
    "domain",
    "motif",
    "protein_location",
    "length",
    "disease_MIM2",
    "weight_tag",
    "length_tag",
    "phenotypes",
]

"""
A list of the phenotype columns for aggregation into one GramART feature.
"""
const CMT_PHENOTYPES = [
    "ataxia",
    "atrophy",
    "auditory",
    "autonomic",
    "behavior",
    "cognitive",
    "cranial_nerve",
    "deformity",
    "dystonia",
    "gait",
    "hyperkinesia",
    "hyperreflexia",
    "hypertonia",
    "hypertrophy",
    "hyporeflexia",
    "hypotonia",
    "muscle",
    "pain",
    "seizure",
    "sensory",
    "sleep",
    "speech",
    "tremor",
    "visual",
    "weakness",
]

# -----------------------------------------------------------------------------
# FULL STRING STATEMENT CMT PARSER
# -----------------------------------------------------------------------------

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

"""
Loads and sanitizes the CMT protein dataframe.

# Arguments
- `file::AbstractString`: the location of the CSV file containing CMT protein data.
"""
function load_cmt(file::AbstractString)
    df = DataFrame(CSV.File(file))

    # Generate a new column of piped elements
    phenotype_column = Vector{String}()
    for row in eachrow(df)
        element = ""
        # for phen in CMT_PHENOTYPES
        for ix in eachindex(CMT_PHENOTYPES)
            # if row[phen] == 1
            phen = CMT_PHENOTYPES[ix]
            if ix == 1
                element *= phen
            else
                element *= " | " * phen
            end
        end
        push!(phenotype_column, element)
    end

    # Add the phenotypes column to the dataframe
    df.phenotypes = phenotype_column
    # Return the sanitized dataframe
    return df
end

"""
Loads and sanitizes the CMT data dictionary file.

# Arguments
- `file::AbstractString`: the location of the data dictionary CSV file.
"""
function load_cmt_dict(file::AbstractString)
    df_dict = DataFrame(CSV.File(file))
    # Sanitize
    df_dict.pipes = replace(df_dict.pipes, "yes" => true)
    df_dict.pipes = replace(df_dict.pipes, missing => false)
    df_dict.pipes = Bool.(df_dict.pipes)
    return df_dict
end

"""
Turns the CMT protein DataFrame into a vector of string statements.

# Arguments
- `df::DataFrame`: the sanitized CMT protein data DataFrame.
"""
function protein_df_to_strings(df::DataFrame)
    statements = Vector{String}()

    for row in eachrow(df)
        statement = raw""
        for column in CMT_CLUSTERING_COLUMNS
            statement *= "'" * string(row[column]) * "' "
        end
        push!(statements, statement)
    end

    return statements
end


"""
Piped statements tree.
"""
struct CMTPipedTree <: Transformer end

# Turn statements into Julia Vectors
@rule statement(t::CMTPipedTree, p) = Vector{CMTSymbol}(p)

# Define the datatype for the strings themselves
@rule cmt_symb(t::CMTPipedTree, p) = CMTSymbol(p[1], true)

"""
Constructs and returns a parser for just piped strings.
"""
function get_piped_parser()
    # Declare the rules of the CMT protein data parser
    local_grammar = raw"""
        ?start: statement
        statement: piped_words+
        piped_words : /\w+[\.\w]*/ "|"* -> cmt_symb

        %import common.WS
        %ignore WS
    """

    # Create the parser from these rules
    local_parser = Lark(
        local_grammar,
        parser="lalr",
        lexer="standard",
        transformer=CMTPipedTree()
    )

    return local_parser
end

"""
Turns a vector of GramARTSymbols into a nonterminal [`OAR.TreeNode`](@ref) with children.

# Arguments
- `local_vec::Vector{GramARTSymbol}`: the vector to turn into a [`OAR.TreeNode`](@ref).
- `nonterminal::AbstractString`: the nonterminal string name at the top of the tree.
"""
function vector_to_tree(
    local_vec::Vector{GramARTSymbol},
    nonterminal::AbstractString
)
    # Create a nonterminal TreeNoe
    local_tree = OAR.TreeNode(
        nonterminal,
        false
    )

    # Create a TreeNode from every element of the vector and push to the children
    for element in local_vec
        terminal_tree = OAR.TreeNode(element)
        push!(local_tree.children, terminal_tree)
    end

    # Return the constructed local_tree
    return local_tree
end

"""
Checks the data dictionary if the named variable is piped.

# Arguments
- `data_dict::DataFrame`: the data_dictionary containing attributes about variables, such as if they are piped or not.
- `name::AbtractString`: the variable name to identify if it is piped.
"""
function check_if_piped(data_dict::DataFrame, name::AbstractString)
    @info name
    index = findfirst(data_dict.Variable .== name)
    return data_dict.pipes[index]
end

"""
Turns a protein data DataFrame into a vector of [`OAR.TreeNode`](@ref)s.

# Arguments
- `data::DataFrame`: the DataFrame containing rows of elements to turn into statements via [`OAR.TreeNode`](@ref)s.
- `data_dict::DataFrame`: the DataFrame containing attributes about the columns of the protein data, such as if they are piped or not.
"""
function df_to_trees(data::DataFrame, data_dict::DataFrame)
    # statements = Vector{Vector{GramARTSymbol}}()
    # statements = GramARTStatements()
    statements = Vector{TreeNode}()
    piped_parser = get_piped_parser()

    for row in eachrow(data)
        # statement = Vector{GramARTSymbol}()
        # statement = GramARTStatement()
        statement = TreeNode("statement", false)
        for column in CMT_CLUSTERING_COLUMNS
            if check_if_piped(data_dict, column)
                local_string = String(row[column])
                local_vec = run_parser(piped_parser, local_string)
                local_tree = vector_to_tree(local_vec, column)
                push!(statement.children, local_tree)
            else
                local_string = string(row[column])
                local_tree = TreeNode(local_string, true)
                push!(statement.children, local_tree)
            end
        end
        push!(statements, statement)
    end
    return statements
end
