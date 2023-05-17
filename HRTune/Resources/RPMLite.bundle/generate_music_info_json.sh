#!/bin/bash

output_file="music_info.json"
echo "[" > "$output_file"

folders=(*/)
total_folders=${#folders[@]}
folder_count=0

for folder in "${folders[@]}"; do
    folder_count=$((folder_count + 1))
    album_name=$(basename "$folder")
    echo "  {" >> "$output_file"
    echo "    \"albumName\": \"$album_name\"," >> "$output_file"
    echo "    \"musicInfo\": [" >> "$output_file"

    mp3_files=$(find "$folder" -iname "*.mp3")
    IFS=$'\n'

    count=0
    total_files=$(echo "$mp3_files" | wc -l | tr -d ' ')

    for file_path in $mp3_files; do
        count=$((count + 1))

        file_name=$(basename "$file_path")
        bitRate=$(ffprobe -v error -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "$file_path" | head -n1)
        sampleRate=$(ffprobe -v error -show_entries stream=sample_rate -of default=noprint_wrappers=1:nokey=1 "$file_path" | head -n1)
        duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file_path" | head -n1)
        file_size=$(stat -f%z "$file_path")
        serialNumber=$(echo "$file_name" | cut -d' ' -f1)

        if [ -z "$bitRate" ]; then
            bitRate="null"
        fi

        if [ -z "$sampleRate" ]; then
            sampleRate="null"
        fi

        if [ -z "$album_name" ]; then
            album_name="null"
        fi

        echo "      {" >> "$output_file"
        echo "        \"title\": \"$file_name\"," >> "$output_file"
        echo "        \"bitRate\": $bitRate," >> "$output_file"
        echo "        \"sampleRate\": $sampleRate," >> "$output_file"
        echo "        \"duration\": $duration," >> "$output_file"
        echo "        \"size\": $file_size," >> "$output_file"
        echo "        \"serialNumber\": \"$serialNumber\"," >> "$output_file"
        echo "        \"albumName\": \"$album_name\"," >> "$output_file"
        echo "        \"isFavor\": false," >> "$output_file"
        echo "        \"favorDate\": 0.0" >> "$output_file"

        if [ $count -eq $total_files ]; then
            echo "      }" >> "$output_file"
        else
            echo "      }," >> "$output_file"
        fi
    done

    echo "    ]" >> "$output_file"
    if [ $folder_count -ne $total_folders ]; then
        echo "  }," >> "$output_file"
    else
        echo "  }" >> "$output_file"
    fi
done

echo "]" >> "$output_file"
