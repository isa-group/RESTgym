#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
GENERATOR=$(basename "$SCRIPT_DIR")
JAR_PATH="/tool/restest-cli.jar"
CONFIG_DIR="/tool/src/main/resources"

echo "INFO: Starting Ollama server for '$GENERATOR' generator..."
ollama serve >/dev/null &
OLLAMA_PID=$! # Capture the PID of the background server process

echo "INFO: Post-processing testConf.yaml for $GENERATOR..."
python3.11 "$SCRIPT_DIR/postprocess_testconf.py" "$CONFIG_DIR/testConf.yaml" "$SCRIPT_DIR/testConf.yaml"

echo "INFO: Waiting for Ollama server to start (PID: $OLLAMA_PID)..."
for i in $(seq 1 30); do
    if ollama list >/dev/null 2>&1; then
        echo "INFO: Ollama server started successfully."
        break
    else
        : "$i"
        sleep 2
    fi
done

if ! ollama list >/dev/null 2>&1; then
    echo "ERROR: Ollama server failed to start within the expected time. Aborting model pull."
    kill "$OLLAMA_PID"
    exit 1
fi

RERUN_LLM=true

while true; do
    if $RERUN_LLM; then
        echo "INFO: Running LLM to generate parameter values for $GENERATOR..."

        (
            cd "$SCRIPT_DIR"/parameter-values-generator || exit 1
            python3.11 -m testconf_agent.main "$CONFIG_DIR/swagger.yaml" "$SCRIPT_DIR/generator-sources"
        )

        PYTHON_EXIT_CODE=$?
        if [ $PYTHON_EXIT_CODE -ne 0 ]; then
            echo "ERROR: Parameter values generator for '$GENERATOR' failed with exit code $PYTHON_EXIT_CODE. Restarting in 3 seconds..."
            RERUN_LLM=true
            sleep 3
            continue
        fi
        RERUN_LLM=false
    fi

    echo "INFO: Running $GENERATOR instance..."
    java -jar "$JAR_PATH" -g -e "$SCRIPT_DIR/user_config.properties" > /dev/null
    EXIT_CODE=$?

    if [ $EXIT_CODE -ne 0 ]; then
        echo "ERROR: $GENERATOR instance failed with exit code $EXIT_CODE. Restarting in 3 seconds..."
        RERUN_LLM=true
        sleep 3
    else
        echo "INFO: $GENERATOR instance exited gracefully. Restarting..."
    fi
done
