# OAR

[![oar-header](docs/src/assets/logo.png)][docs-url]

Ontologies with Adaptive Resonance Theory (ART).
Please see the [documentation][docs-url].

| **Documentation** | **Docs Build Status** | **Coveralls** |
|:-----------------:|:---------------------:|:--------:|
| [![Docs][docs-img]][docs-url] | [![Docs Status][doc-status-img]][doc-status-url] | [![Coveralls][coveralls-img]][coveralls-url] |
| **Zenodo DOI** | **Testing Status** | **Codecov** |
| [![DOI][zenodo-img]][zenodo-url] | [![CI Status][ci-img]][ci-url] |  [![Codecov][codecov-img]][codecov-url] |

[doc-status-img]: https://github.com/AP6YC/OAR/actions/workflows/Documentation.yml/badge.svg
[doc-status-url]: https://github.com/AP6YC/OAR/actions/workflows/Documentation.yml

[docs-img]: https://img.shields.io/badge/docs-blue.svg
[docs-url]: https://AP6YC.github.io/OAR/dev/

[ci-img]: https://github.com/AP6YC/OAR/workflows/CI/badge.svg
[ci-url]: https://github.com/AP6YC/OAR/actions?query=workflow%3ACI

[codecov-img]: https://codecov.io/gh/AP6YC/OAR/branch/main/graph/badge.svg
[codecov-url]: https://codecov.io/gh/AP6YC/OAR

[coveralls-img]: https://coveralls.io/repos/github/AP6YC/OAR/badge.svg?branch=main
[coveralls-url]: https://coveralls.io/github/AP6YC/OAR?branch=main

[zenodo-img]: https://zenodo.org/badge/601743357.svg
[zenodo-url]: https://zenodo.org/badge/latestdoi/601743357

## Table of Contents

- [OAR](#oar)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Usage](#usage)
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
[11]: https://docs.python.org/
[3]: https://docs.julialang.org/en/v1/
[4]: https://juliadynamics.github.io/DrWatson.jl/dev/
[5]: https://jupyter.org/
[6]: https://docs.github.com/en/actions/using-workflows
[7]: https://documenter.juliadocs.org/stable/
[8]: https://democards.juliadocs.org/stable/
[9]: https://www.rust-lang.org/
[12]: https://www.rust-lang.org/learn
[10]: https://ap6yc.github.io/OAR/dev/man/languages/

## Overview

This repository is a research project for working with ontologies with Adaptive Resonance Theory (ART) algorithms.

This project contains [`Julia`][1] ([docs][3]), [`Python`][2] ([docs][11]), and [`Rust`][9] ([docs][12]) experiments, so typical project structures for these languages are overlapping in this repository.
This generally does not result in software collision, but this is noted here to clarify any confusion that could arise from this to the reader.

The majority of the project is structured as a [`DrWatson`][4] research project, but the source files are organized into a `Julia` Package for documentation, testing, and reproducibility.

## Usage

This project has both [`Julia`][1], [`Python`][2], and [`Rust`][9] code, so files and experiments using each of these languages are listed separately.

For a detailed usage guide and outline, please see the [Languages][10] section in the documentation.

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
- [Fusion 360 Gallery Datset](https://github.com/AutodeskAILab/Fusion360GalleryDataset) ([paper](https://arxiv.org/pdf/2010.02392.pdf))

### Miscellaneous

- [FBVector](https://github.com/facebook/folly/blob/main/folly/docs/FBVector.md)
- [Lotka-Volterra](https://www.wikiwand.com/en/Lotka%E2%80%93Volterra_equations)
- [Karpathy's Makemore Tutorial](https://youtu.be/PaCmpygFfXo)

## Attribution

### Citations

- [START](https://scholarsmine.mst.edu/masters_theses/44):
  - _Meuth, Ryan J., "Adaptive multi-vehicle mission planning for search area coverage" (2007). Masters Theses. 44. [https://scholarsmine.mst.edu/masters_theses/44](https://scholarsmine.mst.edu/masters_theses/44)_

### Authors

- Sasha Petrenko <petrenkos@mst.edu>
- Dr. Daniel Hier <dbhier@dbhier.com>

### Images

This project uses the following images:

- [Boat icons created by Freepik - Flaticon](https://www.flaticon.com/free-icons/boat) ([boat_2383726](https://www.flaticon.com/free-icon/boat_2383726))
- [Oar icons created by Freepik - Flaticon](https://www.flaticon.com/free-icons/oar) ([boat_196204](https://www.flaticon.com/free-icon/boat_196204))
