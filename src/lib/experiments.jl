"""
    experiments.jl

# Description
Driver functions for serial and distributed experiments.
"""

"""
Common save function for simulations.

# Arguments
$ARG_SIM_DIR_FUNC
$ARG_SIM_D
- `fulld::AbstractDict`: the dictionary containing the sim results.
"""
function save_sim(
    dir_func::Function,
    d::AbstractDict,
    fulld::AbstractDict,
)
    # Point to the correct save file for the results dictionary
    sim_save_name = dir_func(savename(
        d,
        "jld2";
        digits=4,
        ignores=[
            "rng_seed",
            "m",
        ],
    ))

    # Log completion of the simulation
    @info "Worker $(myid()): saving to $(sim_save_name)"

    # DrWatson function to save the results with an additional tag entry
    tagsave(sim_save_name, fulld)

    # Empty return
    return
end

"""
Trains and classifies a GramART module on the provided statements.

# Arguments
$ARG_SIM_D
$ARG_SIM_TS
$ARG_SIM_DIR_FUNC
$ARG_SIM_OPTS
"""
function tc_gramart(
    d::AbstractDict,
    ts::SomeStatements,
    dir_func::Function,
    opts::AbstractDict,
)
    # Initialize the random seed at the beginning of the experiment
    Random.seed!(d["rng_seed"])

    # Initialize the GramART module
    gramart = OAR.GramART(
        opts["grammar"],
        rho=d["rho"],
        terminated=false,
    )

    # Process the statements
    for tn in ts
        OAR.train!(gramart, tn)
    end

    # Classify and add the cluster label
    clusters = Vector{Int}()
    for jx in eachindex(ts)
        local_cluster = OAR.classify(
            gramart,
            ts[jx],
            get_bmu=true,
        )
        push!(clusters, local_cluster)
    end

    # Copy the input sim dictionary
    fulld = deepcopy(d)

    # Add entries for the results
    fulld["clusters"] = clusters

    # Save the results
    save_sim(dir_func, d, fulld)

    # Explicitly empty return
    return
end

"""
Trains and tests a GramART module on the provided statements.

# Arguments
$ARG_SIM_D
- `data::VectoredDataset`: the dataset to train and test on.
$ARG_SIM_DIR_FUNC
$ARG_SIM_OPTS
"""
function tt_gramart(
    d::AbstractDict,
    data::VectoredDataset,
    dir_func::Function,
    opts::AbstractDict,
)
    # Initialize the GramART module
    # gramart = OAR.GramART(grammmar)
    gramart = OAR.GramART(opts["grammmar"])

    # Set the vigilance parameter and show
    # gramart.opts.rho = 0.15
    gramart.opts.rho = 0.05

    # Process the statements
    for ix in eachindex(data.train_x)
        statement = data.train_x[ix]
        label = data.train_y[ix]
        OAR.train!(gramart, statement, y=label)
    end

    # Classify
    clusters = zeros(Int, length(data.test_y))
    for ix in eachindex(data.test_x)
        clusters[ix] = OAR.classify(gramart, data.test_x[ix], get_bmu=true)
    end

    # Calculate testing performance
    perf = OAR.AdaptiveResonance.performance(data.test_y, clusters)

    # Copy the input sim dictionary
    fulld = deepcopy(d)

    # Add entries for the results
    fulld["p"] = perf
    fulld["n_cat"] = gramart.stats["n_categories"]

    # Save the results
    save_sim(dir_func, d, fulld)
end
