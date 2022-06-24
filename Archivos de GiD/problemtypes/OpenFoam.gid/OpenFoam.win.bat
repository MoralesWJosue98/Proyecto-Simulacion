rem    OutputFile: %2\%1.info
rem    ErrorFile: %2\%1.err
rem    WarningFile: %2\%1.war

echo Mesh file written: '%2\points; %2\faces; %2\boundary; %2\owner; %2\neighbour' > %2\%1.war

rem if OpenFoam is installed it can be automatically started here:
rem %3\exec\OpenFoam.exe %2\%1-OpenFoam.msh
