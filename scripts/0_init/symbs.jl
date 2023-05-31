"""
    symbs.jl

# Description
This script is a place to tinker with the development of grammar symbols in the OAR project.
"""

# -----------------------------------------------------------------------------
# PREAMBLE
# -----------------------------------------------------------------------------

using Revise
using DrWatson
@quickactivate :OAR

# -----------------------------------------------------------------------------
# SYMBOLS EXPERIMENT
# -----------------------------------------------------------------------------

# Create some symbols from convenience aliases
a = OAR.Terminal("SP")
b = OAR.NonTerminal("SP")
# a_set = Set([a])

# Create some symbol sets with convenience constructors
c = OAR.SymbolSet([a])
d = OAR.SymbolSet([a, b])
