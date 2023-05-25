"""
    gramart.jl

# Description
This script is used in the development of GramART.
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using DrWatson
@quickactivate :OAR

# -----------------------------------------------------------------------------
# IRIS DATASET
# -----------------------------------------------------------------------------

# All-in-one function
fs, bnf = OAR.symbolic_iris()

gramart = OAR.GramART(bnf)

# Init the top protonode
# gramart = ProtoNode(bnf.T)

# Iterate over the production rules
for (nonterminal, prod_rule) in bnf.P
    # Add a node for each non-terminal place
    local_node = ProtoNode(bnf.T)
    # Add a node for each terminal
    for terminal in prod_rule
        # push!(local_node.children, ProtoNode(bnf.T))
        local_node.children[terminal] = ProtoNode(bnf.T)
    end
    # Add the ndoe with nodes to the top node
    # push!(gramart.children, local_node)
    gramart.protonodes.children[nonterminal] = local_node
end

@info gramart

# Process the statements
n_positions = length(bnf.S)
for statement in fs.train_x
    OAR.process_statement!(gramart, statement)
end

# # Initialize the protonode tree for the grammar
# v_gramart = Vector{ProtoNode}()
# for S in bnf.S
#     # Create a protonode from just the production rule symbols
#     local_pn = ProtoNode(bnf.P[S])
#     push!(v_gramart, local_pn)
# end

# @info v_gramart

# # Update the counts of each symbol
# n_symbols = length(v_gramart)
# for statement in fs.train_x
#     for n = 1:n_symbols
#         # @info statement[n]
#         v_gramart[n].N[statement[n]] += 1
#         # v_gramart[n]
#     end
#     # @info statement
# end

# # Calculate the distributions
# for v in v_gramart
#     m = 0
#     # Get the total counts of all symbols in the node
#     for (key, count) in v.N
#         m += count
#     end
#     # Calculate the PMF for each symbol in the node
#     for (key, dist) in v.dist
#         v.dist[key] = v.N[key] / m
#     end
#     # Reset the counters
#     for (key, count) in  v.N
#         v.N[key] = 0
#     end
# end

# @info [value for (_, value) in v_gramart[1].dist]
