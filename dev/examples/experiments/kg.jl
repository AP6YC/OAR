# Import the OAR project module
using OAR

# Location of the edge attributes file, formatted for Lerch parsing
edge_file = joinpath("..", "assets", "edge_attributes_lerche.txt")

statements = OAR.get_kg_statements(edge_file)

grammar = OAR.SPOCFG(statements)

gramart = OAR.GramART(
    grammar,
    rho=0.1,
    terminated=false,
)

for statement in statements
    OAR.train!(gramart, statement)
end

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

