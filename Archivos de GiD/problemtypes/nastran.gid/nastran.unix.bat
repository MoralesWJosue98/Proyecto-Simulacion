#!/bin/csh -f

# ErrorFile: "$2/$1.err"
echo "To obtain the input file for NASTRAN can also use command Files->Export->Calculation file" > "$2/$1.err"
# if the nastran solver is available can be run setting here the command to start it
# "$3/nastran.exe" "$2/$1.nas"
