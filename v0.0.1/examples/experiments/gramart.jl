# Import the OAR project module
using OAR

# All-in-one function
fs, bnf = OAR.symbolic_iris()

# Initialize the GramART module
gramart = OAR.GramART(bnf)

# Initalize the first node of the module
OAR.add_node!(gramart)

# Process the statements
for statement in fs.train_x
    OAR.process_statement!(gramart, statement, 1)
end

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

