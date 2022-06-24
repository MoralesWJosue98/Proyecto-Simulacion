
namespace eval Function {
    variable insert_data {
        R0lGODlhGAAYAOMAAAICBK2tmo2NgOXlztXVvzY2MlxcWfLy2///////////
        /////////////////////yH5BAEKAAgALAAAAAAYABgAAAR4EMlJq704awu2
        BkDQeRVIDERBTibhnuPWuugwiLLw7vagfr5Xr3eIXQCHQ4E3SKKMpWZBN0wm
        oRSkQdi0WrGSVs3mTeI43G45ScACaCfy+tA+DtVlEOZ9Lw/AFAZyZQKAWU14
        fysISFZPi4wEbAaGGUh1kFmVmRoRADs=
    }
    variable insert [image create photo -data [set insert_data]]
    
    variable get_data {
        R0lGODlhGAAYAOMAAAICBK2tmo2NgOXlztXVvzY2MlxcWfLy2///////////
        /////////////////////yH5BAEKAAgALAAAAAAYABgAAAR/EMlJq704awu2
        BkDQeRVIDERBTibhnuPWuugwiLLw7vagfj4XoGcDHGIX46FAMBWHzcxwKQD1
        QIej9GAQDozgrDYJoA3PRzGO8/p+08pstERrFrPxw7x0HaT/R0gUZUR+Ygdf
        GwY2h2JVHlOGWYkreSiCMgRyBpiQep2VoCujEQA7
    }
    variable get [image create photo -data [set get_data]]
    
    
    
    variable delete_data {
        R0lGODlhDwAPAKEAAP8AAICAgAAAAP///yH+Dk1hZGUgd2l0aCBHSU1QACH5
        BAEKAAMALAAAAAAPAA8AAAIxnI+AAxDbXJIstnesvlOLj2XWJyzVWEKNYIUi
        wEbu+RnyW4vhmk4p3IOkcqYBsWgqAAA7
    }
    variable delete [image create photo -data [set delete_data]]
    
    variable entrytype
    variable deltax
    variable x 
    variable y
    variable tox
    variable toy
    variable ldeltax
    variable lx
    variable ly
    variable ltox
    variable ltoy
    variable edeltax
    variable ex
    variable ey
    variable etox
    variable etoy
    variable etoy2
    variable index 0
    variable insertype
    variable table
    variable list
    variable can   
    variable type
} 
proc Function::ComunicateWithGiD { op args } {
    
    switch $op {
        "INIT" {
            set  Function::list ""
            set PARENT [lindex $args 0]
            upvar [lindex $args 1] ROW
            set GDN [lindex $args 2]
            set STRUCT [lindex $args 3]
            set f [frame $PARENT.f]
            Function::initwindow $f 
            grid $f -row $ROW -column 0 -sticky nsew -columnspan 2 -pady 3 -padx 2
            grid rowconf $PARENT $ROW -weight 1
            grid columnconf $PARENT 1 -weight 1
            upvar \#0 $GDN GidData
            set Function::type [DWUnder2Space $GidData($STRUCT,VALUE,3)] 
            if { $GidData($STRUCT,VALUE,2) != "#N# 1 none" } {
                Function::getvalues $GidData($STRUCT,VALUE,2)
            }
            return ""
        }
        "SYNC" {
            set GDN [lindex $args 0]
            set STRUCT [lindex $args 1]
            set values [Function::dump]
            DWLocalSetValue $GDN $STRUCT "Value_type:" [DWSpace2Under $Function::type] 
            DWLocalSetValue $GDN $STRUCT  "Table_Interpolation_Values:" $values
            return ""
        }
        "CLOSE" {
            set  Function::list ""
        }
    }
}

proc  Function::getvalues { entries } {
    variable table
    
    set nelems [lindex $entries 1]
    set nelems [expr $nelems-1] 
    for { set i 2 } { $i <= $nelems  } { incr i 2 } {
        set x [lindex $entries $i ]
        set y [lindex $entries [expr $i+1]]
        $table insert end "[format %#16e $x] [format %#16e $y]"
    }
    
}


