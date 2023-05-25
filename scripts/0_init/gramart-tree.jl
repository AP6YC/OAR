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

# Init the top protonode
gramart = ProtoNode(bnf.T)

# # Initialize the top node with a distribution of all symbols
# for terminal in bnf.T
#     gramart.N[terminal] = 0
#     gramart.dist[terminal] = 0.0
# end

# Populate the sub nodes
for S in bnf.S
    push!(gramart.children, ProtoNode(bnf.T))
end

# # Process the statements
# for S in bnf.S

# end


# Initialize the protonode tree for the grammar
v_gramart = Vector{ProtoNode}()
for S in bnf.S
    # @info N
    local_dist = OAR.TerminalDist()
    local_count = OAR.SymbolCount()
    for T in bnf.P[S]
        # @info T
        local_dist[T] = 0.0
        # push!(local_count, 0)
        local_count[T] = 0
    end

    local_pn = ProtoNode(
        local_dist,
        local_count,
        Vector{ProtoNode}()
    )
    push!(v_gramart, local_pn)
end

@info v_gramart

# Update the counts of each symbol
n_symbols = length(v_gramart)
for statement in fs.train_x
    for n = 1:n_symbols
        @info statement[n]
        v_gramart[n].N[statement[n]] += 1
        # v_gramart[n]
    end
    # @info statement
end

# Calculate the distributions
for v in v_gramart
    m = 0
    # Get the total counts of all symbols in the node
    for (key, count) in v.N
        m += count
    end
    # Calculate the PMF for each symbol in the node
    for (key, dist) in v.dist
        v.dist[key] = v.N[key] / m
    end
    # Reset the counters
    for (key, count) in  v.N
        v.N[key] = 0
    end
end

@info [value for (_, value) in v_gramart[1].dist]
