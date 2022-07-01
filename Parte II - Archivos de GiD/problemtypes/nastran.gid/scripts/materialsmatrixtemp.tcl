namespace eval matmatrix { } {
    variable text
    variable num_row
    variable num_col
    variable sym 
    variable selection
    variable table
}

proc matmatrix::initwindow {parent rows col labels type variable command} {
    variable text
    variable num_row 
    variable num_col
    variable selection
    variable sym 
    variable table ""
    set num_row $rows
    set num_col $col
    set sym $type
    
    
    
    if { $sym=="yes" } {
        set jstart i
    } else {
        set aux 1
        set jstart aux
    }
    set index 0
    if { $num_col == 0} {
        for {set i 1 } {$i<=$num_row } {incr i } {
            set text($i) [lindex $labels $index]
            incr index
        }
    } else {
        for {set i 1 } {$i<=$num_row } {incr i } {
            for {set j [set $jstart]} {$j<=$num_col} {incr j} {
                set text($i,$j) [lindex $labels $index]
                incr index
            }
        }
    }
    
    
    global tkPriv tcl_platform
    set topname $parent.section
    catch {destroy $topname}
    toplevel $topname
    
    wm title $topname [= "Temperature"]
    if { $tcl_platform(platform) == "windows" } {
        wm transient $topname [winfo toplevel [winfo parent $topname]]
    }
    
    grid columnconf $topname 0 -weight 1
    grid rowconf $topname 1 -weight 1
    
    set ftext [frame $topname.ftext]
    set ltext [Label $ftext.ltext -text [= "Select which field  you want to define as temperature dependent"]]
    
    set fradio [frame $topname.fradio]
    if { $num_col==0} {
        for {set i 1 } {$i <=$num_row} { incr i} {
            set r$i [radiobutton $fradio.r$i -textvariable matmatrix::text($i) -variable matmatrix::selection -value "$i"]
        }
    } else {
        for {set i 1 } {$i <=$num_row} { incr i} {
            for {set j [set $jstart]} {$j<=$num_col } {incr j} {
                set r$i$j [radiobutton $fradio.r$i$j -textvariable matmatrix::text($i,$j) -variable matmatrix::selection -value "$i$j"]
            }
        }
    }
    
    
    set fcombo [frame $topname.fcombo]
    set ltable [Label $fcombo.ltable -text [= "Table Temp."] -helptext [= "Select a table of values to define the temperature variation of the field"]]
    set cbtable [ComboBox $fcombo.cbtable -textvariable matmatrix::table -editable no \
            -postcommand "matmatrix::updatecombovalues $fcombo.cbtable"]
    set btable  [Button $fcombo.btable -text [= "Create Table"]... -command "GidOpenMaterials Tables; matmatrix::updatecombovalues $cbtable"]
    
    set fbuttons [frame $topname.fbuttons -bd 1 -relief sunken -pady 3 -padx 3]
    set baccept [Button $fbuttons.baccept -text [= "Ok"] -command "matmatrix::accept $topname $variable $command"]
    set bcancel [Button $fbuttons.bcancel -text [= "Cancel"] -command "matmatrix::cancel $topname"]
    
    
    
    grid $ftext -row 0 -column 0 -sticky nsew
    grid $ltext -row 0 -column 0 -sticky ns
    
    grid $fradio -row 1 -column 0 -sticky nsew
    if {$num_col ==0} {
        for {set i 1 } {$i <=$num_row} { incr i} {
            set widget r$i
            grid [set $widget] -row 0 -column [expr $i-1] 
        }
    } else {
        for {set i 1 } {$i <=$num_row} { incr i} {
            for {set j [set $jstart]} {$j<=$num_col } {incr j} {
                set widget r$i$j
                grid [set $widget] -row [expr $i-1] -column [expr $j-1] 
            }
        }
    }
    grid $fcombo -row 2 -column 0 -sticky nsew
    grid $ltable -row 0 -column 0 -sticky ew
    grid $cbtable -row 0 -column 1 -sticky ew
    grid $btable -row 1 -column 0 -sticky ew -columnspan 2 -pady 4
    
    grid $fbuttons -row 3 -column 0 -sticky nsew -pady 4
    grid columnconf $fbuttons 0 -weight 1
    grid rowconf $fbuttons 0 -weight 1
    grid columnconf $fbuttons 1 -weight 1
    grid $baccept -row 0 -column 0 -sticky nsew -padx 2
    grid $bcancel -row 0 -column 1 -sticky nsew -padx 2
    
    
    
    wm withdraw $topname
    update idletasks
    set xpos [ expr [winfo x  [winfo toplevel $parent]]+[winfo width [winfo toplevel $parent]]/2-[winfo reqwidth $topname]/2]
    set ypos [ expr [winfo y  [winfo toplevel $parent]]+[winfo height [winfo toplevel $parent]]/2-[winfo reqheight $topname]/2]
    
    wm geometry $topname +$xpos+$ypos
    wm deiconify $topname
}

proc matmatrix::updatecombovalues {combo} {
    variable table 
    set values ""
    set materials [ GiD_Info materials]
    foreach mat $materials {
        if { [GiD_Info materials $mat BOOK] == "Tables" } {
            set tableinfo [lrange [GiD_Info materials $mat] 1 end]
            set index [lsearch $tableinfo "Value_type*"]
            incr index
            if { [lindex $tableinfo $index] == "vs._Temperature"} {
                lappend values  $mat
            }
        }
    }
    $combo configure -values $values
    if {$table == ""} {
        set table [lindex $values 0]
    }
}

proc matmatrix::accept {window  variable command} { 
    variable text 
    variable num_row 
    variable num_col
    variable selection
    variable sym 
    variable table 
    if { $selection != "" } {
        set $variable [list $table $selection]
        $command
    }
    array unset text
    unset num_col 
    unset num_row 
    unset selection
    unset sym
    unset table
    destroy $window
}

proc matmatrix::cancel {window} { 
    variable text 
    variable num_row 
    variable num_col
    variable selection
    variable sym 
    variable table 
    
    array unset text
    unset num_col 
    unset num_row 
    unset selection
    unset sym
    unset table
    destroy $window
}

