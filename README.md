# photo-video-organizer
Bash script to organize your photo/video memories by year/month. It does this by performing the following steps:
* Finds when a photo or video was created using the creation date. If no creation date is present, will look at the modification date instead.
* Renames files to `yyyy-mm-dd_hh-mm-ss`, adding a counter onto the end if many files are taken at the same second *and they are not duplicates*.
* Removes duplicates.
* Moves file into a folder representing the year and month. (i.e. /2022/01-Janurary/)
* Moves files that are not photos/videos into their own folder named `Other`, for you to organize manually.
* Moves files with an unknown creation/modification date to a folder named `Unknown`, for you to organize manually.

# Prerequisites
Have these programs installed:
* exiftool

# Usage
`./organize-files.sh <old_and_disorganized_folder> <new_and_organized_folder>` 
