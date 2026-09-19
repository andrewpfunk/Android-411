#!/bin/bash

FILE=$1

if [ ! -f "$FILE" ]; then
    echo "Usage: convert.sh FILENAME"
    exit 1
fi

ffmpeg -i "$1" -c:v libx264 -profile:v high -level:v 4.1 -pix_fmt yuv420p -g 48 -keyint_min 48 -movflags +faststart -c:a aac "${1%.*}.mp4"


