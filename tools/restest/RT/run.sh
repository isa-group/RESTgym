#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
GENERATOR=$(basename "$SCRIPT_DIR")
JAR_PATH="/tool/restest-cli.jar"

# Run the tool 25 times regardless of result; succeed if any run succeeds
MAX_RUNS=25
ATTEMPT=1
ANY_SUCCESS=0
LAST_EXIT_CODE=0

while [ $ATTEMPT -le $MAX_RUNS ]; do
    echo "INFO: Running $GENERATOR instance (attempt $ATTEMPT/$MAX_RUNS)"
    java -jar "$JAR_PATH" -g -e "$SCRIPT_DIR/user_config.properties" > /dev/null
    EXIT_CODE=$?
    LAST_EXIT_CODE=$EXIT_CODE

    if [ $EXIT_CODE -eq 0 ]; then
        echo "INFO: Attempt #$ATTEMPT RT succeeded."
        ANY_SUCCESS=1
    else
        echo "ERROR: Attempt #$ATTEMPT of RT failed with exit code $EXIT_CODE."
    fi

    if [ $ATTEMPT -lt $MAX_RUNS ]; then
        sleep 3
    fi

    ATTEMPT=$((ATTEMPT + 1))
done

if [ $ANY_SUCCESS -eq 1 ]; then
    echo "INFO: At least one attempt of RT succeeded. Returning 0."
    exit 0
else
    echo "ERROR: All $MAX_RUNS attempts failed for RT. Returning last exit code: $LAST_EXIT_CODE."
    exit $LAST_EXIT_CODE
fi
