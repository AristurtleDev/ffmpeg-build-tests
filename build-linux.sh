#!/bin/bash

ROOT_DIR="$(pwd)"
SHARED_CONFIG="--enable-static \
               --disable-shared \
               --disable-encoders \
               --enable-encoder=pcm_u8 \
               --enable-encoder=pcm_f32le \
               --enable-encoder=pcm_s16le \
               --enable-encoder=adpcm_ms \
               --enable-encoder=wmav2 \
               --enable-encoder=adpcm_ima_wav \
               --enable-encoder=aac \
               --enable-libvorbis \
               --enable-libmp3lame \
               --enable-encoder=mp4 \
               --disable-decoders \
               --enable-decoder=pcm_u8 \
               --enable-decoder=pcm_f32le \
               --enable-decoder=pcm_s16le \
               --enable-decoder=adpcm_ms \
               --enable-decoder=wmav2 \
               --enable-decoder=adpcm_ima_wav \
               --enable-decoder=aac \
               --enable-decoder=libvorbis \
               --enable-decoder=libmp3lame \
               --enable-decoder=mp4 \
               --disable-muxers \
               --enable-muxer=wav \
               --enable-muxer=asf \
               --enable-muxer=ipod \
               --enable-muxer=ogg \
               --enable-muxer=mp3"

# Install general dependencies
sudo apt-get update
sudo apt-get install -y build-essential pkg-config yasm git

# Install library dependencies
sudo apt-get install -y libx264-dev libx265-dev libvorbis-dev libmp3lame-dev lame

# Clone the ffmpeg repository
git clone --depth 1 --branch n7.0 https://github.com/ffmpeg/ffmpeg.git

cd ffmpeg
./configure $SHARED_CONFIG
make -j$(nproc)

cd "$ROOT_DIR"
mkdir artifacts-linux
cp ./ffmpeg/ffmpeg ./artifacts-linux

# Move to artifacts-linux directory
cd ./artifacts-linux

# Execute ldd on the ffmpeg binary and extract the library dependencies
ldd_output=$(ldd ffmpeg)

# Loop through each line of ldd output
while IFS= read -r line; do
    # Extract the library path from each line
    lib_path=$(echo "$line" | awk '{print $(NF-1)}')

    # Check if the library path is within /lib, /lib64, or /usr/lib
    if [[ $lib_path =~ ^(/lib|/lib64|/usr/lib) ]]; then
        # Extract the library name
        lib_name=$(echo "$line" | awk '{print $1}')

        # Copy the library to the artifacts-linux directory
        cp --parents "$lib_name" .
    fi
done <<< "$ldd_output"

echo "ffmpeg binary dependencies copied to artifacts-linux directory."
