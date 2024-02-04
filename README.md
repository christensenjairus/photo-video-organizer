# photo-video-organizer
Bash script to organize your photo/video memories by year/month
* Finds when a photo or video was created using the creation date. If no creation date is present, will look at the modification date instead.
* Renames files to `yyyy-mm-dd_hh-mm-ss`
* Moves file into a folder representing the year and month. (i.e. /2022/Janurary/)
* Movies files that are not photos/videos into their own folder named `Other`, for you to organize later.

# Prerequisites
Have these programs installed:
* exiftool

# Usage
`./organize-files.sh <disorganized_folder> <new_and_organized_folder>` 
