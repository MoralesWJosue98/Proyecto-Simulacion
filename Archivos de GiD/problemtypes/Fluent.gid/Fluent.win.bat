rem    OutputFile: %2\%1.info
rem    ErrorFile: %2\%1.err
rem    WarningFile: %2\%1.war

echo Mesh file written: '%2\%1-Fluent.msh' > %2\%1.war

rem if Fluent is installed it can be automatically started here:
rem %3\exec\Fluent.exe %2\%1-Fluent.msh
