proc LoadCasesInit { dir } {
    global ProblemTypePriv
    
    for { set i 1 } { $i <= 9 } { incr i } {
        set ProblemTypePriv(loadcaseimg$i) [image create photo \
                -file [file join $dir images l$i.gif]]
    } 
    set ProblemTypePriv(loadcaseimgldots) [image create photo \
            -file [file join $dir images ldots.gif]]
    set ProblemTypePriv(loadcaseimgcheck) [image create photo \
            -file [file join $dir images check.gif]]
    set ProblemTypePriv(loadcaseimgrename) [image create photo \
            -file [file join $dir images rename.gif]]
    set ProblemTypePriv(loadcaseimgerase-cross) [image create photo \
            -file [file join $dir images erase-cross.gif]]
    set ProblemTypePriv(loadcaseimgchecked-off) [image create photo \
            -file [file join $dir images checked-off.gif]]
    set ProblemTypePriv(loadcaseimgelu) [image create photo \
            -file [file join $dir images elu.gif]]
    set ProblemTypePriv(loadcaseimgchecked-on) [image create photo \
            -file [file join $dir images checked-on.gif]]
    
    set ProblemTypePriv(imagesdir) [file join $dir images]
    
    
    set ProblemTypePriv(condfuns) "DWAssignCond DWEntitiesCond DWDrawConds \
        DWUnassignSome DWUnassignAllThis DWUnassignAllCND"
    
    auto_load DWAssignCond
    foreach i $ProblemTypePriv(condfuns) {
        catch { rename $i $i-base }
        proc $i { GDN args } "LoadCasesCondFuncs $i-base \$GDN \$args"
    }
    
    set therearechanges [lindex [GiD_Info Project] 2]
    set DisableWriteBatch 1
    catch {
        set DisableWriteBatch [.central.s disable writebatch]
        .central.s disable writebatch 1
    }
    GetLoadCaseNames
    ChangeToLoadCase 1
    
    if { !$therearechanges } {
        GiD_Process *****CLEARPROJECTCHANGES
        #after idle .central.s clearprojectchanges
    }
    if { !$DisableWriteBatch } { .central.s disable writebatch 0 }
}

proc LoadCasesBackToIntervalOne {} {
    
    delayedop -cancel changefunc "LoadCasesBackToIntervalOne"
    
    set DisableGraphics [.central.s disable graphics]
    set DisableWarnLine [.central.s disable warnline]
    
    .central.s disable graphics 1
    .central.s disable warnline 1
    
    .central.s wordcomeraseall
    
    GiD_Process escape escape escape escape data intervals changeinterval 1 escape
    
    if { !$DisableGraphics } { .central.s disable graphics 0 }
    if { !$DisableWarnLine } { .central.s disable warnline 0 }
}

proc LoadCasesDraw { what } {
    global ProblemTypePriv
    
    switch $what {
        constraints {
            set intervaltochange [expr $ProblemTypePriv(currentloadcase)+1]
            set books [list "Constraints" "Connections" "Static_Loads" "Dynamic_Loads" \
                    "Thermal Loads" "Heat Boundaries"]
        }
        loads {
            set intervaltochange [expr $ProblemTypePriv(currentloadcase)+1]
            set books [list "Static_Loads" "Dynamic_Loads" "Constraints" "Connections" \
                    "Thermal Loads" "Heat Boundaries"]
        }
        properties {
            set intervaltochange 1
            set books [list "Local_Axes" "Advanced_Conditions"]
        }
    }
    
    set DisableGraphics [.central.s disable graphics]
    set DisableWarnLine [.central.s disable warnline]
    
    GiD_Process escape escape escape escape
    
    .central.s disable graphics 1
    .central.s disable warnline 1
    
    GiD_Process data intervals changeinterval $intervaltochange escape
    
    if { !$DisableGraphics } { .central.s disable graphics 0 }
    if { !$DisableWarnLine } { .central.s disable warnline 0 }
    
    GiD_Process escape escape escape escape data conditions drawcond -BOOKS- {*}$books -draw-
    
    delayedop changefunc "LoadCasesBackToIntervalOne"
}

proc LoadCasesCondFuncs { func GDN args } {
    global ProblemTypePriv
    
    upvar \#0 $GDN GidData
    
    set intervaltochange 1
    if { $GidData(BOOK) == "Static_Loads" || $GidData(BOOK) == "Dynamic_Loads" || $GidData(BOOK) =="Constraints" \
        || $GidData(BOOK) =="Connections"} {
        set intervaltochange [expr $ProblemTypePriv(currentloadcase)+1]
    }
    set DisableGraphics [.central.s disable graphics]
    set DisableWarnLine [.central.s disable warnline]
    
    .central.s disable graphics 1
    .central.s disable warnline 1
    
    GiD_Process escape escape escape escape
    GiD_Process data intervals changeinterval $intervaltochange escape
    
    if { !$DisableGraphics } { .central.s disable graphics 0 }
    if { !$DisableWarnLine } { .central.s disable warnline 0 }
    
    set execline [list $func $GDN]
    foreach i [lindex $args 0] { 
        lappend execline $i
    }
    eval $execline
    
    # it is cancelled before just for strange cases
    delayedop -cancel changefunc "LoadCasesBackToIntervalOne"
    set fail [delayedop changefunc "LoadCasesBackToIntervalOne"]
    if { $fail == 1 } {
        LoadCasesBackToIntervalOne
    }
}

proc GetLoadCaseNames {} {
    global ProblemTypePriv
    
    set DisableGraphics [.central.s disable graphics]
    set DisableWarnLine [.central.s disable warnline]
    
    .central.s disable graphics 1
    .central.s disable warnline 1
    
    foreach "current total" [GiD_Info intvdata num] break
    
    set ProblemTypePriv(loadcasenames) ""
    for { set i 2 } { $i <= $total } { incr i } {
        GiD_Process escape escape escape escape data intervals changeinterval $i escape
        lappend ProblemTypePriv(loadcasenames) [lindex [GiD_Info intvdata] 2]
    }
    GiD_Process escape escape escape escape data intervals changeinterval 1 escape
    
    if { !$DisableGraphics } { .central.s disable graphics 0 }
    if { !$DisableWarnLine } { .central.s disable warnline 0 }
    
}

proc AddHelpToLoadCaseIcon { text } {
    global ProblemTypePriv
    
    set var ""
    foreach i [split [bind $ProblemTypePriv(loadcasewin) <Enter>] \n] {
        if { ![string match DisplayGidHelpLauncher* $i] } {
            append var $i\n
        }
    }
    bind $ProblemTypePriv(loadcasewin) <Enter> $var
    
    GidHelpT $ProblemTypePriv(loadcasewin) $text
}

