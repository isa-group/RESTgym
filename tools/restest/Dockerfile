FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system updates and dependencies
RUN apt update && \
    apt -y upgrade && \
    apt -y install \
        git \
        curl \
        openjdk-11-jdk \
        software-properties-common

# Install Python 3.11 and pip
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt update && \
    apt -y install python3.11 python3.11-dev python3-pip && \
    python3.11 -m pip install --upgrade pip pyyaml

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Pull LLM model
COPY ./tools/restest/pull-llm-model.sh .
RUN chmod +x ./pull-llm-model.sh && bash ./pull-llm-model.sh && rm -rf ./pull-llm-model.sh

WORKDIR /tool

# Clone parameter-values-generator and install dependencies
RUN git clone https://github.com/juaaloval/testConfGenerator RT-LLM/parameter-values-generator && \
    cd RT-LLM/parameter-values-generator && \
    git checkout d4fcced && \
    python3.11 -m pip install --no-cache-dir -r requirements.txt

# Clone tool files
COPY ./tools/restest/ /tool/
COPY ./apis/*/specifications/* /specifications/

RUN chmod +x /tool/config.sh /tool/run.sh /tool/*/run.sh
CMD bash config.sh && bash run.sh
