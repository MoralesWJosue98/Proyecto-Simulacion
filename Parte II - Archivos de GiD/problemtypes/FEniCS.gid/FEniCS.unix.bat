#!/bin/bash

# OutputFile: "$2/$1.log"
# ErrorFile: "$2/$1.err"

rm -f "$1.post.res"
rm -f parameters_dolfin.xml
rm -f trianglemesh_dolfin-2.xml
rm -f tetmesh.xml
rm -f subdomains.xml

mv "$1.dat" parameters_dolfin.xml
mv "$1-1.dat" trianglemesh_dolfin-2.xml
mv "$1-2.dat" tetmesh.xml
mv "$1-3.dat" subdomains.xml

# "$3/runme" "$2/$1"