proc NewLoadCase { { name "" } {parent .gid } } {
    global ProblemTypePriv
    
    if { $name == "" } {
        set text [= "Enter new load case name"]
        while 1 {
            set var [list rambshell_dialogCombo $parent.temp {New load case} \
                    $text question 1]
            
            set args ""
            foreach i $ProblemTypePriv(loadcasenames) {
                regsub -all {_} $i { } iname
                lappend args $iname
            }
            lappend var $args
            set name [eval $var]
            if { $name == "--CANCEL--" } { return }
            set name [string trim $name "\" \t"]
            regsub -all {\s+} $name {_} name
            if { ![regexp {^\w+$} $name] } {
                set text [= "Name must contain only letters and numbers and spaces. Enter new load case name"]
            } elseif { [lsearch $ProblemTypePriv(loadcasenames) $name] != -1 } {
                set text [= "Name already exists. Enter new load case name"]
            } else { break }
        }
    }
    
    set DisableGraphics [.central.s disable graphics]
    set DisableWarnLine [.central.s disable warnline]
    
    .central.s disable graphics 1
    .central.s disable warnline 1
    
    GiD_Process escape escape escape escape data intervals newinterval yes no
    GiD_Process escape escape escape escape data IntervalData $name escape
    
    lappend ProblemTypePriv(loadcasenames) $name
    set len [llength $ProblemTypePriv(loadcasenames)]
    
    if { !$DisableGraphics } { .central.s disable graphics 0 }
    if { !$DisableWarnLine } { .central.s disable warnline 0 }
    
    ChangeToLoadCase $len
    
    if { [info exists ProblemTypePriv(loadcasestype)] } {
        # trick to update the combined load cases frame
        set ProblemTypePriv(loadcasestype) $ProblemTypePriv(loadcasestype)
    }
} 

proc DeleteLoadCase { { parent .gid } } {
    global ProblemTypePriv
    
    if { [llength $ProblemTypePriv(loadcasenames)] == 1 } {
        WarnWin [= "Load case cannot be deleted. There must be, at least, one loadcase"]
        return
    }
    
    set im1 [expr $ProblemTypePriv(currentloadcase)-1]
    set name [lindex $ProblemTypePriv(loadcasenames) $im1]
    regsub -all {_} $name { } vname
    
    set retval [tk_dialogRAM $parent.tempwiniw {Confirm deletion} \
            [= "Are you sure to delete current loadcase '%s'?" $vname] \
            questhead 0 [= "Yes"] [= "No"]]
    if { $retval == 1 } { return }
    
    set DisableGraphics [.central.s disable graphics]
    set DisableWarnLine [.central.s disable warnline]
    set DisableWindows [.central.s disable windows]
    
    .central.s disable graphics 1
    .central.s disable warnline 1
    .central.s disable windows 1
    
    set ProblemTypePriv(loadcasenames) [lreplace $ProblemTypePriv(loadcasenames) \
            $im1 $im1]
    
    GiD_Process escape escape escape escape data intervals ChangeInterval \
        [expr $ProblemTypePriv(currentloadcase)+1]
    GiD_Process escape escape escape escape data intervals DeleteInterval yes escape
    GiD_Process escape escape escape escape data intervals ChangeInterval 1
    
    if { !$DisableGraphics } { .central.s disable graphics 0 }
    if { !$DisableWarnLine } { .central.s disable warnline 0 }
    if { !$DisableWindows } {  .central.s disable windows 0 }
    
    ChangeToLoadCase $ProblemTypePriv(currentloadcase)
    
    if { [info exists ProblemTypePriv(loadcasestype)] } {
        # trick to update the combined load cases frame
        set ProblemTypePriv(loadcasestype) $ProblemTypePriv(loadcasestype)
    }
} 

proc RenameLoadCase { { parent .gid } } {
    global ProblemTypePriv
    
    set im1 [expr $ProblemTypePriv(currentloadcase)-1]
    set name [lindex $ProblemTypePriv(loadcasenames) $im1]
    regsub -all {_} $name { } vname
    
    set text [= "Enter new name for loadcase '%s'" $vname]
    
    while 1 {
        set var [list rambshell_dialogCombo $parent.temp {rename load case} \
                $text question 1]
        
        set args ""
        foreach i $ProblemTypePriv(loadcasenames) {
            regsub -all {_} $i { } name
            lappend args $name
        }
        lappend var $args
        set retval [eval $var]
        if { $retval == "--CANCEL--" } { return }
        set retval [string trim $retval "\" \t"]
        regsub -all {\s+} $retval {_} retval
        if { ![regexp {^\w+$} $retval] } {
            set text [= "Name must contain only letters and numbers and spaces. Enter new name for loadcase '%s'" $vname]
        } elseif { [lsearch $ProblemTypePriv(loadcasenames) $retval] != -1 } {
            set text [= "Name already exists. Enter new name for loadcase '%s'" $vname]
        } else { break }
    }
    
    set DisableGraphics [.central.s disable graphics]
    set DisableWarnLine [.central.s disable warnline]
    
    .central.s disable graphics 1
    .central.s disable warnline 1
    
    GiD_Process escape escape escape escape data intervals ChangeInterval \
        [expr $ProblemTypePriv(currentloadcase)+1]
    GiD_Process escape escape escape escape data IntervalData $retval escape
    GiD_Process escape escape escape escape data intervals ChangeInterval 1
    
    set ProblemTypePriv(loadcasenames) [lreplace $ProblemTypePriv(loadcasenames) \
            $im1 $im1 $retval]
    
    if { !$DisableGraphics } { .central.s disable graphics 0 }
    if { !$DisableWarnLine } { .central.s disable warnline 0 }
    
    ChangeToLoadCase $ProblemTypePriv(currentloadcase)
    
    if { [info exists ProblemTypePriv(loadcasestype)] } {
        # trick to update the combined load cases frame
        set ProblemTypePriv(loadcasestype) $ProblemTypePriv(loadcasestype)
    }
} 

proc ChangeToLoadCaseCombo {} {
    global ProblemTypePriv
    
    set name $ProblemTypePriv(loadcasecombotext)
    if { $name == "" } { return }
    regsub -all { } $name {_} name
    set num [lsearch $ProblemTypePriv(loadcasenames) $name]
    incr num
    ChangeToLoadCase $num
}

