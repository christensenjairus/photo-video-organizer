# Photo & Video Organizer
Bash script to organize your photo/video memories by year & month. 

It does this by performing the following steps:
* Finds when a photo or video was created using the creation date. If no creation date is present, will look at the modification date instead.
* Renames files to `yyyy-mm-dd_hh-mm-ss`, adding a counter onto the end if many files were created at the same second *and they are not duplicates*.
* Removes duplicates.
* Moves file into a folder representing the year and month. (i.e. `/2022/(2022-01) January 2022/`)
* Moves files that are not photos/videos into their own folder named `Other`, for you to organize manually (or delete!).
* Moves files with an unknown creation/modification date to a folder named `Unknown Date`, for you to organize manually.

## Prerequisites
Have these programs installed:
* `exiftool`
* `md5sum`

## Usage
`./organize-files.sh [--delete] <old_and_disorganized_folder> <new_and_organized_folder>`

### Delete Mode
***TAKE A BACKUP BEFORE USING***

This mode, triggered by the `--delete` flag will move the files instead of copy them, then delete leftover duplicates from the source directory.

### Identify Duplicates Usage
*You probably won't need this script. I created this only because I had many HEIC files and JPEG files with the same content and needed to find & delete the HIEC ones.*
This is an extra script that you can run after you've organized your photos to ensure there are no duplicates. This script can optionally delete one of the duplicates with the `--delete` flag. The script prefers to keep the well-named one and/or the non-HEIC one.

`./identify-duplicates.sh [--delete] <folder>`

## Results

![image](https://github.com/christensenjairus/photo-video-organizer/assets/58751387/199fdc0a-d941-46d6-bc25-6c7966a7cecc)
