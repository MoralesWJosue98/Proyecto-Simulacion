@ECHO OFF
rem OutputFile: %2\%1.log
rem ErrorFile: %2\%1.err
del %2\%1.log
del %2\%1.post.res
del %2\%1.err
rem %3\cmas2d-windows.exe %2\%1
rem wsl.exe -- /home/escolano/GiDx64/gid-15.1.1d/problemtypes/Examples/cmas2d.gid/cmas2d-linux-64_unprotected.exe "/mnt/c/temp/test_cmas2d.gid/test_cmas2d"

tcl
lassign $argv dummy dummy basename modeldir problemtypedir
set modeldir2 [file normalize $modeldir]
set unit_letter [string index $modeldir2 0]
set linux_modelname [file join [string map [list $unit_letter: [string tolower $unit_letter]] $modeldir2] $basename]
exec wsl.exe -- "/home/escolano/GiDx64/gid-15.1.1d/problemtypes/Examples/cmas2d.gid/cmas2d-linux-64_unprotected.exe" "/mnt/$linux_modelname"
