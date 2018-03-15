#!/bin/sh

rm -rf usr

# list of posix headers
# from http://pubs.opengroup.org/onlinepubs/9699919799/idx/head.html

gen-ffi.sh /usr/include/aio.h
gen-ffi.sh /usr/include/arpa/inet.h
gen-ffi.sh /usr/include/assert.h
gen-ffi.sh /usr/include/complex.h
gen-ffi.sh /usr/include/cpio.h
gen-ffi.sh /usr/include/ctype.h
gen-ffi.sh /usr/include/dirent.h
gen-ffi.sh /usr/include/dlfcn.h
gen-ffi.sh /usr/include/errno.h
gen-ffi.sh /usr/include/fcntl.h
gen-ffi.sh /usr/include/fenv.h
gen-ffi.sh /usr/include/float.h
gen-ffi.sh /usr/include/fmtmsg.h
gen-ffi.sh /usr/include/fnmatch.h
gen-ffi.sh /usr/include/ftw.h
gen-ffi.sh /usr/include/glob.h
gen-ffi.sh /usr/include/grp.h
gen-ffi.sh /usr/include/iconv.h
gen-ffi.sh /usr/include/inttypes.h
gen-ffi.sh /usr/include/iso646.h
gen-ffi.sh /usr/include/langinfo.h
gen-ffi.sh /usr/include/libgen.h
gen-ffi.sh /usr/include/limits.h
gen-ffi.sh /usr/include/locale.h
gen-ffi.sh /usr/include/math.h
gen-ffi.sh /usr/include/monetary.h
gen-ffi.sh /usr/include/mqueue.h
gen-ffi.sh /usr/include/ndbm.h
gen-ffi.sh /usr/include/net/if.h
gen-ffi.sh /usr/include/netdb.h
gen-ffi.sh /usr/include/netinet/in.h
gen-ffi.sh /usr/include/netinet/tcp.h
gen-ffi.sh /usr/include/nl_types.h
gen-ffi.sh /usr/include/poll.h
gen-ffi.sh /usr/include/pthread.h
gen-ffi.sh /usr/include/pwd.h
gen-ffi.sh /usr/include/regex.h
gen-ffi.sh /usr/include/sched.h
gen-ffi.sh /usr/include/search.h
gen-ffi.sh /usr/include/semaphore.h
gen-ffi.sh /usr/include/setjmp.h
gen-ffi.sh /usr/include/signal.h
gen-ffi.sh /usr/include/spawn.h
gen-ffi.sh /usr/include/stdarg.h
gen-ffi.sh /usr/include/stdbool.h
gen-ffi.sh /usr/include/stddef.h
gen-ffi.sh /usr/include/stdint.h
gen-ffi.sh /usr/include/stdio.h
gen-ffi.sh /usr/include/stdlib.h
gen-ffi.sh /usr/include/string.h
gen-ffi.sh /usr/include/strings.h
gen-ffi.sh /usr/include/sys/ipc.h
gen-ffi.sh /usr/include/sys/mman.h
gen-ffi.sh /usr/include/sys/msg.h
gen-ffi.sh /usr/include/sys/resource.h
gen-ffi.sh /usr/include/sys/select.h
gen-ffi.sh /usr/include/sys/sem.h
gen-ffi.sh /usr/include/sys/shm.h
gen-ffi.sh /usr/include/sys/socket.h
gen-ffi.sh /usr/include/sys/stat.h
gen-ffi.sh /usr/include/sys/statvfs.h
gen-ffi.sh /usr/include/sys/time.h
gen-ffi.sh /usr/include/sys/times.h
gen-ffi.sh /usr/include/sys/types.h
gen-ffi.sh /usr/include/sys/uio.h
gen-ffi.sh /usr/include/sys/un.h
gen-ffi.sh /usr/include/sys/utsname.h
gen-ffi.sh /usr/include/sys/wait.h
gen-ffi.sh /usr/include/syslog.h
gen-ffi.sh /usr/include/tar.h
gen-ffi.sh /usr/include/termios.h
gen-ffi.sh /usr/include/tgmath.h
gen-ffi.sh /usr/include/time.h
gen-ffi.sh /usr/include/ulimit.h
gen-ffi.sh /usr/include/unistd.h
gen-ffi.sh /usr/include/utime.h
gen-ffi.sh /usr/include/utmpx.h
gen-ffi.sh /usr/include/wchar.h
gen-ffi.sh /usr/include/wctype.h
gen-ffi.sh /usr/include/wordexp.h

# additional headers needed to compile ccl
gen-ffi.sh /usr/include/sysexits.h
gen-ffi.sh /usr/include/sys/sysctl.h
gen-ffi.sh /usr/include/machine/fpu.h
gen-ffi.sh /usr/include/machine/ucontext.h
gen-ffi.sh /usr/include/ucontext.h
gen-ffi.sh /usr/include/ifaddrs.h
gen-ffi.sh /usr/include/sys/elf.h
gen-ffi.sh /usr/include/sys/link_elf.h

