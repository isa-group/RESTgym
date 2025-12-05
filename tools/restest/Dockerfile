FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system updates and dependencies
RUN apt update && \
    apt -y upgrade && \
    apt -y install \
        git \
        wget \
        openjdk-11-jdk \
        software-properties-common

# Install Python 3.11 and pip
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt update && \
    apt -y install python3.11 python3.11-dev python3-pip && \
    python3.11 -m pip install --upgrade pip pyyaml

WORKDIR /tool

# Clone parameter-values-generator and install dependencies
RUN git clone https://github.com/juaaloval/testConfGenerator RT-LLM/parameter-values-generator && \
    cd RT-LLM/parameter-values-generator && \
    git checkout 0af3081 && \
    python3.11 -m pip install --no-cache-dir -r requirements.txt

# Download LLM model
RUN mkdir -p RT-LLM/parameter-values-generator/model && \
    wget -P RT-LLM/parameter-values-generator/model \
    https://huggingface.co/lmstudio-community/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf

# Clone tool files
COPY ./tools/restest/ /tool/
COPY ./apis/*/specifications/* /specifications/

RUN chmod +x /tool/config.sh /tool/run.sh /tool/*/run.sh
CMD bash config.sh && bash run.sh
