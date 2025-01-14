#!/bin/bash

# Variables
LOG_DIR="/log_cgnat/10.3.41.83/2025/"
LOG_EXTENSION="*.log"
OUTPUT_LOG="/var/log/compress_logs.log"
CURRENT_DATE=$(date +%Y-%m-%d)

# Function to log messages
echo_log() {
    local MESSAGE="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $MESSAGE" | tee -a "$OUTPUT_LOG"
}

# Start of the script
echo_log "Script started. Processing log files in $LOG_DIR."

# Find and process files
find "$LOG_DIR" -type f -name "$LOG_EXTENSION" ! -newermt "$CURRENT_DATE" | while read -r FILE; do
    if [ -f "$FILE" ]; then
        OUTPUT_FILE="$FILE.zst"

        echo_log "Compressing: $FILE"
        
        zstd -T4 "$FILE" -o "$OUTPUT_FILE"
        if [ $? -eq 0 ]; then
            echo_log "Compression successful: $OUTPUT_FILE"
            
            rm "$FILE"
            if [ $? -eq 0 ]; then
                echo_log "Deleted original file: $FILE"
            else
                echo_log "Error deleting original file: $FILE"
            fi
        else
            echo_log "Compression failed for: $FILE"
        fi
    else
        echo_log "File not found or not accessible: $FILE"
    fi

done

echo_log "Script completed."
