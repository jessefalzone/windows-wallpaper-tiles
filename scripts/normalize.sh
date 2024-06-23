#!/bin/bash

# Function to add spaces before capital letters and numbers, and remove underscores
add_spaces_and_keep_capitals() {
    echo "$1" | sed -r 's/([a-z])([A-Z0-9])/\1 \2/g' | sed -r 's/([0-9])([A-Za-z])/\1 \2/g' | tr '_' ' '
}

# Check if directory argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Directory to process
directory="$1"

# Loop through each file in the directory
for file in "$directory"/*; do
    # Extract the filename from the path
    filename=$(basename "$file")
    # Extract the directory path
    dir=$(dirname "$file")

    # Normalize the filename by replacing spaces with underscores
    normalized_name=$(echo "$filename" | sed -r 's/[[:space:]]+/_/g')
    # Add spaces before capital letters and numbers, remove underscores
    spaced_name=$(add_spaces_and_keep_capitals "$normalized_name")

    # Rename the file if the new name is different
    if [[ "$filename" != "$spaced_name" ]]; then
        mv "$file" "$dir/$spaced_name"
        echo "Renamed '$filename' to '$spaced_name'"
    fi
done
