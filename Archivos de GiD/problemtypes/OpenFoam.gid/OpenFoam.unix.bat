#!/bin/bash

#    OutputFile: $2/$1.info
#    ErrorFile: $2/$1.err
#    WarningFile: $2/$1.war

echo "Mesh file written: '$2\points; $2\faces; $2\boundary; $2\owner; $2\neighbour" > $2\$1.war

# if OpenFoam is installed it can be automatically started here:
# $3/exec/OpenFoam $2/$1-OpenFoam.msh
