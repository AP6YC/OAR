# OAR

Ontologies with Adaptive Resonance

## Table of Contents

- [OAR](#oar)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Usage](#usage)
    - [Julia](#julia)
    - [Python](#python)
  - [Links](#links)
    - [Ontology](#ontology)
    - [Miscellaneous](#miscellaneous)

[1]: https://julialang.org/
[2]: https://www.python.org/
[3]: https://docs.julialang.org/en/v1/
[4]: https://juliadynamics.github.io/DrWatson.jl/dev/
[5]: https://jupyter.org/


## Overview

This repository is a research project for working with ontologies with Adaptive Resonance Theory (ART) algorithms.

This project contains both `Julia` and `Python` experiments, so typical project structures for these languages are overlapping in this repository.
This generally does not result in software collision, but this is noted here to clarify any confusion that could arise from this to the reader.

## Usage

This project has both `Julia` and `Python` code, so files and experiments using each of these languages are listed separately.

### Julia

The `Julia` component of this repository is implemented as a [`DrWatson`][4] project, so the repo structure and experiment usage generally follows the `DrWatson` philosophy with some minor changes:

- Experiments are enumerated in their own folders under `scripts`.
- Datasets for experiments and the destination for subsequent results are under `work`.

This repo is also structured as its own project for common code under `src/`.
As such, experiments being with the following preamble to initialize `DrWatson` and load the `OAR` libary code:

```julia
using DrWatson
@quickactivate :OAR
```

### Python

`Python` experiments are currently in the form of [IPython Jupyter notebooks][4] under the `notebooks/` folder.
Pip requirements are listed in `requirements.txt`, and Python 3.11 is used.

## Links

This section contains several categories of links to useful resources when working with ontologies and the programming techniques of this research project.

### Ontology

- [SIPOC](https://www.wikiwand.com/en/SIPOC)
- [QSAR](https://www.wikiwand.com/en/Quantitative_structure%E2%80%93activity_relationship)
- [Protege](https://protege.stanford.edu/)
- [Barry Smith homepage](http://ontology.buffalo.edu/smith/)

### Miscellaneous

- [FBVector](https://github.com/facebook/folly/blob/main/folly/docs/FBVector.md)
- [Lotka-Volterra](https://www.wikiwand.com/en/Lotka%E2%80%93Volterra_equations)
