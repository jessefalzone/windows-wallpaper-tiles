#!/bin/bash

# Function to replace spaces with underscores
replace_spaces_with_underscores() {
    echo "$1" | sed -r 's/[[:space:]]+/_/g'
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
    # Extract the filename and extension
    filename=$(basename "$file")
    extension="${filename##*.}"
    name="${filename%.*}"

    # Normalize the filename by replacing spaces with underscores
    normalized_name=$(replace_spaces_with_underscores "$name")
    new_filename="${normalized_name}.${extension}"

    # Extract the directory path
    dir=$(dirname "$file")

    # Rename the file if the new name is different
    if [[ "$filename" != "$new_filename" ]]; then
        mv "$file" "$dir/$new_filename"
        echo "Renamed '$filename' to '$new_filename'"
    fi
done
