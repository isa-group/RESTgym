#!/bin/bash
BASE_GENERATOR_DIR="/tool"

run_generator_instance() {
    local generator="$1"
    local run_script="$1/run.sh"

    while true; do
        echo "INFO: Running $generator instance..."

        bash "$run_script"
        local exit_code=$?

        if [ $exit_code -ne 0 ]; then
            echo "ERROR: $generator instance failed with exit code $exit_code. Restarting in 3 seconds..."
            sleep 3
        else
            echo "INFO: $generator instance exited gracefully. Restarting..."
        fi
    done
}

# Iterate through each subdirectory within the BASE_GENERATOR_DIR
# We explicitly check for directory type (-d) to avoid issues with other file types.
for generator_dir in "$BASE_GENERATOR_DIR"/*; do
    if [ -d "$generator_dir" ]; then
        generator=$(basename "$generator_dir")
        run_script="$generator_dir/run.sh"

        if [ -f "$run_script" ] && [ -x "$run_script" ]; then
            run_generator_instance "$generator" &
        fi
    fi
done

wait # will block indefinitely because the background jobs are in while true loops
