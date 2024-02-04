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
    declare -A month_names=([01]="January" [02]="February" [03]="March" [04]="April" [05]="May" [06]="June" [07]="July" [08]="August" [09]="September" [10]="October" [11]="November" [12]="December")

    # Use exiftool to extract the creation date
    creationDate=$(exiftool -d "%Y-%m-%d_%H-%M-%S" -DateTimeOriginal -CreateDate -ModifyDate -FileModifyDate -ExtractEmbedded "$file" | awk -F": " "{ print \$2 }" | head -n 1)

    if [ -z "$creationDate" ]; then
        echo "Creation date not found for $file, using modification date."
        creationDate=$(date -r "$file" "+%Y-%m-%d_%H-%M-%S")
    fi

    extension="${file##*.}"
    year=$(echo "$creationDate" | cut -d"-" -f1)
    month=$(echo "$creationDate" | cut -d"-" -f2)
    day=$(echo "$creationDate" | cut -d"-" -f3 | cut -d"_" -f1)
    time=$(echo "$creationDate" | cut -d"_" -f2)
    month_name="${month_names[$month]}"
    destinationPath="$target_dir/$year/${month}-${month_name}"
    mkdir -p "$destinationPath"

    newFilename="${year}-${month}-${day}_${time}.${extension,,}"
    counter=1
    originalHash=$(md5sum "$file" | cut -d " " -f1)

    while [ -f "$destinationPath/$newFilename" ]; do
        newFileHash=$(md5sum "$destinationPath/$newFilename" | cut -d " " -f1)
        if [[ "$originalHash" == "$newFileHash" ]]; then
            echo "Duplicate file detected, skipping copy for $file"
            break
        else
            newFilename="${year}-${month}-${day}_${time}_${counter}.${extension,,}"
            ((counter++))
        fi
    done

    if [[ "$originalHash" != "$newFileHash" ]]; then
        cp -f "$file" "$destinationPath/$newFilename"
        echo "Copied and renamed $file to $destinationPath/$newFilename"
    fi
    shopt -u nocasematch
' bash {} "$TARGET_DIR" "$OTHER_FOLDER_PATH" \;
