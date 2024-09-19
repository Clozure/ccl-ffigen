#!/bin/sh

# For x86-32 FreeBSD

set -e
rm -rf ./usr

# If FFIGEN as defined in the environment, use that as the
# path to the ffigen5 binary.  Otherwise, assume that it's on the
# user's path.

if [ -z "${FFIGEN}" ]; then
    FFIGEN=ffigen5
fi

platform_flags="-m32"

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

# FreeBSD's libmd library

translate -include /usr/include/sys/types.h /usr/include/md4.h
translate -include /usr/include/sys/types.h /usr/include/md5.h
translate /usr/include/ripemd.h
translate /usr/include/sha.h
translate /usr/include/sha224.h
translate /usr/include/sha256.h
translate /usr/include/sha384.h
translate /usr/include/sha512.h
translate /usr/include/sha512t.h
translate /usr/include/skein.h

