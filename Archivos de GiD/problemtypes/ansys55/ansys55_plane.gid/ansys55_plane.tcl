
proc InitGIDProject { dir } {
    if { [GidUtils::IsTkDisabled] } {    
        return
    }
    CreateMenu "ANSYS" PRE
    InsertMenuOption "ANSYS" "Info" 0 HelpOnANSYS PRE
    InsertMenuOption "ANSYS" "Read postprocess ANSYS file" 1 LoadANSYSFileToGiD PRE
    UpdateMenus
}

proc EndGIDProject {} {
}

proc HelpOnANSYS {} {

    WarnWin [join [list "The two files needed, are an output from ANSYS using commands:    "\
	                  "ANSYS MAIN MENU->GENERAL POSTPROC->LIST RESULT->NODAL SOLUTION    and    "\
                        "ANSYS MAIN MENU->GENERAL POSTPROC->LIST RESULT->ELEMENT SOLUTION  "]]
}

proc LoadANSYSFileToGiD {} {

    set fileName [Browser-ramR file read .gid {Read ANSYS}]
    update idletasks
    if { $fileName == "" } { return }

    


    set aa [GiD_Info Project]
    set ProjectName [lindex $aa 1]
    if { [file extension $ProjectName] == ".gid" } {
    set ProjectName [file root $ProjectName]
    }
    
    set basename [file tail $ProjectName]

    if { $ProjectName == "UNNAMED" } {
	tk_dialogRAM .gid.tmpwin error \
		"Before Reading ANSYS, a project title is needed. Save project to get it" \
		error 0 OK
	return
    }
    
    set directory $ProjectName.gid
    if { [file pathtype $directory] == "relative" } {
	set directory [file join [pwd] $directory]
    }

    set postfile [file join $directory $basename.flavia.res]

    set fin [open $fileName r]
    set fout [open $postfile w]

    .central.s waitstate 1

    while { ![eof $fin] } {
	gets $fin aa
	if { [regexp {[ ]*NODE[ ]*UX.*} $aa] } {
	    while 1 {
		gets $fin aa
		if { [regexp {^[ ]*1[ ].*} $aa] } {
		    puts $fout "DISPLACEMENT      2 1 2  1  1"
		    puts $fout "X-DISP\nY-DISP\nZ-DISP"

		}
		if { ![regexp {[ ]*[0-9].*} $aa] } { break }
		puts $fout $aa
	    }
	} elseif { [regexp {[ ]*NODE[ ]*SX.*} $aa] } {
	    while 1 {
		gets $fin aa
		if { [regexp {^[ ]*1[ ].*} $aa] } {
		    puts $fout "NODAL STRESS      2  1 3 1  1"
		    puts $fout "Sx\nSy\nSz\nSxy\nSxz\nSyz"
		}
		if { ![regexp {[ ]*[0-9].*} $aa] } { break }
		puts $fout $aa
	    }
	}
    }
    
    close $fin
    close $fout
    .central.s waitstate 0
    WarnWin "ANSYS file read. It is possible to postprocess now"
}