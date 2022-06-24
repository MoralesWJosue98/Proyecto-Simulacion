namespace eval convection { } {
    variable conv
    variable window
}

proc convection::ComunicateWithGiD { op args } {
    variable conv
    variable window 
    
    switch $op {
        "INIT" {
            set PARENT [lindex $args 0]
            set window $PARENT
            upvar      [lindex $args 1] ROW
            set GDN [lindex $args 2]
            set STRUCT [lindex $args 3]
            set tf [TitleFrame $PARENT.f -text [= "Convection Properties"] -bd 2 -relief groove]
            set f [$tf getframe]
            convection::initwindow $f 
            grid $tf -row $ROW -column 0 -sticky nsew -columnspan 2  -padx 2
            grid rowconf $PARENT [expr $ROW+1] -weight 1
            grid columnconf $PARENT 1 -weight 1
            upvar \#0 $GDN GidData
            set conv $GidData($STRUCT,VALUE,1)
            return ""
        }
        "SYNC" {
            set GDN [lindex $args 0]
            set STRUCT [lindex $args 1]
            if { [ convection::errorcntrl $window] } {
                DWLocalSetValue $GDN $STRUCT "Convection_coef." $conv 
                
            }
            return ""
        }
        "CLOSE" {
            set  conv 0.0
        }
    }
}

proc convection::initwindow { parent } {
    
    set lconv [label $parent.lconv -text [= "Convection Coef."]:]
    set econv [entry $parent.econv -textvariable convection::conv]
    set bconv [menubutton $parent.bconv -text [= "Temp"]... -menu $parent.bconv.mconv \
            -bd 2 -relief raised ]
    set mconv [menu $bconv.mconv -title NULL \
            -postcommand "::nasmat::updatetablelist $bconv.mconv convection::conv"]
    
    grid $lconv -row 0 -column 0 -sticky e
    grid $econv -row 0 -column 1 -sticky ew -pady 2
    grid $bconv -row 0 -column 2 -sticky ew -padx 4   
}

proc convection::errorcntrl { window } {
    
    variable conv
    
    set tables ""
    set aux [ GiD_Info materials]
    foreach elem $aux {
        if { [GiD_Info materials $elem BOOK] == "Tables" } {
            set tableinfo [lrange [GiD_Info materials $elem] 1 end]
            set index [lsearch $tableinfo "Value_type*"]
            incr index
            if { [lindex $tableinfo $index] == "vs._Temperature"} {
                lappend tables  $elem
            }
        }
    }
    
    set write 0
    set message [= "Problems found in Convection Properties:"]\n
    set varvalues [list $conv]
    foreach value $varvalues {
        if { ![string is double [string trim $value]] } {
            set addmsg 1
            foreach tablename $tables { 
                if { $value == $tablename } {
                    set addmsg 0
                    break
                }
            }
            if { $addmsg } {
                append message [= "'%s' is not a valid input" $value]\n
                set write 1
            }
        }
    }
    if { $write } {
        WarnWin $message $window
        return 0
    } else {
        return 1
    }
}

proc convection::setvarconv { value } {
    variable conv
    set conv $value
    return ""
}

proc convection::write2bas { propID } {
    variable conv
    
    set tables ""
    set aux [ GiD_Info materials]
    set index 1 
    foreach elem $aux {
        if { [GiD_Info materials $elem BOOK] == "Tables" } {
            lappend tables  [list $elem $index]
            incr index
        }
    }
    set indexconv -1
    foreach elem $tables {
        if { $conv == [lindex $elem 0] } {
            set indexconv [lindex $elem 1]
        }
    }
    if {  $indexconv != -1} {
        set output1 [format "MAT4%12i                             1.0" $propID]
        set output2 [format "MATT4%11i                        %8i" $propID $indexconv] 
    } else {
        set output1 [format "MAT4%12i                        " $propID]
        append output1 [CorrectExp [format "%#8.3g"  $conv]]
    }
    if { [info exists output2 ] }  {
        return [append output1 $output2]
    } else {
        return $output1
    }
}
