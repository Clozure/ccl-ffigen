#!/bin/sh
#
# Generate .ffi files for AVKit.
#
# Usage: ./translate.sh
#
# This runs ffigen5 on AVKit.h, which includes everything AVKit
# depends on (Foundation, AppKit, AVFoundation, ...).  The output goes
# in a directory tree under this one that mirrors the SDK path, i.e.,
#
#   ./Applications/Xcode.app/.../AVKit.framework/Headers/AVKit.ffi
#
# To build CCL's interface databases from it, put this C directory at
# ccl/darwin-arm64-headers/avkit/C, and then, in CCL, do:
#
#   (require "PARSE-FFI")
#   (ccl::parse-standard-ffi-files :avkit)
#   (ccl::parse-standard-ffi-files :avkit)  ;do it a second time
#
# Programs can then use (use-interface-dir :avkit).
#
# To make interfaces for some other framework, copy this directory and
# change the header named at the end of this file.
#
# Environment variables (all optional):
#   FFIGEN  path to the ffigen5 executable
#   SDK     macOS SDK path (default: xcrun --show-sdk-path)

set -e

# Work in the directory containing this script, since we're about to
# delete and recreate output directories.
cd "$(dirname "$0")"
if [ "$(basename "$PWD")" != C ]; then
    echo "translate.sh must live in an interface's C directory" >&2
    exit 1
fi
rm -rf ./usr ./Applications ./Library ./System

if [ -z "$FFIGEN" ]; then
    if [ -x ../../../ffigen5/ffigen5 ]; then
        FFIGEN=$(pwd)/../../../ffigen5/ffigen5
    elif command -v ffigen5 >/dev/null; then
        FFIGEN=ffigen5
    else
        echo "Can't find ffigen5; set FFIGEN to its path." >&2
        exit 1
    fi
fi

SDK=${SDK:-$(xcrun --show-sdk-path)}
CLANG_INCLUDE=$(xcrun clang -print-resource-dir)/include

translate()
{
    header=$1
    output_dir=.$(dirname "$header")
    output_path=$output_dir/$(basename "$header" .h).ffi

    echo "$header" | sed "s|$SDK||g"
    mkdir -p "$output_dir"
    if ! "$FFIGEN" -arch arm64 -isysroot "$SDK" -isystem "$CLANG_INCLUDE" \
            -F"$SDK/System/Library/Frameworks" -x objective-c \
            "$header" -o "$output_path"; then
        echo "ffigen5 failed on $header" >&2
        rm -f "$output_path"
        exit 1
    fi
}

translate "$SDK/System/Library/Frameworks/AVKit.framework/Headers/AVKit.h"
