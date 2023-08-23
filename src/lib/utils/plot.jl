"""
    plot.jl

# Description
A collection of plotting utilities and recipes for the project.
"""

"""
Wrapper for how figures are saved in the OAR project.

# Arguments
- `p::Plots.Plot`: the Plot object to save.
$ARG_FILENAME
"""
function _save_plot(p::Plots.Plot, filename::AbstractString)
    savefig(p, filename)
end

"""
Wrapper for how tables are saved in the OAR project.

# Arguments
- `table`: the table object to save.
$ARG_FILENAME
"""
function _save_table(table, filename::AbstractString)
    open(filename, "w") do io
        write(io, table)
    end
end

"""
Dictionary mapping the names of result save types to the private wrapper functions that implement them.
"""
const SAVE_MAP = Dict(
    "figure" => :_save_fig,
    "table" => :_save_table,
)

"""
Saves the plot to the both the local results directory and to the paper directory.

# Arguments
- `p::Plots.Plot`: the handle of the plot to save.
- `fig_name::AbstractString`: the name of the figure file itself.
- `exp_top::AbstractString`: the top of the experiment directory.
- `exp_name::AbstractString`: the name of the experiment itself.
"""
function save_plot(
    p::Plots.Plot,
    fig_name::AbstractString,
    exp_top::AbstractString,
    exp_name::AbstractString
)
    # Save to the local results directory
    mkpath(results_dir(exp_top, exp_name))
    _save_plot(p, results_dir(exp_top, exp_name, fig_name))
    # Save to the paper directory
    mkpath(paper_results_dir(exp_top, exp_name))
    _save_plot(p, paper_results_dir(exp_top, exp_name, fig_name))

    return
end

"""
Generates the plot for the cluster statistics.

# Arguments
- `df::DataFrame`
"""
function cluster_stats_plot(df::DataFrame)
    # Number of rows in the dataframe
    n = size(df)[1]

    # 1. Number of clusters
    n_cluster = zeros(Int, n)
    # 2. Maximum number samples in any one cluster
    max_membership = zeros(Int, n)
    # 3. Number of clusters with only one member
    n_one = zeros(Int, n)
    # Compute the values for each row
    # for row in eachrow(df)
    for ix = 1:n
        # Local cluster assignments
        # lc = row[:clusters]
        lc = df[ix, :clusters]

        # Uniques vector
        uniques = unique(lc)
        # Number of uniques
        n_unique = length(uniques)

        # 1. Number of clusters
        n_cluster[ix] = n_unique

        # 2. Maximum number of samples
        n_memberships = zeros(Int, n_unique)
        for jx = 1:n_unique
            n_memberships[jx] = count(x ->x==uniques[jx], lc)
        end
        max_membership[ix] = maximum(n_memberships)

        # 3. Number of clusters with one
        n_with_one = 0
        for jx = 1:n_unique
            if n_memberships[jx] == 1
                n_with_one += 1
            end
        end
        n_one[ix] = n_with_one
    end

    # Plot each attribute
    p = plot()
    xs = df[:, :rho]
    plot!(p, xs,
        n_cluster,
        label="n_cluster",
    )
    plot!(p, xs,
        max_membership,
        label="max_membership",
    )
    plot!(p, xs,
        n_one,
        label="n_one",
    )

    # Display the plot
    isinteractive() && display(p)

    # Return the plot handle
    return p
end
