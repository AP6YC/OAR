# OAR

[![oar-header](docs/build/assets/boat-2-512.png)][docs-url]

Ontologies with Adaptive Resonance Theory (ART).

| **Documentation** | **Docs Build Status**|  **Testing Status** |
|:-----------------:|:--------------------:|:-------------------:|
| [![Docs][docs-img]][docs-url] | [![Docs Status][doc-status-img]][doc-status-url] | [![CI Status][ci-img]][ci-url]  |

[doc-status-img]: https://github.com/AP6YC/OAR/actions/workflows/Documentation.yml/badge.svg
[doc-status-url]: https://github.com/AP6YC/OAR/actions/workflows/Documentation.yml

[docs-img]: https://img.shields.io/badge/docs-blue.svg
[docs-url]: https://AP6YC.github.io/OAR/dev/

<!-- [docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://AP6YC.github.io/OAR/dev -->

[ci-img]: https://github.com/AP6YC/OAR/workflows/CI/badge.svg
[ci-url]: https://github.com/AP6YC/OAR/actions?query=workflow%3ACI

## Table of Contents

- [OAR](#oar)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Usage](#usage)
    - [Julia](#julia)
      - [Testing](#testing)
      - [Documentation](#documentation)
    - [Python](#python)
    - [Rust](#rust)
  - [Links](#links)
    - [Ontology](#ontology)
    - [Packages](#packages)
    - [Miscellaneous](#miscellaneous)
  - [Attribution](#attribution)
    - [Citations](#citations)
    - [Authors](#authors)
    - [Images](#images)

[1]: https://julialang.org/
[2]: https://www.python.org/
[3]: https://docs.julialang.org/en/v1/
[4]: https://juliadynamics.github.io/DrWatson.jl/dev/
[5]: https://jupyter.org/
[6]: https://docs.github.com/en/actions/using-workflows
[7]: https://documenter.juliadocs.org/stable/
[8]: https://democards.juliadocs.org/stable/
[9]: https://www.rust-lang.org/

## Overview

This repository is a research project for working with ontologies with Adaptive Resonance Theory (ART) algorithms.

This project contains [`Julia`][1], [`Python`][2], and [`Rust`][9] experiments, so typical project structures for these languages are overlapping in this repository.
This generally does not result in software collision, but this is noted here to clarify any confusion that could arise from this to the reader.

## Usage

This project has both [`Julia`][1], [`Python`][2], and [`Rust`][9] code, so files and experiments using each of these languages are listed separately.

### Julia

The [`Julia`][1] (usage documentation [here][3]) component of this repository is implemented as a [`DrWatson`][4] project, so the repo structure and experiment usage generally follows the `DrWatson` philosophy with some minor changes:

- Experiments are enumerated in their own folders under `scripts`.
- Datasets for experiments and the destination for subsequent results are under `work`.

This repo is also structured as its own project for common code under `src/`.
As such, experiments being with the following preamble to initialize `DrWatson` and load the `OAR` libary code:

```julia
using DrWatson
@quickactivate :OAR
```

#### Testing

Some unit tests are written to validate the library code used for experiments.
Testing is done in the usual `Julia` workflow through the `Julia` REPL:

```julia-repl
julia> ]
(@v1.8) pkg> activate .
(OAR) pkg> test
```

These unit tests are also automated through [GitHub workflows][6].

#### Documentation

The [`Documenter.jl`][7] package is used to generate documentation with examples being generated with [`DemoCards.jl`][8].
This documentation is generated and hosted with [GitHub workflows][6] for the project.
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

### Python

[`Python`][2] experiments are currently in the form of [IPython Jupyter notebooks][5] under the `notebooks/` folder.
Pip requirements are listed in `requirements.txt`, and Python 3.11 is used.

### Rust

The [`Rust`][9] component of the project is contained with its own `oar/` folder.
Until the `Rust` component becomes more sophisticated, its usage simply follows the usual compile-execute method with `cargo`:

```shell
cd oar
cargo run
```

## Links

This section contains several categories of links to useful resources when working with ontologies and the programming techniques of this research project.

### Ontology

- [SIPOC](https://www.wikiwand.com/en/SIPOC)
- [QSAR](https://www.wikiwand.com/en/Quantitative_structure%E2%80%93activity_relationship)
- [Protege](https://protege.stanford.edu/)
- [Barry Smith homepage](http://ontology.buffalo.edu/smith/)

### Packages

- [Julia word2vec Wrapper](https://github.com/JuliaText/Word2Vec.jl)
- [GPT/Hugging Face Tokenizer](https://github.com/huggingface/tokenizers)

### Miscellaneous

- [FBVector](https://github.com/facebook/folly/blob/main/folly/docs/FBVector.md)
- [Lotka-Volterra](https://www.wikiwand.com/en/Lotka%E2%80%93Volterra_equations)
- [Karpathy's Makemore Tutorial](https://youtu.be/PaCmpygFfXo)

## Attribution

### Citations

- GramART:
  - Meuth, Ryan J., "Adaptive multi-vehicle mission planning for search area coverage" (2007). Masters Theses. 44. https://scholarsmine.mst.edu/masters_theses/44

### Authors

- Sasha Petrenko <sap625@mst.edu>

### Images

This project uses the following images:

- [Boat icons created by Freepik - Flaticon](https://www.flaticon.com/free-icons/boat) ([boat_2383726](https://www.flaticon.com/free-icon/boat_2383726))
- [Oar icons created by Freepik - Flaticon](https://www.flaticon.com/free-icons/oar) ([boat_196204](https://www.flaticon.com/free-icon/boat_196204))
