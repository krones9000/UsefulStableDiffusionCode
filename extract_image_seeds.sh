#!/bin/bash

######################################################################################
# Script Name: extract_image_seeds.sh
# Author: Kieran Currie Rones
# Version: 1.0
# Description:
# This script extracts seed values embedded in the metadata of image files 
# (e.g., PNG, JPEG, BMP) located in a selected folder, and assuming the images
# were created with Stable Diffusion and related tools. 
#
# It uses ImageMagick's `identify` command to parse the 
# metadata and extract the "Seed" field. This is useful when taking multiple images
# back through the generation process with hires-fix applied. The ouput comma
# delimited seeds can be provided to the "X/Y/Z Plot" script in A1111, Forge, 
# and similar.
#
# The extracted seeds are combined into a single comma-separated string and 
# copied to the system clipboard for further use. If no seeds are found, the 
# script notifies the user.
#
# Dependencies:
# 1. ImageMagick: Provides the `identify` command to extract metadata.
# 2. Zenity: Provides the GUI for selecting a folder and showing notifications.
# 3. xclip: Copies the extracted seed data to the clipboard.
#
# Usage:
# 1. Run the script in a Linux environment with the required dependencies installed.
# 2. A Zenity dialog will appear prompting the user to select a folder.
# 3. The script processes image files in the selected folder and extracts seed values.
# 4. If seeds are found, they are copied to the clipboard and displayed in a dialog.
# 5. If no seeds are found, the user is notified via a Zenity dialog.
#
# Example:
# $ ./extract_image_seeds.sh
#
# Notes:
# - Ensure that ImageMagick, Zenity, and xclip are installed on your system.
# - The script only processes files with extensions: .png, .jpg, .jpeg, .bmp.
# - Seeds are expected to be labeled as "Seed: [value]" in the metadata.
######################################################################################

# Prompt the user to select a folder using Zenity
folder=$(zenity --file-selection --directory --title="Select a Folder")

# Check if the user selected a folder; if not, exit with an error message
[ -z "$folder" ] && { 
    zenity --error --text="No folder selected. Exiting."; 
    exit 1; 
}

# Use the `find` command to locate image files in the selected folder
# and its subdirectories. The script processes files with the extensions:
# .png, .jpg, .jpeg, and .bmp. For each file, it runs the `identify` command 
# to extract metadata and then filters out the seed value using `grep` and `sed`.
seeds=$(find "$folder" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.bmp" \) \
  -exec sh -c '
    identify -format "%[parameters]" "$1" 2>/dev/null | grep -o "Seed: [0-9]*" | sed "s/Seed: //"
  ' _ {} \; | paste -sd, -)

# If seeds were found, copy them to the clipboard using `xclip` and notify the user
if [ -n "$seeds" ]; then
    # Copy the seeds to the clipboard
    echo -n "$seeds" | xclip -selection clipboard

    # Show a success message with the extracted seeds
    zenity --info --text="Seeds copied to clipboard:\n$seeds"
else
    # Notify the user that no seeds were found
    zenity --error --text="No valid seeds found in the folder."
fi
