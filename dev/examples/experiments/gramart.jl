# Import the OAR project module
using OAR

# All-in-one function
fs, bnf = OAR.symbolic_iris()

# Initialize the GramART module
gramart = OAR.GramART(bnf)

# Process the statements
for statement in fs.train_x
    OAR.process_statement!(gramart, statement)
end

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