proc Function::initwindow { parent } {
    variable table
    variable can   
    set w $parent
    #-------------------------Crear Table values-----------------------------------#
    set pw [PanedWindow $w.pw -side top -width 10]
    set pw0 [$pw add -weight 1 ]
    set pane [ $pw getframe 0]
    set ftype [frame $pane.ftype ]
    set ltype [label $ftype.ltype -text [= "Value type"]]
    set cbtype [ComboBox $ftype.cbtype -values [list "vs. Time" "vs. Frequency" "vs. Temperature"] -textvariable Function::type \
            -editable no]
    set title1 [TitleFrame $pane.tablevalues -relief groove -bd 2 -text [= "Table Values"] -side left]
    set f1 [$title1 getframe]
    set sw [ScrolledWindow $f1.scroll -scrollbar both]
    set table [tablelist::tablelist $f1.scroll.table \
            -columns [list 0 [= "X Values"] center 0 [= "Y Values"] center] \
            -stretch all -background white \
            -listvariable Function::list -selectmode extended]
    $sw setwidget $table
    bind [$table bodypath] <Double-ButtonPress-1> { Function::edit $Function::table }
    set bbox [ButtonBox $f1.bbox1 -spacing 0 -padx 1 -pady 1 -homogeneous 0]
    #$bbox add -image $Function::insert -width 24 \
        #    -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        #    -helptext "Insert a new entry" -command "Function::insert $table"
    $bbox add -image $Function::get -width 24 \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext [= "Edit entry"] -command "Function::edit $table"
    $bbox add -image $Function::delete -width 24 \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext [= "Delete entry"] -command "Function::delete $table"
    
    #---------------------------Crear Data Entry-------------------------------------------------#
    set pw2 [$pw add -weight 1]
    set pane2 [ $pw getframe 1 ] 
    set title2 [TitleFrame $pane2.data -relief groove -bd 2 -text [= "Data Entry"] -side left]
    set f2 [$title2 getframe]
    
    catch { unset bgcolor }
    set bgcolor [$f2 cget -background]
    set Function::entrytype "Single Value"
    trace variable Function::entrytype w "Function::modify ;# "
    
    frame $f2.f
    radiobutton $f2.f.single -text [= "Single Value"] -var Function::entrytype \
        -value "Single Value"  -selectcolor white 
    radiobutton $f2.f.linear -text [= "Linear Ramp"] -var Function::entrytype \
        -value "Linear Ramp" -selectcolor white
    radiobutton $f2.f.equation -text [= "Equation"] -var Function::entrytype \
        -value "Equation" -selectcolor white
    radiobutton $f2.f.periodic -text [= "Periodic"] -var Function::entrytype \
        -value "Periodic" -selectcolor white
    
    set Function::x "" 
    set Function::y ""
    set Function::deltax ""
    set Function::tox ""
    set Function::toy ""   
    
    set Function::ldeltax [label $f2.ldeltax -text [= "Delta X"] -justify right \
            -disabledforeground grey60 -foreground black -state disabled]
    set Function::edeltax [entry $f2.edeltax -textvariable Function::deltax \
            -justify left -bd 2 -relief sunken  -background $bgcolor \
            -state disabled] 
    set Function::lx [label $f2.lx -text "X" -justify right]
    set Function::ex [entry $f2.ex -textvariable Function::x -justify left \
            -bd 2  -relief sunken]
    set Function::ly [label $f2.ly -text "Y" -justify right -disabledforeground grey60 \
            -foreground black -state normal]
    set Function::ey [entry $f2.ey -textvariable Function::y -justify left  -bd 2 \
            -relief sunken -state normal]
    set Function::ltox [label $f2.ltox -text [= "To X"] -justify right \
            -disabledforeground grey60 -foreground black -state disabled]
    set Function::etox [entry $f2.etox -textvariable Function::tox -justify left \
            -bd 2  -relief sunken -background $bgcolor -state disabled]
    set Function::ltoy [label $f2.ltoy -text [= "To Y"] -justify right \
            -disabledforeground grey60 -foreground black -state disabled]
    frame $f2.etoy
    set Function::etoy [entry $f2.etoy.e -textvariable Function::toy -justify left \
            -bd 2 -relief sunken -background $bgcolor -state disabled]
    set examples { 3*x+log(x) pow(x,2)*exp(x) x*cos(3*x) sqrt(x+2)+sinh(pow(x,3)) \
        atan(x) abs(x) }
    set Function::etoy2 [ComboBox $f2.etoy.cb -textvariable Function::toy  \
            -background $bgcolor -values $examples]
    frame $pane2.fadd 
    button $pane2.fadd.badd -text [= "Add"] -underline 0 -padx 5 -command "Function::add $table $w;#" 
    button $pane2.fadd.bclear -text [= "Clear All"] -underline 1 -padx 5 \
        -command "Function::clear $table"  
    frame $pane2.fradio
    set Function::insertype end
    radiobutton $pane2.fradio.end -text [= "Add at End"] -variable  Function::insertype \
        -justify left -value end 
    radiobutton $pane2.fradio.no -text [= "Add before Selected"] -variable  Function::insertype \
        -value no 
    set can [canvas $pane2.can -relief sunken -bd 2 -bg white -width 130 -height 100]
    
    grid rowconf $w 0 -weight 1
    grid columnconf $w 0 -weight 1
    
    
    grid $pw  -sticky nsew
    grid rowconf $pw 0 -weight 1
    grid columnconf $pw 0 -weight 1
    grid rowconf $pane 1 -weight 1
    grid columnconf $pane 0 -weight 1
    grid rowconf $pane2 3 -weight 1
    grid columnconf $pane2 0 -weight 1
    
    grid $ftype -column 0 -row 0 -padx 2 -pady 2 -sticky nsew
    grid $ltype -column 0 -row 0 -sticky nw
    grid $cbtype -column 1 -row 0 -sticky wen
    grid $title1 -column 0 -row 1 -padx 2 -pady 2 -sticky nsew 
    grid rowconf $title1 2 -weight 1
    
    
    grid $title2 -column 0 -row 0 -padx 2 -pady 2 -sticky nsew
    
        
    grid $f2.etoy.e -row 0 -column 0 -sticky nsew
    grid $f2.etoy.cb -row 0 -column 0 -sticky nsew
    grid columnconf $f2.etoy 0 -weight 1
    grid rowconf $f2.etoy 0 -weight 1
    grid remove $f2.etoy.cb
    grid propagate $f2.etoy 0
    
    grid $pane2.fadd -row 1 -column 0 -sticky nsew 
    grid columnconf $pane2.fadd 1 -weight 1
    grid $pane2.fadd.badd -row 0 -column 0 -padx 5 -pady 5
    grid $pane2.fadd.bclear -row 0 -column 1 -padx 5 -pady 5
    grid $pane2.fradio -row 2 -column 0 -sticky nsew 
    grid columnconf $pane2.fradio 2 -weight 1
    grid $pane2.fradio.end -row 0 -column 0 
    grid $pane2.fradio.no -row 0 -column 1
    grid $can -row 3 -column 0 -sticky nsew -padx 5 -pady 5
    
    grid $f1.scroll -sticky nsew
    grid $f1.bbox1 -sticky wne
    grid columnconfigure $f1 0 -weight 1
    grid rowconfigure $f1 0 -weight 1
    
    grid $f2.f.single $f2.f.linear
    grid $f2.f.equation $f2.f.periodic -sticky wn
    grid $f2.f -columnspan 4 -pady 6
    grid $f2.ldeltax $f2.edeltax -pady 1
    grid configure $f2.edeltax -sticky ew
    grid $f2.lx $f2.ex $f2.ly $f2.ey -pady 1
    grid configure $f2.ex $f2.ey -sticky ew
    grid $f2.ltox $f2.etox $f2.ltoy $f2.etoy -pady 1
    grid configure $f2.etox $f2.etoy -sticky ew

    grid columnconfigure $f2 "1 3" -weight 1
    grid rowconfigure $f2 0 -weight 1
    
    bind $w <Alt-KeyPress-a> "tkButtonInvoke $pane2.fadd.badd"
    bind $w <Alt-KeyPress-l> "tkButtonInvoke $pane2.fadd.bclear"
    bind $can <Configure> "Function::IntDrawGraphR $can ;#"
    #     bind $pane2.fadd.badd <ButtonRelease> "Function::IntDrawGraphR $can ;#"
    #     bind $pane2.fadd.bclear <ButtonRelease> "Function::IntDrawGraphR $can ;#"
}

