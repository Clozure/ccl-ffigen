#!/bin/sh

# Sample script to be used as a basic for the script that would be
# located at <my-interface-dir>/C/translate.sh.

#set -e

# This script writes .ffi output files to a directory derived from the
# input include file's directory name.
#
# For example, when processing, for example, /usr/include/foo.h, it
# creates ./usr/include/foo.ffi.
#
# Change this as needed so that any already-generated output is
# cleaned out each time the script is run.
rm -rf ./usr

# If FFIGEN as defined in the environment, use that as the
# path to the ffigen5 binary.  Otherwise, assume that it's on the
# user's path.

if [ -z "${FFIGEN}" ]; then
    FFIGEN=ffigen5
fi

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

translate /usr/include/some-header.h
# you might need to pass some special flags for a particular header
translate -D_GNU_SOURCE /usr/include/some-other-header.h
# or you might need to include some other header
translate -include /usr/include/sys/types.h /usr/include/yet-another-header.h

# and so forth, for all the headers you want to process
