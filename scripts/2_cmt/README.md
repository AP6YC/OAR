# 2_cmt

This experiment runs the GramART method on parsed statements from a medical knowledge graph of the Charcot-Marie-Tooth (CMT) disease.

## Files

- `knowledge_graph_cmt_orig.py`: Dr. Hier's original script generating `node_attributes.txt`, `edge_attributes.txt`, and `OWL` files from the CMT OMIM data.
- `knowledge_graph_cmt_simple.py`: Dr. Hier's original script implementing a simple knowledge graph and ontology for visualization.
- `kgcmt.py`: A modification of `knowledge_graph_cmt_orig.py`, used for generating `edge_attributes_lerche.txt` for parsing in Julia with Lerche.jl.
