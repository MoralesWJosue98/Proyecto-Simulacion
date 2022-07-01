#!/bin/sh -f

rm -f "$2/$1.log"
rm -f "$2/$1.err"
rm -f "$2/$1.post.res"

# OutputFile: $2/$1.log
# ErrorFile: $2/$1.err

# delete the line before and uncomment the following line 
# to execute the program

KERNEL=`uname -s`
if [ $KERNEL = "Darwin" ]
then
KERNEL_NAME="macosx"
else
KERNEL_NAME="linux"
fi

PLATFORM=`uname -m`
if [ $PLATFORM = "x86_64" ]
then
KERNEL_PLATFORM="64"
else
KERNEL_PLATFORM="32"
fi

# FULL_CMAS2D_NAME="$3/cmas2d-${KERNEL_NAME}-${KERNEL_PLATFORM}_protected.exe"

FULL_CMAS2D_NAME="$3/cmas2d-${KERNEL_NAME}-${KERNEL_PLATFORM}.exe"

# _protected needs gid's libraries libcrypto.so.1.1 and libssl.so.1.1
gid_base_dir="$(dirname "$4")"
if [ $KERNEL = "Darwin" ]
then
    export DYLIB_LIBRARY_PATH="$gid_base_dir"/lib:$DYLIB_LIBRARY_PATH
    export DYLD_FALLBACK_LIBRARY_PATH="$gid_base_dir"/lib:$DYLD_FALLBACK_LIBRARY_PATH
else
    export LD_LIBRARY_PATH="$gid_base_dir"/lib:$LD_LIBRARY_PATH
    current_stdc=`ldd "$FULL_CMAS2D_NAME" 2>/dev/null | grep -w -o " /.*stdc++.*6 "`
    if [ "$current_stdc" != "" ]; then
	proper_gcc=`strings $current_stdc |grep GLIBCXX_3.4.21`
	if [ -z "$proper_gcc" ]; then
            export LD_LIBRARY_PATH="$gid_base_dir"/lib/old:$LD_LIBRARY_PATH
	fi
    fi
fi
"$FULL_CMAS2D_NAME" "$2/$1"

if [ ! -e "$2/$1.post.res" -o ! -s "$2/$1.post.res" ]
then
  echo "Program '$FULL_CMAS2D_NAME' failed" >> "$2/$1.err"
# else
#     rm -f "$2/$1.dat"
fi
