#!/bin/sh

set -e

# Work in the directory containing this script, since we're about to
# delete and recreate output directories.
cd "$(dirname "$0")"
if [ "$(basename "$PWD")" != C ]; then
    echo "translate.sh must live in an interface's C directory" >&2
    exit 1
fi
rm -rf ./usr ./Applications ./Library ./System

if [ -z "${FFIGEN}" ]; then
    HERE=$(pwd)
    if [ -x "${HERE}/../../../ffigen5/ffigen5" ]; then
        FFIGEN="${HERE}/../../../ffigen5/ffigen5"
    elif [ -x "${HERE}/../../ffigen5/ffigen5" ]; then
        FFIGEN="${HERE}/../../ffigen5/ffigen5"
    else
        FFIGEN=ffigen5
    fi
fi

if [ -z "${SDK}" ]; then
    SDK=$(xcrun --show-sdk-path)
fi
if [ -z "${TOOLCHAIN}" ]; then
    TOOLCHAIN=$(xcrun --show-toolchain-path)
fi
CLANG_VERSION=$(`xcrun --find clang` --version | head -n 1 | grep -o -E '[[:digit:]]*' | head -n 1)

platform_flags="-arch arm64 -isysroot ${SDK} -isystem ${TOOLCHAIN}/usr/lib/clang/${CLANG_VERSION}/include -F${SDK}/System/Library/Frameworks"

translate()
{
    includes=""
    other_flags=""

    while [ $# -gt 1 ]; do
        case "$1" in
            -include)
                includes="$includes -include $2"
                shift; shift
                ;;
            -*)
                other_flags="$other_flags $1"
                shift
                ;;
            *)
                ;;
        esac
    done
    output_dir=".`dirname $1`"
    mkdir -p "$output_dir"
    output_file="`basename $1 .h`.ffi"
    output_path="$output_dir/$output_file"
    echo "$1 $other_flags $includes" | sed "s|$SDK||g"
    if ! "$FFIGEN" $platform_flags $other_flags -x objective-c $includes "$1" -o "$output_path"; then
        echo "WARN: ffigen failed: $1" >&2
        rm -f "$output_path"
        exit 0
    fi
}

# ObjC runtime (C headers still useful under objective-c mode)
for h in \
  "${SDK}/usr/include/objc/objc.h" \
  "${SDK}/usr/include/objc/runtime.h" \
  "${SDK}/usr/include/objc/objc-runtime.h" \
  "${SDK}/usr/include/objc/objc-exception.h" \
  "${SDK}/usr/include/objc/NSObject.h" \
  "${SDK}/usr/include/objc/Protocol.h" \
  "${SDK}/System/Library/Frameworks/Foundation.framework/Headers/Foundation.h" \
  "${SDK}/System/Library/Frameworks/AppKit.framework/Headers/AppKit.h"
do
  translate "$h"
done
