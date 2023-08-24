# Just load this project
using OAR

# Point to the relative file location
filename = joinpath("..", "assets", "mushrooms.csv")
# All-in-one function
fs, bnf = OAR.symbolic_mushroom(filename)

# Initialize the module with options
art = OAR.GramART(bnf,
    rho = 0.6,
)

# Iterate over the training data
for ix in eachindex(fs.train_x)
    statement = fs.train_x[ix]
    label = fs.train_y[ix]
    OAR.train!(
        art,
        statement,
        y=label,
    )
end

# Create a container for the output labels
clusters = zeros(Int, length(fs.test_y))
# Iterate over the testing data
for ix in eachindex(fs.test_x)
    clusters[ix] = OAR.classify(
        art,
        fs.test_x[ix],
        get_bmu=true,
    )
end

# Calculate testing performance
perf = OAR.AdaptiveResonance.performance(fs.test_y, clusters)

# Logging
@info "Final performance: $(perf)"
@info "n_categories: $(art.stats["n_categories"])"

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

