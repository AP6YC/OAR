# Import the OAR project module
using OAR

# All-in-one function
fs, bnf = OAR.symbolic_iris()

# Initialize the GramART module
gramart = OAR.GramART(bnf)

# Cluster the statements
for statement in fs.train_x
    OAR.train!(gramart, statement)
end

# Initialize the GramART module
gramart_supervised = OAR.GramART(bnf)
# Set the vigilance low for generalization
gramart_supervised.opts.rho = 0.05
# Train in supervised mode
for ix in eachindex(fs.train_x)
    sample = fs.train_x[ix]
    label = fs.train_y[ix]
    OAR.train!(gramart_supervised, sample, y=label)
end

# Inspect the module
@info "Number of categories: $(length(gramart.protonodes))"

# Classification
y_hat = zeros(Int, length(fs.test_y))
for ix in eachindex(fs.test_x)
    sample = fs.test_x[ix]
    y_hat[ix] = OAR.classify(gramart_supervised, sample, get_bmu=true)
end

# Calculate performance
perf = OAR.AdaptiveResonance.performance(y_hat, fs.test_y)
@info "Supervised testing performance: $(perf)"

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

