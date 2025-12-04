#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
JAR_PATH="/tool/restest-cli.jar"

# Execute the RESTest CLI tool with the user configuration
java -jar "$JAR_PATH" -g -e "$SCRIPT_DIR/user_config.properties" > /dev/null

# Wait 60 seconds before next iteration to slow down fuzzing
sleep 60
