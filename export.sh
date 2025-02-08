#!/bin/bash

if [ "$1" == "-v" ]; then
    VERBOSE=true
    shift
fi

XML_PATH=$1
if [ -z "$XML_PATH" ]; then
    echo "No XML file path provided."
    exit 1
fi

if [[ "$XML_PATH" =~ ^[A-Za-z]:\\ ]]; then
    XML_PATH=$(echo "$XML_PATH" | sed 's/\\/\//g' | sed 's/^\([A-Za-z]\):/\1:\/mnt\/c/')
fi

echo "XML path is: $XML_PATH"

docker cp "$XML_PATH" xml_to_redis:/app/input.xml

docker-compose up --build

if [ "$VERBOSE" = true ]; then
    docker exec -it redis_store redis-cli keys "*"
fi

if [[ $verbose -eq 1 ]]; then
  echo "Running with verbose mode, showing Redis keys after processing."
  docker-compose down
  docker-compose build
  docker-compose run --rm -v "$XML_FILE" xml_to_redis node /app/xmlToRedis.js /app/input.xml -v
else
  docker-compose down
  docker-compose build
  docker-compose run --rm -v "$XML_FILE" xml_to_redis node /app/xmlToRedis.js /app/input.xml
fi

if [ "$VERBOSE" = true ]; then
    echo "Printing all keys in Redis:"
    docker exec -it redis_store redis-cli keys "*"
fi

read -p "Press Enter to exit..."

