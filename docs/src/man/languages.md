# [Languages](@id languages)

This project has both [`Julia`](https://julialang.org/), [`Python`](https://www.python.org/), and [`Rust`](https://www.rust-lang.org/) code, so files and experiments using each of these languages are listed separately.

- [`Julia`](@ref man-julia): an outline of the main `julia` component of the project.
  - [Testing](@ref man-julia-testing): how `julia` unit tests work in the project.
  - [Documentation](@ref man-julia-documentation): how this very documentation is generated and hosted with `julia` and `Documenter.jl`
- [`Python`](@ref man-python): how the various `python` components of the project work, including notebooks, scripts, and their requirements.
- [`Rust`](@ref man-rust): where the `rust` component of the project is located and how to run it.

## [Julia](@id man-julia)

The [`Julia`](https://julialang.org/) (usage documentation [here](https://docs.julialang.org/en/v1/)) component of this repository is implemented as a [`DrWatson`](https://juliadynamics.github.io/DrWatson.jl/dev/) project, so the repo structure and experiment usage generally follows the `DrWatson` philosophy with some minor changes:

- Experiments are enumerated in their own folders under `scripts`.
- Datasets for experiments and the destination for subsequent results are under `work`.

This repo is also structured as its own Julia module with common code under `src/`.
As such, most experiments begin with the following preamble to load `Revise` and `OAR`:

```julia
using Revise
using OAR
```

`Revise.jl` is used here because it affords the ability to change functions and modules in scripts without having to reload the `Julia` session every time that a change is made.
`OAR` is loaded as its own module because it contains most of the driver code for experiments.

Some other experiments follow the `DrWatson` usage with the following preamble, which initializes `DrWatson` and loads the `OAR` libary code:

```julia
using DrWatson
@quickactivate :OAR
```

The `@quickactivate` macro simply makes sure that the activate project is the `OAR` project and loads it.
This usage is only necessary if running the experiment from some directory outside the project, but the assumption is made for most experiments that the script is run from the top of the `OAR` project

### [Testing](@id man-julia-testing)

Some unit tests are written to validate the library code used for experiments.
Testing is done in the usual `Julia` workflow through the `Julia` REPL:

```julia-repl
julia> ]
(@v1.9) pkg> activate .
(OAR) pkg> test
```

These unit tests are also automated through [GitHub workflows](https://docs.github.com/en/actions/using-workflows).

### [Documentation](@id man-julia-documentation)

The [`Documenter.jl`](https://documenter.juliadocs.org/stable/) package is used to generate documentation with examples being generated with [`DemoCards.jl`](https://democards.juliadocs.org/stable/).
This documentation is generated and hosted with [GitHub workflows](https://docs.github.com/en/actions/using-workflows) for the project.
To generate the documentation locally, change your terminal directory to the `docs/` directory and run Julia with the following REPL commands:

```julia-repl
julia> ]
(@v1.9) pkg> activate .
(docs) pkg> instantiate
(docs) pkg> <BACKSPACE>
julia> include("serve".jl)
```

The line `<BACKSPACE>` means hitting the backspace key on your keyboard.
This instantiates the documentation (downloading and precompiling dependencies), builds the documentation, and hosts it locally.
If you wish to just build the docs, instead run `include("make.jl")` (the `serve.jl` script simply runs the make script and runs a local live server for convenience).

## [Python](@id man-python)

[`Python`](https://www.python.org/) (usage docs [here](https://docs.python.org/)) experiments are currently in the form of [IPython Jupyter notebooks](https://jupyter.org/) under the `notebooks/` folder.
Pip requirements are listed in `requirements.txt`, and Python 3.11 is used.

## [Rust](@id man-rust)

The [`Rust`](https://www.rust-lang.org/) (usage docs [here](https://www.rust-lang.org/learn)) component of the project is contained with its own `oar/` folder.
Until the `Rust` component becomes more sophisticated, its usage simply follows the usual binary project compile-execute method with `cargo run`:

```shell
cd oar
cargo run
```
