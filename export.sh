#!/bin/bash

verbose=0  # Default verbose mode is off

while getopts "v" opt; do
  case $opt in
    v) verbose=1 ;;  # If '-v' is passed, set verbose mode to 1
    \?) echo "Usage: $0 [-v] /path/to/xml"  # Show usage if invalid option
        read -p "Press Enter to exit..."
        exit 1 ;;
  esac
done

# The last argument should be the XML file path
XML_FILE="${@:$OPTIND:1}"

if [[ -z "$XML_FILE" ]]; then  # Check if XML file is missing
  echo "Error: XML file path is required."
  echo "Usage: $0 [-v] /path/to/xml"
  read -p "Press Enter to exit..."
  exit 1
fi

# Check if the XML file exists
if [[ ! -f "$XML_FILE" ]]; then
  echo "Error: XML file not found."
  echo $XML_FILE
  read -p "Press Enter to exit..."
  exit 1
fi


# If '-v' is passed, run Docker Compose with verbose mode
if [[ $verbose -eq 1 ]]; then
  echo "Running with verbose mode, showing Redis keys after processing."
  docker-compose down
  docker-compose build
  docker-compose run --rm -v "$(pwd)/$XML_FILE:/app/input.xm" xml_to_redis node /app/xmlToRedis.js /app/input.xml -v
else
  docker-compose down
  docker-compose build
  docker-compose run --rm -v "$(pwd)/$XML_FILE:/app/input.xm" xml_to_redis node /app/xmlToRedis.js /app/input.xml
fi

read -p "Press Enter to exit..."