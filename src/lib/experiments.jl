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
