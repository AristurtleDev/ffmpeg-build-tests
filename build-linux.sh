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
git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg

cd ffmpeg
./configure $SHARED_CONFIG
make -j$(nproc)

cd "$ROOT_DIRECTORY"
mkdir artifacts-linux
cp ./ffmpeg/ffmpeg ./artifacts-linux

# Execute ldd on the ffmpeg binary and extract only the first part of each line
ldd_output=$(ldd ffmpeg | awk '{print $1}')

# Check if any of the lines in the ldd output fail the check
if grep -qEv 'linux-vdso.so|libstdc++.so|libgcc_s.so|libc.so|libm.so|libdl.so|libpthread.so|/lib/ld-linux-|/lib64/ld-linux-' <<< "$ldd_output"; then
    echo "Error: ffmpeg binary dependencies check failed."
    exit 1
fi

echo "ffmpeg binary dependencies check passed."
