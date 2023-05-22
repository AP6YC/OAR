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

N = [
    "SL", "SW", "PL", "PW",
]
bins = 10
bnf = OAR.DescretizedBNF(OAR.quick_symbolset(N), bins=bins)


# All-in-one function
fs = OAR.symbolic_iris()
# @info fs

# Make a protonode
pn = ProtoNode()
@info pn

# Make a treenode
tn = TreeNode("testing")
@info tn


# Initialize the protonode tree for the grammar
v_gramart = Vector{ProtoNode}()
for N in bnf.N
    # @info N
    local_dist = OAR.TerminalDist()
    local_count = OAR.SymbolCount()
    for T in bnf.P[N]
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

    end
    # @info statement
end
