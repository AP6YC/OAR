#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 31 10:04:34 2023
@author: danielhier
What this program does?
This is a python program that uses the networkx library
It creates a knowledge graph based on 34 varianats of dystonia
"""
######################
# Import libraries
from rdflib import Graph, Literal, Namespace, RDF, RDFS, OWL, XSD, URIRef
import pandas as pd
import networkx as nx
import os
#######################
# File are in default directory desktop/networkx
os.chdir('/Users/danielhier/desktop/dystonia')
# G is Networkx Graph object for dystonia
G = nx.DiGraph()
phenotype_list = []
protein_list = []
gene_list = []
gene_protein_map = []
variants = []
disease_MIMs = []
disease_MIM = ''
phenotype_HPO_list = []
inheritance_list = []
disease_list = []
gene_location = ''
gene_location_list = []
MIM = ''
disease = ''
gene_name = ''
genes = []
g = ''
# Read in the csv file from OMIM with the dystonia phenotypic series
df = pd.read_csv("OMIM_dystonia_series.csv", header=0)
#Create supernodes
G.add_node('disease', category = 'disease',class_type='class')
G.add_node('chromosome', category='chromosome',class_type='class')
G.add_node('gene', category='gene', class_type='class')
G.add_node('inheritance', category ='inheritance', class_type='class')
G.add_node('protein', category ='protein', class_type='class')
G.add_node('gene_location', category='gene_location', class_type='class')
G.add_node('inheritance', category='inheritance', class_type='class')
G.add_node('phenotype', category='phenotype', class_type='class')
G.add_node('protein_class', category='protein_class', class_type='class')
G.add_node('biologic_process',category='biologic_process', class_type='class')
G.add_node('molecular_function',category='molecular_function', class_type='class')
G.add_node('disease_involvement',category='disease_involvement', class_type='class')
G.add_node('protein_location', category ='protein_location',class_type ='class')
G.add_node('protein_domain',category ='protein_domain', class_type='class')
G.add_node('protein_motif', category = 'protein_motif', class_type='class')
#########################################################################################################
# The file OMIM_dystonia_series.csv is a CSV file derived from OMIM                                     #
# It has 34 rows for 34 variants of dystonia                                                                #
#      [0]            [1]                      [2]           [3]      [4]         [5]                   #
#[Gene_Location]	[Disease__name]	       [Disease_MIM]	[Gene]	 [Gene_MIM] [mode_of_inheritance]    #  
#########################################################################################################
dystonia_variants = df.values.tolist()  # Converts df to a list of 34 variants


# Add data from OMIM
for d in dystonia_variants:
    gene_location = d[0]
    disease_name = d[1]
    disease_MIM = d[2]
    gene_name = d[3]
    gene_MIM = d[4]
    inheritance = d[5]
    if disease_name not in disease_list:
        disease_list.append(disease_name)
    # the name of the disease variant
    G.add_node(disease_name, category='disease', MIM=disease_MIM, class_type='individual')
    # append disease_MIM to a list of disease_MIMs
    disease_MIMs.append(disease_MIM)
    # 'disease' is a supernode--all diseases are linked to this supernode
    G.add_edge(disease_name, 'disease', relation='is_a')
    if gene_location not in gene_location_list:
        # gene_location_list is a list of gene)location (n=61)
        gene_location_list.append(gene_location)
   # G.add_edge(gene_location, 'gene_location', relation = 'isa')
    G.add_node(gene_location, category='gene_location', class_type='individual')
    G.add_node(gene_name, category='gene', MIM=gene_MIM, class_type='individual')  # add each gene as a node
    G.add_edge(gene_location, 'gene_location', relation ='is_a')
    # add an edge between disease and causative gene
    G.add_edge(gene_name, disease_name, relation='causes')
    if gene_name not in gene_list:
        # Useful list of all genes in knowledge graph
        gene_list.append(gene_name)
    # add edge between each gene and supernored "gene"
    G.add_edge(gene_name, 'gene', relation='is_a')
    G.add_edge(gene_name, gene_location, relation ='has_gene_location')
    G.add_edge(gene_location, 'gene_location', relation='is_a')

    inherit = []
    # Some diseases have multiple inheritances.  We use pipe charactder to separate multiple inheritances
    inherit = inheritance.split('|')
    for inheritance_name in inherit:
        # Each form of inheritance is a node
        G.add_node(inheritance_name, category='inheritance', class_type= 'individual')
        # add an edge between the disease and how it is inherited
        G.add_edge(disease_name, inheritance_name, relation='has_inheritance_by')
        G.add_edge(inheritance_name, 'inheritance', relation='is_a')
        if inheritance_name not in inheritance_list:
            inheritance_list.append(inheritance_name)

####################################################
# ADD PHENOTYPE DATA
#  The file HPO_to_tag.csv relates the HPO accession number to the text name of a phenotype feature
###################################################################################################
hpo_to_phenotype = pd.read_csv('HPO_to_tag.csv', header =0)
# The is a list of HP numbers and text tags for phenotypes (n =20,958)
hpo_tags = hpo_to_phenotype.values.tolist()
# hpo_tags maps an HPO number to a text tag describing a phenotype
phenotype_tags = []
phenotypes = []
phenotype_file = pd.read_csv("Phenotype_by_disease.csv", header = 0)
phenotype_by_disease = phenotype_file.values.tolist()
###################################################################
#      [0]            [1]           [2]
# [disease_MIM]    [disease]      [hpo_ID]
###################################################################
phenotype_list = []
disease_MIM_set=set()
for d in dystonia_variants:
    disease_MIM = d[2]
    disease_MIM_set.add(disease_MIM)
for p in phenotype_by_disease:
        target_MIM = p[0]  #This is the MIM for each disease
        target_name = p[1] #this is the name of each disease
        target_hpo_ID = p[2] #This the the HPO ID for the pnenotype
        if target_MIM in disease_MIM_set:  #Note that disease_MIMs is a list of 34 diseases with dystonia
            for h in hpo_tags: #hpo_tags is a list of 20,958 phenotype features h[0] is the hpo_id and h[1] is the tag
                hpo = h[0]
                phenotype = h[1]
                if hpo == target_hpo_ID:
                    if phenotype not in phenotype_list:
                        phenotype_list.append(phenotype)
                    G.add_node(phenotype, category='phenotype', hpo_id=hpo, class_type='individual')
                    print(phenotype)
                    G.add_edge(target_name, phenotype, relation='has_phenotype')
for p in phenotype_list:
    G.add_edge(p, 'phenotype', relation = 'is_a')             


###############################################################
# ADD PROTEIN DATA
#  The file proteinatlas.csv has tabular data on different protein characteristics
# 
#   [0]  |    [1]      |       [2]  |      [3]         |       [4]  |     [5]       |            [6]      |         [7]       |   [8]              | [9]       |   [10]      |[11]    |    [12]            |  [13]   |
# Gene |Protein Name   |	Uniprot_num |	Chromosome |	Position |	Protein class|	Biologic process |Molecular function   | disease_invovlement |  MW       |  protein_domain     | protein_motif  |  protein_location |  length |
#######################################################################################
protein_domain_list=[]
protein_motif_list=[]
protein_location_list=[]
diseases_involved_list=[]
molecular_function_list=[]
biologic_process_list =[]
protein_class_list =[]
chromosome_list =[]
df_proteins =pd.read_csv('protein_list_dystonia.csv', header=0)
protein_data = df_proteins.values.tolist()
for p in protein_data:
    gene = p[0]
    protein =p[1]
    uniprot = p[2]
    chromosome =p[3]
    position = p[4]
    protein_class = p[5]
    biologic_process = p[6]
    molecular_function = p[7]
    disease_involvement = p[8]
    MW= p[9]
    protein_domain=p[10]
    protein_motif =p[11]
    protein_location =str(p[12])
    length = p[13]
    if protein != 'none':
        if protein not in protein_list:
            protein_list.append(protein)
            G.add_node(protein, category ='protein', uniprot = uniprot, molecular_weight= MW, length = length, class_type='individual') 
            G.add_edge(protein, 'protein', relation ='is_a')
    if chromosome not in chromosome_list:
         chromosome_list.append(chromosome)
         G.add_node(chromosome, category='chromosome',class_type='individual')
         G.add_edge(gene, chromosome, relation='is_on_chromosome')
         G.add_edge(chromosome, 'chromosome', relation='is_a')
    G.add_edge(gene, position, relation='has_gene_location')
    G.add_node(position, category='gene_location', class_type='individual')
    protein_classes = []
    protein_classes = protein_class.split('|')
    for pc in protein_classes:
        if pc != 'none':
            G.add_node(pc, category='protein_class', class_type='individual')
            G.add_edge(protein, pc, relation='is_of_protein_class')
            G.add_edge(pc,'protein_class', relation='is_a')
            if pc not in protein_class_list:
                protein_class_list.append(pc)
  
    biologic_processes = biologic_process.split('|')
    for bp in biologic_processes:
        if bp != 'none':
            G.add_node(bp, category='biologic_process', class_type='individual')
            G.add_edge(protein, bp, relation='has_biologic_process')
            G.add_edge(bp, 'biologic_process', relation ='is_a')
            if bp not in biologic_process_list:
                biologic_process_list.append(bp)
    molecular_functions = molecular_function.split('|')
    for mf in molecular_functions:
        if mf not in ['unknown','none']:
            G.add_node(mf, category='molecular_function', class_type='individual')
            G.add_edge(protein, mf, relation="has_molecular_function")
            G.add_edge(mf, 'molecular_function', relation ='is_a')
            if mf not in molecular_function_list:
                molecular_function_list.append(mf)
    G.add_edge(gene, protein, relation='codes_for')
    involved_diseases = disease_involvement.split('|')
    for di in involved_diseases:
        if di != 'none':
            G.add_node(di, category='disease_involvement',class_type='individual')
            G.add_edge(protein, di, relation='has_disease_involvement')
            G.add_edge(di,'disease_involvement', relation='is_a')
    protein_locations=[]
    protein_locations =  protein_location.split('|')
    for pl in protein_locations:
        if pl != 'none':
            G.add_node(pl, category='protein_location', class_type='individual')
            G.add_edge(protein, pl, relation='has_cellular_location')
            G.add_edge(pl, 'protein_location', relation='is_a')
            if pl not in protein_location_list:
                protein_location_list.append(pl)                               
    protein_domains = protein_domain.split('|')            
    for p_d in protein_domains:
            if p_d != 'none':
                G.add_node(p_d, category='protein_domain', class_type='individual')
                G.add_edge(protein, p_d, relation='has_protein_domain')
                G.add_edge(pd, 'protein_domain', relation ='is_a')
                G.add_node('protein', class_type='class', category='protein')
                if pd not in protein_domain_list:
                    # Add to list of protein domains
                    protein_domain_list.append(p_d)
    protein_motifs = protein_motif.split('|')
    for p_m in protein_motifs:
            if p_m != 'none':
                G.add_node(p_m, category='protein_motif',class_type='individual')
                G.add_edge(protein, p_m, relation='has_protein_motif')
                G.add_edge(p_m,'protein_motif', relation='is_a')
                if p_m not in protein_motif_list:
                    protein_motif_list.append(p_m)
                             
                 
# Draw a low-resolution graph
nx.draw_networkx(G, with_labels=False)
# Write the graph to file in graphml format for GEPHI
nx.write_graphml(G, 'dystonia.graphml')                    


# Create a new RDF graph
g = Graph()
# Define the namespaces and prefixes
#ex = Namespace("http://example.org/#")

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








#Add classes
for c in class_list:
    g.add((c, RDF.type, OWL.Class))

for n in G.nodes.data():
   # print(n)
    node_type=''
    node_type= n[1].get('class_type',0)
    if node_type=='individual':
       #   print(n[0])
          class_name = n[1].get('category',0)
          individual_name = n[0]
          individual_name_uri = ex[individual_name]
          class_name_uri =ex[class_name]
          g.add((individual_name_uri, RDF.type,class_name_uri )) 
            
         
     
    
#Add object relationships         
relations = set()
start_nodes_set=set()
end_nodes_set=set()
i=1
for e in G.edges.data():
    start_uri = ex[e[0]]
    start_node= e[0]
    start_nodes_set.add(start_node)
    end_node=e[1]
    if end_node != 'none':
        if start_node !='none':
            end_uri = ex[e[1]]
            end_nodes_set.add(end_node)
            object_property_dict = e[2]
            object_property = object_property_dict.get('relation',0)
            end_value = G.nodes[end_node].get('category',0)
       #     end_node_category = end_node.get('category', 0)
        #    print(end_node_category)
            relations.add(object_property)
            relations.discard('is_a')
            relations.discard(0)
            object_property_list = list(relations)      
            if object_property in object_property_list:      # print(object_property)
              range_value =G.nodes[end_node].get("category", 0)
              domain_value = G.nodes[start_node].get("category",0)
          #    print('<<',i,'>>',start_uri,'>>', end_uri, '>>',object_property,'>>', start_node, '>>',domain_value, '>>', range_value)
              i+=1
              object_property_uri = ex[object_property]
              range_uri=ex[range_value]
              domain_uri =ex[domain_value]
              g.add((object_property_uri, RDF.type, RDF.Property))
              g.add((object_property_uri, RDFS.domain, domain_uri))
              g.add((object_property_uri, RDFS.range, range_uri))
              g.add((start_uri, object_property_uri,end_uri))




################################################################
# Data Properties for the Proteins are added here
################################################################



# create list of proteins and their molecular weights and lengths
MW_list = []
length_list = []
uniprot_list=[]
for p in G.nodes:
    if p != 'protein':
        cat = G.nodes[p].get('category', 0)
        if str(cat) == 'protein':
            uniprot = ''
            uniprot = G.nodes[p].get('uniprot',0)
            uniprot_pair =[]
            uniprot_pair.append(p)
            uniprot_pair.append(uniprot)
            uniprot_list.append(uniprot_pair)
            MW = 0
            MW = G.nodes[p].get('molecular_weight',0)
            MW_pair = []
            MW_pair.append(p)
            MW_pair.append(MW)
            MW_list.append(MW_pair)
            length = 0
            length = G.nodes[p].get('length',0)
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
#    print(p, ex[p[0]], p[1])
    protein_uri = ex[p[0]]
    length_aa = p[1]
 #   print(protein_uri, length_aa)
    g.add((protein_uri, protein_length_uri, Literal(
        length_aa, datatype=XSD.string)))

# Add a new data property for the protein uniprot num

uniprot_uri = ex['unipro_num']
g.add((uniprot_uri, RDFS.label, Literal("uniprot_num")))
g.add((uniprot_uri, RDF.type, OWL.DatatypeProperty))
g.add((uniprot_uri, RDFS.domain, ex.protein))
g.add((uniprot_uri, RDFS.range, XSD.string))
for p in uniprot_list:
    print(p[0],'>>', p[1])
    protein_uri = ex[p[0]]
    uniprot= p[1]
  #  print(protein_uri, length_aa)
    g.add((protein_uri, uniprot_uri, Literal(
        uniprot, datatype=XSD.string)))



################################
# Data properities for Genes
###############################

gene_MIM_list=[]
for w in G.nodes:
        cat = G.nodes[w].get('category', 0)
        if str(cat) == 'gene':
            gene_MIM = ''
            gene_MIM = G.nodes[w].get('MIM',0)
            gene_pair =[]
            gene_pair.append(w)
            gene_pair.append(gene_MIM)
            gene_MIM_list.append(gene_pair)

gene_MIM_uri = ex['gene_MIM']
g.add((gene_MIM_uri, RDFS.label, Literal("gene_MIM")))
g.add((gene_MIM_uri, RDF.type, OWL.DatatypeProperty))
g.add((gene_MIM_uri, RDFS.domain, ex.gene))
g.add((gene_MIM_uri, RDFS.range, XSD.string))
for w in gene_MIM_list:
    gene_uri=ex[w[0]]
    MIM= w[1]
    g.add((gene_uri, gene_MIM_uri, Literal(MIM, datatype=XSD.string)))



##############################

# Data Properties for phenotypes
phenotype_hpo_list=[]
phenotype_hpo_uri = ex['phenotype_hpo']
g.add((phenotype_hpo_uri, RDFS.label, Literal("phenotype_hpo")))
g.add((phenotype_hpo_uri, RDF.type, OWL.DatatypeProperty))
g.add((phenotype_hpo_uri, RDFS.domain, ex.phenotype))
g.add((phenotype_hpo_uri, RDFS.range, XSD.string))
for x in G.nodes:
        cat = G.nodes[x].get('category',0)
        if cat =='phenotype':
 #           print(cat)
            hpo = G.nodes[x].get('hpo_id',0)
            if hpo !=0:
                phenotype_uri = ex[x]
                g.add((phenotype_uri, phenotype_hpo_uri, Literal(
                    hpo, datatype=XSD.string)))
# Data Properties for disease
for d in G.nodes:
        cat = G.nodes[d].get('category',0)
        if cat !=0:
            if cat =='disease':
                MIM = G.nodes[d].get('MIM',0)
                variant = d
                if MIM !=0:
                    disease_MIM_uri = ex['disease_MIM']
                    g.add((disease_MIM_uri, RDFS.label, Literal("disease_MIM")))
                    g.add((disease_MIM_uri, RDF.type, OWL.DatatypeProperty))
                    g.add((disease_MIM_uri, RDFS.domain, ex.phenotype))
                    g.add((disease_MIM_uri, RDFS.range, XSD.string))
                    disease_uri = ex[variant]
                    disease_MIM = MIM
                    g.add((disease_uri, disease_MIM_uri, Literal(
                        disease_MIM, datatype=XSD.string)))


# Serialize the RDF graph to an OWL file
file_out ='dystonia.owl'
g.serialize(file_out, format="xml")
# Print confirmation message
print("Dystonia Ontology written to", file_out)






# Find nodes without any edges
isolated_nodes = list(nx.isolates(G))
print('isolated nodes', isolated_nodes)
#for node, attributes in G.nodes.data():
 #   print(f"Node {node}: {attributes}")     

# Create a set to store unique attribute keys
attribute_keys = set()

# Iterate over all nodes and collect attribute keys
for node, attributes in G.nodes.data():
    attribute_keys.update(attributes.keys())

# Convert the set to a list
attribute_list = list(attribute_keys)

#print(attribute_list)      

# Print the isolated nodes
#print('isolated nodes:',isolated_nodes)
edge_attributes =[]
# Traverse edges and retrieve attributes
for u, v, attributes in G.edges.data():
    if attributes not in edge_attributes:
        edge_attributes.append(attributes)
#for n, attibutes in G.nodes.data():
    #print(n, attributes)
# Print the list of edge attributes
#print('edge attributes:', edge_attributes)



#number of nodes
number_of_nodes = nx.number_of_nodes(G)
print ('Number of nodes: ', number_of_nodes)

number_of_edges =nx.number_of_edges(G)
print("number_of_edges: ", number_of_edges)

# Serialize the RDF graph to an OWL file
file_out ='dystonia.owl'
g.serialize(file_out, format="xml")
# Print confirmation message
print("Dystonia Ontology written to", file_out)

# Assuming you already have a graph G

# Open a file in write mode
with open('node_attributes_dystonia.txt', 'w') as file:
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
with open('edge_attributes_dystonia.txt', 'w') as file:
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

# Close the file
file.close()

# Close the file
file.close()


