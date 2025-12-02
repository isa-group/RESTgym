FROM ubuntu:22.04

RUN mkdir /tool && \
    apt update && \
    apt -y upgrade && \
    apt -y install openjdk-11-jdk python3 python3-pip && \
    pip install pyyaml

COPY ./tools/restest/ /tool/
COPY ./apis/*/specifications/* /specifications/

WORKDIR /tool

CMD bash config.sh && bash run.sh
