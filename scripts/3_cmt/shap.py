#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
    shap.py

# Description

Demonstration of SHAP values for clustering of CMT cases

# Acknowledgements

## History
Created on Fri Jul  8 13:07:47 2022

## Authors
- Sasha Petrenko
- danielhier
"""

# -----------------------------------------------------------------------------
# IMPORTS
# -----------------------------------------------------------------------------

# import os
# import numpy as np
# from matplotlib import pyplot as plt
import pandas as pd
# import array as arr
import shap
import xgboost
# from sklearn.ensemble import RandomForestClassifier
# from shap import TreeExplainer, Explanation
# from shap.plots import waterfall
from sklearn.ensemble import HistGradientBoostingClassifier

from pathlib import Path

# -----------------------------------------------------------------------------
# EXPERIMENT
# -----------------------------------------------------------------------------

# os.chdir('/Users/danielhier/Desktop/MS Clustering')
#########################################################################
# df = pd.read_csv('cmt_flat_file_data_for_SHAP_1.csv')
# data_file = Path("..", "..", "work", "results", "3_cmt", "cmt-clusters.csv")
data_file = Path("work", "results", "3_cmt", "old-csv", "cmt-clusters-sweep.csv")
df = pd.read_csv(data_file)
column_headings = df.columns.tolist()
# column_headings = column_headings[5:]
# i_rho =
column_headings = column_headings[5:]

# Display the list of column headings (optional).
print(column_headings)
# X = df.iloc[:, 5:].values
X = df.iloc[:, 5:].values
y = df.iloc[:, 0].values
print(X.shape)  # should print (81, 211)
print(y.shape)  # should print (81,)

# We need to convert clusters to a classification problem to use SHAP
# SHAP ONLY WORKS ON CLASSIFIERS NOT ON CLUSTERING ALGORITHMS

clf = HistGradientBoostingClassifier().fit(X, y)
print(clf.score(X, y))

feature_names = column_headings

# model = xgboost.XGBRegressor().fit(X, y)

# Assuming you have a trained model called model
model = clf.fit(X, y)
explainer = shap.TreeExplainer(
    model,
    feature_names=feature_names
)

# Assuming you have input data called X IN THE FORMAT OF AN ARRAY
shap_values = explainer.shap_values(X)
# Visualize SHAP values
# X.columns =feature_names
# Visualize SHAP values with feature names
class_names = [
    'Cluster 1',
    'Cluster 2',
    'Cluster 3',
    'Cluster 4',
    'Cluster 5',
    'Cluster 6',
    'Cluster 7',
    'Cluster 8',
    'Cluster 9',
]

shap.summary_plot(
    shap_values,
    X,
    plot_type='bar',
    feature_names=feature_names,
    class_names=class_names,
    max_display=12,
    plot_size=float(0.5)
)
model = xgboost.XGBRegressor().fit(X, y)
explainer = shap.Explainer(
    model,
    feature_names=feature_names,
)
shap_values = explainer(X)

# visualize the frst prediction's explanation
shap.plots.waterfall(
    shap_values[0],
    max_display=12,
)

model = xgboost.XGBRegressor().fit(X, y)

# Assuming you have a trained model called model
# model = clf.fit(X, y)
explainer = shap.TreeExplainer(
    model,
    feature_names=feature_names,
)
shap_values = explainer.shap_values(X)

# Visualize SHAP values
# X.columns =feature_names
# Visualize SHAP values with feature names
class_names = [
    'Cluster 1',
    'Cluster 2',
    'Cluster 3',
    'Cluster 4',
    'Cluster 5',
    'Cluster 6',
    'Cluster 7',
    'Cluster 8',
    'Cluster 9',
]

shap.summary_plot(
    shap_values,
    X,
    plot_type='bar',
    feature_names=feature_names,
    class_names=class_names,
    max_display=12,
    plot_size=float(0.5),
)
