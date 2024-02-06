#!/bin/bash

# Initialize flag indicating whether to delete duplicates
delete_duplicates=false

# Check for --delete flag
if [[ "$1" == "--delete" ]]; then
    delete_duplicates=true
    shift # Remove the --delete argument from the list
fi

# Check if the correct number of arguments was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [--delete] <directory>"
    exit 1
fi

TARGET_DIR="$1"

# Ensure the target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "The specified directory does not exist. Please provide a valid path."
    exit 1
fi

echo "Searching for duplicate files in '$TARGET_DIR'..."

# Generate MD5 hashes for all files
find "$TARGET_DIR" -type f -exec md5sum {} + | sort > /tmp/all_files_hashes.txt

# Identify duplicate hashes
cut -d ' ' -f 1 /tmp/all_files_hashes.txt | uniq -d > /tmp/duplicate_hashes.txt

if [ -s /tmp/duplicate_hashes.txt ]; then
    echo "Duplicate files found based on content. Processing duplicates..."

    while IFS= read -r hash; do
        echo "Duplicates for hash: $hash"
        
        # Extract file paths for the current hash
        grep "^$hash " /tmp/all_files_hashes.txt | sed 's/^[^ ]* //' > /tmp/duplicate_files.txt
        
        # Display the group of duplicate files
        cat /tmp/duplicate_files.txt

        # If delete flag is set, proceed with deletion logic
        if [ "$delete_duplicates" = true ]; then
            preferred_file_found=false
            keep_file=""
            non_heic_file=""
            
            # First pass to find a non-HEIC preferred file
            while IFS= read -r file_path; do
                file_name=$(basename "$file_path")
                
                if [[ "$file_name" =~ ^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}_[0-9]{2}-[0-9]{2}-[0-9]{2} ]] && [[ "$file_name" != .* ]]; then
                    # Check if file is not a HEIC file
                    file_name_lower=$(echo "$file_name" | tr '[:upper:]' '[:lower:]')
                     if [[ "$file_name_lower" != *.heic ]]; then
                        echo "Preferred non-HEIC file found and kept: $file_path"
                        preferred_file_found=true
                        keep_file="$file_path"
                        break # Stop the loop once a preferred non-HEIC file is found
                    elif [ -z "$non_heic_file" ]; then
                        # If it's a HEIC file, remember it as a fallback
                        non_heic_file="$file_path"
                    fi
                fi
            done < /tmp/duplicate_files.txt
            
            # If no preferred non-HEIC file found, but a HEIC file was, mark it as the file to keep
            if [ "$preferred_file_found" = false ] && [ -n "$non_heic_file" ]; then
                keep_file="$non_heic_file"
                preferred_file_found=true
                echo "Fallback to HEIC file: $keep_file"
            fi
            
            # Second pass to delete all other files if a preferred file is found
            if [ "$preferred_file_found" = true ]; then
                while IFS= read -r file_path; do
                    if [ "$file_path" != "$keep_file" ]; then
                        echo "Removing duplicate $file_path"
                        rm -f "$file_path"
                    fi
                done < /tmp/duplicate_files.txt
            else
                # If no preferred format found, keep the first file and remove the rest
                echo "No preferred file format found among duplicates. Keeping one and removing the rest."
                while IFS= read -r line; do
                    if [ -z "$keep_file" ]; then
                        keep_file="$line"
                        echo "Keeping one file by default: $line"
                    else
                        if [ "$line" != "$keep_file" ]; then
                            echo "Removing non-preferred duplicate '$line'"
                            rm -f "$line"
                        fi
                    fi
                done < /tmp/duplicate_files.txt
            fi
        fi


        echo "-----" # Separator for readability
    done < /tmp/duplicate_hashes.txt
    # Optional cleanup
   rm /tmp/all_files_hashes.txt /tmp/duplicate_hashes.txt /tmp/duplicate_files.txt
else
    echo "No duplicates found based on content."
fi