#----------------------------------------Modificacio finestra--------------------------------#
proc Function::modify { } {
    
    if { ![winfo exists $Function::ldeltax] } { return }
    
    catch { unset bgcolor }
    set bgcolor [$Function::ldeltax cget -background]  
    
    if { $Function::entrytype == "Single Value" } {
        set Function::deltax "" 
        set Function::x ""
        set Function::y ""
        set Function::tox ""
        set Function::toy ""
        $Function::ldeltax configure -state disable  -text [= "Delta X"]
        $Function::edeltax configure -state disable -background $bgcolor 
        $Function::ly configure -state normal
        $Function::ey configure -state normal -background white
        $Function::ltox configure -state disable  
        $Function::etox configure -state disable -background $bgcolor
        $Function::ltoy configure -state disabled -text [= "To Y"]
        $Function::etoy configure -state disabled -background $bgcolor
        
        grid $Function::etoy
        grid remove $Function::etoy2 
        
        
    }
    if { $Function::entrytype == "Linear Ramp" } {
        set Function::deltax "" 
        set Function::x ""
        set Function::y ""
        set Function::tox ""
        set Function::toy ""
        $Function::ldeltax configure -state normal -text [= "Delta X"]
        $Function::edeltax configure -state normal -background white
        $Function::ly configure -state normal
        $Function::ey configure -state normal -background white
        $Function::ltox configure -state normal  
        $Function::etox configure -state normal -background white
        $Function::ltoy configure -state normal -text [= "To Y"]
        $Function::etoy configure -state normal -background white 
        grid $Function::etoy
        grid remove $Function::etoy2 
    }
    if { $Function::entrytype == "Equation" } {
        set Function::deltax "" 
        set Function::x ""
        set Function::y ""
        set Function::tox ""
        set Function::toy ""
        $Function::ldeltax configure -state normal -text [= "Delta X"]
        $Function::edeltax configure -state normal -background white
        $Function::ly configure -state disabled
        $Function::ey configure -state disabled -background $bgcolor
        $Function::ltox configure -state normal  
        $Function::etox configure -state normal -background white
        $Function::ltoy configure -state normal -text "Y(X)"
        $Function::etoy configure -state normal -background white 
        grid $Function::etoy2
        grid remove $Function::etoy 
    }
    if { $Function::entrytype == "Periodic" } {
        set Function::deltax "" 
        set Function::x ""
        set Function::y ""
        set Function::tox ""
        set Function::toy ""
        $Function::ldeltax configure -state normal -text [= "Period"]
        $Function::edeltax configure -state normal -background white
        $Function::ly configure -state normal
        $Function::ey configure -state normal -background white
        $Function::ltox configure -state normal  
        $Function::etox configure -state normal -background white
        $Function::ltoy configure -state disabled -text [= "To Y"]
        $Function::etoy configure -state disabled -background $bgcolor 
        grid $Function::etoy
        grid remove $Function::etoy2 
    } 
}



