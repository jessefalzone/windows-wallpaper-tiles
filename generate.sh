#!/bin/bash

IMAGE_DIR="./images"
OUTPUT_HTML="index.html"

# HTML boilerplate
cat <<EOL >$OUTPUT_HTML
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Windows Tiled Backgrounds</title>
<style>
:root {
--gray: #c3c3c3;
}
body {
  height: 100%;
  margin: 0;
  line-height: 1.5;
}
#controls {
  margin: 20px;
  background-color: var(--gray);
  max-width:800px;
  border-top: 2px solid var(--gray);
  border-right: 2px solid black;
  border-bottom: 2px solid black;
  border-left: 2px solid var(--gray);
}
#inner-wrapper {
  padding: 20px;
  border-top: 2px solid white;
  border-right: 2px solid #555;
  border-bottom: 2px solid #555;
  border-left: 2px solid white;
}
fieldset {
  margin: 20px 0;
}
label {
  white-space: nowrap;
  margin: 0 5px;
}
body:has(fieldset[data-category="Patterns"] input:checked) {
  image-rendering: pixelated;
  background-size: 16px;
}
EOL

# Create CSS rules for each image
find "$IMAGE_DIR" -type f \( -iname "*.bmp" -o -iname "*.png" -o -iname "*.jpeg" \) | while IFS= read -r filepath; do
  # Extract filename without extension
  filename=$(basename -- "$filepath")
  filename="${filename%.*}"

  # Extract subdirectory name
  subdir_name=$(basename "$(dirname "$filepath")")

  # Create a valid CSS value
  valid_value="${subdir_name}_${filename}"
  valid_value=$(echo "$valid_value" | tr -cd '[:alnum:]_') # Remove invalid characters

  # Add stylesheet rule for each file path
  echo "body:has(input[value=\"$valid_value\"]:checked) {
  background-image: url(\"$filepath\");
}" >>$OUTPUT_HTML
done

# Complete the stylesheet and start the body
cat <<EOL >>$OUTPUT_HTML
</style>
</head>
<body>
<div id="controls">
<div id="inner-wrapper">
<h1>Windows Tile Backgrounds</h1>
EOL

# Loop through each subdirectory in the image directory
checked=true
find "$IMAGE_DIR" -mindepth 1 -type d | sort | while IFS= read -r subdir; do
  # Get the name of the subdirectory
  subdir_name=$(basename "$subdir")

  # Start a new fieldset for each subdirectory
  echo "<fieldset data-category=\"$subdir_name\">" >>"$OUTPUT_HTML"
  echo "<legend>$subdir_name</legend>" >>"$OUTPUT_HTML"

  # Loop through each file in the current subdirectory
  while IFS= read -r -d '' filepath; do
    # Extract filename without extension
    filename=$(basename -- "$filepath")
    filename="${filename%.*}"

    # Create a valid HTML ID and value
    valid_id="${subdir_name}_$filename"
    valid_id=$(echo "$valid_id" | tr -cd '[:alnum:]_') # Remove invalid characters
    valid_id=$(echo "$valid_id" | sed 's/^[0-9]/x&/') # Prefix with 'x' if it starts with a number

    valid_value="${subdir_name}_${filename}"
    valid_value=$(echo "$valid_value" | tr -cd '[:alnum:]_') # Remove invalid characters

    # Add HTML for each radio button
    echo "<label><input type=\"radio\" id=\"$valid_id\" name=\"background\" value=\"$valid_value\"$(if $checked; then echo " checked"; fi)><span>$filename</span></label>" >>$OUTPUT_HTML
    checked=false
  done < <(find "$subdir" -maxdepth 1 -type f \( -iname "*.bmp" -o -iname "*.png" -o -iname "*.jpeg" \) -print0 | sort -z)

  # Close the fieldset
  echo "</fieldset>" >>"$OUTPUT_HTML"
done

# Complete the HTML
cat <<EOL >>"$OUTPUT_HTML"
</div>
</div>
</body>
</html>
EOL

echo "Done building $OUTPUT_HTML."
