#!/bin/bash

BASE_DIR="/tool"
GENERATORS=(
    "FT"
    "RT"
    "RT-LLM"
)

echo "INFO: Launching specified instances: ${GENERATORS[*]}"

for GENERATOR in "${GENERATORS[@]}"; do
    INSTANCE_DIR="$BASE_DIR/$GENERATOR"
    if [ -d "$INSTANCE_DIR" ]; then
        RUN_SCRIPT="$INSTANCE_DIR/run.sh"

        if [ -f "$RUN_SCRIPT" ] && [ -x "$RUN_SCRIPT" ]; then
            bash "$RUN_SCRIPT" &
        else
            echo "ERROR: Instance $GENERATOR found, but '$RUN_SCRIPT' is missing or not executable. Skipping."
        fi
    else
        echo "ERROR: Instance $GENERATOR directory not found at '$INSTANCE_DIR'. Skipping."
    fi
done

wait # will block indefinitely because the background jobs are in while true loops