proc ChangeToLoadCase { num } {
    global ProblemTypePriv
    #    UpdateLoadCaseNames
    set len [llength $ProblemTypePriv(loadcasenames)]
    
    if { !$len } {
        NewLoadCase "Load_case_1"
        #this func is called by NewLoadCase
        return
    }
    
    if { $num > $len } { set num $len }
    
    if { [info exists  ProblemTypePriv(currentloadcase)] && \
        $ProblemTypePriv(currentloadcase) != $num } {
        GiD_Process escape escape escape escape
    }
    
    if { [info exists ProblemTypePriv(loadcasewin)] && \
        [winfo exists $ProblemTypePriv(loadcasewin)] } {
        
        if { $num < 10 } {
            $ProblemTypePriv(loadcasewin) conf -image $ProblemTypePriv(loadcaseimg$num)
        } else {
            $ProblemTypePriv(loadcasewin) conf -image $ProblemTypePriv(loadcaseimgldots)
        }
        
        set menu [$ProblemTypePriv(loadcasewin) cget -menu]
        $menu del 0 end
        for { set i 1 } { $i <= $len } { incr i } {
            set im1 [expr $i-1]
            set name [lindex $ProblemTypePriv(loadcasenames) $im1]
            regsub -all {_} $name { } name
            set name "Loadcase: \[$i] $name"
            if { $i != $num } {
                $menu add command
            } else {
                $menu add checkbutton -onvalue 0
                AddHelpToLoadCaseIcon $name
            }
            $menu entryconf $im1 -label $name -command \
                "ChangeToLoadCase $i"
        }
        $menu add separator
        $menu add command -label [= "New"] -command NewLoadCase
        $menu add command -label [= "Delete"] -command DeleteLoadCase
        $menu add command -label [= "Rename"] -command RenameLoadCase
        $menu add command -label [= "Load case window"]... -command LoadCaseWindow
    }
    if { [info exists ProblemTypePriv(loadcasecombo)] && \
        [winfo exists $ProblemTypePriv(loadcasecombo)] } {
        $ProblemTypePriv(loadcasecombo) conf -editable 1
        set lcns ""
        set inum 1
        foreach i $ProblemTypePriv(loadcasenames) {
            regsub -all {_} $i { } name
            lappend lcns $name
            if { $inum == $num } {
                set cname $name
            }
            incr inum
        }
        $ProblemTypePriv(loadcasecombo) conf -history $lcns
        $ProblemTypePriv(loadcasecombo) del 0 end
        $ProblemTypePriv(loadcasecombo) ins end $cname
        $ProblemTypePriv(loadcasecombo) conf -editable 0
    }
    
    set ProblemTypePriv(currentloadcase) $num
}
proc UpdateLoadCaseNames {} {
    global ProblemTypePriv
    
    foreach "current total" [GiD_Info intvdata num] break
    if { [llength $ProblemTypePriv(loadcasenames)] == [expr $total-1] } return
    
    set DisableGraphics [.central.s disable graphics]
    set DisableWarnLine [.central.s disable warnline]
    
    .central.s disable graphics 1
    .central.s disable warnline 1
    
    #    set ProblemTypePriv(loadcasenames) ""
    for { set i 2 } { $i <= $total } { incr i } {
        GiD_Process escape escape escape escape data intervals changeinterval \
            $i escape
        lappend ProblemTypePriv(loadcasenames) [lindex [GiD_Info intvdata] 2]
    }
    GiD_Process escape escape escape escape data intervals changeinterval $current escape
    
    if { !$DisableGraphics } { .central.s disable graphics 0 }
    if { !$DisableWarnLine } { .central.s disable warnline 0 }
}

proc LoadCaseWindow {} {
    global ProblemTypePriv
    
    
    UpdateLoadCaseNames
    
    set FontHeight [font metric NormalFont -linespace]
    set FramesSeparation [expr $FontHeight/2+1]
    set w .gid.loadcases
    
    if { [info procs InitWindow] != "" } {
        InitWindow $w [= "Load cases"] PreLoadCasesWindowGeom LoadCaseWindow
    } else {
        toplevel $w
    }
    
    framelabel $w.fl [= "Load Cases type"]
    frame $w.fl.f
    grid $w.fl.f -pady $FramesSeparation -sticky nw
    
    radiobutton $w.fl.f.r1 -text [= "Prestress model"] \
        -var ProblemTypePriv(loadcasestype) -value prestress
    radiobutton $w.fl.f.r2 -text [= "One result for every loadcase"] \
        -var ProblemTypePriv(loadcasestype) -value independent
    radiobutton $w.fl.f.r3 -text [= "Use combined loadcases"] \
        -var ProblemTypePriv(loadcasestype) -value combined
    
    GidHelp "$w.fl.f.r1 $w.fl.f.r2 $w.fl.f.r3" [= "These options control the way of dealing with"\
            " loadcases:\n.-Prestress model: There will be one combined loadcase that"\
            " will contain all simple loadcases used to calculate prestress in the model and "\
            " anohter combined loadcase with the poststress loads. \n.-One results for every laodcase:"\
            " There will be one combined loadcase for every simple loadcase. User can enter the"\
            " amplification factors.\n.-Use combined loadcases: It is possible to define as many"\
            " combined loadcases as desired. Every one will be composed by a combination of simple"\
            " loadcases with amplification factors entered by the user."]
    
    grid $w.fl.f.r1 -sticky nw
    grid $w.fl.f.r2 -sticky nw
    grid $w.fl.f.r3 -sticky nw
    
    framelabel $w.f1b [= "Current Load Case"]
    frame $w.f1b.f
    grid $w.f1b.f -pady $FramesSeparation -sticky nwes -padx 2 -row 1 -column 1
    grid columnconf $w.f1b 1 -weight 1
    set lcns ""
    set inum 1
    foreach i $ProblemTypePriv(loadcasenames) {
        regsub -all {_} $i { } name
        lappend lcns $name
        if { $inum == $ProblemTypePriv(currentloadcase) } {
            set cname $name
        }
        incr inum
    }
    set ProblemTypePriv(loadcasecombo) [combobox $w.f1b.f.c -editable 1 \
            -keephistory 0 -history $lcns -textvar ProblemTypePriv(loadcasecombotext)]
    $w.f1b.f.c del 0 end
    $w.f1b.f.c ins end $cname
    $w.f1b.f.c conf -editable 0
    
    GidHelp $w.f1b.f.c [= "This is a list of all created simple loadcases. In this menu it is "\
            "selected the active loadcase. All new loads assigned to entities will be inserted"\
            " in the active loadcase. The active loadcase can also be changed in the Ram Series"\
            " toolbars buttons."]
    
    trace var ProblemTypePriv(loadcasecombotext) w "ChangeToLoadCaseCombo ;#"
    
    button $w.f1b.f.b1 -image $ProblemTypePriv(loadcaseimgcheck) -padx 0 -bd 1 -pady 0 \
        -command "NewLoadCase {} $w"
    GidHelp $w.f1b.f.b1 [= "Creates new simple load case"]
    button $w.f1b.f.b2 -image $ProblemTypePriv(loadcaseimgrename) -padx 0 -bd 1 -pady 0 \
        -command "RenameLoadCase $w"
    GidHelp $w.f1b.f.b2 [= "Renames current simple load case"]
    button $w.f1b.f.b3 -image $ProblemTypePriv(loadcaseimgerase-cross) -padx 0 -bd 1 -pady 0 \
        -command "DeleteLoadCase $w"
    GidHelp $w.f1b.f.b3 [= "Deletes current simple load case. All loads contained in this loadcase will be deleted, too"].
    
    grid $w.f1b.f.c -row 1 -column 1 -padx 2 -sticky ew
    grid $w.f1b.f.b1 -row 1 -column 2 -padx 0
    grid $w.f1b.f.b2 -row 1 -column 3 -padx 0
    grid $w.f1b.f.b3 -row 1 -column 4 -padx 0
    grid columnconf $w.f1b.f 1 -weight 1
    
    framelabel $w.f2 [= "Combined Load Cases"]
    frame $w.f2.f
    grid $w.f2.f -pady $FramesSeparation -sticky nwes -row 1 -column 1
    grid columnconf $w.f2 1 -weight 1
    grid rowconf $w.f2 1 -weight 1
    canvas $w.f2.f.c -xscrollcommand "$w.f2.f.sx set" -yscrollcommand \
        "$w.f2.f.sy set" -highlightthickness 0
    frame $w.f2.f.c.f
    $w.f2.f.c create window 0 0 -window $w.f2.f.c.f -anchor nw
    scrollbar $w.f2.f.sx -orient h -command "$w.f2.f.c xview"
    scrollbar $w.f2.f.sy -orient v -command "$w.f2.f.c yview"
    
    proc ScrollHideShow  { c sx sy } {
        foreach "a b" [$c xview] ""
        if { $a == 0.0 && $b == 1.0 } {
            grid remove $sx
        } else {
            grid $sx
        }
        foreach "a b" [$c yview] ""
        if { $a == 0.0 && $b == 1.0 } {
            grid remove $sy
        } else {
            grid $sy
        }
    }
    bind $w.f2.f.c <Configure> "after idle ScrollHideShow $w.f2.f.c $w.f2.f.sx $w.f2.f.sy"
    
    
    grid $w.f2.f.c -sticky nsew -row 1 -column 1
    grid $w.f2.f.sy -sticky ns -row 1 -column 2
    grid $w.f2.f.sx -sticky ew -row 2 -column 1
    grid columnconf $w.f2.f 1 -weight 1
    grid rowconf $w.f2.f 1 -weight 1
    
    frame $w.const
    set bgcolor [ $w.const cget -bg]
    proc chkbuttonupdate { value window} { 
        if { $value == 0 } { 
            event generate $window <<desactivate>>
        } else { 
            event generate $window <<activate>> 
        }
    }
    
    checkbutton $w.const.chk -text [= "Same constraints for all load cases"] \
        -var chk -command { chkbuttonupdate $chk .gid.loadcases }
    GidHelp $w.const.chk [= "Contraints defined in the selected load case will be used for all load cases."]
    label $w.const.label -text LoadCase -disabledforeground grey60 -foreground black
    bind $w <<desactivate>> "$w.const.label  configure -state disabled "
    bind $w <<activate>> "$w.const.label  configure -state normal "
    
    proc comboupdate { combo } {
        global ProblemTypePriv
        $combo configure -values $ProblemTypePriv(loadcasenames)
    } 
    ComboBox $w.const.cblcase -values $ProblemTypePriv(loadcasenames) \
        -textvariable ProblemTypePriv(constraints) -editable false \
        -postcommand "comboupdate $w.const.cblcase"
    
    bind $w <<desactivate>> "+ $w.const.cblcase  configure -state disabled -entrybg $bgcolor;  set ProblemTypePriv(constraints) {} "
    bind $w <<activate>> "+ $w.const.cblcase  configure -state normal -entrybg white ;
        set ProblemTypePriv(constraints) [lindex $ProblemTypePriv(loadcasenames) 0] "
    
    
    grid $w.const.chk -column 0 -row 0
    grid $w.const.label -column 1 -row 0
    grid $w.const.cblcase -column 2 -row 0
    
    frame $w.buts
    button $w.buts.acc -text [= "Accept"] -und 0 -width 11 -command \
        "AcceptLCData $w.f2.f.c.f $w.f2.f.c"
    button $w.buts.cancel -text [= "Close"] -und 0 -width 11 -command \
        "destroy $w"
    button $w.buts.hp -image [imagefromram questionarrow.gif] -command "PickHelp $w.buts.hp" \
        -highlightthickness 0
    
    GidHelp $w.buts.acc [= "This button stores all the changes made inside this window"].
    GidHelp $w.buts.cancel [= "This button closes the window. If changes are to be accepted, press before button 'Accept data'"].
    
    bind $w <Alt-a> "tkButtonInvoke $w.buts.acc"
    bind $w <Alt-c> "tkButtonInvoke $w.buts.cancel"
    bind $w <Escape> "tkButtonInvoke $w.buts.cancel"
    grid $w.buts.acc -row 1 -column 1 -padx 2
    grid $w.buts.cancel -row 1 -column 2 -padx 2
    grid $w.buts.hp -row 1 -column 3 -padx 2
    
    grid $w.fl -pady $FramesSeparation -sticky nsew -row 1 -column 1 -padx 1
    grid $w.f1b -pady $FramesSeparation -sticky nsew -row 1 -column 2 -padx 1
    grid $w.f2 -pady $FramesSeparation -sticky nwes -row 2 -column 1 \
        -columnspan 2 -padx 1
    grid $w.const -sticky ew -row 3 -column 1 -columnspan 2 -padx 1 -pady 2
    grid $w.buts -sticky ew -row 4 -column 1 -columnspan 2 -padx 1 -pady 2
    grid columnconf $w 1 -weight 1
    grid columnconf $w 2 -weight 1
    grid rowconf $w 2 -weight 1
    
    trace var ProblemTypePriv(loadcasestype) w "CombinedLCUpdate $w.f2.f.c.f $w.f2.f.c ;#"
    
    set gendata [GiD_Info gendata]
    foreach "name value" [lrange $gendata 1 end] {
        if { [string match Activate_Load_Cases* $name] } {
            set lct $value
            set ProblemTypePriv(loadcasestype) $lct
        } elseif { [string match Combined_load_cases* $name] } {
            set ProblemTypePriv(combined) [lrange $value 2 end]
        } elseif { [string match Constraints_load_cases* $name] } {
            if { $value == "none" } { 
                set ProblemTypePriv(constraints) {}
                set chk 0
                $w.const.chk deselect
                event generate $w <<desactivate>>
            } else { 
                set ProblemTypePriv(constraints) $value
                set chk 1
                $w.const.chk select
                event generate $w <<activate>>
            }
        }
    }
}

