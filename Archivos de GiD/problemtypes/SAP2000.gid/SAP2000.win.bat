rem OutputFile: %2\%1.log

delete %1.$2k
delete %1.log
delete %1.out
delete %1.s2k
delete %1.sdb
delete %1.post.res

rename %1.dat %1.s2k
"C:\Program Files\Computers and Structures\SAP2000 15\SAP2000.exe" %2\%1.s2k /RP1 S1 /K A
rem /C
