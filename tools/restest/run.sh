#!/bin/sh

JAR_PATH="/tool/restest-cli.jar"
CONFIG_DIR="/tool/src/main/resources"

run_generator_instance() {
    config_filepath="$1"
    config_filename=$(basename "$config_filepath")
    generator_prefix="${config_filename%%_user_config.properties}"

    while true; do
        echo "INFO: Running RESTest with $generator_prefix generator for $config_filename"
        java -jar "$JAR_PATH" -g -e "$config_filepath" > /dev/null

        exit_code=$?
        if [ $exit_code -ne 0 ]; then
            echo "ERROR: RESTest for $generator_prefix generator failed with exit code $exit_code. Restarting in 3 seconds..."
            sleep 3
        else
            echo "WARN: RESTest for $generator_prefix generator exited gracefully. Restarting..."
        fi
    done
}

for filepath in "$CONFIG_DIR"/*_user_config.properties; do
    run_generator_instance "$filepath" &
done

wait # will block indefinitely because the background jobs are in while true loops
