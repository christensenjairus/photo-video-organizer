#!/bin/bash

# Initialize delete flag
delete_files=false

# Check for --delete option
if [[ "$1" == "--delete" ]]; then
    delete_files=true
    shift # Remove the --delete argument
fi

# Check if the correct number of arguments was provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 [--delete] <source directory> <target directory>"
    exit 1
fi

SOURCE_DIR="$1"
TARGET_DIR="$2"

# Ensure the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "The source directory does not exist. Please provide a valid path."
    exit 1
fi

# Convert to absolute paths to avoid misleading comparisons due to relative paths
ABS_SOURCE_DIR="$(realpath "$SOURCE_DIR")"
ABS_TARGET_DIR="$(realpath "$TARGET_DIR")"

# Check if source and destination directories are the same
if [ "$ABS_SOURCE_DIR" == "$ABS_TARGET_DIR" ]; then
    echo "The source and target directories must be different."
    exit 1
fi

# Ensure the target directory exists, or create it
mkdir -p "$TARGET_DIR"

# Define the 'Other' and 'Unknown Date' folder paths in the target directory
OTHER_FOLDER_PATH="${TARGET_DIR}/Other"
UNKNOWN_DATE_FOLDER_PATH="${TARGET_DIR}/Unknown Date"
mkdir -p "$OTHER_FOLDER_PATH"
mkdir -p "$UNKNOWN_DATE_FOLDER_PATH"

# Process every file in the source directory recursively
find "$SOURCE_DIR" -type f -exec bash -c '
    shopt -s nocasematch
    delete_files='"$delete_files"'
    file="$1"
    target_dir="$2"
    other_folder_path="$3"
    unknown_date_folder_path="$4"
    operation="cp -f" # Default operation is to copy
    if [[ "$delete_files" == true ]]; then
        operation="mv -f" # Change operation to move if --delete option is set
    fi

    # Move files starting with "._" directly to the Other folder
    # My syncing client uses these files for sync information
    if [[ "$(basename "$file")" == ._* ]]; then
        echo "File \"$file\" starts with ._ , moving to Other."
        $operation "$file" "$other_folder_path/$(basename "$file")"
    else
        # Use exiftool to attempt to extract the creation date
        creationDate=$(exiftool -d "%Y-%m-%d" -DateTimeOriginal -CreateDate -ModifyDate -FileModifyDate -ExtractEmbedded "$file" | awk -F": " "{ print \$2 }" | head -n 1)

        # # Check if the creation date is February 5th, 2022
        # if [[ "$creationDate" == "2022-02-05" ]]; then
        #     echo "Creation date for \"$file\" is February 5th, 2022, moving to Unknown Date."
        #     $operation "$file" "$unknown_date_folder_path/$(basename "$file")"
        # else
            # List of possible file extensions for photos or videos in lowercase
            photo_video_extensions=("jpg" "jpeg" "png" "gif" "bmp" "tif" "tiff" "webp" "heic" "mov" "mp4" "avi" "mkv" "wmv" "flv" "mpeg" "mpg" "3gp" "m4v" "mts" "cr2")

            # Extract the file extension and convert to lowercase
            extension=$(echo "${file##*.}" | tr "[:upper:]" "[:lower:]")

            # Check if the file extension is in the list of photo/video extensions
            is_photo_video=false
            for ext in "${photo_video_extensions[@]}"; do
                if [[ "$extension" == "$ext" ]]; then
                    is_photo_video=true
                    break
                fi
            done

            if [[ "$is_photo_video" == false ]]; then
                echo "File \"$file\" is not a photo or video, moving to Other."
                $operation "$file" "$other_folder_path/$(basename "$file")"
            else
                # Use exiftool to attempt to extract the creation date
                creationDate=$(exiftool -d "%Y-%m-%d_%H-%M-%S" -DateTimeOriginal -CreateDate -ModifyDate -FileModifyDate -ExtractEmbedded "$file" | awk -F": " "{ print \$2 }" | head -n 1)

                    if [[ "$creationDate" == "0000:00:00 00:00:00" ]] || [[ -z "$creationDate" ]]; then
                    echo "Valid creation date not found for \"$file\", moving to Unknown Date."
                    $operation "$file" "$unknown_date_folder_path/$(basename "$file")"
                else
                    year=$(echo "$creationDate" | cut -d"-" -f1)
                    month=$(echo "$creationDate" | cut -d"-" -f2)
                    day=$(echo "$creationDate" | cut -d"-" -f3 | cut -d"_" -f1)
                    time=$(echo "$creationDate" | cut -d"_" -f2)

                    # Month names
                    month_names=("January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")
                    month_decimal=$((10#$month)) # Force base-10 interpretation
                    month_name="${month_names[month_decimal - 1]}"

                    destinationPath="$target_dir/$year/($year-$month) $month_name $year"
                    mkdir -p "$destinationPath"

                    newFilename="${year}-${month}-${day}_${time}.${extension}"
                    counter=1
                    originalHash=$(md5sum "$file" | cut -d " " -f1)

                    while [ -f "$destinationPath/$newFilename" ]; do
                        newFileHash=$(md5sum "$destinationPath/$newFilename" | cut -d " " -f1)
                        if [[ "$originalHash" == "$newFileHash" ]]; then
                            echo "Duplicate file detected, skipping copy for \"$file\""
                            break
                        else
                            newFilename="${year}-${month}-${day}_${time}_${counter}.${extension}"
                            ((counter++))
                        fi
                    done

                    if [[ "$originalHash" != "$newFileHash" ]]; then
                        $operation "$file" "$destinationPath/$newFilename"
                        echo "Copied and renamed \"$file\" to \"$destinationPath/$newFilename\""
                    fi
                fi
            fi
        # fi
    fi
    shopt -u nocasematch
' bash {} "$TARGET_DIR" "$OTHER_FOLDER_PATH" "$UNKNOWN_DATE_FOLDER_PATH" \;


# Delete empty directories in source and target directories
find "$SOURCE_DIR" "$TARGET_DIR" -type d -empty -delete

echo "Operation completed. Empty directories have been cleaned up."
