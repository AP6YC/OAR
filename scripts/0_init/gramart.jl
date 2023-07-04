"""
    gramart.jl

# Description
This script is used in the early development of GramART.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using OAR

# -----------------------------------------------------------------------------
# IRIS DATASET
# -----------------------------------------------------------------------------

# All-in-one function
fs, bnf = OAR.symbolic_iris()

# Make a protonode
pn = ProtoNode()
@info pn

# Make a treenode
tn = TreeNode("testing")
@info tn

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

# @info v_gramart

# Update the counts of each symbol
n_symbols = length(v_gramart)
for statement in fs.train_x
    for n = 1:n_symbols
        # @info statement[n]
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
