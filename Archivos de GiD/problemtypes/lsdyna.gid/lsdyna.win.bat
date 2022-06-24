rem OutputFile: %2\messag

del %2\%1.flavia.msh
del %2\%1.flavia.res
del %2\%1.info
del %2\%1_steel.html

del %2\%1.dyn
rename %2\%1.dat %2\%1.dyn

tcl
proc LaunchMoldCalculation  { basename dir problemtypedir file } {
    exec $file i=[file join $dir $basename.dyn]
    exec [file join $problemtypedir easydyna.exe] [file join $dir $basename.dyn]
    
    #if { ![file exists $file] } {
    #	set fout [open [file join $dir $basename.err] a]
    #	puts $fout "Please Select a correct Solver Path in Calculate Menu"
    #}
    
    if { ![file exists [file join $dir $basename.post.res]] } {
	file rename [file join $dir messag] [file join $dir $basename.err]
	set fout [open [file join $dir $basename.err] a]
	puts $fout "Program failed"
    }
}

foreach "- - basename dir problemtypedir - file" $argv break
LaunchMoldCalculation $basename $dir $problemtypedir $file







