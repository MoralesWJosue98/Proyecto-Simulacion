@ECHO OFF
rem set basename = %1
rem set directory = %2
rem set ProblemDirectory = %3
rem OutputFile: %2\%1.ans
rem ErrorFile: %2\%1.err
copy %1.dat %1.ans
erase %1.dat
