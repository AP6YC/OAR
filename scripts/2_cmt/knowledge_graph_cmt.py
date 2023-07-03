"""
    knowledge_graph_cmt.py

# Description
This file is a transcription of the original experiment authored by Dr. Daniel Hier.

# Authors
- Dr. Daniel Hier <dhier@mst.edu>
- Sasha Petrenko <petrenkos@mst.edu>
"""

import os
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

# Local utilities
from utils import results_dir

# os.chdir("../../work/data/cmt/")
# os.chdir("work/data/cmt/")

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
# graph_file = 'small_kg.graphml'
graph_file = results_dir('small_kg.graphml')
nx.write_graphml(g, graph_file)
print(f"{graph_file} saved as as file.")

# Convert NetworkX graph to RDFLib graph
G = Graph()

# Namespaces
ex = Namespace("http://example.org/")
# Add data property molecular weight to graph G
molecular_weight_uri = ex['molecular_weight']
G.add((molecular_weight_uri, RDFS.label, Literal("molecular_weight")))
G.add((molecular_weight_uri, RDF.type, OWL.DatatypeProperty))
G.add((molecular_weight_uri, RDFS.domain, ex.protein))
G.add((molecular_weight_uri, RDFS.range, XSD.integer))
# Add object property "codes_for" to G
object_property_uri = ex['codes_for']
range_uri = ex['protein']
domain_uri = ex['gene']
G.add((object_property_uri, RDF.type, RDF.Property))
G.add((object_property_uri, RDFS.domain, domain_uri))
G.add((object_property_uri, RDFS.range, range_uri))
# Add nodes and their attributes
for node, data in g.nodes(data=True):
    type_of_class = data['class_type']
    category_name = data['category']
    if type_of_class == 'instance':
        instance_name_uri = ex[node]
        category_name_uri = ex[category_name]
        G.add((instance_name_uri, RDF.type, category_name_uri))
        if category_name == 'protein':
            mw = data['molecular_weight']
            instance_name_uri = ex[node]
            G.add((instance_name_uri, ex['molecular_weight'], Literal(mw)))

# Add edges and their attributes
for start_node, end_node, attribute in g.edges(data=True):
    if attribute['relation'] == 'codes_for':
        G.add((ex[start_node], ex['codes_for'], ex[end_node]))

# Save RDFLib graph G to OWL file
# ontology_file = 'small_ontology.owl'
ontology_file = results_dir('small_ontology.owl')
G.serialize(destination=ontology_file, format='xml')
print(f"Ontology saved to {ontology_file} in OWL format.")

# Define SPARQL query to find proteins with MW > 10

query = """
    PREFIX ex: <http://example.org/>
    SELECT ?protein ?mw
    WHERE {
        ?protein a ex:protein;
            ex:molecular_weight ?mw.
        FILTER (?mw > 10)
    }
"""

# Execute the query on the graph G
results = G.query(query)
