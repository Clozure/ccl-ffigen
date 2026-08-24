#!/bin/sh

set -e
rm -rf ./usr ./Applications ./Library ./System

if [ -z "${FFIGEN}" ]; then
    HERE=$(cd "$(dirname "$0")" && pwd)
    if [ -x "${HERE}/../../../ffigen5/ffigen5" ]; then
        FFIGEN="${HERE}/../../../ffigen5/ffigen5"
    elif [ -x "${HERE}/../../ffigen5/ffigen5" ]; then
        FFIGEN="${HERE}/../../ffigen5/ffigen5"
    else
        FFIGEN=ffigen5
    fi
fi

if [ -z "${FILTER_FFI}" ]; then
    HERE=$(cd "$(dirname "$0")" && pwd)
    if [ -x "${HERE}/../../../filter_ffi.py" ]; then
        FILTER_FFI="${HERE}/../../../filter_ffi.py"
    elif [ -x "${HERE}/../../filter_ffi.py" ]; then
        FILTER_FFI="${HERE}/../../filter_ffi.py"
    else
        echo "Cannot find filter_ffi.py" >&2
        exit 1
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
    echo $1 $other_flags $includes
    if ! "$FFIGEN" $platform_flags $other_flags -x objective-c $includes "$1" -o "$output_path"; then
        echo "WARN: ffigen failed: $1" >&2
        rm -f "$output_path"
        exit 0
    fi
    if [ -f "$output_path" ]; then
        FILTER_FFI_MACROS=frameworks python3 $FILTER_FFI "$output_path"
    fi
}

translate "${SDK}/System/Library/Frameworks/QuartzCore.framework/Headers/QuartzCore.h"