proc ChangeStateChildren { w newstate } {
    foreach i [winfo children $w] {
        catch { $i conf -state $newstate }
        if { $newstate == "disabled" } {
            catch {
                $i conf -fg grey60
            }
            bind $i <Double-1> ""
            bind $i <3> ""
        } else {
            catch {
                $i conf -fg black
            }
        }
        ChangeStateChildren $i $newstate
    }
}

proc AcceptLCData { w canvas } {
    global ProblemTypePriv
    
    ComputeValuesFromCanvas $w
    
    set DisableGraphics [.central.s disable graphics]
    set DisableWarnLine [.central.s disable warnline]
    
    .central.s disable graphics 1
    .central.s disable warnline 1
    
    if { !$DisableGraphics } { .central.s disable graphics 0 }
    if { !$DisableWarnLine } { .central.s disable warnline 0 }
    
    set newgendata ""
    foreach "name value" [lrange [GiD_Info gendata] 1 end] {
        if { [string match Activate_Load_Cases* $name] } {
            lappend newgendata $ProblemTypePriv(loadcasestype)
        } elseif { [string match Combined_load_cases* $name] } {
            #             set numlost 0
            #             while { [string length $ProblemTypePriv(combined)] > 1000 } {
                #                 set len [llength $ProblemTypePriv(combined)]
                #                 set ProblemTypePriv(combined) [lrange $ProblemTypePriv(combined) 0 \
                    #                         [expr $len-4]]
                #                 incr numlost
                #             }
            #             if { $numlost } {
                #                 WarnWin [concat "Error: One internal limit has been reached. $numlost "\
                    #                         "combined load cases could not be maintained"]
                #                 CombinedLCUpdate $w $canvas 0
                #             }
            
            lappend newgendata [concat "#N# [llength $ProblemTypePriv(combined)] "\
                    "$ProblemTypePriv(combined)"]
        } elseif { [string match Constraints_load_cases* $name]  } {
            if { $ProblemTypePriv(constraints) == {}} {
                lappend newgendata none
            } else {
                lappend newgendata $ProblemTypePriv(constraints)
            }
        } else {
            lappend newgendata [DWSpace2Under $value]
        }
    }
    GiD_Process escape escape escape escape data ProblemData {*}$newgendata escape    
    
    if { !$DisableGraphics } { .central.s disable graphics 0 }
    if { !$DisableWarnLine } { .central.s disable warnline 0 }
}

