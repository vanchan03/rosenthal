#  multilingual.sh
#  whisperx
#
#  Created by Vanessa Chan on 18/5/25.
#

#!/bin/bash
main_output_dir="/home/disinfo_study_2310/vanessachan/whisper-outputs"
input_dir="/home/disinfo_study_2310/vanessachan/test-convert"
wav_file="$1"

base_name=$(basename "$wav_file" .wav)
output_dir="${main_output_dir}/${base_name}_splits"

mkdir -p "${output_dir}"
cd "${output_dir}" || exit 1

# Split into 180-second chunks
ffmpeg -i "${main_output_dir}/${base_name}.wav" -f segment -segment_time 180 -c copy "chunk_%03d.wav"


index=0
for chunk in chunk_*.wav; do
    # Transcribe
    /home/disinfo_study_2310/vanessachan/whisper-scripts/whisper.cpp/build/bin/whisper-cli \
        -m /home/disinfo_study_2310/vanessachan/whisper-scripts/whisper.cpp/models/ggml-large-v2.bin \
        -f "$chunk" --output-srt --language auto

    mv "${chunk%.wav}.srt" "transcript_${index}.srt"

    # Translate
    /home/disinfo_study_2310/vanessachan/whisper-scripts/whisper.cpp/build/bin/whisper-cli \
        -m /home/disinfo_study_2310/vanessachan/whisper-scripts/whisper.cpp/models/ggml-large-v2.bin \
        -f "$chunk" --output-srt --language auto --translate

    mv "${chunk%.wav}.srt" "translation_${index}.srt"

    index=$((index + 1))
done

# Combine SRTs
cat transcript_*.srt > "${main_output_dir}/${base_name}_transcription.srt"
cat translation_*.srt > "${main_output_dir}/${base_name}_translation.srt"
