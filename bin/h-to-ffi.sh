#!/bin/sh
FFIGEN_DIR=`dirname $0`/../ffigen
CFLAGS="-isystem ${FFIGEN_DIR}/include -isystem /usr/include -isystem /usr/local/include -quiet -fffigen ${CFLAGS}"
GEN=${FFIGEN_DIR}/bin/ffigen


while [ $# -gt 1 ]
do 
    case ${1} in
      -pthread*)
        CFLAGS="${CFLAGS} -D_REENTRANT"
        shift
        ;;
      -x)
        shift
        shift
        ;;
      *)
        CFLAGS="${CFLAGS} ${1}"
        shift
        ;;
   esac
done

echo +++ ${1}
mkdir -p .`dirname ${1}`
OFILE=.`dirname ${1}`/`basename ${1} .h`.ffi
${GEN} ${CFLAGS} -o ${OFILE} ${1}

