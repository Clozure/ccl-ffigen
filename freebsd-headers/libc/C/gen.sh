#!/bin/sh

# For FreeBSD 32-bit x86

set -e

rm -rf ./usr

# If FFIGEN as defined in the environment, use that as the
# path to the ffigen5 binary.  Otherwise, assume that it's on the
# user's path.

if [ -z "${FFIGEN}" ]; then
    FFIGEN=ffigen5
fi

translate()
{
    output_dir=".`dirname $1`"
    mkdir -p "$output_dir"
    output_file="`basename $1 .h`.ffi"
    output_path="$output_dir/$output_file"
    echo $1
    "$FFIGEN" -m32 -x c -I/usr/include -include /usr/include/sys/types.h "$1" -o "$output_path"
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
translate /usr/include/dlfcn.h
translate /usr/include/errno.h
translate /usr/include/fcntl.h
translate /usr/include/fenv.h
translate /usr/include/float.h
translate /usr/include/fmtmsg.h
translate /usr/include/fnmatch.h
translate /usr/include/ftw.h
translate /usr/include/glob.h
translate /usr/include/grp.h
translate /usr/include/iconv.h
translate /usr/include/inttypes.h
translate /usr/include/iso646.h
translate /usr/include/langinfo.h
translate /usr/include/libgen.h
translate /usr/include/limits.h
translate /usr/include/locale.h
translate /usr/include/math.h
translate /usr/include/monetary.h
translate /usr/include/mqueue.h
translate /usr/include/ndbm.h
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
translate /usr/include/stdarg.h
translate /usr/include/stdbool.h
translate /usr/include/stddef.h
translate /usr/include/stdint.h
translate /usr/include/stdio.h
translate /usr/include/stdlib.h
translate /usr/include/string.h
translate /usr/include/strings.h
translate /usr/include/sys/ipc.h
translate /usr/include/sys/mman.h
translate /usr/include/sys/msg.h
translate /usr/include/sys/resource.h
translate /usr/include/sys/select.h
translate /usr/include/sys/sem.h
translate /usr/include/sys/shm.h
translate /usr/include/sys/socket.h
translate /usr/include/sys/stat.h
translate /usr/include/sys/statvfs.h
translate /usr/include/sys/time.h
translate /usr/include/sys/times.h
translate /usr/include/sys/types.h
translate /usr/include/sys/uio.h
translate /usr/include/sys/un.h
translate /usr/include/sys/utsname.h
translate /usr/include/sys/wait.h
translate /usr/include/syslog.h
translate /usr/include/tar.h
translate /usr/include/termios.h
translate /usr/include/tgmath.h
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
translate /usr/include/sys/sysctl.h
translate /usr/include/machine/fpu.h
translate /usr/include/machine/ucontext.h
translate /usr/include/ucontext.h
translate /usr/include/ifaddrs.h
translate /usr/include/sys/elf.h
translate /usr/include/sys/link_elf.h

