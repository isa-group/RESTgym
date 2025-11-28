FROM ubuntu:22.04

RUN mkdir /tool && \
    apt update && \
    apt -y upgrade && \
    apt -y install openjdk-11-jdk

COPY ./tools/restest/ /tool/
COPY ./apis/*/specifications/* /specifications/

WORKDIR /tool

CMD sh config.sh && sh run.sh
