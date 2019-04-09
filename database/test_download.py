# Path to ffmpeg
ffmpeg_path = '/bin/anaconda3/bin/ffmpeg'

import sys
import os.path
# Make sure ffmpeg is on the path so sk-video can find it
sys.path.append(os.path.dirname(ffmpeg_path))
import skvideo.io
import matplotlib.pyplot as plt
import numpy as np
import pafy
import soundfile as sf
import subprocess as sp
from IPython.display import Video

# Set output settings
audio_codec = 'flac'
audio_container = 'flac'
video_codec = 'h264'
video_container = 'mp4'


# Load the AudioSet training set
with open('./database/banjo_train_subset.csv') as f:
    lines = f.readlines()

dl_list = [line.strip().split(',')[:3] for line in lines[3:]]


# Select a YouTube video from the training set
ytid, ts_start, ts_end = dl_list[0]
ytid = ytid.replace('"', '')
ts_start, ts_end = float(ts_start), float(ts_end)
duration = ts_end - ts_start

print("YouTube ID: " + ytid)
print("Trim Window: ({}, {})".format(ts_start, ts_end))

# Get the URL to the video page
video_page_url = 'https://www.youtube.com/watch?v={}'.format(ytid)

# Get the direct URLs to the videos with best audio and with best video (with audio)
video = pafy.new(video_page_url)

best_video = video.getbestvideo()
best_video_url = best_video.url
print("Video URL: " + best_video_url)

best_audio = video.getbestaudio()
best_audio_url = best_audio.url
print("Audio URL: " + best_audio_url)

# Get output video and audio filepaths
basename_fmt = '{}_{}_{}'.format(ytid, int(ts_start*1000), int(ts_end*1000))
video_filepath = os.path.join('./database', basename_fmt + '.' + video_container)
audio_filepath = os.path.join('./database', basename_fmt + '.' + audio_codec)
print("Video path: " + video_filepath)
print("Audio path: " + audio_filepath)

# Download the audio
audio_dl_args = [ffmpeg_path, '-n',
    '-ss', str(ts_start),    # The beginning of the trim window
    '-i', best_audio_url,    # Specify the input video URL
    '-t', str(duration),     # Specify the duration of the output
    '-vn',                   # Suppress the video stream
    '-ac', '2',              # Set the number of channels
    '-sample_fmt', 's16',    # Specify the bit depth
    '-acodec', audio_codec,  # Specify the output encoding
    '-ar', '44100',          # Specify the audio sample rate
    audio_filepath]

proc = sp.Popen(audio_dl_args, stdout=sp.PIPE, stderr=sp.PIPE)
stdout, stderr = proc.communicate()
if proc.returncode != 0:
    print(stderr)
else:
    print("Downloaded audio to " + audio_filepath)
