#!/bin/sh -f

rm -f "$2/$1.log"
rm -f "$2/$1.post.res"
rm -f "$2/$1.err"

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

"$3/cmas2d_iga-$KERNEL_NAME-$KERNEL_PLATFORM.exe" "$2/$1"
#echo "running  $3/cmas2d_iga-$KERNEL_NAME-$KERNEL_PLATFORM.exe $2/$1"
if [ ! -e "$2/$1.post.res" -o ! -s "$2/$1.post.res" ]
then
  echo "Program '$3/cmas2d_iga-$KERNEL_NAME-$KERNEL_PLATFORM.exe' failed" >> "$2/$1.err"
# else
#     leave the .dat file as example
#     rm -f "$2/$1.dat"
fi
