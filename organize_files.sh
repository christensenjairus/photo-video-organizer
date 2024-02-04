#!/bin/bash

# Check if the correct number of arguments was provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source directory> <target directory>"
    exit 1
fi

SOURCE_DIR="$1"
TARGET_DIR="$2"

# Ensure the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "The source directory does not exist. Please provide a valid path."
    exit 1
fi

# Ensure the target directory exists, or create it
mkdir -p "$TARGET_DIR"

# Define the 'Other' folder path in the target directory
OTHER_FOLDER_PATH="${TARGET_DIR}/Other"
mkdir -p "$OTHER_FOLDER_PATH"

# Month names array
declare -A month_names=( [01]="January" [02]="February" [03]="March" [04]="April" [05]="May" [06]="June" [07]="July" [08]="August" [09]="September" [10]="October" [11]="November" [12]="December" )

# Process every file in the source directory recursively
find "$SOURCE_DIR" -type f -exec bash -c '
    shopt -s nocasematch
    file="$1"
    target_dir="$2"
    other_folder_path="$3"
    declare -A month_names=( [01]="January" [02]="February" [03]="March" [04]="April" [05]="May" [06]="June" [07]="July" [08]="August" [09]="September" [10]="October" [11]="November" [12]="December" )

    # Use exiftool to extract the creation date
    creationDate=$(exiftool -d "%Y-%m-%d_%H-%M-%S" -DateTimeOriginal -CreateDate -ModifyDate -FileModifyDate -ExtractEmbedded "$file" | awk -F": " "{ print \$2 }" | head -n 1)

    # Use files last modification date if creation date is not found
    if [ -z "$creationDate" ]; then
        echo "Creation date not found for $file, using modification date."
        creationDate=$(date -r "$file" "+%Y-%m-%d_%H-%M-%S")
    fi

    # Determine the file extension
    extension="${file##*.}"
    filename=$(basename "$file")

    # Extract year, month, and day
    year=$(echo "$creationDate" | cut -d"-" -f1)
    month=$(echo "$creationDate" | cut -d"-" -f2)
    day=$(echo "$creationDate" | cut -d"-" -f3 | cut -d"_" -f1)

    # Convert month number to month name
    month_name="${month_names[$month]}"

    if [[ "$filename" =~ \.(jpg|jpeg|png|gif|bmp|tif|tiff|heic|mp4|mov|avi|wmv|flv|mkv)$ ]]; then
        # Create directory structure based on year and full month name in the target directory
        destinationPath="$target_dir/$year/$month_name"
        mkdir -p "$destinationPath"

        # Rename and copy the file to the new directory
        newFilename="${year}-${month_name}-${day}_${creationDate##*_}.${extension,,}"
        cp -f "$file" "$destinationPath/$newFilename"
        echo "Copied and renamed $file to $destinationPath/$newFilename"
    else
        # Copy non-photo/video files to the Other folder in the target directory
        cp -f "$file" "$other_folder_path/$filename"
        echo "Copied $file to $other_folder_path/$filename"
    fi
    shopt -u nocasematch
' bash {} "$TARGET_DIR" "$OTHER_FOLDER_PATH" \;
