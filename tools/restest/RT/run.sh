#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
JAR_PATH="/tool/restest-cli.jar"

java -jar "$JAR_PATH" -g -e "$SCRIPT_DIR/user_config.properties" > /dev/null
