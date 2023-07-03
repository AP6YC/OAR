#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
    kgcmt.py

# Description
This file is a modification of the `knowledge_graph_cmt_orig.py` experiment originally authors by Dr. Daniel Hier <dbhier@dbhier.com> and modified by Sasha Petrenko <petrenkos@mst.edu>

# Authors
- Dr. Daniel Hier <dbhier@dbhier.com>
- Sasha Petrenko <petrenkos@mst.edu>

# Original Description
Created on Fri Mar 31 10:04:34 2023

@author: danielhier
What this program does?
This is a python program that uses the networkx library
It creates a knowledge graph based on 81 cases of Charcot-Marie-Tooth disease
Cases are from the CMT phenotypic series in the OMIM (On-Line Mendelian Inheritance of Man)
The graph is a bipartite graph with major nodes as disease variants (n=81) and genes (n=64)
The disease variants are in the disease_list (n=81)
The genes are in the gene_list (n=64)
Genes are mapped to proteins
Proteins are in the gene_protein_map which is a list of 60 sublists (n=60) which maps 60 genes(first element)
 to 60 proteins (second element)
The inheritance list (n=4) lists the four modes of genetic inheritance [AR,AD, XLD, and XLR]
"""

# -----------------------------------------------------------------------------
# DEPENDENCIES
# -----------------------------------------------------------------------------

# Top-level imports
import pandas as pd
import networkx as nx
from rdflib import Graph, Literal, Namespace, RDF, RDFS, OWL, XSD

# Local imports
from utils import (
    results_dir,
    data_dir,
)

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

# Data files
CMT_DATA = data_dir("CMT_Location_Disease_Gene.csv")
PHENOTYPE_DATA = data_dir("Phenotype_by_disease.csv")
HPO_DATA = data_dir('HPO_to_tag.csv')
PROTEIN_DATA = data_dir('protein_list_CMT.csv')

# Output/result files
GRAPH_ATTRIBUTES = results_dir('graph_attributes.txt')
EDGE_ATTRIBUTES = results_dir('edge_attributes.txt')
RDF_OWL = results_dir('cmt.owl')
LERCHE_EDGE_ATTRIBUTES = results_dir('edge_attributes_lerche.txt')

# -----------------------------------------------------------------------------
# EXPERIMENT
# -----------------------------------------------------------------------------

# G is the Graph object for CMT
G = nx.DiGraph()
phenotype_list = []
gene_list = []
gene_protein_map = []
variants = []
disease_MIMs = []
disease_MIM = ''
phenotype_HPO_list = []
inheritance_list = []
disease_list = []
gene_location = ''
gene_locations = []
MIM = ''
disease = ''
gene = ''
proteins = set()
df = pd.read_csv(CMT_DATA, header=0)

#################################################################################################################
# The file CMT_Location_Disease_Gene.csv is a CSV file derived from OMIM                                        #
# First row is header row                                                                                        #
# It has 81 datarows for 81 variants of CMT                                                                     #
# All spaces replaced with underscore (_)                                                                       #
# In column [5] when 2 modes of inheritance are noted, the two modes are separated by a pipe character (|)      #
#                        [0]            [1]                [2]           [3]      [4]         [5]               #
# Column headers are [Gene_Location]	[Disease_variant]	[Disease_MIM]	[Gene]	[Gene_MIM] [inheritance]         #
################################################################################################################
CMT_variants = df.values.tolist()  # Converts df to a list of 81 variants
# Create supernodes
G.add_node('disease', category='disease', class_type='class')
G.add_node('gene', category='gene', class_type='class')
G.add_node('inheritance', category='inheritance', class_type='class')
G.add_node('protein', category='protein', class_type='class')
G.add_node('gene_location', category='gene_location', class_type='class')
G.add_node('inheritance', category='inheritance', class_type='class')
G.add_node('phenotype', category='phenotype', class_type='class')
G.add_node('protein_class', category='protein_class', class_type='class')
G.add_node('biologic_process', category='biologic_process', class_type='class')
G.add_node('molecular_function', category='molecular_function', class_type='class')
G.add_node('disease_involvement', category='disease_involvement', class_type='class')
G.add_node('protein_location', category='protein_location', class_type='class')
G.add_node('protein_domain', category='protein_domain', class_type='class')
G.add_node('protein_motif', category='protein_motif', class_type='class')
G.add_node('chromosome', category='chromosome', class_type='class')
# Add nodes and edges from file CMT_Location_Disease_Gene.csv
# Add gene data from "CMT_Location_Disease_Gene.csv"

gene_locations = []
for d in CMT_variants:
    gene_location = d[0]
    disease = d[1]
    disease_MIM = d[2]
    gene = d[3]
    gene_MIM = d[4]
    inheritance = d[5]
    if disease not in disease_list:
        disease_list.append(disease)
    G.add_node(disease, category='disease', MIM=disease_MIM, class_type='individual')   # the name of the disease variant
    disease_MIMs.append(disease_MIM)     # append disease_MIM to a list of disease_MIMs
    G.add_edge(disease, 'disease', relation='is_a')     # 'disease' is a supernode--all diseases are linked to this supernode
    if gene_location not in gene_locations:
        gene_locations.append(gene_location)    # gene_locations is a list of gene)location (n=61
    G.add_node(gene_location, category='gene_location', class_type='individual')
    G.add_edge(gene_location, 'gene_location', relation='is_a')
    G.add_edge(gene, gene_location, relation='has_gene_location')
    G.add_node(gene, category='gene', MIM=gene_MIM, gene_location=gene_location, class_type='individual')   # add each gene as a node
    G.add_edge(disease, gene, relation='is_caused_by')  # add an edge between disease and causative gene
    G.add_edge(gene, 'gene', relation='is_a')
    if gene not in gene_list:
        gene_list.append(gene)  # Useful list of all genes in knowledge graph
    inherit = []
    inherit = inheritance.split('|')    # Some diseases have multiple inheritances.  We use pipe charactder to separate multiple inheritances
    for inherit_type in inherit:
        G.add_node(inherit_type, category='inheritance', class_type='individual')   # Each form of inheritance is a node
        G.add_edge(inherit_type, 'inheritance', relation='is_a')
        G.add_edge(disease, inherit_type, relation='inherited_by')  # add an edge between the disease and how it is inherited
        if inherit_type not in inheritance_list:
            inheritance_list.append(inherit_type)

#######################################################################################################################
# ADD PHENOTYPE DATA                                                                                                   #
#  The file HP)_to_tag.csv relates the HPO accession number to the text name of a phenotype feature                   #
#######################################################################################################################

hpo_to_phenotype = pd.read_csv(HPO_DATA)
hpo_tags = hpo_to_phenotype.values.tolist()   # The is a list of HP numbers and text tags for phenotypes (n=20958)
# hpo_tags maps an HPO number to a text tag describing a phenotype
phenotype_tags = []
phenotypes = []
phenotype_file = pd.read_csv(PHENOTYPE_DATA)
phenotype_by_disease = phenotype_file.values.tolist()

###################################################################
#      [0]            [1]           [2]
# [disease_MIM]    [disease]      [hpo_ID]
#########################################################################################################################
for p in phenotype_by_disease:            # phenotype by disease has a length of 255,541
    disease_MIM = p[0]
    disease = p[1]
    hpo_ID = p[2]
#      print(disease, disease_MIM)
    if disease_MIM in disease_MIMs:     # Disease MIMs is a list of 81 variants of CMT
        for h in hpo_tags:
            hpo = h[0]
            phenotype = h[1]
            if hpo == hpo_ID:
                if phenotype not in phenotype_list:
                    phenotype_list.append(phenotype)
                    G.add_node(phenotype, category='phenotype', hpo_id=hpo_ID, class_type='individual')
                    G.add_edge(phenotype, 'phenotype', relation='is_a')
                    G.add_edge(disease, phenotype, relation='has_a_phenotype')


####################################################################################################################################################################################
# ADD PROTEIN DATA                                                                                                                                                                  #
#  The file proteinatlas.csv has tabular data on different protein characteristics                                                                                                 #
# data is on 20,090 proteins that links gene to protein name                                                                                                                       #
# [0]  |    [1]        |       [2]      |      [3]    |       [4]       |     [5]           |            [6]      |         [7]       |   [8]  | [9]   | [10]  | 11 |     |12    | #
# Gene |Protein Name   |	Uniprot_num Protein Class |	Biologic process |Molecular function |Disease involvement  | Protein_location  |    MW  | domain|motif  |location | length| #
####################################################################################################################################################################################

df_cmt_proteins = pd.read_csv(PROTEIN_DATA)
cmt_proteins = df_cmt_proteins.values.tolist()
for p in cmt_proteins:
    gene = p[0]
    protein = p[1]
    uniprot = p[2]
    chromosome = p[3]
    chromosome__location = p[4]
    protein_class = p[5]
    biologic_process = p[6]
    molecular_function = p[7]
    disease_involvement = p[8]
    MW = p[9]
    domain = p[10]
    motif = p[11]
    protein_location = p[12]
    length = p[13]
    G.add_node(chromosome, category='chromosome', class_type='individual')
    G.add_edge(chromosome, 'chromosome', relation='is_a')
    G.add_edge(gene, chromosome, relation='is_on_chromosome')
    G.add_node(protein, category='protein', uniprot=uniprot, class_type='individual')
    G.add_edge(protein, 'protein', relation='is_a')
    G.add_edge(gene, protein, relation='codes_for')
    protein_classes = protein_class.split('|')
    if 'none' not in protein_class:
        for pc in protein_classes:
            G.add_node(pc, category='protein_class', class_type='individual')
            G.add_edge(pc, 'protein_class', relation='is_a')
            G.add_edge(protein, pc, relation='has_protein_class')
    if 'none' not in biologic_process:
        biological_processes = biologic_process.split('|')
        for bp in biological_processes:
            G.add_node(bp, category='biologic_process', class_type='individual')
            G.add_edge(protein, bp, relation='has_biologic_process')
            G.add_edge(bp, 'biologic_process', relation='is_a')
    if 'none' not in molecular_function:
        molecular_functions = molecular_function.split('|')
        for mf in molecular_functions:
            G.add_node(mf, category='molecular_function', class_type='individual')
            G.add_edge(protein, mf, relation="has_molecular_function")
            G.add_edge(mf, 'molecular_function', relation='is_a')
    if 'none' not in disease_involvement:
        diseases_involved = disease_involvement.split('|')
        for di in diseases_involved:
            G.add_node(di, category='disease_involvement', class_type='individual')
            G.add_edge(protein, di, relation='has_disease_involvement')
            G.add_edge(di, 'disease_involvement', relation='is_a')
    G.add_edge(gene, protein, relation='codes_for')
    protein_domain = domain.split('|')
    if 'none' not in protein_domain:
        for p_d in protein_domain:
            G.add_node(p_d, category='protein_domain', class_type='individual')
            G.add_edge(p_d, 'protein_domain', relation='is_a')
            G.add_edge(protein, p_d, relation='has_a_domain')

    protein_motif = motif.split('|')
    if 'none' not in protein_motif:
        for pm in protein_motif:
            G.add_node(pm, category='protein_motif', class_type='individual')
            G.add_edge(pm, 'protein_motif', relation='is_a')
            G.add_edge(protein, pm, relation='has_a_motif')

    protein_locations = protein_location.split('|')
    if 'none' not in protein_location:
        for pl in protein_locations:
            G.add_node(pl, category='protein_location', class_type='individual')
            G.add_edge(pl, 'protein_location', relation='is_a')
            G.add_edge(protein, pl, relation='is_located_at')

    nx.set_node_attributes(G, {protein: {"molecular_weight": MW}})
    nx.set_node_attributes(G, {protein: {"protein_length": length}})
# You can access the attribute using the `nodes` dictionary
# print(G.nodes[protein]["molecular_weight"])
# print(G.nodes[protein]["protein_length"])


# Draw a low-resolution graph
nx.draw_networkx(G, with_labels=False)

# Write the graph to file in graphml format for GEPHI
nx.write_graphml(G, results_dir('cmt.graphml'))
# nx.write_graphml(G, 'cmt.graphml')
# Find nodes without any edges
isolated_nodes = list(nx.isolates(G))


# Assuming you already have a graph G

# Open a file in write mode
with open(GRAPH_ATTRIBUTES, 'w') as file:
    # Iterate through all nodes in the graph
    for node in G.nodes():
        # Retrieve the attributes of the node
        attributes = G.nodes[node]

        # Write the node and its attributes to the file
        file.write(f"Node: {node}\n")
        for attr, value in attributes.items():
            file.write(f"{attr}: {value}\n")
        file.write('\n')  # Add a blank line between nodes


# Assuming you already have a graph G

# Open a file in write mode
with open(EDGE_ATTRIBUTES, 'w') as file:
    # Iterate through all edges in the graph
    for edge in G.edges():
        # Check if the edge has attributes
        attributes = G.get_edge_data(*edge)
        if attributes:
            # Write the edge and its attributes to the file
            file.write(f"Edge: {edge}\n")
            for attr, value in attributes.items():
                file.write(f"{attr}: {value}\n")
            file.write('\n')  # Add a blank line between edges

# Print the isolated nodes
print('isolated_nodes: ', isolated_nodes)
edge_attributes = []
# Traverse edges and retrieve attributes
for u, v, attributes in G.edges.data():
    if attributes not in edge_attributes:
        edge_attributes.append(attributes)


# Print the list of edge attributes
print('edge attributes:', edge_attributes)

# number of nodes
number_of_nodes = nx.number_of_nodes(G)
print('Number of nodes: ', number_of_nodes)

number_of_edges = nx.number_of_edges(G)
print("number_of_edges: ", number_of_edges)


# Create a new RDF graph
g = Graph()
# Define the namespaces and prefixes
ex = Namespace("http://example.org/#")

# Define the namespaces
ex = Namespace("http://example.org/")
rdf = Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
rdfs = Namespace("http://www.w3.org/2000/01/rdf-schema#")
g.bind("ex", ex)
# Define the classes and subclasses
molecular_function = ex['molecular_function']
biologic_process = ex['biologic_process']
protein_class = ex['protein_class']
protein_motif = ex['protein_motif']
protein_location = ex['protein_location']
gene_location = ex['gene_location']
protein_domain = ex['protein_domain']
chromosome = ex['chromosome']
inheritance = ex['inheritance']
protein = ex["protein"]
gene = ex["gene"]
disease = ex["disease"]
phenotype = ex["phenotype"]
class_list = [molecular_function, protein_location, biologic_process, protein_class, protein_motif,
              gene_location, protein_domain, chromosome, inheritance, protein, gene, disease, phenotype]

# Add classes
for c in class_list:
    if c != '':
        g.add((c, RDF.type, OWL.Class))

for n in G.nodes.data():
    # print(n)
    node_type = ''
    node_type = n[1].get('class_type', 0)
    if node_type == 'individual':
        # print(n[0])
        class_name = n[1].get('category', 0)
        if class_name != 0:
            individual_name = n[0]
            individual_name_uri = ex[individual_name]
            class_name_uri = ex[class_name]
            g.add((individual_name_uri, RDF.type, class_name_uri))


# ADD OBJECT RELATIONSHIPS
relations = set()
start_nodes_set = set()
end_nodes_set = set()
i = 1
start_list = []
for e in G.edges.data():
    start_node = e[0]
    attributes = G.nodes[start_node]
    # print("Start Node:", start_node)
    # print("Attributes:", attributes)
    class_type_num = G.nodes[start_node].get('class_type', 0)
    if class_type_num == 'individual':
        print(start_node, '>', class_type_num)
        start_uri = ex[e[0]]
        start_node = e[0]
        start_nodes_set.add(start_node)
        end_node = e[1]
        if (end_node != 'none' or ''):
            if (start_node != 'none' or ''):
                end_uri = ex[e[1]]
                end_nodes_set.add(end_node)
                object_property_dict = e[2]
                object_property = object_property_dict.get('relation', 0)
                end_value = G.nodes[end_node].get('category', 0)
                # end_node_category = end_node.get('category', 0)
                # print(end_node_category)
                relations.add(object_property)
                # relations.discard('is_a')
                relations.discard(0)
                object_property_list = list(relations)
                if object_property in object_property_list:      # print(object_property)
                    range_value = G.nodes[end_node].get("category", 0)
                    domain_value = G.nodes[start_node].get("category", 0)
                #    print('<<',i,'>>',start_uri,'>>', end_uri, '>>',object_property,'>>', start_node, '>>',domain_value, '>>', range_value)
                    i += 1
                    object_property_uri = ex[object_property]
                    range_uri = ex[range_value]
                    domain_uri = ex[domain_value]
                    g.add((object_property_uri, RDF.type, RDF.Property))
                    g.add((object_property_uri, RDFS.domain, domain_uri))
                    g.add((object_property_uri, RDFS.range, range_uri))
                    g.add((start_uri, object_property_uri, end_uri))
                    start_list.append(start_uri)


################################################################
# Data Properties for the Proteins are added here
################################################################

# create list of proteins and their molecular weights and lengths
MW_list = []
length_list = []
uniprot_list = []
for p in G.nodes:
    if p != 'protein':
        cat = G.nodes[p].get('category', 0)
        if str(cat) == 'protein':
            uniprot = ''
            uniprot = G.nodes[p].get('uniprot', 0)
            uniprot_pair = []
            uniprot_pair.append(p)
            uniprot_pair.append(uniprot)
            uniprot_list.append(uniprot_pair)
            MW = 0
            MW = G.nodes[p].get('molecular_weight', 0)
            MW_pair = []
            MW_pair.append(p)
            MW_pair.append(MW)
            MW_list.append(MW_pair)
            length = 0
            length = G.nodes[p].get('protein_length', 0)
            print(length)
            length_pair = []
            length_pair.append(p)
            length_pair.append(length)
            length_list.append(length_pair)

# Loop through the list and add each protein node and its dataproperty to the graph
protein_weight_uri = ex['protein_weight']
# Add the classes and their labels
g.add((protein_weight_uri, RDFS.label, Literal("protein_weight")))
g.add((protein_weight_uri, RDF.type, OWL.DatatypeProperty))
g.add((protein_weight_uri, RDFS.domain, ex.protein))
g.add((protein_weight_uri, RDFS.range, XSD.string))
for p in MW_list:
    protein_uri = ex[p[0]]
    mol_weight = p[1]
#    print(protein_uri, mol_weight)
    g.add((protein_uri, protein_weight_uri, Literal(
        mol_weight, datatype=XSD.string)))


g.add((protein_weight_uri, RDFS.label, Literal("protein_weight")))
g.add((protein_weight_uri, RDF.type, OWL.DatatypeProperty))
g.add((protein_weight_uri, RDFS.domain, ex.protein))
g.add((protein_weight_uri, RDFS.range, XSD.string))


# Add a new data property for the protein class
protein_length_uri = ex['protein_length']
g.add((protein_length_uri, RDFS.label, Literal("protein_length")))
g.add((protein_length_uri, RDF.type, OWL.DatatypeProperty))
g.add((protein_length_uri, RDFS.domain, ex.protein))
g.add((protein_length_uri, RDFS.range, XSD.string))
for p in length_list:
    # print(p, ex[p[0]], p[1])
    protein_uri = ex[p[0]]
    length_aa = p[1]
    # print(protein_uri, length_aa)
    g.add((protein_uri, protein_length_uri, Literal(
        length_aa, datatype=XSD.string)))

# Add a new data property for the protein uniprot num

uniprot_uri = ex['unipro_num']
g.add((uniprot_uri, RDFS.label, Literal("uniprot_num")))
g.add((uniprot_uri, RDF.type, OWL.DatatypeProperty))
g.add((uniprot_uri, RDFS.domain, ex.protein))
g.add((uniprot_uri, RDFS.range, XSD.string))
for p in uniprot_list:
    # print(p[0],'>>', p[1])
    protein_uri = ex[p[0]]
    uniprot = p[1]
    # print(protein_uri, length_aa)
    g.add((protein_uri, uniprot_uri, Literal(
        uniprot, datatype=XSD.string)))


################################
# Data properities for Genes
###############################

gene_MIM_list = []
for w in G.nodes:
    cat = G.nodes[w].get('category', 0)
    if str(cat) == 'gene':
        gene_MIM = ''
        gene_MIM = G.nodes[w].get('MIM', 0)
        gene_pair = []
        gene_pair.append(w)
        gene_pair.append(gene_MIM)
        gene_MIM_list.append(gene_pair)

gene_MIM_uri = ex['gene_MIM']
g.add((gene_MIM_uri, RDFS.label, Literal("gene_MIM")))
g.add((gene_MIM_uri, RDF.type, OWL.DatatypeProperty))
g.add((gene_MIM_uri, RDFS.domain, ex.gene))
g.add((gene_MIM_uri, RDFS.range, XSD.string))
for w in gene_MIM_list:
    gene_uri = ex[w[0]]
    MIM = w[1]
    g.add((gene_uri, gene_MIM_uri, Literal(MIM, datatype=XSD.string)))


##############################

# Data Properties for phenotypes
phenotype_hpo_list = []
phenotype_hpo_uri = ex['phenotype_hpo']
g.add((phenotype_hpo_uri, RDFS.label, Literal("phenotype_hpo")))
g.add((phenotype_hpo_uri, RDF.type, OWL.DatatypeProperty))
g.add((phenotype_hpo_uri, RDFS.domain, ex.phenotype))
g.add((phenotype_hpo_uri, RDFS.range, XSD.string))
for x in G.nodes:
    cat = G.nodes[x].get('category', 0)
    if cat == 'phenotype':
        #  print(cat)
        hpo = G.nodes[x].get('hpo_id', 0)
        if hpo != 0:
            phenotype_uri = ex[x]
            g.add((phenotype_uri, phenotype_hpo_uri, Literal(
                hpo, datatype=XSD.string)))

# Data Properties for disease
for d in G.nodes:
    cat = G.nodes[d].get('category', 0)
    if cat != 0:
        if cat == 'disease':
            MIM = G.nodes[d].get('MIM', 0)
            variant = d
            if MIM != 0:
                disease_MIM_uri = ex['disease_MIM']
                g.add((disease_MIM_uri, RDFS.label, Literal("disease_MIM")))
                g.add((disease_MIM_uri, RDF.type, OWL.DatatypeProperty))
                g.add((disease_MIM_uri, RDFS.domain, ex.phenotype))
                g.add((disease_MIM_uri, RDFS.range, XSD.string))
                disease_uri = ex[variant]
                disease_MIM = MIM
                g.add((disease_uri, disease_MIM_uri, Literal(
                    disease_MIM, datatype=XSD.string)))

# Find nodes without any edges
isolated_nodes = list(nx.isolates(G))
print('isolated nodes', isolated_nodes)
# for node, attributes in G.nodes.data():
#   print(f"Node {node}: {attributes}")

# Create a set to store unique attribute keys
attribute_keys = set()

# Iterate over all nodes and collect attribute keys
for node, attributes in G.nodes.data():
    attribute_keys.update(attributes.keys())

# Convert the set to a list
attribute_list = list(attribute_keys)

# print(attribute_list)

# Print the isolated nodes
# print('isolated nodes:',isolated_nodes)
edge_attributes = []
# Traverse edges and retrieve attributes
for u, v, attributes in G.edges.data():
    if attributes not in edge_attributes:
        edge_attributes.append(attributes)
# for n, attibutes in G.nodes.data():
    # print(n, attributes)
# Print the list of edge attributes
# print('edge attributes:', edge_attributes)

# number of nodes
number_of_nodes = nx.number_of_nodes(G)
print('Number of nodes: ', number_of_nodes)

number_of_edges = nx.number_of_edges(G)
print("number_of_edges: ", number_of_edges)

# Serialize the RDF graph to an OWL file
file_out = RDF_OWL
g.serialize(file_out, format="xml")
# Print confirmation message
print("CMT Ontology written to", file_out)

# Assuming you already have a graph G

# Open a file in write mode
with open(GRAPH_ATTRIBUTES, 'w') as file:
    # Iterate through all nodes in the graph
    for node in G.nodes():
        # Retrieve the attributes of the node
        attributes = G.nodes[node]

        # Write the node and its attributes to the file
        file.write(f"Node: {node}\n")
        for attr, value in attributes.items():
            file.write(f"{attr}: {value}\n")
        file.write('\n')  # Add a blank line between nodes

# CONVIENCE TRANSCRIPTION FOR LERCHE IN JULIA

# Open a file in write mode
with open(LERCHE_EDGE_ATTRIBUTES, 'w') as file:
    # Iterate through all edges in the graph
    for edge in G.edges():
        # Check if the edge has attributes
        attributes = G.get_edge_data(*edge)
        if attributes:
            # Write in a convenient
            file.write(f"\"{edge[0]}\" \"{attributes['relation']}\" \"{edge[1]}\"\n")
            # file.write(f"{edge[0]} {attributes['relation']} {edge[1]}\n")

print(LERCHE_EDGE_ATTRIBUTES)
