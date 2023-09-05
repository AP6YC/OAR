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
Computes the sliding window average of a vector with window size `n`.

# Arguments
- `vs::RealVector`: the original vector for sliding window averages.
- `n::Integer`: the size of the sliding window.
"""
function sliding_avg(vs::RealVector, n::Integer)
    # Construct and return the sliding window average
    return [
        sum(@view vs[i:(i+n-1)])/n for i in 1:(length(vs)-(n-1))
    ]
end

"""
Constructs a windowed matrix of a vector.

# Arguments
- `vs::RealVector`: the original vector.
- `n::Integer`: the size of the sliding window.
"""
function get_windows(vs::RealVector, n::Integer)
    # Compute the size of the window
    n_window = length(vs) - n + 1

    # Initialize the windowed matrix version of the input vector
    local_window = zeros(n, n_window)

    # Construct a windowed version of vector at each index of n_window
    for ix = 1:n_window
        local_window[:, ix] = vs[ix:(ix + n - 1)]
    end

    # Return the windowed matrix version of the vector
    return local_window
end

"""
Generates the plot for the cluster statistics.

# Arguments
- `df::DataFrame`: the dataframe with the clusters vs. rho to plot.
- `avg::Bool=false`: flag for using the sliding average procedure.
- `err::Bool=false`: flag for using a StatsPlots `errorline!`.
- `n::Integer=10`: used if `avg` is high, the size of the sliding window.
"""
function cluster_stats_plot(
    df::DataFrame;
    avg::Bool=false,
    err::Bool=false,
    n::Integer=10,
    fontsize::Integer=10,
    kwargs...,
)
    # Number of rows in the dataframe
    n_rows = size(df)[1]

    # 1. Number of clusters
    n_cluster = zeros(Int, n_rows)
    # 2. Maximum number samples in any one cluster
    max_membership = zeros(Int, n_rows)
    # 3. Number of clusters with only one member
    n_one = zeros(Int, n_rows)
    # Compute the values for each row
    # for row in eachrow(df)
    for ix = 1:n_rows
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

    attrs = (
        (n_cluster, "Number of clusters"),
        (max_membership, "Maximum cluster size"),
        (n_one, "Singleton Clusters"),
    )
    xs = df[:, :rho]

    # Create the plot
    p = plot(
        dpi=DPI,
        titlefontsize=fontsize,
        tickfontsize=fontsize,
        legendfontsize=fontsize,
        guidefontsize=fontsize,
        legendtitlefontsize=fontsize,
        # scalefontsizes=fontsize,
        # title = "Vigilance ρ vs. Clustering Attribute",
        fontfamily=FONTFAMILY,
    )

    # Add the pass-through plots kwargs
    plot!(p;
        kwargs...
    )

    # Plot each attribute
    for (data, label) in attrs
        if err
            # Point to the the x and y of the plot
            local_x = xs[1:end - n + 1]
            local_y = transpose(get_windows(data, n))
            errorline!(p,
                local_x,
                local_y,
                label = label,
                linewidth = LINEWIDTH,
                color_palette = COLORSCHEME,
                errorstyle = :ribbon,
            )
        else
            # If selected, do the windowed averaging procedure
            if avg
                local_x = xs[1:end-n+1]
                local_y = sliding_avg(data, n)
            else
                local_x = xs
                local_y = data
            end
            plot!(p,
                local_x,
                local_y,
                label = label,
                linewidth = LINEWIDTH,
                color_palette = COLORSCHEME,
            )
        end
    end

    # Add the vline for the preselected rho value
    vline!(p,
        [0.6],
        linewidth=LINEWIDTH,
        linestyle = :dash,
        label="",
    )

    # Display the plot
    isinteractive() && display(p)

    # Plots.scalefontsizes()

    # Return the plot handle
    return p
end
