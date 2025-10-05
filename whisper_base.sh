#!/bin/bash

#  whisper_base.sh
#  whisperx
#
#  Created by Vanessa Chan on 28/4/25.

# Set working directory
# Create output directory (optional)

output_dir="/home/disinfo_study_2310/vanessachan/whisper-outputs"
source /home/disinfo_study_2310/vanessachan/test-convert/env
conda activate env


# Loop over all MP4 files
for f in *.mp4; do
    # Skip if no MP4 files exist
    [ -f "$f" ] || continue
    
    name=$(basename "$f" .wav)
    
    # Convert MP4 to WAV
    wav_file="$output_dir/${name}.wav"
    echo "Converting $f to $wav_file..."
    ffmpeg -i "$f" -ar 16000 -ac 1 -y "$wav_file"

    # Check if WAV file was created
    if [ ! -f "${output_dir}/${name}.wav" ]; then
        echo "Error: Failed to create ${output_dir}/${name}.wav"
        continue
    fi
    
    echo "Transcribing $wav_file with medium model..."
        /home/disinfo_study_2310/vanessachan/whisper-scripts/whisper.cpp/build/bin/whisper-cli \
        -m /home/disinfo_study_2310/vanessachan/whisper-scripts/whisper.cpp/models/ggml-medium.bin \
        -f "$wav_file" --output-srt
            
    # Check if SRT file was created
    if [ ! -f "${output_dir}/${name}.wav.srt" ]; then
        echo "Error: Failed to create ${output_dir}/${name}.wav.srt"
        continue
    fi
    
    
    multilingual=$(python3 /home/disinfo_study_2310/vanessachan/whisper-scripts/is_multilingual.py "${output_dir}/${name}.wav.srt")

    # Run appropriate script based on language
    if [ "$multilingual" = "True" ]; then
        echo "Running multilingual for $wav_file..."
        /home/disinfo_study_2310/vanessachan/whisper-scripts/multilingual.sh ${output_dir}/${name}.wav
    fi
    
    
done
