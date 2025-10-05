# I do recommend setting up a basic python or python3 environment before running this

import argparse
import nemo.collections.asr as nemo_asr
import torch
torch.cuda.empty_cache()

ap = argparse.ArgumentParser(description="Transcribe or translate audio/video files using Parakeet")
ap.add_argument('input_file', type=str, help='Input file to process (e.g., file.wav)')
ap.add_argument('--output_srt', type=str, default='output.srt', help='Path to save SRT file')
args = ap.parse_args()

asr_model = nemo_asr.models.ASRModel.from_pretrained(model_name="nvidia/parakeet-tdt_ctc-110m")

asr_model.change_attention_model("rel_pos_local_attn", [128,128])
asr_model.change_subsampling_conv_chunking_factor(2)
asr_model.to(torch.bfloat16)

output = asr_model.transcribe([args.input_file], timestamps=True)
# by default, timestamps are enabled for char, word and segment level
word_timestamps = output[0].timestamp['word'] # word level timestamps for first sample
segment_timestamps = output[0].timestamp['segment'] # segment level timestamps
char_timestamps = output[0].timestamp['char'] # char level timestamps

for stamp in segment_timestamps:
    print(f"{stamp['start']}s - {stamp['end']}s : {stamp['segment']}")

# run with command: python /home/disinfo_study_2310/vanessachan/whisper-scripts/parakeet.py input_file
