using Revise

using DrWatson
@quickactivate :OAR

a = OAR.Terminal("SP")
b = OAR.NonTerminal("SP")
# a_set = Set([a])

c = OAR.SymbolSet([a])
d = OAR.SymbolSet([a, b])
