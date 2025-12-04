#!/bin/bash

MODEL_TO_PULL="llama3.2:3b"

echo "INFO: Starting Ollama server temporarily for model pull..."
ollama serve &
OLLAMA_PID=$! # Capture the PID of the background server process

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

echo "INFO: Pulling Ollama model: $MODEL_TO_PULL..."
ollama pull "$MODEL_TO_PULL"
PULL_EXIT_CODE=$?

echo "INFO: Shutting down Ollama server (PID: $OLLAMA_PID)..."
kill "$OLLAMA_PID"

if [ "$PULL_EXIT_CODE" -ne 0 ]; then
    echo "ERROR: Ollama model pull failed with exit code $PULL_EXIT_CODE. Exiting build."
    exit 1
else
    echo "INFO: Ollama model '$MODEL_TO_PULL' pulled successfully."
fi
