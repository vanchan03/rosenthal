#!/bin/sh

#  mpg_convert.sh
#  whisperx
#
#  Created by Vanessa Chan on 11/4/25.
#  
#!/bin/bash

# Define paths
INPUT_DIR="/home/disinfo_study_2310/vanessachan/mpeg2-transfer"
OUTPUT_DIR="/home/disinfo_study_2310/vanessachan/rosenthal-landing"
LOG_FILE="$OUTPUT_DIR/processed_files.txt"

# Check if processed_files already exists
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE" || { echo "Error: Could not create $LOG_FILE"; exit 1; }
fi

# Check for .mpg files
if ! ls "$INPUT_DIR"/*.mpg >/dev/null 2>&1; then
    echo "No .mpg files found in $INPUT_DIR"
    exit 1
fi

# Check if already processed
if [ -f "$OUTPUT_DIR/processed_files.txt" ]; then
    if grep -Fx "$BASENAME.mpg" "$OUTPUT_DIR/processed_files.txt" > /dev/null; then
        echo "Skipping $INPUT_FILE (already processed)"
        continue
    fi
fi


# Loop over .mpg files
for INPUT_FILE in "$INPUT_DIR"/*.mpg; do
    [ -f "$INPUT_FILE" ] || continue

    BASENAME=$(basename "$INPUT_FILE" .mpg)
    OUTPUT_FILE="$OUTPUT_DIR/$BASENAME.mp4"
    echo "Processing: $INPUT_FILE"
    
    # Get original file size (in bytes)
    ORIG_SIZE=$(ls -l "$INPUT_FILE" 2>/dev/null | awk '{print $5}')
    
    # Calculate target size (20% of original, in bytes)
    TARGET_SIZE=$((ORIG_SIZE / 5))
    
    # Get file duration (in seconds)
    DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT_FILE" | awk '{printf "%.0f", $1}')
    
    # Calculate max bitrate: (target_size * 8) / duration, in bits/s
    if [ "$DURATION" -gt 0 ]; then
        MAX_BITRATE=$(( (TARGET_SIZE * 8) / DURATION ))
        if [ "$MAX_BITRATE" -gt 10000000 ]; then
            MAX_BITRATE=10000000
        fi
        # Adjust target bitrate to fit target size if needed
        TARGET_BITRATE=$(( (TARGET_SIZE * 8) / DURATION ))
        if [ "$TARGET_BITRATE" -gt 5000000 ]; then
            TARGET_BITRATE=5000000
        fi
    else
        echo "Warning: Could not get duration for $INPUT_FILE, using 10M maxrate and 5M target"
        MAX_BITRATE=10000000
        TARGET_BITRATE=5000000
    fi

    # Record start time
    START_TIME=$(date +%s)
    
    # First pass
    ffmpeg -y -vsync 0 -hwaccel cuda -i "$INPUT_FILE" -c:v h264_nvenc -preset p7 -pass 1 -b:v "$TARGET_BITRATE" -maxrate "$MAX_BITRATE" -vf "scale=640:426" -r 29.97 -an -f mp4 /dev/null
    
    # Second pass
    ffmpeg -y -vsync 0 -hwaccel cuda -i "$INPUT_FILE" -c:v h264_nvenc -preset p7 -pass 2 -b:v "$TARGET_BITRATE" -maxrate "$MAX_BITRATE" -vf "scale=640:426" -r 29.97 -c:a aac -b:a 142k "$OUTPUT_DIR/$BASENAME.mp4"
    
    # Record end time and calculate runtime
    END_TIME=$(date +%s)
    RUNTIME=$((END_TIME - START_TIME))
    echo "Completed $BASENAME.mpg in $RUNTIME seconds" >> "$LOG_FILE"
done


