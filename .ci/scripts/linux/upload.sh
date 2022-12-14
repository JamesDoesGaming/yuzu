#!/bin/bash -ex

# SPDX-FileCopyrightText: 2019 yuzu Emulator Project
# SPDX-License-Identifier: GPL-2.0-or-later

. .ci/scripts/common/pre-upload.sh

APPIMAGE_NAME="yuzu-${GITDATE}-${GITREV}.AppImage"
REV_NAME="yuzu-linux-${GITDATE}-${GITREV}"
ARCHIVE_NAME="${REV_NAME}.tar.xz"
COMPRESSION_FLAGS="-cJvf"

if [ "${RELEASE_NAME}" = "mainline" ]; then
    DIR_NAME="${REV_NAME}"
else
    DIR_NAME="${REV_NAME}_${RELEASE_NAME}"
fi

mkdir "$DIR_NAME"

cp build/bin/yuzu-cmd "$DIR_NAME"
cp build/bin/yuzu "$DIR_NAME"

# Build an AppImage
cd build

wget -nc https://github.com/yuzu-emu/ext-linux-bin/raw/main/appimage/appimagetool-x86_64.AppImage
chmod 755 appimagetool-x86_64.AppImage

# if FUSE is not available, then fallback to extract and run
if ! ./appimagetool-x86_64.AppImage --version; then
    export APPIMAGE_EXTRACT_AND_RUN=1
fi

if [ "${RELEASE_NAME}" = "mainline" ]; then
    # Generate update information if releasing to mainline
    ./appimagetool-x86_64.AppImage -u "gh-releases-zsync|yuzu-emu|yuzu-${RELEASE_NAME}|latest|yuzu-*.AppImage.zsync" AppDir "${APPIMAGE_NAME}"
else
    ./appimagetool-x86_64.AppImage AppDir "${APPIMAGE_NAME}"
fi
cd ..

# Copy the AppImage and update info to the artifacts directory and avoid compressing it
cp "build/${APPIMAGE_NAME}" "${ARTIFACTS_DIR}/"
if [ -f "build/${APPIMAGE_NAME}.zsync" ]; then
    cp "build/${APPIMAGE_NAME}.zsync" "${ARTIFACTS_DIR}/"
fi

. .ci/scripts/common/post-upload.sh
