#!/bin/bash

# Script to extract basic metadata (filename, date, GPS) from media files
# Supports: JPG, JPEG, PNG, MOV, MP4
# Usage: ./extract_metadata.sh [input_directory]

# Start the timer
start_time=$(date +%s)

# Array to store files with valid GPS data
declare -a files_with_gps

# Function to format GPS coordinates and check if they're valid
format_coordinates() {
    local input_file="$1"
    local lat=$(exiftool -n -s -s -s -GPSLatitude "$input_file" 2>/dev/null)
    local long=$(exiftool -n -s -s -s -GPSLongitude "$input_file" 2>/dev/null)
    
    if [ ! -z "$lat" ] && [ ! -z "$long" ]; then
        # Check if coordinates are not 0,0
        if [ "$lat" != "0" ] || [ "$long" != "0" ]; then
            # Add to array of files with GPS
            files_with_gps+=("$(basename "$input_file") ($lat, $long)")
            echo "Location: ($lat, $long)"
        else
            echo "Location: Not available (0,0)"
        fi
    fi
}

# Function to extract metadata from a file
extract_metadata() {
    local input_file="$1"
    local log_file="$2"
    local file_type="$3"
    
    # Get just the filename without the path
    local filename=$(basename "$input_file")
    
    # Output filename
    echo "File: $filename" >> "$log_file"
    echo "Type: $file_type" >> "$log_file"
    
    if command -v exiftool >/dev/null 2>&1; then
        # Extract and format date/time based on file type
        local datetime
        if [[ "$file_type" == "Image" ]]; then
            datetime=$(exiftool -s -s -s -DateTimeOriginal -d "%Y-%m-%d %H:%M:%S" "$input_file" 2>/dev/null)
        else
            datetime=$(exiftool -s -s -s -CreateDate -d "%Y-%m-%d %H:%M:%S" "$input_file" 2>/dev/null)
        fi
        
        if [ ! -z "$datetime" ]; then
            echo "Taken: $datetime" >> "$log_file"
        fi

        # Format and append GPS coordinates
        format_coordinates "$input_file" >> "$log_file" 2>/dev/null || {
            echo "Location: Not available" >> "$log_file"
        }
        
        # Add a blank line after each file
        echo "" >> "$log_file"
    else
        echo "WARNING: ExifTool not installed" >> "$log_file"
        echo "" >> "$log_file"
    fi

    return 0
}

# Set input directory (use current directory if not specified)
INPUT_DIR="${1:-.}"

# Create reports directory if it doesn't exist
REPORTS_DIR="reports"
mkdir -p "$REPORTS_DIR"

LOG_FILE="$REPORTS_DIR/media_metadata_$(date '+%Y%m%d_%H%M%S').txt"

# Create temporary file for the main content
TEMP_FILE=$(mktemp)

# Initialize temp file with header
echo "Media File Metadata Summary" > "$TEMP_FILE"
echo "Generated on: $(date '+%Y-%m-%d %H:%M:%S')" >> "$TEMP_FILE"
echo "Source Directory: $INPUT_DIR" >> "$TEMP_FILE"
echo -e "==================================================\n" >> "$TEMP_FILE"

# Counters for processed files
processed=0
images=0
videos=0

# Process all supported files
while IFS= read -r -d '' file; do
    echo "Processing: $file"
    
    # Determine file type based on extension
    if [[ "${file,,}" =~ \.(jpg|jpeg|png)$ ]]; then
        extract_metadata "$file" "$TEMP_FILE" "Image"
        ((images++))
    elif [[ "${file,,}" =~ \.(mov|mp4)$ ]]; then
        extract_metadata "$file" "$TEMP_FILE" "Video"
        ((videos++))
    fi
    ((processed++))
done < <(find "$INPUT_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.mov" -o -iname "*.mp4" \) -print0)

# Calculate elapsed time
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
elapsed_formatted=$(printf '%02d:%02d:%02d' $((elapsed_time/3600)) $((elapsed_time%3600/60)) $((elapsed_time%60)))

# Create the final log file with GPS summary at the top
{
    echo "=== Files with GPS Data ==="
    if [ ${#files_with_gps[@]} -eq 0 ]; then
        echo "No files found with valid GPS coordinates"
    else
        printf '%s\n' "${files_with_gps[@]}"
    fi
    echo -e "\n=== Detailed Metadata ===\n"
    cat "$TEMP_FILE"
    echo -e "\n=================================================="
    echo "Total files processed: $processed"
    echo "Images processed: $images"
    echo "Videos processed: $videos"
    echo "Files with GPS data: ${#files_with_gps[@]}"
    echo "Process completed on: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Total processing time: $elapsed_formatted"
} > "$LOG_FILE"

# Clean up
rm "$TEMP_FILE"

# Print completion message with timing
echo "Metadata extraction complete!"
echo "Processed $processed files:"
echo "- Images: $images"
echo "- Videos: $videos"
echo "- Files with GPS data: ${#files_with_gps[@]}"
echo "Total processing time: $elapsed_formatted"
echo "Results saved to: $LOG_FILE" 