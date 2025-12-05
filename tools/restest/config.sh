#!/bin/bash

echo "host=http://localhost:$PORT" >> common/config.properties
cp /specifications/"$API".yaml common/swagger.yaml
cp /specifications/"$API"-openapi.json common/openapi.json

# Generate configuration based on the specification
java -jar restest-cli.jar -c common/openapi.json

# Run testConf.yaml fix script
# Last-minute hotfix for duplicate parameter names
echo "INFO: Running testConf.yaml duplicate parameter names fix..."
python3.11 fix_testconf.py common/testConf.yaml $SCRIPT_DIR/testConf.yaml
FIX_TESTCONF_EXIT_CODE=$?

if [ $FIX_TESTCONF_EXIT_CODE -ne 0 ]; then
    echo "ERROR: testConf.yaml fix script failed. Cannot proceed."
    exit 1
fi

# Necessary files for RESTest in src/main/resources
mkdir -p src/main/
mv common/ src/main/resources/
