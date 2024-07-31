# SPDX-License-Identifier: Apache-2.0

# Note that it's fine to use a 64-bit version of ffigen5 to
# process header files for 32-bit binaries. (Pass the -m32 flag.)

#CC = /usr/local/opt/llvm/bin/clang
#LIBDIR = /usr/local/opt/llvm/lib
#INCDIR = /usr/local/opt/llvm/include

## For Ubuntu Linux
# Get libclang with:
# apt install libclang-dev

# The LLVM version installed by libclang-dev may change. Update
# as needed.
LLVM_VERSION = 15

CC = cc
# or you could use clang if you have it installed
#CC = /usr/lib/llvm-$(LLVM_VERSION)/bin/clang
LIBDIR = /usr/lib/llvm-$(LLVM_VERSION)/lib
INCDIR = /usr/lib/llvm-$(LLVM_VERSION)/include
EXTRA_FLAGS=

## for OmniOS
# from the extra.omnios publisher
# pkg install llvm-15
# pkg install clang-15

#CC = /opt/ooce/llvm-15/bin/clang
#LIBDIR = /opt/ooce/llvm-15/lib
#INCDIR = /opt/ooce/llvm-15/include
#EXTRA_FLAGS = -Wl,-R,$(LIBDIR)

## for FreeBSD
# Get libclang with:
# pkg install llvm15-lite

#CC = /usr/local/llvm15/bin/clang
#LIBDIR = /usr/local/llvm15/lib
#INCDIR = /usr/local/llvm15/include

CFLAGS = -I$(INCDIR) -g
OBJS = ffigen5.o

ffigen5: $(OBJS) Makefile
	$(CC) $(EXTRA_FLAGS) -o ffigen5 $(OBJS) -L$(LIBDIR) -lclang

clean:
	rm -f *.o ffigen5

