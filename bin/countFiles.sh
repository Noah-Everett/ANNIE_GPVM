#!/bin/bash

# Check if directory is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: source countFiles.sh <directory>"
  return 1
fi

# Directory to monitor
DIR="$1"

while true; do
  # Count the number of files in the directory
  FILE_COUNT=$(ls -1 "$DIR" | wc -l)
  
  # Print the number of files and overwrite the previous output
  echo -ne "\rNumber of files: $FILE_COUNT"
  
  # Sleep for a specified interval
  sleep 1
done
