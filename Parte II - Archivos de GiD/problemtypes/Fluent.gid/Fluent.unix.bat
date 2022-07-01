#!/bin/bash -f

#    OutputFile: $2/$1.info
#    ErrorFile: $2/$1.err
#    WarningFile: $2/$1.war


echo "Mesh file written: '$2/$1-Fluent.msh'" > $2/$1.war

# if Fluent is installed it can be automatically started here:
# $3/exec/Fluent $2/$1-Fluent.msh