proc Function::add { wtext parent } {
    variable entrytype
    variable deltax
    variable x
    variable y
    variable tox
    variable toy
    variable index
    variable insertype
    variable can
    
    
    if { [errorcntrl $parent] } {  
        if { $insertype == "end" } {
            if { $entrytype == "Single Value" } {
                $wtext insert $index "[format %#16e $x] [format %#16e $y]"
                $wtext see end
                set index [expr $index+1]
            }
            if { $entrytype == "Linear Ramp" } {
                set x [expr double($x)]
                set tox [expr double($tox)]
                set deltax [expr double($deltax)]
                set numint [expr abs([expr round([expr ($x-$tox)/$deltax])])]
                set v1 [expr double([expr $tox-$x])]
                set v2 [expr double([expr $toy-$y])]
                set b [expr $y-$x*$v2/$v1]
                set m [expr $v2/$v1]
                for { set i 0 } { $i<=$numint } { incr i } {
                    set xi [expr $x+$i*$deltax]
                    set yi [expr $m*$xi+$b]
                    $wtext insert $index "[format %#16e $xi] [format %#16e $yi]"
                    $wtext see end
                    set index [expr $index+1]
                }
            }
            if { $entrytype == "Equation" } {
                set x [expr double($x)]
                set tox [expr double($tox)]
                set deltax [expr double($deltax)]
                set numint [expr abs([expr round([expr ($x-$tox)/$deltax])])]
                string tolower $toy
                regsub -all {\mx\M} $toy \$xi aux
                set xi $x
                if { [catch { expr $aux } error] } { 
                    WarnWin $error
                    return 0 
                }
                for { set i 0 } { $i<=$numint } { incr i } {
                    set xi [expr double([expr $x+$i*$deltax])]
                    set yi [expr $aux]
                    $wtext insert $index "[format %#16e $xi] [format %#16e $yi]"
                    $wtext see end
                    set index [expr $index+1]
                }
            }
            if { $entrytype == "Periodic" } {
                set x [expr double($x)]
                set tox [expr double($tox)]
                set deltax [expr double($deltax)]
                set numint [expr abs([expr round([expr ($x-$tox)/$deltax])])]
                for { set i 0 } { $i<=$numint } { incr i } {
                    set xi [expr $x+$i*$deltax]
                    $wtext insert $index "[format %#16e $xi] [format %#16e $y]"
                    $wtext see end
                    set index [expr $index+1]
                }
            }
        }
        if { $insertype == "no" } {
            set entry [$wtext curselection]
            if { $entry == "" } {
                WarnWin [= "It is necessary to select a row of values"]
            } else {
                if { $entrytype == "Single Value" } {
                    $wtext insert $entry "[format %#16e $x] [format %#16e $y]"
                    $wtext see $entry
                }
                if { $entrytype == "Linear Ramp" } {
                    set x [expr double($x)]
                    set tox [expr double($tox)]
                    set deltax [expr double($deltax)]
                    set numint [expr abs([expr round([expr ($x-$tox)/$deltax])])]
                    set v1 [expr double([expr $tox-$x])]
                    set v2 [expr double([expr $toy-$y])]
                    set b [expr $y-$x*$v2/$v1]
                    set m [expr $v2/$v1]
                    for { set i 0 } { $i<=$numint } { incr i } {
                        set xi [expr $x+$i*$deltax]
                        set yi [expr $m*$xi+$b]
                        $wtext insert $entry "[format %#16e $xi] [format %#16e $yi]"
                        $wtext see $entry
                        set entry [expr $entry+1]
                    }
                }
                if { $entrytype == "Equation" } {
                    set x [expr double($x)]
                    set tox [expr double($tox)]
                    set deltax [expr double($deltax)]
                    set numint [expr abs([expr round([expr ($x-$tox)/$deltax])])]
                    string tolower $toy
                    regsub -all {\mx\M} $toy \$xi aux
                    for { set i 0 } { $i<=$numint } { incr i } {
                        set xi [expr double([expr $x+$i*$deltax])]
                        set yi [expr $aux]
                        $wtext insert $entry "[format %#16e $xi] [format %#16e $yi]"
                        $wtext see $entry
                        set entry [expr $entry+1]
                    }
                }
                if { $entrytype == "Periodic" } {
                    set x [expr double($x)]
                    set tox [expr double($tox)]
                    set deltax [expr double($deltax)]
                    set numint [expr abs([expr round([expr ($x-$tox)/$deltax])])]
                    for { set i 0 } { $i<=$numint } { incr i } {
                        set xi [expr $x+$i*$deltax]
                        $wtext insert $entry "[format %#16e $xi] [format %#16e $y]"
                        $wtext see $entry
                        set entry [expr $entry+1]
                    } 
                }
            }
        }
    }
    Function::IntDrawGraphR $can 
}
proc Function::edit { table } {
    
    variable x
    variable y
    set index [$table curselection]
    if { [llength $index] > 1} {
        WarnWin [= "It is only possible edit one row at the same time"]
        return
    } 
    if { $index != "" } {
        set entry [$table get $index]
        set x [lindex $entry 0]  
        set y [lindex $entry 1]
    }
} 

