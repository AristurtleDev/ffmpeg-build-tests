#!/bin/bash

ROOT_DIR="$(pwd)"
DEPENDENCIES_DIR="$ROOT_DIR/dependencies"
ARTIFACTS_DIR="$ROOT_DIR/artifacts-linux"
FFMPEG_DIR="$ROOT_DIR/ffmpeg"

# Install general build tools
sudo apt-get update
sudo apt-get install -y build-essential pkg-config yasm git

# Create directories
mkdir -p "$DEPENDENCIES_DIR"
mkdir -p "$ARTIFACTS_DIR"

# Build and install libvorbis
cd "$DEPENDENCIES_DIR"
git clone https://gitlab.xiph.org/xiph/vorbis.git libvorbis
cd libvorbis
./autogen.sh
./configure --prefix="$ARTIFACTS_DIR" --enable-static --disable-shared
make
make install

# Build and install libmp3lame
cd "$DEPENDENCIES_DIR"
wget https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz
tar -xf lame-3.100.tar.gz
cd lame-3.100
./configure --prefix="$ARTIFACTS_DIR" --enable-static --disable-shared
make
make install

# Clone the ffmpeg repository
cd "$ROOT_DIR"
git clone --depth 1 --branch n7.0 https://github.com/ffmpeg/ffmpeg.git

# Compile FFmpeg
cd "$FFMPEG_DIR"
./configure --prefix="$ARTIFACTS_DIR" --enable-static \
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
            --enable-muxer=mp3
make
make install

echo "FFmpeg compiled and installed with static dependencies."

# Print ldd output for FFmpeg binary
cd "$ARTIFACTS_DIR"
echo "ldd ffmpeg result:"
ldd ffmpeg
