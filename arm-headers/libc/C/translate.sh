#!/bin/sh

# For 32-bit ARM Linux

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
# The old gcc-4.0.0 ffigen, on the other hand, does support the
# transparent union definitions.  (And there is support for it in
# the parse-ffi Lisp code.)

platform_flags="-D_DEFAULT_SOURCE -D_XOPEN_SOURCE=600 \
                    -m32 -isystem /usr/include/arm-linux-gnueabihf"

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

# list of posix headers
# from http://pubs.opengroup.org/onlinepubs/9699919799/idx/head.html

translate /usr/include/aio.h
translate /usr/include/arpa/inet.h
translate /usr/include/assert.h
translate /usr/include/complex.h
translate /usr/include/cpio.h
translate /usr/include/ctype.h
translate /usr/include/dirent.h
# need struct Dl_info & friends
translate -D_GNU_SOURCE /usr/include/dlfcn.h
translate /usr/include/errno.h
translate /usr/include/fcntl.h
translate /usr/include/fenv.h
#translate /usr/include/float.h
translate /usr/include/fmtmsg.h
translate /usr/include/fnmatch.h
translate /usr/include/ftw.h
translate /usr/include/glob.h
translate /usr/include/grp.h
translate /usr/include/iconv.h
translate /usr/include/inttypes.h
#translate /usr/include/iso646.h
translate /usr/include/langinfo.h
translate /usr/include/libgen.h
translate /usr/include/limits.h
translate /usr/include/locale.h
translate /usr/include/math.h
translate /usr/include/monetary.h
translate /usr/include/mqueue.h
#translate /usr/include/ndbm.h
translate /usr/include/net/if.h
translate /usr/include/netdb.h
translate /usr/include/netinet/in.h
translate /usr/include/netinet/tcp.h
translate /usr/include/nl_types.h
translate /usr/include/poll.h
translate /usr/include/pthread.h
translate /usr/include/pwd.h
translate /usr/include/regex.h
translate /usr/include/sched.h
translate /usr/include/search.h
translate /usr/include/semaphore.h
translate /usr/include/setjmp.h
translate /usr/include/signal.h
translate /usr/include/spawn.h
#translate /usr/include/stdarg.h
#translate /usr/include/stdbool.h
#translate /usr/include/stddef.h
translate /usr/include/stdint.h
translate /usr/include/stdio.h
translate /usr/include/stdlib.h
translate /usr/include/string.h
translate /usr/include/strings.h
# there's no /usr/include/sys...
translate /usr/include/arm-linux-gnueabihf/sys/ipc.h
translate /usr/include/arm-linux-gnueabihf/sys/mman.h
translate /usr/include/arm-linux-gnueabihf/sys/msg.h
translate /usr/include/arm-linux-gnueabihf/sys/resource.h
translate /usr/include/arm-linux-gnueabihf/sys/select.h
translate /usr/include/arm-linux-gnueabihf/sys/sem.h
translate /usr/include/arm-linux-gnueabihf/sys/shm.h
translate /usr/include/arm-linux-gnueabihf/sys/socket.h
translate /usr/include/arm-linux-gnueabihf/sys/stat.h
translate /usr/include/arm-linux-gnueabihf/sys/statvfs.h
translate /usr/include/arm-linux-gnueabihf/sys/time.h
translate /usr/include/arm-linux-gnueabihf/sys/times.h
translate /usr/include/arm-linux-gnueabihf/sys/types.h
translate /usr/include/arm-linux-gnueabihf/sys/uio.h
translate /usr/include/arm-linux-gnueabihf/sys/un.h
translate /usr/include/arm-linux-gnueabihf/sys/utsname.h
translate /usr/include/arm-linux-gnueabihf/sys/wait.h
translate /usr/include/syslog.h
translate /usr/include/tar.h
translate /usr/include/termios.h
#translate /usr/include/tgmath.h
translate /usr/include/time.h
translate /usr/include/ulimit.h
translate /usr/include/unistd.h
translate /usr/include/utime.h
translate /usr/include/utmpx.h
translate /usr/include/wchar.h
translate /usr/include/wctype.h
translate /usr/include/wordexp.h

# additional headers needed to compile ccl
translate /usr/include/sysexits.h
# need _GNU_SOURCE for REG_RIP, REG_EFL, etc.
translate -D_GNU_SOURCE /usr/include/ucontext.h
translate /usr/include/ifaddrs.h
translate /usr/include/link.h
translate /usr/include/elf.h

# for leaks.lisp
translate /usr/include/mcheck.h
translate /usr/include/malloc.h

# for pty.lisp
translate /usr/include/pty.h
