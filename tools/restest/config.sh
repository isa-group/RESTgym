echo "host=http://localhost:$PORT" >> resources/config.properties
cp /specifications/"$API"-openapi.json resources/openapi.json

# Generate configuration based on the specification
java -jar restest-cli.jar -c resources/openapi.json

# Necessary files for RESTest in src/main/resources
mkdir -p src/main/
mv resources/ src/main/resources/
