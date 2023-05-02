# [Languages](@id languages)

This project has both [`Julia`](https://julialang.org/), [`Python`](https://www.python.org/), and [`Rust`](https://www.rust-lang.org/) code, so files and experiments using each of these languages are listed separately.

## Julia

The [`Julia`](https://julialang.org/) (usage documentation [here](https://docs.julialang.org/en/v1/)) component of this repository is implemented as a [`DrWatson`](https://juliadynamics.github.io/DrWatson.jl/dev/) project, so the repo structure and experiment usage generally follows the `DrWatson` philosophy with some minor changes:

- Experiments are enumerated in their own folders under `scripts`.
- Datasets for experiments and the destination for subsequent results are under `work`.

This repo is also structured as its own project for common code under `src/`.
As such, experiments being with the following preamble to initialize `DrWatson` and load the `OAR` libary code:

```julia
using DrWatson
@quickactivate :OAR
```

### Testing

Some unit tests are written to validate the library code used for experiments.
Testing is done in the usual `Julia` workflow through the `Julia` REPL:

```julia-repl
julia> ]
(@v1.8) pkg> activate .
(OAR) pkg> test
```

These unit tests are also automated through [GitHub workflows]https://docs.github.com/en/actions/using-workflows.

### Documentation

The [`Documenter.jl`](https://documenter.juliadocs.org/stable/) package is used to generate documentation with examples being generated with [`DemoCards.jl`](https://democards.juliadocs.org/stable/).
This documentation is generated and hosted with [GitHub workflows]https://docs.github.com/en/actions/using-workflows for the project.
To generate the documentation locally, change your terminal directory to the `docs/` directory and run Julia with the following REPL commands:

```julia-repl
julia> ]
(@v1.8) pkg> activate .
(docs) pkg> instantiate
(docs) pkg> <BACKSPACE>
julia> include("serve".jl)
```

The line `<BACKSPACE>` means hitting the backspace key on your keyboard.
This instantiates the documentation (downloading and precompiling dependencies), builds the documentation, and hosts it locally.
If you wish to just build the docs, instead run `include("make.jl")` (the `serve.jl` script simply runs the make script and runs a local live server for convenience).

## Python

[`Python`](https://www.python.org/) experiments are currently in the form of [IPython Jupyter notebooks]https://jupyter.org/ under the `notebooks/` folder.
Pip requirements are listed in `requirements.txt`, and Python 3.11 is used.

## Rust

The [`Rust`](https://www.rust-lang.org/) component of the project is contained with its own `oar/` folder.
Until the `Rust` component becomes more sophisticated, its usage simply follows the usual compile-execute method with `cargo`:

```shell
cd oar
cargo run
```
