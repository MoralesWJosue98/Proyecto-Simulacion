proc InitGIDProject { dir } {
    if { [GidUtils::IsTkDisabled] } {    
        return
    }
    CreateMenu "ANSYS" PRE
    InsertMenuOption "ANSYS" "Info" 0 Ansys::HelpS PRE
    InsertMenuOption "ANSYS" "Import ANSYS file" 1 Ansys::ReadW PRE
    InsertMenuOption "ANSYS" "Read postprocess ANSYS file" 2 Ansys::ConvertResultsToGiD PRE
    UpdateMenus
}

proc EndGIDProject {} {
}

namespace eval Ansys {
    variable version 1.0 ;#Ansys plugin version      
}

proc Ansys::Help {} {
    WarnWin [join [list "The two files needed, are an output from ANSYS using commands:    "\
	                  "ANSYS MAIN MENU->GENERAL POSTPROC->LIST RESULT->NODAL SOLUTION    and    "\
                        "ANSYS MAIN MENU->GENERAL POSTPROC->LIST RESULT->ELEMENT SOLUTION  "]]
}

proc Ansys::ConvertResultsToGiD {} {
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
    WarnWin "ANSYS file read"
}



proc Ansys::ReadW { } {
    set filename [Browser-ramR file read .gid [= "Read Ansys file"] \
	    {} {{{Ansys} {.prp }} {{All files} {.*}}} ]
    if {$filename == ""} {
	return
    }
    GidUtils::WaitState .gid
    GidUtils::DisableGraphics
    set fail 0
    if { [catch {Ansys::Read $filename} err] } {
	set  fail 1
    }
    GidUtils::EnableGraphics
    GidUtils::EndWaitState .gid
    GidUtils::SetWarnLine [= "File read"]    
    GiD_Process MEscape Meshing MeshView
    GiD_Process Mescape View Zoom Frame escape    
    if { $fail } {
	WarnWin $err
    }
}

proc Ansys::Read { filename } {
    set fp [open $filename r]
    if { $fp == "" } {
	#WarnWin [= "Cannot open file '%s'" $filename]
	return 1
    }
    #offset to be added to the number if a previous model exists
    set offset [GiD_Info Mesh MaxNumNodes]      
    set layer_name nodes
    if { [lsearch [GiD_Info Layers] $layer_name] == -1 } {
	GiD_Process Layers New $layer_name
    } else {
	GiD_Process Layers ToUse $layer_name
    }
    while { ![eof $fp] } {
	gets $fp line
	set line [string trim $line]
	if { $line == "" } {
	    continue
	}
	set c [string index $line 0]
	if { $c == "!" } {
	    #comment line
	    if { [string range $line 0 9] == "!materiale" } {
		#!materiale :    $matname
		set current_matname [string trim [lindex [split $line :] 1]]	
	    }
	    continue
	} elseif { $c == "/" } {
	    #Ansys command, ignore it
	    continue
	}
	set items [split $line ,]
	set w0 [string trim [lindex $items 0]]
	if { $w0 == "N" } {
	    lassign $items - num x y z
	    if { $offset } {
		incr num $offset
	    }
	    GiD_Mesh create node $num "$x $y $z"
	} elseif { $w0 == "EN" } {
	    #EN,   10500,    1329,    1340,    1331,    1330,    7999,    8002,    8001,    8000
	    lassign $items - num n(1) n(2) n(3) n(4) n(5) n(6) n(7) n(8)
	    if { $offset } {
		foreach i {1 2 3 4 5 6 7 8} {
		    incr n($i) $offset
		}		
	    }
	    GiD_Mesh create element append hexahedra 8 "$n(1) $n(2) $n(3) $n(4) $n(5) $n(6) $n(7) $n(8)"
	} elseif { $w0 == "MPDATA" } {
	    #MPDATA,murx,   $matnum,1
	    set matnum [string trim [lindex $items 2]]
	    if { [info exists current_matname] } {
		set material_name($matnum) $current_matname	    
	    } else {
		WarnWinText "material $matnum not has a name set by a previous !materiale special comment"
	    }
	} elseif { $w0 == "MAT" } {
	    #MAT,      $matnum
	    set matnum [string trim [lindex $items 1]]
	    if { [info exists material_name($matnum)] } {
		set layer_name $material_name($matnum)
		if { [lsearch [GiD_Info Layers] $layer_name] == -1 } {
		    GiD_Process Layers New $layer_name
		} else {
		    GiD_Process Layers ToUse $layer_name
		}
	    } else {
		WarnWinText "material $matnum was not read"
	    }
	} elseif { $w0 == "csys" } {
	    #csys,0
	} elseif { $w0 == "wpcsys" } {
	    #wpcsys,-1
	} elseif { $w0 == "ET" } {
	    #ET, 1,Solid 97  
	} elseif { $w0 == "KEYOPT" } {
	    #KEYOPT,1,1,0  
	} elseif { $w0 == "TYPE" } {
	    #TYPE, 1
	} elseif { $w0 == "MPTEMP" } {
	    #MPTEMP,,,,,,,,  
	    #MPTEMP,1,0 
	} elseif { $w0 == "SHPP" } {
	    #SHPP, OFF	
	} elseif { $w0 == "TYPE" } {
	    #TYPE,   1
	} elseif { $w0 == "CHECK" } {
	    #CHECK
	} elseif { $w0 == "FINISH" } {
	    #FINISH
	} else {
	    WarnWinText "unexpecte word $w0"
	}					               	   
    }
    close $fp
    return 0
}
