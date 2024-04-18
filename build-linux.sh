#!/bin/bash

ROOT_DIR="$(pwd)"
DEPENDENCIES_DIR="$ROOT_DIR/dependencies"
ARTIFACTS_DIR="$ROOT_DIR/artifacts-linux"
FFMPEG_DIR="$ROOT_DIR/ffmpeg"
LOG_DIR="$ARTIFACTS_DIR/logs"
PATH="$ARTIFACTS_DIR/bin:$PATH"
PKG_CONFIG_PATH="$ARTIFACTS_DIR/lib/pkgconfig" 

create_directory() {
    local dir=$1

    # Check if directory exists
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
}

build_nasm() {
    cd "$DEPENDENCIES_DIR"

    if [ -d "nasm-2.16.01" ]; then
        echo "Directory already exists. Cleaning and reconfiguring..."
        cd nasm-2.16.01
        make clean
        ./configure --clean
    else
        echo "Downloading and extracting tar file..."
        wget https://www.nasm.us/pub/nasm/releasebuilds/2.16.01/nasm-2.16.01.tar.bz2
        tar xjvf nasm-2.16.01.tar.bz2
        cd nasm-2.16.01
        ./autogen.sh
    fi
    

    ./configure --prefix="$ARTIFACTS_DIR" --bindir="$ARTIFACTS_DIR/bin" && \
    make -j$(nproc)
    make install
}

build_libdrm() {
    cd "$DEPENDENCIES_DIR"

    if [ -d "libdrm" ]; then
        # Repository already cloned. Cleaning and reconfiguring
        cd libdrm
        git pull
    else
        # Cloning repository
        git clone https://gitlab.freedesktop.org/mesa/drm.git libdrm
        cd libdrm
    fi

    # Configure and compile libdrm
    meson builddir/ --prefix="$ARTIFACTS_DIR"
    ninja -C builddir/ install
}

build_libasound() {
    cd "$DEPENDENCIES_DIR"

    if [ -d "alsa-lib" ]; then
        # Repository already cloned. Cleaning and reconfiguring
        cd alsa-lib
        git pull
    else
        # Cloning repository
        git clone https://github.com/alsa-project/alsa-lib.git alsa-lib
        cd alsa-lib
    fi

    # Configure and compile libasound
    ./gitcompile
    ./configure --prefix="$ARTIFACTS_DIR" --disable-shared
    make -j$(nproc)
    make install
}

build_libxv() {
    cd "$DEPENDENCIES_DIR"

    if [ -d "libXv" ]; then
        # Repository already cloned. Cleaning and reconfiguring
        cd libXv
        git pull
    else
        # Cloning repository
        git clone https://gitlab.freedesktop.org/xorg/lib/libXv.git libXv
        cd libXv
    fi

    # Configure and compile libXv
    ./autogen.sh
    ./configure --prefix="$ARTIFACTS_DIR" --disable-shared
    make -j$(nproc)
    make install
}

build_libxext() {
    cd "$DEPENDENCIES_DIR"

    if [ -d "libXext" ]; then
        # Repository already cloned. Cleaning and reconfiguring
        cd libXext
        git pull
    else
        # Cloning repository
        git clone git://anongit.freedesktop.org/xorg/lib/libXext libXext
        cd libXext
    fi

    # Configure and compile libXext
    ./autogen.sh
    ./configure --prefix="$ARTIFACTS_DIR" --disable-shared
    make -j$(nproc)
    make install
}

build_libx11() {
    cd "$DEPENDENCIES_DIR"

    if [ -d "libX11" ]; then
        # Repository already cloned. Cleaning and reconfiguring
        cd libX11
        git pull
    else
        # Cloning repository
        git clone git://anongit.freedesktop.org/xorg/lib/libX11 libX11
        cd libX11
    fi

    # Configure and compile libX11
    ./autogen.sh
    ./configure --prefix="$ARTIFACTS_DIR" --disable-shared
    make -j$(nproc)
    make install
}

build_libbsd() {
    cd "$DEPENDENCIES_DIR"

    if [ -d "libbsd" ]; then
        # Repository already cloned. Cleaning and reconfiguring
        cd libbsd
        git pull
    else
        # Cloning repository
        git clone https://gitlab.freedesktop.org/libbsd/libbsd.git libbsd
        cd libbsd
    fi

    # Configure and compile libbsd
    ./autogen
    ./configure --prefix="$ARTIFACTS_DIR" --disable-shared --with-crypto=openssl
    make -j$(nproc)
    make install
}




build_x264() {
    cd "$DEPENDENCIES_DIR"

    if [ -d "x264" ]; then
        # Repository already cloned. Cleaning and reconfiguring
        cd x264
        make clean
        ./configure --clean
    else
        # Cloning repository
        git -C x264 pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/x264.git
        cd x264
    fi    

    ./configure --prefix="$ARTIFACTS_DIR" --bindir="$ARTIFACTS_DIR/bin" --enable-static --enable-pic
    make -j$(nproc)
    make install    
}

