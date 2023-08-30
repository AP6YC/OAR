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
    art = OAR.GramART(
        opts["grammar"],
        rho=d["rho"],
        terminated=false,
    )

    # Process the statements
    for tn in ts
        OAR.train!(art, tn)
    end

    # Classify and add the cluster label
    clusters = Vector{Int}()
    for jx in eachindex(ts)
        local_cluster = OAR.classify(
            art,
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
    try
    # Initialize the GramART module
    # art = OAR.GramART(grammmar)
    art = OAR.GramART(opts["grammmar"])

    # Set the vigilance parameter and show
    # art.opts.rho = 0.15
    art.opts.rho = 0.05

    # Process the statements
    for ix in eachindex(data.train_x)
        statement = data.train_x[ix]
        label = data.train_y[ix]
        OAR.train!(art, statement, y=label)
    end

    # Classify
    clusters = zeros(Int, length(data.test_y))
    for ix in eachindex(data.test_x)
        clusters[ix] = OAR.classify(art, data.test_x[ix], get_bmu=true)
    end

    # Calculate testing performance
    perf = OAR.AdaptiveResonance.performance(data.test_y, clusters)

    # Copy the input sim dictionary
    fulld = deepcopy(d)

    # Add entries for the results
    fulld["p"] = perf
    fulld["n_cat"] = art.stats["n_categories"]

    # Save the results
    save_sim(dir_func, d, fulld)

    catch
        @warn "Failed to run sim from worker $(myid())"
    end

    return
end

function tt_serial(
    art::AbstractGramART,
    data::VectoredDataset;
    display::Bool=false
)
    # Process the statements
    # @showprogress "Training" for ix in eachindex(data.train_x)
    for ix in eachindex(data.train_x)
        statement = data.train_x[ix]
        label = data.train_y[ix]
        OAR.train!(
        # OAR.train_dv!(
            art,
            statement,
            y=label,
            # epochs=5,
        )
    end

    # Classify
    clusters = zeros(Int, length(data.test_y))
    # @showprogress "Classifying" for ix in eachindex(data.test_x)
    for ix in eachindex(data.test_x)
        clusters[ix] = OAR.classify(
        # clusters[ix] = OAR.classify_dv(
            art,
            data.test_x[ix],
            get_bmu=true,
        )
    end

    # Calculate testing performance
    perf = OAR.AdaptiveResonance.performance(data.test_y, clusters)

    # Logging
    if display
        @info "Final performance: $(perf)"
        @info "n_categories: $(art.stats["n_categories"])"
        # @info "n_instance: $(art.stats["n_instance"])"
    end

    n_categories = art.stats["n_categories"]

    return perf, n_categories
end

function cluster_serial(
    art::AbstractGramART,
    data::Statements,
)
    # dim, n_samples = size(data)

    # Process the statements
    # @showprogress for ix in n_samples
    y_hats = zeros(Int, length(data))
    # @showprogress for statement in data
    @showprogress "Clustering" for ix in eachindex(data)
        statement = data[ix]

        # y_hats[ix] = OAR.train!(
        OAR.train!(
        # OAR.train_dv!(
            art,
            statement,
            # epochs=5,
        )
    end

    @showprogress "Classifying" for ix in eachindex(data)
        statement = data[ix]

        y_hats[ix] = OAR.classify(
            art,
            statement,
        )
    end

    # Logging
    @info "n_categories: $(art.stats["n_categories"])"
    # @info "n_instance: $(art.stats["n_instance"])"

    return y_hats
end

function cluster_rand(
    art::AbstractGramART,
    data::Statements,
    truth::Vector{Int},
)
    # Cluster the data and get the cluster labels
    y_hats = OAR.cluster_serial(
        art,
        data,
    )

    # Compute the adjusted rand index
    ri = randindex(y_hats, truth)

    return ri
end

function cluster_rand_data(
    art::AbstractGramART,
    data::DataSplitGeneric,
)
    ri = cluster_rand(
        art,
        vcat(data.train_x, data.test_x),
        vcat(data.train_y, data.test_y),
    )

    return ri
end

"""
Common save function for simulations without ignores.

# Arguments
$ARG_SIM_DIR_FUNC
$ARG_SIM_D
- `fulld::AbstractDict`: the dictionary containing the sim results.
"""
function full_save_sim(
    dir_func::Function,
    d::AbstractDict,
    fulld::AbstractDict,
)
    # Point to the correct save file for the results dictionary
    sim_save_name = dir_func(savename(
        d,
        "jld2";
        digits=4,
    ))

    # Log completion of the simulation
    @info "Worker $(myid()): saving to $(sim_save_name)"

    # DrWatson function to save the results with an additional tag entry
    tagsave(sim_save_name, fulld)

    # Empty return
    return
end

"""
Trains and tests a START module on the provided statements.

# Arguments
$ARG_SIM_D
$ARG_SIM_DIR_FUNC
$ARG_SIM_OPTS
"""
function sim_tt_serial(
    d::AbstractDict,
    dir_func::Function,
    opts::AbstractDict,
)
    # try

    # Point to the correct data and grammar
    data = opts["data"][d["data"]]
    grammar = opts["grammar"][d["data"]]

    # Initialize the GramART module
    if d["m"] == "start"
        art = OAR.GramART(
            grammar,
            rho = d["rho"],
            epochs=1,
        )
    elseif d["m"] == "dvstart"
        art = OAR.GramART(
            grammar,
            rho_lb = d["rho_lb"],
            rho_ub = d["rho_ub"],
            epochs=1,
        )
    elseif d["m"] == "ddvstart"
        art = OAR.DDVSTART(
            rho_lb = d["rho_lb"],
            rho_ub = d["rho_ub"],
            similarity=d["similarity"],
            epochs=1,
        )
    else
        error("Unrecognized module type")
    end

    # Train and test
    perf, n_categories = OAR.tt_serial(
        art,
        data,
        display=false,
    )

    # Copy the input sim dictionary
    fulld = deepcopy(d)

    # Add entries for the results
    fulld["p"] = perf
    fulld["n_cat"] = n_categories

    # Save the results
    full_save_sim(dir_func, d, fulld)

    # catch
    #     @warn "Failed to run sim from worker $(myid())"
    # end

    return
end
