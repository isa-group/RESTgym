#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
GENERATOR=$(basename "$SCRIPT_DIR")
JAR_PATH="/tool/restest-cli.jar"
CONFIG_DIR="/tool/src/main/resources"

# Thread controls for RT-LLM (fixed values)
export OMP_NUM_THREADS=8
export GGML_NUM_THREADS=8

echo "INFO: Post-processing testConf.yaml for $GENERATOR..."
python3.11 "$SCRIPT_DIR/postprocess_testconf.py" "$CONFIG_DIR/testConf.yaml" "$SCRIPT_DIR/testConf.yaml"
POSTPROCESS_TESTCONF_EXIT_CODE=$?

if [ $POSTPROCESS_TESTCONF_EXIT_CODE -ne 0 ]; then
    echo "ERROR: Post-processing script failed for '$GENERATOR'. Cannot proceed."
    exit 1
fi

# Select model based on number of API operations in $CONFIG_DIR/swagger.yaml
echo "INFO: Calculating number of API operations from $CONFIG_DIR/swagger.yaml..."
OP_COUNT=$(python3.11 "$SCRIPT_DIR/count_operations.py" "$CONFIG_DIR/swagger.yaml")
COUNT_EXIT_CODE=$?
if [ $COUNT_EXIT_CODE -ne 0 ]; then
    echo "WARN: Could not determine API operation count (exit $COUNT_EXIT_CODE). Defaulting OP_COUNT=0."
    OP_COUNT=0
fi
echo "INFO: API has $OP_COUNT operations. Selecting appropriate model..."

MODEL_DIR="$SCRIPT_DIR/parameter-values-generator/model"
DEST_MODEL="$MODEL_DIR/model.gguf"
if [ "$OP_COUNT" -gt 40 ]; then
    SRC_MODEL="$MODEL_DIR/llama-3.2-1b-instruct-q4_k_m.gguf"
else
    SRC_MODEL="$MODEL_DIR/Llama-3.2-3B-Instruct-Q4_K_M.gguf" 
fi

if [ -f "$SRC_MODEL" ]; then
    mkdir -p "$MODEL_DIR"
    mv -f "$SRC_MODEL" "$DEST_MODEL"
    echo "INFO: Selected model: $(basename "$SRC_MODEL") -> $(basename "$DEST_MODEL")"
else
    echo "ERROR: Model file not found: $SRC_MODEL"
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
