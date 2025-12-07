#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
GENERATOR=$(basename "$SCRIPT_DIR")
JAR_PATH="/tool/restest-cli.jar"

# Run the tool once, retrying up to 5 times on error
MAX_RETRIES=5
ATTEMPT=1

echo "INFO: Running $GENERATOR instance (attempt $ATTEMPT/$MAX_RETRIES)"
while [ $ATTEMPT -le $MAX_RETRIES ]; do
    java -jar "$JAR_PATH" -g -e "$SCRIPT_DIR/user_config.properties" > /dev/null
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        echo "INFO: $GENERATOR completed successfully on attempt #$ATTEMPT."
        exit 0
    fi

    if [ $ATTEMPT -lt $MAX_RETRIES ]; then
        echo "ERROR: $GENERATOR failed with exit code $EXIT_CODE (attempt #$ATTEMPT). Retrying in 3 seconds..."
        sleep 3
    else
        echo "ERROR: $GENERATOR failed after $MAX_RETRIES attempts. Exit code: $EXIT_CODE."
        exit $EXIT_CODE
    fi

    ATTEMPT=$((ATTEMPT + 1))
done
