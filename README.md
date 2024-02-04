# Photo & Video Organizer
Bash script to organize your photo/video memories by year & month. 

It does this by performing the following steps:
* Finds when a photo or video was created using the creation date. If no creation date is present, will look at the modification date instead.
* Renames files to `yyyy-mm-dd_hh-mm-ss`, adding a counter onto the end if many files were created at the same second *and they are not duplicates*.
* Removes duplicates.
* Moves file into a folder representing the year and month. (i.e. `/2022/01 - January/`)
* Moves files that are not photos/videos into their own folder named `Other`, for you to organize manually (or delete!).
* Moves files with an unknown creation/modification date to a folder named `Unknown Date`, for you to organize manually.

## Prerequisites
Have these programs installed:
* `exiftool`
* `md5sum`

## Usage
`./organize-files.sh <old_and_disorganized_folder> <new_and_organized_folder>` 

## Results

![image](https://github.com/christensenjairus/photo-video-organizer/assets/58751387/5801986f-f9cc-486e-98fd-54e102d79e42)

