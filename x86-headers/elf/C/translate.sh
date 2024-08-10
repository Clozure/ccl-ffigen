#!/bin/sh

# For x86-32 Linux

set -e
rm -rf ./usr

# If FFIGEN as defined in the environment, use that as the
# path to the ffigen5 binary.  Otherwise, assume that it's on the
# user's path.

if [ -z "${FFIGEN}" ]; then
    FFIGEN=ffigen5
fi

# I think I would like to define _GNU_SOURCE, but that exposes
# definitions that use "__attribute__ ((__transparent_union__))",
# and libclang doesn't appear to support that (it reports
# CXCursor_UnexposedAttr).
#
# The old gcc-4.0.0 ffigen (and the Lisp parse-ffi code), on the
# other hand, did support the transparent union definitions.

platform_flags="-D_DEFAULT_SOURCE -D_XOPEN_SOURCE=600 -m32"

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
    "$FFIGEN" $platform_flags $other_flags \
              -x c -isystem /usr/include $includes "$1" \
              -o "$output_path"
}

# as installed via "apt install libelf-dev"
translate /usr/include/libelf.h