proc Function::delete { wtext } {
    variable x
    variable y
    variable can
    
    set entry [$wtext curselection]
    if { $entry != "" } {
        $wtext delete [lindex $entry 0] [lindex $entry end]
        $wtext see [lindex $entry end]
        Function::IntDrawGraphR $can     
    }   
}


proc Function::errorcntrl { parent } {
    variable deltax
    variable x
    variable y
    variable tox
    variable entrytype  
    set cntrlx 0
    set cntrly 0
    set cntrltox 0
    set cntrldeltax 0
    set text [= "Please make sure all activated fields are filled only with numerical values"].
    set texteq [= "Please make sure all activated fields are filled only with numerical values.\n \
            Only the Y(X) field can be filled with an equation including alphabetical characters"].
    
    if { [string is double -strict $x] || [string is integer -strict $x] } {
        set cntrlx 1
    } 
    if { [string is double -strict $y] || [string is integer -strict $y] } {
        set cntrly 1
    }
    if { [string is double -strict $tox] || [string is integer -strict $tox] } {
        set cntrltox 1
    }
    if { [string is double -strict $deltax] || [string is integer -strict $deltax] } {
        set cntrldeltax 1
    }
    
    if { $entrytype == "Single Value"  } {
        if { [expr $cntrlx+$cntrly] == 2 } {
            return 1
        } else {
            append text \n\n[= "Errors found"]:
            if { $cntrlx == 0 } {
                append text "\nX " [= "file is blank or filled with alphabetical characters"].
            }
            if { $cntrly == 0 } {
                append text "\nY " [= "file is blank or filled with alphabetical characters"].
            }
            WarnWin $text $parent
            return 0
        }
    }
    if { $entrytype == "Linear Ramp"  } {
        if { [expr $cntrlx+$cntrly+$cntrldeltax+$cntrltox] == 4 } {
            return 1
        } else {
            append text \n\n[= "Errors found"]:
            if { $cntrlx == 0 } {
                append text "\nX " [= "file is blank or filled with alphabetical characters"].
            }
            if { $cntrly == 0 } {
                append text "\nY " [= "file is blank or filled with alphabetical characters"].
            }
            if { $cntrldeltax == 0 } {
                append text "\n" [= "Delta X"] " " [= "file is blank or filled with alphabetical characters"].
            }
            if { $cntrltox == 0 } {
                append text "\n" [= "To X"] " " [= "file is blank or filled with alphabetical characters"].
            }
            WarnWin $text $parent
            return 0
        }
    }
    if { $entrytype == "Equation"  } {
        if { [expr $cntrlx+$cntrldeltax+$cntrltox] == 3 } {
            return 1
        } else {
            append texteq \n\n[= "Errors found"]:
            if { $cntrlx == 0 } {
                append texteq "\nX " [= "file is blank or filled with alphabetical characters"].
            }
            if { $cntrltox == 0 } {
                append texteq "\n" [= "To X"] " " [= "file is blank or filled with alphabetical characters"].
            }
            if { $cntrldeltax == 0 } {
                append texteq "\n" [= "Delta X"] " " [= "file is blank or filled with alphabetical characters"].
            }
            WarnWin $texteq $parent
            return 0
        }
    }
    if { $entrytype == "Periodic"  } {
        if { [expr $cntrlx+$cntrldeltax+$cntrltox+$cntrly] == 4 } {
            return 1
        } else {
            append text \n\n[= "Errors found"]:
            if { $cntrlx == 0 } {
                append text "\nX " [= "file is blank or filled with alphabetical characters"].
            }
            if { $cntrly == 0 } {
                append text "\nY " [= "file is blank or filled with alphabetical characters"].
            }
            if { $cntrldeltax == 0 } {
                append text "\n" [= "Delta X"] " " [= "file is blank or filled with alphabetical characters"].
            }
            if { $cntrltox == 0 } {
                append text "\n" [= "To X"] " " [= "file is blank or filled with alphabetical characters"].
            }
            WarnWin $text $parent
            return 0
        }
    }
}

