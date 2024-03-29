"""
    make.jl

# Description
This file builds the documentation for the `OAR` project using Documenter.jl and other tools.

# Authors
- Sasha Petrenko <petrenkos@mst.edu>
"""

# -----------------------------------------------------------------------------
# DEPENDENCIES
# -----------------------------------------------------------------------------

using
    Documenter,
    DemoCards,
    Logging,
    Pkg

# -----------------------------------------------------------------------------
# SETUP
# -----------------------------------------------------------------------------

# Common variables of the script
PROJECT_NAME = "OAR"
DOCS_NAME = "docs"

# Fix GR headless errors
ENV["GKSwstype"] = "100"

# Get the current workind directory's base name
current_dir = basename(pwd())
@info "Current directory is $(current_dir)"

# If using the CI method `julia --project=docs/ docs/make.jl`
#   or `julia --startup-file=no --project=docs/ docs/make.jl`
if occursin("OAR", current_dir)
    push!(LOAD_PATH, "../src/")
# Otherwise, we are already in the docs project and need to dev the above package
elseif occursin("docs", current_dir)
    Pkg.develop(path="..")
# Otherwise, building docs from the wrong path
else
    error("Unrecognized docs setup path")
end

# Inlude the local package
using OAR

# using JSON
if haskey(ENV, "DOCSARGS")
    for arg in split(ENV["DOCSARGS"])
        (arg in ARGS) || push!(ARGS, arg)
    end
end

# -----------------------------------------------------------------------------
# DOWNLOAD LARGE ASSETS
# -----------------------------------------------------------------------------


# Point to the raw FileStorage location on GitHub
top_url = raw"https://media.githubusercontent.com/media/AP6YC/FileStorage/main/OAR/"

# List all of the files that we need to use in the docs
files = [
    "header.png",
]

# Make a destination for the files, accounting for when folder is AdaptiveResonance.jl
assets_folder = joinpath("src", "assets")
if basename(pwd()) == PROJECT_NAME || basename(pwd()) == PROJECT_NAME * ".jl"
    assets_folder = joinpath(DOCS_NAME, assets_folder)
end

download_folder = joinpath(assets_folder, "downloads")
mkpath(download_folder)
download_list = []

# Download the files one at a time
for file in files
    # Point to the correct file that we wish to download
    src_file = top_url * file * "?raw=true"
    # Point to the correct local destination file to download to
    dest_file = joinpath(download_folder, file)
    # Add the file to the list that we will append to assets
    push!(download_list, dest_file)
    # If the file isn't already here, download it
    if !isfile(dest_file)
        download(src_file, dest_file)
        @info "Downloaded $dest_file, isfile: $(isfile(dest_file))"
    else
        @info "File already exists: $dest_file"
    end
end

# Downloads debugging
detailed_logger = Logging.ConsoleLogger(stdout, Info, show_limited=false)
with_logger(detailed_logger) do
    @info "Current working directory is $(pwd())"
    @info "Assets folder is:" readdir(assets_folder, join=true)
    # full_download_folder = joinpath(pwd(), "src", "assets", "downloads")
    @info "Downloads folder exists: $(isdir(download_folder))"
    if isdir(download_folder)
        @info "Downloads folder contains:" readdir(download_folder, join=true)
    end
end

# -----------------------------------------------------------------------------
# GENERATE
# -----------------------------------------------------------------------------

# Generate the demo files
# this is the relative path to docs/
demopage, postprocess_cb, demo_assets = makedemos("examples")

assets = [
    joinpath("assets", "favicon.ico"),
]

# if there are generated css assets, pass it to Documenter.HTML
isnothing(demo_assets) || (push!(assets, demo_assets))

# Make the documentation
makedocs(
    modules=[OAR],
    format=Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets = assets,
        size_threshold = Int(1e6),
    ),
    pages=[
        "Home" => "index.md",
        # "Getting Started" => [
        #     "getting-started/whatisart.md",
        #     "getting-started/basic-example.md",
        # ],
        "Manual" => [
            "Guide" => "man/guide.md",
            demopage,
            "Languages" => "man/languages.md",
            # "Examples" => "man/examples.md",
            # "Modules" => "man/modules.md",
        ],
        "Internals" => [
            "Index" => "man/full-index.md",
            "Dev Index" => "man/dev-index.md",
            "Contributing" => "man/contributing.md",
        ],
    ],
    repo="https://github.com/AP6YC/OAR/blob/{commit}{path}#L{line}",
    sitename="OAR",
    authors="Sasha Petrenko",
    # assets=String[],
)

# 3. postprocess after makedocs
postprocess_cb()

# a workdaround to github action that only push preview when PR has "push_preview" labels
# issue: https://github.com/JuliaDocs/Documenter.jl/issues/1225
# function should_push_preview(event_path = get(ENV, "GITHUB_EVENT_PATH", nothing))
#     event_path === nothing && return false
#     event = JSON.parsefile(event_path)
#     haskey(event, "pull_request") || return false
#     labels = [x["name"] for x in event["pull_request"]["labels"]]
#     return "push_preview" in labels
#  end

# -----------------------------------------------------------------------------
# DEPLOY
# -----------------------------------------------------------------------------

deploydocs(
    repo="github.com/AP6YC/OAR.git",
    # devbranch="develop",
    devbranch="main",
    # push_preview = should_push_preview(),
)
