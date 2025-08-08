#!/bin/bash

# vim: tabstop=4 shiftwidth=4 softtabstop=4
# -*- sh-basic-offset: 4 -*-

set -exuo pipefail

SRC=/src
QT_BRANCH_MAJOR="6.9"
QT_BRANCH_MINOR="1"
DEBIAN_VERSION=$(lsb_release -cs)
MAKE_CORES="$(expr $(nproc))"
BUILD_TARGET_PI=/build/qtpi-build
BUILT_TARGET_PI=/built

mkdir -p "$BUILT_TARGET_PI"
mkdir -p "$BUILD_TARGET_PI"

/usr/games/cowsay -f tux "Building QT version $QT_BRANCH_MAJOR.$QT_BRANCH_MINOR."

function build_qtpi () {
    local SRC_DIR="$SRC/qt6"

    pushd "$BUILD_TARGET_PI"

    cmake $SRC_DIR -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DINPUT_opengl=es2 \
        -DQT_FEATURE_kms=ON \
        -DQT_FEATURE_opengles2=ON \
        -DQT_FEATURE_opengles3=ON \
        -DQT_FEATURE_jpeg=OFF \
        -DQT_FEATURE_eglfs=ON \
        -DQT_FEATURE_xcb=ON \
        -DQT_FEATURE_xlib=ON \
        -DQT_FEATURE_pkg_config=ON \
        -DQT_FEATURE_pcre2=ON \
        -DQT_FEATURE_evdev=ON \
        -DQT_FEAATURE_tslib=ON \
        -DQT_FEATURE_system_freetype=ON \
        -DQT_FEATURE_fontconfig=ON \
        -DQT_FEATURE_glib=ON \
        -DQT_FEATURE_cups=OFF \
        -DQT_FEATURE_gtk3=OFF \
        -DQT_BUILD_EXAMPLES=OFF \
        -DQT_BUILD_TESTS=OFF \
        -DQT_QPA_DEFAULT_PLATFORM=eglfs \
        -DFEATURE_xcb_xlib=ON \
        -DBUILD_WITH_PCH=OFF \
        -DBUILD_qtdoc=OFF \
        -DBUILD_qt5compat=OFF \
        -DBUILD_qt3d=OFF \
        -DQT_DEBUG_FIND_PACKAGE=ON \
        -DQT_HOST_PATH=/build/qt-host \
        -DCMAKE_STAGING_PREFIX=/build/qt-raspi \
        -DCMAKE_INSTALL_PREFIX=/usr/local/qt6 \
        -DCMAKE_PREFIX_PATH=/build/qt-host/lib/cmake \
        -DCMAKE_TOOLCHAIN_FILE=/build/toolchain.cmake \
        -DQT_QMAKE_TARGET_MKSPEC=devices/linux-rasp-pi4-aarch64 \
        -DCMAKE_SYSROOT=/sysroot \
        -DQT_AVOID_CMAKE_ARCHIVING_API=ON \
        -DCMAKE_CXX_FLAGS="-O2 -Wno-dev"


    /usr/games/cowsay -f tux "Making QT Pi version $QT_BRANCH_MAJOR.$QT_BRANCH_MINOR."

    cmake --build . --parallel "$MAKE_CORES"

    /usr/games/cowsay -f tux "Installing QT Pi version $QT_BRANCH_MAJOR.$QT_BRANCH_MINOR."
    cmake --install .
    popd

    pushd /build
    tar cfz "$BUILT_TARGET_PI/qt6pi-$QT_BRANCH_MAJOR.$QT_BRANCH_MINOR-$DEBIAN_VERSION.tar.gz" qt-raspi
    sha256sum "$BUILT_TARGET_PI/qt6pi-$QT_BRANCH_MAJOR.$QT_BRANCH_MINOR-$DEBIAN_VERSION.tar.gz" > "$BUILT_TARGET_PI/qt6pi-$QT_BRANCH_MAJOR.$QT_BRANCH_MINOR-$DEBIAN_VERSION.tar.gz.sha256"
    popd

}

build_qtpi