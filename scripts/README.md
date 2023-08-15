# `scripts/`

This folder contains a series of experiments for the `OAR` project, which are enumerated below:

- `0_init`: initial development files for the project and experiment driver library.
- `1_iris`: the GramART method applied to the Iris dataset for verification.
- `2_kg_gramart`: the clustering of medical disease knowledge graphs edge statements with GramART.
This experiment takes existing disease data, generates a knowledge graph from each instance, transforms each instance and relation into a `subject`-`predicate`-`object` statement, and clusters these statements with GramART.
- `3_cmt`: the clustering of disease protein data "flat files" with GramART.
