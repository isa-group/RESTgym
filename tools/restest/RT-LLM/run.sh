#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
GENERATOR=$(basename "$SCRIPT_DIR")
JAR_PATH="/tool/restest-cli.jar"
CONFIG_DIR="/tool/src/main/resources"

MIN_PORT=49152
MAX_PORT=65535

echo "INFO: Post-processing testConf.yaml for $GENERATOR..."
python3.11 "$SCRIPT_DIR/postprocess_testconf.py" "$CONFIG_DIR/testConf.yaml" "$SCRIPT_DIR/testConf.yaml"
POSTPROCESS_TESTCONF_EXIT_CODE=$?

if [ $POSTPROCESS_TESTCONF_EXIT_CODE -ne 0 ]; then
    echo "ERROR: Post-processing script failed for '$GENERATOR'. Cannot proceed."
    exit 1
fi

OLLAMA_PID=""
while true; do
    OLLAMA_PORT=$(shuf -i $MIN_PORT-$MAX_PORT -n 1)
    export OLLAMA_HOST="127.0.0.1:$OLLAMA_PORT"

    echo "INFO: Attempting to start Ollama server for '$GENERATOR' on $OLLAMA_HOST..."

    kill "$(pgrep -f "ollama serve.*$OLLAMA_HOST")" 2>/dev/null || true

    ollama serve > "$SCRIPT_DIR/ollama_log.txt" 2>&1 &
    OLLAMA_PID=$!
    sleep 0.5

    if ! ps -p "$OLLAMA_PID" > /dev/null; then
        echo "WARN: Ollama server (PID: $OLLAMA_PID) failed to start on $OLLAMA_HOST (port might be in use). Retrying with a new port..."
        continue
    fi

    echo "INFO: Waiting for Ollama server to start (PID: $OLLAMA_PID) and be ready on $OLLAMA_HOST..."
    SERVER_READY=false
    for i in $(seq 1 30); do
        if ollama list >/dev/null 2>&1; then
            echo "INFO: Ollama server ready on $OLLAMA_HOST."
            SERVER_READY=true
            break
        else
            : "$i"
            sleep 2
        fi
    done

    if [ "$SERVER_READY" = false ]; then
        echo "ERROR: Ollama server on $OLLAMA_HOST failed to become ready within time. Killing it and trying a new port."
        kill "$OLLAMA_PID" || true
        wait "$OLLAMA_PID" || true
        OLLAMA_PID=""
        continue
    fi

    echo "INFO: Ollama server for '$GENERATOR' successfully initialized on $OLLAMA_HOST."
    break
done

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
