# ---
# title: Simple Experiment
# id: simple_experiment
# date: 2023-4-28
# author: "[Sasha Petrenko](https://github.com/AP6YC)"
# julia: 1.9
# description: This demo shows how to run a simple experiment in the OAR project.
# ---

# ## Overview

# This example shows how to run the `Julia` experiments in the `OAR` project.
# Experiments in the `Julia` component of the project are implemented as `Julia` scripts that load the `OAR` module as a source library and subsequently implement a particular experiment.

# These experiments are enumerated under the `scripts/` folder with a number and shorthand name for the experiment.
# READMEs populate this directory to provide context, explanation, and instructions for each experiment.

# You may run one of these experiments by initiating a Julia REPL and "including" the script (which simply inserts the contents of the script directly into the session and runs it).
# This example points to the relative location of an experiment with respect to this example file, so you may need to adjust how you reference the experiment:

## Include/run an experiment that generates a random statement from a discretized Iris dataset grammar
include(joinpath("..", "..", "..", "..", "scripts", "0_init", "ebnf.jl"))

# The above script very importantly includes the preamble
## using DrWatson
## @quickactivate :OAR
# which makes sure that the correct context is set up and that the OAR module containing experiment driver code is precompiled.
# This example will now reactivate the `docs` package because running the above example activates the top-level `OAR` package.

## Reactivate the documentation for future examples
using Pkg
Pkg.activate(joinpath("..", "..", "..", "..", "docs"))