proc Function::dump { } {
    variable table
    set nelem [$table index end]
    if { $nelem == 0 } {
        set values "#N# 1 none"
    }
    set nelem [expr 2*$nelem+1]
    set values "#N#" 
    set values [append values " $nelem"]
    foreach currentinput [$table get 0 end] {
        set currentinput [string trim $currentinput]
        set values [append values " $currentinput"]
    }
    set values [append values " none"]
    return $values
}

proc Function::clear { values } {
    variable table
    variable can   
    
    set answer [tk_dialogRAMFull $table.empwiniw {information window} \
            [= "Are you sure you want to clear all values?"] \
            "" "" gidquestionhead 0 [_ "Yes"] [_ "No"]]
    if { $answer == 0 } {
        $values delete 0 end
        Function::IntDrawGraphR $can 
    }    
}
proc Function::IntDrawGraphR { can } {
    variable list
    if { [llength $list] > 1} {
        set aux [join $list]
        set aux [string trim $aux]
        foreach { x y } $aux {
            lappend aux1 $y
        }     
        NasDrawGraph::DrawCurve $can $aux1 [lindex $aux [expr [llength $aux]-2]] X "Y(X)" Graph [lindex $aux 0]
    } else {
        $can delete all
    }
}
namespace eval NasDrawGraph {
    variable c
    variable yvalues
    variable maxx
    variable xlabel
    variable ylabel
    variable title
    variable initialx
    variable xfact "" xm "" yfact "" ym "" ymax "" ynummin "" ynummax ""
    
