# rosenthal
Code for processing the Rosenthal files on behalf of the UCLA Department of Communication using Professor Rick Dale's Itkin GPU.
Will contain code for mpg2 to mp4 processing, Whisper implementation, and a scratch code for Grok-AI based segmentation.
Scripts and logs:

cronjob_processing.sh - run the cronjob that processes mpg files int mp4

cronlog.log - logs when the cronjob is activated

crontest.log - log for the cronjob that doesn't really work

is_multilingual.py - clunky script to help me determine whether something was multilingual or not

mpg_convert.sh - convert mpg files into mp4 at a target bitrate of 5 Mbps

multilingual.sh - split multilingual files into 3 minute segments, transcribes each of them with whisper large and stitches it back together

parakeet.py - runs parakeet's lightest model on the GPU cluster from https://huggingface.co/nvidia/parakeet-tdt_ctc-110m

test_gpu_space.py - testing if the gpu has space for parakeet's model (specific to a bug I was getting on parakeet)

whisper.cpp - whisper.cpp repo from https://github.com/ggml-org/whisper.cpp

whisper_base.sh - the base file that runs whisper on an input folder, outputs it to another folder, and then activates 

is_multilingual.py and multilingual.sh

whispers.py - no longer useful integration of whisper on python

whispers_combined.yml - yml environment for whisper.py which is no longer being used
