cp /specifications/"$API"-openapi.json openapi.json

# Generate configuration based on the specification
java -jar restest-cli.jar -c ./openapi.json

# Necessary files for RESTest in src/main/resources
mkdir -p src/main/
mv resources/ src/main/resources/

echo "host=http://localhost:$PORT" >> user_config.properties
