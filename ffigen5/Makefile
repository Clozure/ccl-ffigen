# SPDX-License-Identifier: Apache-2.0

# Note that it's fine to use a 64-bit version of ffigen5 to
# process header files for 32-bit binaries. (Pass the -m32 flag.)

#CC = /usr/local/opt/llvm/bin/clang
#LIBDIR = /usr/local/opt/llvm/lib
#INCDIR = /usr/local/opt/llvm/include

# for OmniOS
# from the extra.omnios publisher
# pkg install llvm-15
# pkg install clang-15

#CC = /opt/ooce/llvm-15/bin/clang
#LIBDIR = /opt/ooce/llvm-15/lib
#INCDIR = /opt/ooce/llvm-15/include

# for FreeBSD
# Get libclang with:
# pkg install llvm15-lite

CC = /usr/local/llvm15/bin/clang
LIBDIR = /usr/local/llvm15/lib
INCDIR = /usr/local/llvm15/include

CFLAGS = -I$(INCDIR) -g
OBJS = ffigen5.o

ffigen5: $(OBJS) Makefile
	$(CC) -o ffigen5 $(OBJS) -L$(LIBDIR) -lclang

clean:
	rm -f *.o ffigen5

