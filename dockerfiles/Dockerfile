FROM julia:latest
# FROM huggingface/transformers-pytorch-gpu
# FROM ubuntu:latest

RUN apt-get update && apt-get install -y python3 python3-pip

COPY requirements.txt /tmp/

RUN pip install -r /tmp/requirements.txt
