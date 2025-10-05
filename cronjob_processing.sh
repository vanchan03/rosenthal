
#  cronjob_processing.sh
#  whisperx
#
#  Created by Vanessa Chan on 15/6/25.
#  
if pgrep -f "mpg_convert.sh" > /dev/null; then
    echo "Script is running"
else
    echo "Script is NOT running"
    bash /home/disinfo_study_2310/vanessachan/whisper-scripts/mpg_convert.sh &
    disown
fi

# I'm not completely sure if this works because I was following all available instructions on the internet about 
# setting up a cron job and it still wasn't working. Possibly because cron might be incompatible with running scripts
# that require a python environment? but that feels unlikely to me
