
rem OutputFile: %2\%1.log
rem ErrorFile: %2\%1.err

delete %1.post.res
delete parameters_dolfin.xml
delete trianglemesh_dolfin-2.xml
delete tetmesh.xml
delete subdomains.xml

rename %1.dat parameters_dolfin.xml
rename %1-1.dat trianglemesh_dolfin-2.xml
rename %1-2.dat tetmesh.xml
rename %1-3.dat subdomains.xml

rem %3\FEniCS\runme.bat %2\%1


