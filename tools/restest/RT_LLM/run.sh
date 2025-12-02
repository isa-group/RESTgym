#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
JAR_PATH="/tool/restest-cli.jar"
CONFIG_DIR="/tool/src/main/resources"

# TODO: call LLM to generate parameters
python3 "$SCRIPT_DIR/postprocess_testconf.py" "$CONFIG_DIR/testConf.yaml" "$SCRIPT_DIR/testConf.yaml"
java -jar "$JAR_PATH" -g -e "$SCRIPT_DIR/user_config.properties" > /dev/null
