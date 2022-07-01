namespace eval heatboundaries { } {
    variable absor
    variable emiss
    variable window
}

proc heatboundaries::ComunicateWithGiD { op args } {
    variable absor
    variable emiss
    variable window 
    
    switch $op {
        "INIT" {
            set PARENT [lindex $args 0]
            set window $PARENT
            upvar [lindex $args 1] ROW
            set GDN [lindex $args 2]
            set STRUCT [lindex $args 3]
            set tf [TitleFrame $PARENT.f -text [= "Radiation Properties"] -bd 2 -relief groove]
            set f [$tf getframe]
            heatboundaries::initwindow $f 
            grid $tf -row $ROW -column 0 -sticky nsew -columnspan 2  -padx 2
            grid rowconf $PARENT [expr $ROW+1] -weight 1
            grid columnconf $PARENT 1 -weight 1
            upvar \#0 $GDN GidData
            set absor $GidData($STRUCT,VALUE,6)
            set emiss $GidData($STRUCT,VALUE,7)
            return ""
        }
        "SYNC" {
            set GDN [lindex $args 0]
            set STRUCT [lindex $args 1]
            if { [ heatboundaries::errorcntrl $window] } {
                DWLocalSetValue $GDN $STRUCT "Absorptivity" $absor 
                DWLocalSetValue $GDN $STRUCT  "Emissivity:" $emiss
            }
            return ""
        }
        "CLOSE" {
            set  absor 0.0
            set emiss 0.0
        }
    }
}

proc heatboundaries::initwindow { parent } {
    
    set labsor [label $parent.labsor -text [= "Absorptivity"]:]
    set eabsor [entry $parent.eabsor -textvariable heatboundaries::absor]
    set babsor [menubutton $parent.babsor -text [= "Temp"]... -menu $parent.babsor.mabsor \
            -bd 2 -relief raised ]
    set mabsor [menu $babsor.mabsor -title NULL \
            -postcommand "::nasmat::updatetablelist $babsor.mabsor heatboundaries::absor"]
    
    set lemiss [label $parent.lemiss -text [= "Emissivity"]:]
    set eemiss [entry $parent.eemiss -textvariable heatboundaries::emiss]
    set bemiss [menubutton $parent.bemiss -text [= "Temp"]... -menu $parent.bemiss.memiss \
            -bd 2 -relief raised ]
    set memiss [menu $bemiss.memiss -title NULL \
            -postcommand "::nasmat::updatetablelist $bemiss.memiss heatboundaries::emiss"]
    
    grid $labsor -row 0 -column 0 -sticky e
    grid $eabsor -row 0 -column 1 -sticky ew -pady 2
    grid $babsor -row 0 -column 2 -sticky ew -padx 4
    grid $lemiss -row 1 -column 0 -sticky e
    grid $eemiss -row 1 -column 1 -sticky ew -pady 2
    grid $bemiss -row 1 -column 2 -sticky ew -padx 4
    
}

proc heatboundaries::errorcntrl { window } {
    
    variable absor
    variable emiss
    
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
    set message [= "Problems found in Radiation Properties:"]\n
    set varvalues [ list $absor $emiss ]
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

proc heatboundaries::setvarabsor { value } {
    variable absor
    set absor $value
    return ""
}
proc heatboundaries::setvaremiss { value } {
    variable emiss
    set emiss $value
    return ""
}
proc heatboundaries::write2bas { propID } {
    variable absor
    variable emiss
    
    set tables ""
    set aux [ GiD_Info materials]
    set index 1 
    foreach elem $aux {
        if { [GiD_Info materials $elem BOOK] == "Tables" } {
            lappend tables  [list $elem $index]
            incr index
        }
    }
    set indexabsor -1
    set indexemiss -1
    foreach elem $tables {
        if { $absor == [lindex $elem 0] } {
            set indexabsor [lindex $elem 1]
        }
        if { $emiss == [lindex $elem 0] } {
            set indexemiss [lindex $elem 1]
        }
    }
    if {  $indexabsor != -1} {
        set output1 [format "RADM%12i     1.0" $propID]
        set output2 [format "RADMT%11i%8i" $propID $indexabsor] 
    } else {
        set output1 [format "RADM%12i" $propID]
        append output1 [CorrectExp [format "%#8.3g"  $absor]]
    }
    if {  $indexemiss != -1} {
        append output1 "     1.0\n" 
        append output2 [format "%8i\n" $indexemiss] 
    } else {
        append output1 [CorrectExp [format "%#8.3g\n" $emiss]]
    }
    if { [info exists output2 ] }  {
        return [append output1 $output2]
    } else {
        return $output1
    }
}