proc ComputeValuesFromCanvas { w } {
    global ProblemTypePriv
    
    set ProblemTypePriv(combined) ""
    set i 1
    while 1 {
        if { ![winfo exists $w.v$i] } { break }
        set name [$w.v$i cget -text]
        regsub -all { } $name {_} name
        set values ""
        set j 1
        while 1 {
            if { ![winfo exists $w.v$i-$j] } { break }
            if { [$w.v$i-$j cget -state] == "normal" } {
                set lname [$w.l$j cget -text]
                regsub -all { } $lname {_} lname
                set value [$w.v$i-$j get]
                
                if { [catch { set value [expr double($value)] }] } {
                    set value 0.0
                }
                if { $value != 0.0 } {
                    if { $values != "" } { append values , }
                    append values $value,$lname
                }
                
            }
            incr j
        }
        if { $values != "" } {
            lappend ProblemTypePriv(combined) $name
            lappend ProblemTypePriv(combined) $ProblemTypePriv(isstrength,$i)
            lappend ProblemTypePriv(combined) $values
        }
        incr i
    }
}

proc LCNameExists { newname } {
    global ProblemTypePriv
    
    regsub -all { } $newname {_} newname
    foreach "name isstrength values" $ProblemTypePriv(combined) {
        if { $newname == $name } { return 1 }
    }
    return 0
}

proc LCHelpForCombined { w x y } {
    set pos [lsearch [bind $w <ButtonPress-3>] DisplayGidHelpMenu]
    if { $pos != -1 } {
        incr pos 2
        set text [lindex [bind $w <ButtonPress-3>] $pos]
    } else {
        set text [= "There is no help for this item"]
    }
    DisplayGidHelp $w $text menu $x $y
}

proc CreateLCMenu {w wl canvas inum x y } {
    
    catch { destroy $w.menu }
    menu $w.menu
    $w.menu add command -label [= "Insert after"] -command \
        "CombinedLCOperations $w $canvas [expr $inum+1] insertrow"
    $w.menu add separator
    $w.menu add command -label [= "Insert before"] -command \
        "CombinedLCOperations $w $canvas $inum insertrow"
    $w.menu add command -label [= "Delete"] -command \
        "CombinedLCOperations $w $canvas $inum deleterow"
    $w.menu add separator
    $w.menu add command -label [= "Change factor"] -command \
        "CombinedLCOperations $w $canvas $inum setvalue"
    $w.menu add command -label [= "Rename"] -command \
        "CombinedLCOperations $w $canvas $inum rename"
    $w.menu add separator
    $w.menu add command -label [= "Help"] -command \
        "LCHelpForCombined $wl $x $y"
    tk_popup $w.menu $x $y 0
}

proc CombinedLCOperations { w canvas inum what { x 0 } } {
    global ProblemTypePriv
    
    switch $what {
        rename {
            entry $w.v$inum.e -relief [$w.v$inum cget -relief] -bd [$w.v$inum cget -bd] \
                -fg [$w.v$inum cget -fg] -bg [$w.v$inum cget -bg] \
                -highlightthickness 0
            $w.v$inum.e del 0 end
            $w.v$inum.e ins end [$w.v$inum cget -text]
            place $w.v$inum.e -in $w.v$inum -x 0 -y 0 -anchor nw -relwidth 1 -relheight 1 \
                -bordermode outside
            
            focus $w.v$inum.e
            tkwait visibility $w.v$inum.e
            grab $w.v$inum.e
            $w.v$inum.e icursor @$x
            
            ComputeValuesFromCanvas $w
            bind $w.v$inum.e <Return> {
                set newname [%W get]
                if { ![LCNameExists $newname] } {
                    [winfo parent %W] conf -text $newname
                }
                destroy %W
                break
            }
            bind $w.v$inum.e <Escape> "destroy %W ; break"
            bind $w.v$inum.e <ButtonPress> {
                if { %x < 0 || %x > [winfo width %W] || %y < 0 || %y > [winfo height %W] } {
                    set newname [%W get]
                    if { ![LCNameExists $newname] } {
                        [winfo parent %W] conf -text $newname
                    }
                    destroy %W
                    break
                }
            }
        }
        setvalue {
            set name [$w.v$inum cget -text]
            set retval [tk_dialogEntryRAM $w.temp [= "Enter factor"] \
                    [= "Enter a factor for all the load cases of '%s'" $name] \
                    question real 1.0]
            if { $retval == "--CANCEL--" } { return }
            ComputeValuesFromCanvas $w
            regsub -all { } $name {_} name
            
            set values ""
            set first 1
            foreach i $ProblemTypePriv(loadcasenames) {
                if { !$first } { 
                    append values ,
                } else { set first 0 }
                append values $retval,$i
            }
            set ProblemTypePriv(combined) [lreplace $ProblemTypePriv(combined) \
                    [expr ($inum-1)*3+2] [expr ($inum-1)*3+2] $values]
            CombinedLCUpdate $w $canvas 0
        }
        insertrow {
            if {$inum == "end" } {
                set inum [expr [llength $ProblemTypePriv(combined)]/3+1]
            }
            
            ComputeValuesFromCanvas $w
            set i 1
            while 1 {
                set newname Combined_$i
                if { ![LCNameExists $newname] } { break }
                incr i
            }
            set values ""
            set first 1
            foreach i $ProblemTypePriv(loadcasenames) {
                if { !$first } { 
                    append values ,
                } else { set first 0 }
                append values 1.0,$i
            }
            set ProblemTypePriv(combined) [linsert $ProblemTypePriv(combined) \
                    [expr ($inum-1)*3] $newname 1 $values]
            CombinedLCUpdate $w $canvas 0
        }
        deleterow {
            if {$inum == "end" } {
                set inum [expr [llength $ProblemTypePriv(combined)]/3]
            }
            
            ComputeValuesFromCanvas $w
            set ProblemTypePriv(combined) [lreplace $ProblemTypePriv(combined) \
                    [expr ($inum-1)*3] [expr ($inum-1)*3+2]]
            CombinedLCUpdate $w $canvas 0
        }
    }
}

