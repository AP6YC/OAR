"""
    knowledge_graph_cmt.py

# Description
This file is the original experiment authored by Dr. Daniel Hier.

# Authors
- Dr. Daniel Hier <dhier@mst.edu>
- Sasha Petrenko <petrenkos@mst.edu>
"""

import os
os.chdir("../../work/data/cmt/")
import networkx as nx
from rdflib import (
    Graph,
    Literal,
    RDF,
    OWL,
    RDFS,
    XSD,
)
from rdflib.namespace import Namespace
genes = ('nefl', 'tor1a', 'mapt')
proteins = ('neurofilament_light', 'torsin_1A', 'tau')
MW = (61, 38, 55)

# Create a directed graph G in Networkx
g = nx.DiGraph()

# Add classes as nodes
g.add_node('gene', category='gene', class_type='class')
g.add_node('protein', category='protein', class_type='class')
# Add instances as nodes and set attributes
for gene, protein, mw in zip(genes, proteins, MW):
    g.add_node(
        gene,
        category='gene',
        class_type='instance',
    )
    g.add_node(
        protein,
        category='protein',
        molecular_weight=mw,
        class_type='instance',
    )
    g.add_edge(
        gene,
        protein,
        relation='codes_for',
    )
    g.add_edge(
        gene,
        'gene',
        relation='SubClassOf',
    )
    g.add_edge(
        protein,
        'protein',
        relation='SubClassOf',
    )

# Save the networkx graph g to disk
graph_file = 'small_kg.graphml'
nx.write_graphml(g, graph_file)
print(f"{graph_file} saved as as file.")