build_x265() {
    cd "$DEPENDENCIES_DIR"

    if [ -d "multicoreware*/build/linux" ]; then
        echo "Directory already exists. Cleaning and reconfiguring..."
        cd multicoreware*/build/linux
        make clean
    else
        echo "Downloading and extracting tar file..."
        wget -O x265.tar.bz2 https://bitbucket.org/multicoreware/x265_git/get/master.tar.bz2
        tar xjvf x265.tar.bz2
        cd multicoreware*/build/linux
    fi    
    
    
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$ARTIFACTS_DIR" -DENABLE_SHARED=off ../../source
    make -j$(nproc)
    make install    
}

build_libvorbis() {
    cd "$DEPENDENCIES_DIR"

    if [ -d "libvorbis" ]; then
        # Repository already cloned. Cleaning and reconfiguring
        cd libvorbis
    else
        # Cloning repository
        git clone https://gitlab.xiph.org/xiph/vorbis.git libvorbis
        cd libvorbis
        ./autogen.sh
    fi

    ./configure --prefix="$ARTIFACTS_DIR"  --bindir="$ARTIFACTS_DIR/bin"--enable-static 
    make -j$(nproc)
    make install
}

build_lame() {
    cd "$DEPENDENCIES_DIR"

    if [ -d "lame-3.100" ]; then
        echo "Directory already exists. Cleaning and reconfiguring..."
        cd lame-3.100
        make clean
        ./configure --clean
    else
        echo "Downloading and extracting tar file..."
        wget https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz
        tar -xf lame-3.100.tar.gz
        cd lame-3.100
    fi
    
    ./configure --prefix="$ARTIFACTS_DIR" --bindir="$ARTIFACTS_DIR/bin" --enable-static
    make -j$(nproc)
    make install
}

build_ffmpeg() {
    cd "$ROOT_DIR"

    if [ -d "$FFMPEG_DIR" ]; then
        # Repository already cloned. Cleaning and reconfiguring
        cd "$FFMPEG_DIR"
        make clean
    else
        # Cloning repository
        git clone --depth 1 --branch n7.0 https://github.com/ffmpeg/ffmpeg.git
        cd "$FFMPEG_DIR"
    fi    

    # Compile FFmpeg
    ./configure \
        --prefix="$ARTIFACTS_DIR" \
        --pkg-config-flags="--static" \
        --extra-cflags="-I$ARTIFACTS_DIR/include" \
        --extra-ldflags="-L$ARTIFACTS_DIR/lib" \
        --extra-libs="-lpthread -lm" \
        --ld="g++" \
        --bindir="$ARTIFACTS_DIR/bin" \
        --enable-static \
        --disable-shared \
        --disable-ffprobe \
        --disable-ffplay \
        --disable-doc \
        --disable-encoders \
        --disable-decoders \
        --disable-muxers \
        --enable-libvorbis \
        --enable-libmp3lame \
        --enable-encoder=pcm_u8 \
        --enable-decoder=pcm_u8 \
        --enable-encoder=pcm_f32le \
        --enable-decoder=pcm_f32le \
        --enable-encoder=pcm_s16le \
        --enable-decoder=pcm_s16le \
        --enable-encoder=adpcm_ms \
        --enable-decoder=adpcm_ms \
        --enable-encoder=wmav2 \
        --enable-decoder=wmav2 \
        --enable-encoder=adpcm_ima_wav \
        --enable-decoder=adpcm_ima_wav \
        --enable-encoder=aac \
        --enable-decoder=aac \
        --enable-encoder=mp4 \
        --enable-decoder=mp4 \
        --enable-muxer=wav \
        --enable-muxer=asf \
        --enable-muxer=ipod \
        --enable-muxer=ogg \
        --enable-muxer=mp3 
    make -j$(nproc)
    make install
}

output_ldd() {
    cd "$ARTIFACTS_DIR/bin"
    echo "ldd ffmpeg result:"
    ldd ffmpeg
}


# Install general build tools
sudo apt-get update -qq
sudo apt-get -y -qq install \
    autoconf \
    automake \
    build-essential \
    cmake \
    git-core \
    libmd-dev \
    libtool \
    meson \
    ninja-build \
    wget \
    xutils-dev

# Create directories
create_directory "$DEPENDENCIES_DIR"
create_directory "$ARTIFACTS_DIR"
create_directory "$LOG_DIR"
build_nasm 2>&1 | tee "$LOG_DIR/nasm-build.log"
build_libdrm 2>&1 | tee "$LOG_DIR/libdrm-build.log"
build_libasound 2>&1 | tee "$LOG_DIR/libsound-build.log"
build_libxv 2>&1 | tee "$LOG_DIR/libxv-build.log"
build_libxext 2>&1 | tee "$LOG_DIR/libxext-build.log"
build_libx11 2>&1 | tee "$LOG_DIR/libx11-build.log"
build_libbsd 2>&1 | tee "$LOG_DIR/libbsd-build.log"
build_libvorbis 2>&1 | tee "$LOG_DIR/libvorbis-build.log"
build_lame 2>&1 | tee "$LOG_DIR/lame-build.log"
build_ffmpeg 2>&1 | tee "$LOG_DIR/ffmpeg-build.log"
output_ldd 2>&1 | tee "$LOG_DIR/ldd.log"