proc CombinedLCUpdate { w canvas { recompute 1 } } {
    global ProblemTypePriv
    
    if { ![winfo exists $w] } { return }
    if { [winfo children $w] != "" && $recompute } { ComputeValuesFromCanvas $w }
    
    foreach i [winfo children $w] { destroy $i }
    
    set ncases [llength $ProblemTypePriv(loadcasenames)]
    
    #     label $w.l0 -image $ProblemTypePriv(loadcaseimgelu) -bd 1 -relief raised
    #     GidHelp $w.l0 "When column 'ELU' is active means that 'combined "\
        #             "load cases' are used to calculate strengths. If not, they are preferred "\
        #             "to calculate displacements. This option do not change the analysis. It is only"\
        #             " used to dimension concrete."
    #     grid $w.l0 -row 0 -column 1 -sticky ew
    for { set i 1 } { $i <= $ncases } { incr i } {
        set name [lindex $ProblemTypePriv(loadcasenames) \
                [expr $i-1]]
        regsub -all {_} $name { } name
        label $w.l$i -text $name -bd 1 -relief raised
        GidHelp $w.l$i [= "These are the simple loadcases.\nA combination of simple loadcases with its"\
                " amplification factors defines a combined loadcase. There will be one result"\
                " for every combined loadcase."]
        grid $w.l$i -row 0 -column [expr $i+1]  -sticky ew
    }
    
    if { [info exists ProblemTypePriv(loadcasestypeold)] && $ProblemTypePriv(loadcasestypeold) != \
        $ProblemTypePriv(loadcasestype) } {
        set ProblemTypePriv(combined) ""
    }
    
    if {[info exists ProblemTypePriv(combined)]} {
        if { $ProblemTypePriv(combined) == "" } {
            set ProblemTypePriv(combined) "Combined_1 1 "
            set first 1
            foreach i $ProblemTypePriv(loadcasenames) {
                if { $first } {
                    set first 0
                } else { append ProblemTypePriv(combined) , }
                append ProblemTypePriv(combined) "1.0,$i"
            }
        }
    }
    if { $ProblemTypePriv(loadcasestype) == "independent" } {
        if {[info exists ProblemTypePriv(combined]} {
            set combined_base $ProblemTypePriv(combined)   
        } else {
            set combined_base ""
        }       
        
        set ProblemTypePriv(combined) ""
        for { set i 1 } { $i <= $ncases } { incr i } {
            set name [lindex $ProblemTypePriv(loadcasenames) \
                    [expr $i-1]]
            set ipos [expr ($i-1)*3]
            lappend ProblemTypePriv(combined) $name
            if { [lindex $combined_base $ipos] == "" } {
                lappend ProblemTypePriv(combined) 1
                lappend ProblemTypePriv(combined) 1.0,$name
            } else {
                lappend ProblemTypePriv(combined) [lindex $combined_base [expr $ipos+1]]
                set list [split [lindex $combined_base [expr $ipos+2]] ,]
                set found 0
                foreach "factor lc" $list {
                    if { $name == $lc } {
                        set ffactor $factor
                        set found 1
                        break
                    } 
                }
                if { !$found } { set ffactor 1.0 }
                lappend ProblemTypePriv(combined) $ffactor,$name
            }
        }
    }
    if { $ProblemTypePriv(loadcasestype) == "prestress" } {
        set combined_base $ProblemTypePriv(combined)
        set ProblemTypePriv(combined) ""
        lappend ProblemTypePriv(combined) Prestress
        lappend ProblemTypePriv(combined) 1
        set list [split [lindex $combined_base [expr 2]] ,]
        for { set i 1 } { $i <= $ncases } { incr i } {
            set found 0
            set name [lindex $ProblemTypePriv(loadcasenames) \
                    [expr $i-1]]
            foreach "factor lc" $list {
                if { $name == $lc } {
                    set ffactor $factor
                    set found 1
                    break
                } 
            }
            if { !$found } { set ffactor 0.0 }
            append aux $ffactor,$name,
        }
        lappend ProblemTypePriv(combined) $aux
        lappend ProblemTypePriv(combined) Combined_1
        lappend ProblemTypePriv(combined) 1
        lappend ProblemTypePriv(combined) $aux
        #         foreach { cbcase isstrenght lcseq } [lrange $combined_base 3 end] {
            #             if { $cbcase != "" } { 
                #                 set lcseq [split $lcseq ,]
                #                 for { set i 1 } { $i <= $ncases } { incr i } {
                    #                     set found 0
                    #                     set name [lindex $ProblemTypePriv(loadcasenames) \
                        #                             [expr $i-1]]
                    #                     foreach "factor lc" $list {
                        #                         if { $name == $lc } {
                            #                             set ffactor $factor
                            #                             set found 1
                            #                             break
                            #                         } 
                        #                     }
                    #                     if { !$found } { set ffactor 1.0 }
                    #                     append aux $ffactor,$name,
                    #                 }
                #                } else {
                #                 lappend ProblemTypePriv(combined) Combined_1
                #                 lappend ProblemTypePriv(combined) 1
                #                  for { set i 1 } { $i <= $ncases } { incr i } {
                    #                     set name [lindex $ProblemTypePriv(loadcasenames) \
                        #                             [expr $i-1]]
                    #                     append aux 0,$name,
                    #                 }
                #                 lappend ProblemTypePriv(combined) $aux
                #             }
            #         }
    }
    set i 1
    foreach "name isstrength values" $ProblemTypePriv(combined) {
        regsub -all {_} $name { } name
        label $w.v$i -text $name -bd 1 -relief raised -anchor e
        
        
        bind $w.v$i <Double-1> "CombinedLCOperations $w $canvas $i rename %x"
        
        GidHelp $w.v$i [= "These are the combined loadcases. To change the name, double-click on"\
                "them. To insert a new one, press right-button-mouse over them.\nA combination "\
                "of simple loadcases with its"\
                " amplification factors defines a combined loadcase. There will be one result"\
                " for every combined loadcase."]
        
        # trick to enter the help but make the right button menu work
        set comm [bind $w.v$i <ButtonPress-3>]
        bind $w.v$i <ButtonPress-3> "CreateLCMenu $w $w.v$i $canvas $i %X %Y ; break ; $comm"
        
        grid $w.v$i -row $i -column 0 -sticky ew -padx 2
        #         checkbutton $w.c$i -var ProblemTypePriv(isstrength,$i) \
            #                 -image $ProblemTypePriv(loadcaseimgchecked-off) \
            #                 -selectimage $ProblemTypePriv(loadcaseimgchecked-on) \
            #                 -indicatoron 0 -bd 0 -selectcolor ""   
        #         GidHelp $w.c$i "When column 'ELU' is active means that 'combined "\
            #                 "load cases' are used to calculate strengths. If not, they are preferred "\
            #                 "to calculate displacements. This option do not change the analysis. It is only"\
            #                 " used to dimension concrete."
        # 
        set ProblemTypePriv(isstrength,$i) $isstrength
        #         grid $w.c$i -row $i -column 1
        
        set list [split $values ,]
        for { set j 1 } { $j <= $ncases } { incr j } {
            set lname [lindex $ProblemTypePriv(loadcasenames) \
                    [expr $j-1]]
            entry $w.v$i-$j -width 3 -bd 1
            
            GidHelp $w.v$i-$j [= "It is possible to enter here the amplification factors for every"\
                    "simple loadcase related to every combined loadcase. A factor of 0.0 means not"\
                    "to consider that simple loadcase inside the combined one\n A combination "\
                    "of simple loadcases with its"\
                    " amplification factors defines a combined loadcase. There will be one result"\
                    " for every combined loadcase."]
            
            grid $w.v$i-$j -row $i -column [expr $j+1] -sticky ew
            
            set found 0
            if { $list == "allone" } {
                set ffactor 1.0
                set found 1
            } else {
                foreach "factor lc" $list {
                    if { $lname == $lc } {
                        set ffactor $factor
                        set found 1
                        break
                    } 
                }
            }
            if { !$found } { set ffactor 0.0 }
            $w.v$i-$j ins end [format %g $ffactor]
            if { $ProblemTypePriv(loadcasestype) == "independent" && \
                $i != $j } {
                $w.v$i-$j conf -state disabled -fg grey60
            }
        }
        incr i
    }
    
    set downarrowfile [file join $ProblemTypePriv(problemtypedir) images downarrow-16.gif]
    set icondownarrow [image create photo -file $downarrowfile]        
    menubutton $w.arrow -image $icondownarrow -menu $w.arrow.menu -relief raised    
    
    menu $w.arrow.menu
    $w.arrow.menu add command -label [= "Insert"] -command \
        "CombinedLCOperations $w $canvas end insertrow"
    $w.arrow.menu add command -label [= "Delete"] -command \
        "CombinedLCOperations $w $canvas end deleterow"
    $w.arrow.menu add separator
    $w.arrow.menu add command -label [= "Help"] -command \
        "LCHelpForCombined $w.arrow \[winfo rootx $w.arrow.menu] \[winfo rooty $w.arrow.menu]"
    
    
    GidHelp $w.arrow [= "These are the combined loadcases. To change the name, double-click on"\
            "them. To insert a new one, press right-button-mouse over them.\nA combination "\
            "of simple loadcases with its"\
            " amplification factors defines a combined loadcase. There will be one result"\
            " for every combined loadcase."]
    
    grid $w.arrow -row $i -column 0 -sticky w -padx 2
    
    if { $ProblemTypePriv(loadcasestype) == "none" } {
        ChangeStateChildren $w disabled
    }
    
    update idletasks
    $canvas conf -scrollregion "0 0 [winfo reqwidth $w] \
        [winfo reqheight $w]"
    event generate $canvas <Configure>
    set ProblemTypePriv(loadcasestypeold) $ProblemTypePriv(loadcasestype)
    
}
proc framelabel { w text } {
    frame $w -bd 2 -relief groove
    set i 0
    set parent [winfo parent $w]
    if { $parent == "." } { set parent "" }
    set label $parent.__label$i
    while { [winfo exists $label] } {
        incr i
        set label $parent.__label$i
    }
    label $label -text $text -pady 0
    place $label -in $w -x 10 -y -1 -anchor w -bordermode outside
    after idle raise $label
    return $w
}

#
# This procedure displays a dialog box, with a combobox, waits for a button in 
# the dialog to be invoked, then returns the entry.
# If cancel is pressed, it returns: --CANCEL--
#
# Arguments:
# w -                Window to use for dialog top-level.
# title -        Title to display in dialog's decorative frame.
# text -        Message to display in dialog.
# bitmap -        Bitmap to display in dialog (empty string means none).
# AcceptNew     Can be: TCL_BOOLEAN or 2 (then, word must begin with a letter)
#                       3 (then, one positive number must be entered)
#
# args some words to add to the combo
#

proc rambshell_dialogCombo {w title text bitmap AcceptNew args} {
    global tkPriv GidPriv tcl_platform
    
    # 1. Create the top-level window and divide it into top, middle
    # and bottom parts.
    
    while { [winfo exists $w] } { append w a }
    catch {destroy $w}
    toplevel $w -class OverlayWindow
    
    wm title $w $title
    wm iconname $w Dialog
    wm protocol $w WM_DELETE_WINDOW { }
    
    if { $tcl_platform(platform) == "windows" } {
        wm transient $w [winfo toplevel [winfo parent $w]]
    }
    
    frame $w.bot -relief raised -bd 1
    pack $w.bot -side bottom -fill both
    frame $w.top -relief raised -bd 1
    pack $w.top -side top -fill both -expand 1
    
    frame $w.middle -relief raised -bd 1
    
    set GidPriv(entry) ""
    set iseditable $AcceptNew
    if { $iseditable > 1 } { set  iseditable 1 }
    combobox $w.middle.e -editable $iseditable \
        -textvariable GidPriv(entry) -bd 1
    
    set last ""
    foreach i [lindex $args 0] {
        if { $i == $last } { continue }
        $w.middle.e add $i
        set last $i
    }
    
    if { $AcceptNew == 0 || $AcceptNew == 3 } {
        set GidPriv(entry) [lindex [lindex $args 0] 0]
        $w.middle.e sel from 0
        $w.middle.e sel to end
    }
    
    pack $w.middle.e -side top -padx 5 -fill x -expand 1
    pack $w.middle -fill x -expand 1
    
    
    # 2. Fill the top part with bitmap and message (use the option
    # database for -wraplength so that it can be overridden by
    # the caller).
    
    option add *Dialog.msg.wrapLength 3i widgetDefault
    label $w.msg -justify left -text $text -wraplength 75m -font BigFont
    
    pack $w.msg -in $w.top -side right -expand 1 -fill both -padx 3m -pady 3m
    if {$bitmap != ""} {
        label $w.bitmap -bitmap $bitmap
        pack $w.bitmap -in $w.top -side left -padx 3m -pady 3m
    }
    
    bind $w <Return> "
        $w.button0 configure -state active -relief sunken
        update idletasks
        after 100
        set tkPriv(button) 0
        "
    
    # 3. Create a row of buttons at the bottom of the dialog.
    
    set UnderLineList ""
    set i 0
    
    set default 0
    set args [list [= "Ok"] [= "Cancel"]]
    set lentext 0
    foreach but $args {
        if { [string length $but] > $lentext } {
            set lentext [string length $but]
        }
    }
    foreach but $args {
        button $w.button$i -text $but -command "set tkPriv(button) $i" \
            -width $lentext -bd 1
        pack $w.button$i -in $w.bot -side left -expand 1 \
            -padx 3m -pady 2m
        bind $w.button$i <Return> "
            $w.button$i configure -state active -relief sunken
            update idletasks
            after 100
            set tkPriv(button) $i
            break
            "
        if { [regexp -nocase cancel $but] } "
            bind $w <Escape> \"
            $w.button$i configure -state active -relief sunken
            update idletasks
            after 100
            set tkPriv(button) $i
            \""
        incr i
    }
    
    # 5. Withdraw the window, then update all the geometry information
    # so we know how big it wants to be, then center the window in the
    # display and de-iconify it.
    
    if { [winfo parent $w] == ".gid" } {
        bind $w <Destroy> [list DestroyWinInDialogs $w GeomDialog]
    }
    if { [info exists GidPriv(GeomDialog)] && [winfo parent $w] == ".gid" } {
        WmGidGeom $w $GidPriv(GeomDialog)
    } else {
        wm withdraw $w
        update idletasks
        # extrange errors with updates
        if { ![winfo exists $w] } { return 0}
        
        set pare [winfo toplevel [winfo parent $w]]
        set x [expr [winfo x $pare]+[winfo width $pare ]/2- [winfo reqwidth $w]/2]
        set y [expr [winfo y $pare]+[winfo height $pare ]/2- [winfo reqheight $w]]
        if { $x < 0 } { set x 0 }
        if { $y < 0 } { set y 0 }
        WmGidGeom $w +$x+$y
        update
        wm deiconify $w
    }
    
    # 6. Set a grab and claim the focus too.
    
    set oldFocus [focus]
    tkwait visibility $w
    set oldGrab [grab current $w]
    if {$oldGrab != ""} {
        set grabStatus [grab status $oldGrab]
    }
    grab $w
    
    focus [$w.middle.e cget entry]
    #     after 100 catch [list "focus -force $w.middle.e"]
    
    
    # 7. Wait for the user to respond, then restore the focus and
    # return the index of the selected button.  Restore the focus
    # before deleting the window, since otherwise the window manager
    # may take the focus away so we can't redirect it.  Finally,
    # restore any grab that was in effect.
    
    while 1 {
        tkwait variable tkPriv(button)
        if { $tkPriv(button) == 1} { break }
        set result [$w.middle.e get]
        
        if { $AcceptNew == 2 && ![regexp {^[a-zA-Z]} $result] } {
            set errorRes [= "Word must begin with a letter"]
        } elseif { $AcceptNew == 3 && ![regexp \
            {^[  ]*([+]?[0-9]*\.?[0-9]*([eE][+-]?[0-9]+)?)[  ]*$} \
                $result] } {
            set errorRes [= "One positive number must be entered"]
        }        
        if { [info exists errorRes] } {
            tk_dialogRAM $w.tempwin {Error window} $errorRes error 0 OK
            unset errorRes
        } else { break }
    }
    
    catch {focus $oldFocus}
    destroy $w
    if {$oldGrab != ""} {
        if {$grabStatus == "global"} {
            grab -global $oldGrab
        } else {
            grab $oldGrab
        }
    }
    if { $tkPriv(button) == 1} { return --CANCEL-- }
    
    set val [string trim $GidPriv(entry)]
    if { [regexp {\s} $val] } { 
        return "\"$val\"" 
    } else {
        return $val
    }
}

proc imagefromram { name } {
    global ProblemTypePriv
    if { ![info exist ProblemTypePriv(image-$name)] } {
        set ProblemTypePriv(image-$name) [image create photo -file \
                [file join $ProblemTypePriv(problemtypedir) images $name]]
    }
    return $ProblemTypePriv(image-$name)
}


proc writebasfile_loadcases  { analysis } {
    global ProblemTypePriv
    
    set list [lrange [GiD_Info gendata] 1 end]
    foreach {name value} $list {
        if { [string match Combined_load_cases* $name] } {
            set combined [lrange $value 2 end]
        } elseif { [string match Constraints_load_cases* $name] } {
            if { $value == "none" } {
                set constraints "none"
            } else {
                set constraints $value
            }
        }
    }
    switch $analysis {
        "STATIC" {
            set numcase 1
            foreach {combname is list} $combined {
                append output "\n SUBCASE $numcase \n  LABEL = Combined load case $combname\n   LOAD = $numcase\n"
                if { $constraints == "none" } {
                    append output "   SPC =  $numcase"
                } else {
                    set loadcasesnum [lindex [GiD_Info intvdata NUM] 1]
                    for { set i 2 } { $i <= $loadcasesnum} { incr i } {
                        set loadcasesname [ lindex [GiD_Info intvdata -interval $i] 2]
                        if { $constraints == $loadcasesname } { 
                            append output "   SPC = [expr $i-1]"
                        }
                    }
                }
                incr numcase 
            }
        }
        "PRESTRESS_STATIC" {
            set numcase 1
            foreach  {combname is list} [lrange $combined 0 2] { }
            append output "\n SUBCASE $numcase \n  LABEL = Prestress load case $combname\n   LOAD = $numcase\n"
            if { $constraints == "none" } {
                append output "   SPC =  $numcase\n"
            } else {
                set loadcasesnum [lindex [GiD_Info intvdata NUM] 1]
                for { set i 2 } { $i <= $loadcasesnum} { incr i } {
                    set loadcasesname [ lindex [GiD_Info intvdata -interval $i] 2]
                    if { $constraints == $loadcasesname } { 
                        append output "   SPC = [expr $i-1]\n"
                    }
                }
            }
            foreach {combname is list} [lrange $combined 3 end] {
                incr numcase 
                append output "\n SUBCASE $numcase \n  LABEL = Combined load case $combname\n   LOAD = $numcase\n"
                if { $constraints == "none" } {
                    append output "   SPC =  $numcase\n"
                } else {
                    set loadcasesnum [lindex [GiD_Info intvdata NUM] 1]
                    for { set i 2 } { $i <= $loadcasesnum} { incr i } {
                        set loadcasesname [ lindex [GiD_Info intvdata -interval $i] 2]
                        if { $constraints == $loadcasesname } { 
                            append output "   SPC = [expr $i-1]\n"
                        }
                    }
                }
            }
        }
    }
    return $output
}


proc writebasfile_combinedcases { } {
    global ProblemTypePriv
    
    set combinednum 1
    set list [lrange [GiD_Info gendata] 1 end]
    foreach {name value} $list {
        if { [string match Combined_load_cases* $name] } {
            set combined [lrange $value 2 end]
        } elseif { [string match Constraints_load_cases* $name] } {
            if { $value == "none" } {
                set constraints "none"
            } else {
                set constraints $value
            }
        } elseif { [string match Consider_Acceleration* $name] } {
            if { $value=="YES" } { 
                set acceleration 1
            } else {
                set acceleration 0
            }
        }
    }
    foreach { combinedname kk values} $combined {
        set values [split $values ,]
        if { $values == "allone" }  {
            if { $acceleration } { 
                append output "\nLOAD    [format %8i $combinednum]     1.0     1.0       1     1.0       2"
            } else {
                set output ""
            }
            break
        } else {
            append output "\nLOAD    [format %8i $combinednum]     1.0"
            foreach { factor loadcase} $values {
                set loadcasesnum [lindex [GiD_Info intvdata NUM] 1]
                for { set i 2 } { $i <= $loadcasesnum} { incr i } {
                    set loadcasesname [ lindex [GiD_Info intvdata -interval $i] 2]
                    if { $loadcasesname == $loadcase } {
                        set numloadcase  [expr $i-1]
                        break
                    }
                }
                if { [string length $output]%73 != 0 } { 
                    append output "[format "%#8.3g%8i" $factor $numloadcase]"
                } else {
                    append output "+L[format "%2i%4i" $combinednum $numloadcase]\n+L[format "%2i%4i" $combinednum $numloadcase]"
                    append output  "[format "%#8.3g%8i" $factor $numloadcase]"
                }
            }
            if { $acceleration } { 
                set factor 1.0 
                if { [string length $output]%73 != 0 } { 
                    append output "[format "%#8.3g%8i" $factor [expr $numloadcase+1]]"
                } else {
                    append output "+L[format "%2i%4i" $combinednum  [expr $numloadcase+1]]\n+L[format "%2i%4i" $combinednum  [expr $numloadcase+1]]"
                    append output  "[format "%#8.3g%8i" $factor  [expr $numloadcase+1]]"
                }
            }
        }
    }
    return $output
}

proc writebasfile_rigid_body  { {offset_element_id 0} } {      
    set conditions {Point_Rigid_Body Line_Rigid_Body Surface_Rigid_Body Volume_Rigid_Body}   
    
    foreach condition $conditions {
        foreach item [GiD_Info conditions $condition mesh] {
            lassign $item - node_id - GN CM
            lappend GMs($GN) $node_id
            set CMs($GN) $CM ;#assumed all are equal for GN
        }        
    }
    
    set element_id $offset_element_id
    set res ""
    foreach GN [lsort -integer [array names GMs]] {
        incr element_id
        set output [format %-8s%8i%8i%8i RBE2 $element_id $GN $CMs($GN)]
        set icol 5
        foreach node_id $GMs($GN) {
            if { $icol == 10 } {
                append output [format %8s\n%8s "" ""]
                set icol 2
            }
            append output [format %8i $node_id]
            incr icol
        }
        append res $output\n
    }
    return $res
}