    proc DrawCurve { cv yvaluesv maxxv xlabelv ylabelv titlev inix} {
        Init $cv $yvaluesv $maxxv $xlabelv $ylabelv $titlev $inix
        Draw
    }
}

proc NasDrawGraph::Init { cv yvaluesv maxxv xlabelv ylabelv titlev inix} {
    variable c $cv
    variable yvalues $yvaluesv
    variable maxx $maxxv
    variable xlabel $xlabelv
    variable ylabel $ylabelv
    variable title $titlev
    variable initialx $inix
}


proc NasDrawGraph::Draw {} {
    variable c
    variable yvalues
    variable maxx
    variable xlabel
    variable ylabel
    variable title
    variable xfact
    variable xm
    variable yfact
    variable ym
    variable ymax
    variable ynummin
    variable ynummax
    variable initialx
    
    $c delete curve
    $c delete axestext
    $c delete titletext
    $c delete zeroline
    
    set inix $initialx
    set numdivisions [expr [llength $yvalues]-1]
    
    set ymax [winfo height $c]
    set xmax [winfo width $c]
    
    set ynummax 0
    set textwidth 0
    for {set i 0 } { $i <= $numdivisions } { incr i } {
        set yval [lindex $yvalues $i]
        if { $yval > $ynummax } {
            set ynummax $yval
        }
        if { $i == 0 || $yval < $ynummin } {
            set ynummin $yval
        }
    }
    if { $ynummax == $ynummin } { set ynummin [expr $ynummin-1] }
    
    set inumtics 8
    for {set i 0 } { $i < $inumtics } { incr i } {
        set yvaltext [format "%.4g" [expr $ynummin+$i/double($inumtics-1)*($ynummax-$ynummin)]]
        regsub {e([+-])00} $yvaltext {e\10} yvaltext
        set tt [font measure NormalFont $yvaltext]
        if { $tt > $textwidth } { set textwidth $tt }
    }
    
    set xm [expr $textwidth+10]
    set textheight [font metrics NormalFont -linespace]
    set ym [expr int($textheight*1.5)+10]
    
    set fam [font configure NormalFont -family]
    set tsize [expr [font configure NormalFont -size]*2]
    $c create text [expr $xmax/2] 6 -anchor n -justify center \
        -text $title -font [list $fam $tsize] -tags titletext
    
    $c create line $xm $ym $xm [expr $ymax-$ym] [expr $xmax-$xm] \
        [expr $ymax-$ym]  -tags axestext
    
    set inumtics 8
    set fam [font configure NormalFont -family]
    set tsize [expr int([expr [font configure NormalFont -size]*0.5])]
    for {set i 0 } { $i < $inumtics } { incr i } {
        set xvaltext [format "%3.1lf" \
                [expr $inix+$i/double($inumtics-1)*($maxx-$inix)]]
        set xval [expr $xm+$i/double($inumtics-1)*($xmax-2*$xm)]
        set xvalt $xval
        if { $i == 0 } { set xvalt [expr $xvalt+4] }
        $c create line $xval [expr $ymax-$ym+2] $xval [expr $ymax-$ym] \
            -tags axestext
        $c create text $xval [expr $ymax-$ym+2] -anchor n -justify center \
            -text $xvaltext -font NormalFont -tags axestext
        
        set yvaltext [format "%.4g" [expr $ynummin+$i/double($inumtics-1)*($ynummax-$ynummin)]]
        regsub {e([+-])00} $yvaltext {e\10} yvaltext
        set yval [expr $ymax-$ym-$i/double($inumtics-1)*($ymax-2*$ym)]
        set yvalt $yval
        if { $i == 0 } { set yvalt [expr $yvalt-4] }
        $c create line [expr $xm-2] $yval $xm $yval -tags axestext
        $c create text [expr $xm-3] $yvalt -anchor e -justify right \
            -text $yvaltext -font [list $fam $tsize] -tags axestext
    }
    $c create text 6 6 -anchor nw -justify left \
        -text $ylabel -font NormalFont -tags axestext
    set textwidth [font measure NormalFont 0.0]
    $c create text [expr $xmax-$xm+$textwidth] [expr $ymax-$ym] \
        -anchor nw -justify left \
        -text $xlabel -font NormalFont -tags axestext
    
    set err [catch { expr ($xmax-2.0*$xm)/double($maxx-$inix) } xfact]
    if { $err } { set xfact 1 }
    set yfact [expr ($ymax-2.0*$ym)/double($ynummax-$ynummin)]
    
    set yval [expr $ymax-$ym-(0.0-$ynummin)*$yfact]
    if { $yval > $ym && $yval <= [expr $ymax-$ym] } {
        $c create line $xm $yval [expr $xmax-$xm] $yval -tags zeroline -dash -.-
    }
    
    set xfactdiv [expr ($xmax-2.0*$xm)/double($numdivisions)]
    set lastyval [expr $ymax-$ym-([lindex $yvalues 0]-$ynummin)*$yfact]
    for {set i 1 } { $i <= $numdivisions } { incr i } {
        set yval [expr $ymax-$ym-([lindex $yvalues $i]-$ynummin)*$yfact]
        $c create line [expr ($i-1)*$xfactdiv+$xm] $lastyval \
            [expr $i*$xfactdiv+$xm] $yval -tags curve -width 3 -fill red
        set lastyval $yval
    }
    
    $c bind curve <ButtonPress-1> "NasDrawGraph::DrawGraphCoords %x %y"
}

