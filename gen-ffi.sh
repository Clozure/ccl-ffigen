#!/bin/sh

GEN=/home/rme/ffigen5/ffigen5

echo ++ ${1}
mkdir -p .`dirname ${1}`
OFILE=.`dirname ${1}`/`basename ${1} .h`.ffi
${GEN} -x c  -I/usr/include -include /usr/include/sys/types.h ${1} -o ${OFILE}

