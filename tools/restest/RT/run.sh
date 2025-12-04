#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
GENERATOR=$(basename "$SCRIPT_DIR")
JAR_PATH="/tool/restest-cli.jar"

while true; do
    echo "INFO: Running $GENERATOR instance..."

    java -jar "$JAR_PATH" -g -e "$SCRIPT_DIR/user_config.properties" > /dev/null
    EXIT_CODE=$?

    if [ $EXIT_CODE -ne 0 ]; then
        echo "ERROR: $GENERATOR instance failed with exit code $EXIT_CODE. Restarting in 3 seconds..."
        sleep 3
    else
        echo "INFO: $GENERATOR instance exited gracefully. Restarting..."
    fi
done