proc NasDrawGraph::FindClosestPoint { x y } {
    variable c
    
    set mindist2 1e20
    foreach i [$c find withtag curve] {
        foreach "ax ay bx by" [$c coords $i] break
        set vx [expr $bx-$ax]
        set vy [expr $by-$ay]
        set alpha [expr $vx*($ax-$x)+$vy*($ay-$y)]
        set landa [expr -1*$alpha/double($vx*$vx+$vy*$vy)]
        if { $landa < 0.0 } { set landa 0.0 }
        if { $landa > 1.0 } { set landa 1.0 }
        set px [expr $ax+$landa*$vx]
        set py [expr $ay+$landa*$vy]
        
        set dist2 [expr ($px-$x)*($px-$x)+($py-$y)*($py-$y)]
        if { $dist2 < $mindist2 } {
            set mindist2 $dist2
            set minpx $px
            set minpy $py
        }
    }
    return [list $minpx $minpy]
}

proc NasDrawGraph::DrawGraphCoords { x y } {
    variable c
    variable xlabel
    variable ylabel
    variable xfact
    variable xm
    variable yfact
    variable ym
    variable ymax
    variable ynummin
    variable ynummax
    variable yvalues
    variable initialx
    
    $c delete coords
    $c delete coordpoint
    
    set ymax [winfo height $c]
    set xmax [winfo width $c]
    
    if { [lindex $yvalues end] < ($ynummax-$ynummin)/2.0 } {
        foreach "{} {} {} ytitle" [$c bbox titletext] break
        set ytitle [expr $ytitle+2]
        set anchor ne
    } else {
        set ytitle [expr $ymax-$ym-5]
        set anchor se
    }
    
    foreach "xcurve ycurve" [NasDrawGraph::FindClosestPoint $x $y] break
    
    $c create oval [expr $xcurve-2] [expr $ycurve-2] [expr $xcurve+2] [expr $ycurve+2] \
        -tags coordpoint
    
    set xtext [expr ($xcurve-$xm)/double($xfact)+$initialx]
    regsub {e([+-])00} $xtext {e\10} xtext
    set ytext [expr ($ymax-$ym-$ycurve)/double($yfact)+$ynummin]
    regsub {e([+-])00} $ytext {e\10} ytext
    
    $c create text [expr $xmax-6] $ytitle -anchor $anchor -font NormalFont \
        -text [format "$xlabel: %.4g  $ylabel: %.4g" $xtext $ytext] -tags coords
    
    $c bind curve <ButtonRelease-1> "$c delete coords coordpoint; $c bind curve <B1-Motion> {}"
    $c bind curve <B1-Motion> "NasDrawGraph::DrawGraphCoords %x %y"
}
