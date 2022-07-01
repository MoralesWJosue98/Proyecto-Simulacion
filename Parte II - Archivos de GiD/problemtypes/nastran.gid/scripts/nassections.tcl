namespace eval sections {
    variable topname 
    variable sectiontype ""
    variable can
    variable width 
    variable height 
    variable topweight
    variable bottomweight
    variable radius
    variable area 0.0
    variable izz 0.0
    variable iyy 0.0
    variable iyz 0.0
    variable j 0.0
    variable oy 0.0
    variable oz 0.0
    variable yscale
    variable zscale
    variable cz
    variable pi 3.14159265358979323846
    variable check
    variable pos
    variable strpos
    variable section_data {
        R0lGODlhGAAYAKEAADMzMwAAAL6NkMzMzCH+Dk1hZGUgd2l0aCBHSU1QACH5
        BAEKAAMALAAAAAAYABgAAAJJnI+py+3fgJwy0KuA2Lx7AWTfyIXJRWKO1EnQ
        Wb6LJgSyCN5wrh+02Rv8goYhMbAB9mi8G6uknFFSFBzpExVeR9nLxOJ1EceP
        AgA7 
    }
    variable section [image create photo -data [set section_data]]
    variable win_info
}

proc sections::ComunicateWithGiDs { op args } {
    variable area 
    variable izz 
    variable iyy 
    variable iyz 
    variable pos
    variable strpos
    variable can
    variable check
    variable win_info
    variable width 
    variable height 
    variable topweight
    variable bottomweight
    variable radius
    switch $op {
        "INIT" {
            set PARENT [lindex $args 0]
            upvar [lindex $args 1] ROW
            set GDN [lindex $args 2]
            set STRUCT [lindex $args 3]
            set fbuttons [frame $PARENT.fbuttons]
            set bshape [Button $fbuttons.bshape -justify center \
                    -command "sections::initwindow [list $GDN $STRUCT $PARENT]" \
                    -image $sections::section -width 50 \
                    -helptext [= "Defines the shape of the section"]]
            set cmd "GidOpenMaterials Material"
            set bmat [Button $fbuttons.bmat -text [= "Create Material"] -helptext [= "Create a new Material"] \
                    -command $cmd  -width 15 -underline 0 -padx 2]
            grid $fbuttons -row $ROW -column 1 -sticky nsew
            grid columnconf $fbuttons 1 -weight 1 
            grid $bshape -row 0 -column 0 -sticky nw -pady 3 -padx 2
            grid $bmat -column 1 -row 0  -sticky nwse -pady 3 -padx 2   
            bind $PARENT <Alt-KeyPress-c> "tkButtonInvoke $bmat"
            upvar \#0 $GDN GidData
            set win_info  [base64::decode $GidData($STRUCT,VALUE,3)]
            return ""
        }
        "SYNC" {
            set GDN [lindex $args 0]
            set STRUCT [lindex $args 1]
            return ""
        }
        "CLOSE" {
            set width ""
            set height ""
            set topweight ""
            set bottomweight ""
            set radius "" 
        }           
    }
}

proc sections::initwindow { GDN STRUCT parent} {
    variable can
    variable yscale
    variable zscale
    variable pos
    variable check
    variable win_info
    variable sectiontype
    variable topname 
    set pos(0) ""
    set pos(1) ""
    set pos(2) ""
    set pos(3) ""
    
    
    global tkPriv tcl_platform
    
    set topname $parent.section
    catch {destroy $topname}
    toplevel $topname
    
    wm title $topname [= "Sections"]
    if { $tcl_platform(platform) == "windows" } {
        wm transient $topname [winfo toplevel [winfo parent $topname]]
    }
    
    grid columnconf $topname 0 -weight 1
    grid rowconf $topname 0 -weight 1
    
    set wingid [TitleFrame $topname.w -relief groove -bd 2 \
            -text [= "Sections"] -side left]
    set fwingid [$wingid getframe]
    grid $wingid -sticky nsew
    grid columnconf $fwingid 0 -weight 1
    grid rowconf $fwingid 0 -weight 1
    set pw [PanedWindow $fwingid.pw -side top ]
    set pane1 [$pw add -weight 1]
    set lsection [label $pane1.lsection -text [= "Section"] -justify center]
    set listsection [list "Rectangular Solid" "Trapezoidal Solid" \
            "Circular Solid" "SemiCircular Solid" "Double T"]
    set cbsection [ComboBox $pane1.cbsection \
            -textvariable sections::sectiontype \
            -editable no -values $listsection]
    set title1 [TitleFrame $pane1.draw -relief groove -bd 2 \
            -text [= "Visual Description"] -side left]
    set f1 [$title1 getframe]
    set can [canvas $f1.can -relief raised -bd 2 -width 200 \
            -height 150 -bg white]
    set pane2 [$pw add -weight 0]
    set title2 [TitleFrame $pane2.prop -relief groove -bd 2 \
            -text [= "Section Properties"] -side left]
    set f2 [$title2 getframe]
    set command "sections::type $title2 $pane2 ;#"
    trace variable sections::sectiontype w $command
    bind $cbsection <Destroy> [list trace vdelete sections::sectiontype w $command]
    set message [ label $f2.canmessage -text [= "Select a section"] -width 15 \
            -height 5]
    set title3 [TitleFrame $pane2.coord -relief groove -bd 2 \
            -text [= "Origin of Coordinates"] -side left -ipad 8]
    set f3 [$title3 getframe] 
    set lycenter [label $f3.lycenter -text [= "Y center"] -justify left]
    set eycenter [Entry $f3.eycenter -textvariable sections::oy \
            -bd 2 -relief sunken]
    set command "sections::linkenrtyscale y ;#"
    trace variable sections::oy w $command
    bind $eycenter <Destroy> [list trace vdelete sections::oy w $command]
    set yscale [scale $f3.ycscale -showvalue 0 -orient horizontal \
            -command "sections::refresh;#" \
            -width 10 -sliderlength 10 -from -100 -to 100 \
            -variable sections::oy -digits 4 \
            -tickinterval 50.0 -resolution 0.5 -length 220]
    set lzcenter [label $f3.lzcenter -text [= "Z center"] -justify left]
    set ezcenter [Entry $f3.ezcenter -textvariable sections::oz \
            -bd 2 -relief sunken]
    set command "sections::linkenrtyscale z ;#"
    trace variable sections::oz w $command
    bind $ezcenter <Destroy> [list trace vdelete sections::oz w $command]
    set zscale [scale $f3.zcscale -showvalue 0 -orient horizontal \
            -command "sections::refresh;#" \
            -width 10 -sliderlength 10 -from -100 -to 100 \
            -variable sections::oz -digits 4 \
            -tickinterval 50.0 -resolution 0.5 -length 220]
    set bcentroid [button $f3.bcentroid -text [= "Centroid"] -underline 1 \
            -command "set sections::oy 0.0 ; set sections::oz 0.0 ; sections::refresh;#"]
    set nastitle1 [TitleFrame $pane2.stress -relief groove -bd 2 \
            -text [= "Stress Recovery"] -side left ]
    set nasf1 [$nastitle1 getframe]
    set check(0) 1
    set naschb1 [checkbutton $nasf1.chb1 -variable sections::check(0)]
    set nasl1 [label $nasf1.l1 -text 1 -justify left]
    set nasab1 [ArrowButton $nasf1.ab1 -dir right -helptext [= "Next Position"] \
            -command "sections::next 0" -type arrow ] 
    set check(1) 1
    set naschb2 [checkbutton $nasf1.chb2 -variable sections::check(1)]
    set nasl2 [label $nasf1.l2 -text 2 -justify left]
    set nasab2 [ArrowButton $nasf1.ab2 -dir right -helptext [= "Next Position"] \
            -command "sections::next 1" -type arrow ]
    set check(2) 1
    set naschb3 [checkbutton $nasf1.chb3 -variable sections::check(2)]
    set nasl3 [label $nasf1.l3 -text 3 -justify left]
    set nasab3 [ArrowButton $nasf1.ab3 -dir right -helptext [= "Next Position"] \
            -command "sections::next 2" \
            -type arrow ]
    set check(3) 1
    set naschb4 [checkbutton $nasf1.chb4 -variable sections::check(3)]
    set nasl4 [label $nasf1.l4 -text 4 -justify left]
    set nasab4 [ArrowButton $nasf1.ab4 -dir right -helptext [= "Next Position"] \
            -command "sections::next 3" \
            -type arrow ]
    set title4 [TitleFrame $pane1.inertia -relief groove -bd 2 \
            -text [= "Moments of Inertia"] -side left -ipad 8]
    set f4 [$title4 getframe]
    set larea [label $f4.larea -text [= "Area"] -justify left]
    set earea [Entry $f4.earea -textvariable sections::area -editable no -relief groove \
            -bd 2 -bg lightyellow -justify right]
    set liyy [label $f4.liyy -text "Iyy" -justify left]
    set eiyy [Entry $f4.eiyy -textvariable sections::iyy -editable no -relief groove -bd 2 \
            -bg lightyellow -justify right]
    set lizz [label $f4.lizz -text "Izz" -justify left]
    set eizz [Entry $f4.eizz -textvariable sections::izz -editable no -relief groove -bd 2  \
            -bg lightyellow -justify right]
    set liyz [label $f4.liyz -text "Iyz" -justify left]
    set eiyz [Entry $f4.eiyz -textvariable sections::iyz -editable no -relief groove -bd 2  \
            -bg lightyellow -justify right]
    set lj [label $f4.lj -text "  J" -justify left]
    set ej [Entry $f4.ej -textvariable sections::j -editable no -relief groove -bd 2  \
            -bg lightyellow -justify right]
    set fbuttons [frame $topname.fbuttons -bd 1 -relief groove ]
    set baccept [button $fbuttons.baccept -text [= "Accept"] -width 20 \
            -command "sections::accepts [list $GDN $STRUCT]"]
    set bcancel [button $fbuttons.bcancel -text [= "Cancel"] -width 20 \
            -command "sections::cancel [list $GDN $STRUCT]"]
    grid $pw -column 0 -row 0 -sticky nsew
    grid columnconf $pane1 1 -weight 1
    grid rowconf $pane1 1 -weight 1
    grid $lsection -column 0 -row 0 -sticky we
    grid $cbsection -column 1 -row 0 -sticky we -pady 4
    grid $title1 -column 0 -row 1 -sticky nsew -columnspan 2
    grid columnconf $f1 0 -weight 1
    grid rowconf $f1 0 -weight 1
    grid $can -column 0 -row 0 -sticky nsew
    grid columnconf $pane2 0 -weight 1
    grid rowconf $pane2 4 -weight 1
    if { $sectiontype == "" } {
        grid $title2 -column 0 -row 0 -sticky nsew
        grid columnconf $f2 0 -weight 1
        grid rowconf $f2 0 -weight 1
        grid $message -column 0 -row 0 
    } else {
        sections::type  $title2 $pane2 
    }
    grid $title3 -column 0 -row 1 -sticky nsew
    grid columnconf $f3 1 -weight 1
    grid $lycenter -column 0 -row 0 -sticky ew
    grid $eycenter -column 1 -row 0 -sticky ew -padx 4
    grid $yscale -column 0 -row 1 -sticky ew -columnspan 2  
    grid $lzcenter -column 0 -row 2 -sticky ew
    grid $ezcenter -column 1 -row 2 -sticky ew -padx 4
    grid $zscale -column 0 -row 3 -sticky ew -columnspan 2
    grid $bcentroid -column 1 -row 4 -sticky w -padx 40
    grid $nastitle1 -column 0 -row 2 -sticky nsew
    grid $naschb1 -column 0 -row 0 
    grid $nasl1 -column 1 -row 0 
    grid $nasab1 -column 2 -row 0
    grid $naschb2 -column 3 -row 0  
    grid $nasl2 -column 4 -row 0
    grid $nasab2 -column 5 -row 0
    grid $naschb3 -column 6 -row 0  
    grid $nasl3 -column 7 -row 0
    grid $nasab3 -column 8 -row 0
    grid $naschb4 -column 9 -row 0  
    grid $nasl4 -column 10 -row 0
    grid $nasab4 -column 11 -row 0
    grid $title4 -column 0 -row 2 -sticky sew -columnspan 2
    grid columnconf $f4 1 -weight 1
    grid $larea -column 0 -row 0 -sticky ew -pady 2
    grid $earea -column 1 -row 0 -sticky ew -pady 2
    grid $liyy -column 0 -row 1 -sticky ew -pady 2
    grid $eiyy -column 1 -row 1 -sticky ew -pady 2
    grid $lizz -column 0 -row 2 -sticky ew -pady 2
    grid $eizz -column 1 -row 2 -sticky ew -pady 2
    grid $liyz -column 0 -row 3 -sticky ew -pady 2
    grid $eiyz -column 1 -row 3 -sticky ew -pady 2
    grid $lj -column 0 -row 4 -sticky ew -pady 2
    grid $ej -column 1 -row 4 -sticky ew -pady 2
    bind $can <Configure> "sections::refresh"
    grid $fbuttons -column 0 -row 1 -sticky nsew -pady 8
    grid $baccept -column 0 -row 0 -sticky nsew -padx 20 -pady 4
    grid $bcancel -column 1 -row 0 -sticky nsew -pady 4
    if { $win_info != 0 } {
        foreach {name value} $win_info  {
            set $name $value
        }
        sections::type  $title2 $pane2                   
    }
    wm withdraw $topname
    update idletasks
    set xpos [ expr [winfo x  [winfo toplevel $parent]]+[winfo width [winfo toplevel $parent]]/2-[winfo reqwidth $topname]/2]
    set ypos [ expr [winfo y  [winfo toplevel $parent]]+[winfo height [winfo toplevel $parent]]/2-[winfo reqheight $topname]/2]
    
    wm geometry $topname +$xpos+$ypos
    wm deiconify $topname
}

proc sections::type { window parent  } {
    variable sectiontype
    variable area ""
    variable izz ""
    variable iyy ""
    variable iyz ""
    variable j ""
    #     variable oy
    #     variable oz 
    
    #     set oy 0.0
    #     set oz 0.0
    destroy $window
    switch $sectiontype {
        "Rectangular Solid" { sections::rect_sol  $parent }
        "Trapezoidal Solid" { sections::trap_sol $parent }
        "Circular Solid" { sections::circ_sol $parent }
        "SemiCircular Solid" { sections::semicirc_sol $parent }
        "Double T" { sections::doublet $parent }
        default { tk_messageBox -message [= "Section %s doesn't exist" $sectiontype] }    
    }
}

proc sections::rect_sol { parent } {
    variable width
    variable height
    variable can
    variable yscale
    variable zscale
    
    set title2 [TitleFrame $parent.prop -relief groove -bd 2 \
            -text [= "Section Properties"] -side left]
    set sectionfr [$title2 getframe]
    grid $title2 -column 0 -row 0 -sticky nsew
    grid columnconf $sectionfr 1 -weight 1
    grid rowconf $sectionfr 2 -weight 1
    set lwidth [label $sectionfr.lwidth -text [= "Width"] -justify left ]
    set ewidth [entry $sectionfr.ewidth -textvariable sections::width -bd 2 -relief sunken]
    set lheight [label $sectionfr.lheight -text [= "Height"] -justify left]
    set eheight [entry $sectionfr.eheight -textvariable sections::height -bd 2 -relief sunken]
    set bcalculate [button $sectionfr.bcalculate -text [= "Calculate"] -underline 0 \
            -command "sections::rect_sol_cal" ]
    grid $lwidth -column 0 -row 0 -sticky nwe
    grid $ewidth -column 1 -row 0 -sticky we
    grid $lheight -column 0 -row 1 -sticky nwe
    grid $eheight -column 1 -row 1 -sticky we
    grid $bcalculate -column 0 -row 2 -pady 4 -columnspan 2
    bind $bcalculate <ButtonPress> { set sections::values [list 5 Width $sections::width Height $sections::height];  \
            if  { ! [sections::errorcntrl $sections::values] } { 
            $sections::yscale configure \
                -to [expr $sections::width/2.0] \
                -from [expr -$sections::width/2.0] \
                -tickinterval [expr -$sections::width/2.0] \
                -resolution [expr -$sections::width/200.0] ; \
                $sections::zscale configure -to [expr $sections::height/2.0] \
                -from [expr -$sections::height/2.0] \
                -tickinterval [expr -$sections::height/2.0] \
                -resolution [expr -$sections::height/200.0] 
        }
    }
    bind $ewidth <KeyPress-Return> { set sections::values [list 5 Width $sections::width Height $sections::height];  \
            if  { ! [sections::errorcntrl $sections::values] } { tkButtonInvoke $sections::bcalculate
            event generate $sections::bcalculate <ButtonRelease>}}
    bind $eheight <KeyPress-Return> { set sections::values [list 5 Width $sections::width Height $sections::height];  \
            if  { ! [sections::errorcntrl $sections::values] } { tkButtonInvoke $sections::bcalculate
            event generate $sections::bcalculate <ButtonRelease>}}
    $can delete all
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set x0 [expr $x/4-10]
    set y0 [expr $y/4-10]
    set x1 [expr $x0+$x/2]
    set y1 [expr $y0+$y/2]
    $can create rectangle $x0 $y0 $x1 $y1 -fill gray85    
}

proc sections::trap_sol { parent } {
    variable topwidth
    variable bottomwidth
    variable height
    variable can
    variable yscale
    variable zscale 
    
    set title2 [TitleFrame $parent.prop -relief groove -bd 2 \
            -text [= "Section Properties"] -side left]
    set sectionfr [$title2 getframe]
    grid $title2 -column 0 -row 0 -sticky nsew
    grid columnconf $sectionfr 1 -weight 1
    grid rowconf $sectionfr 4 -weight 1
    #set topwidth ""
    #set bottomwidth ""
    #set height ""
    set ltopwidth [label $sectionfr.ltopwidth -text [= "Top Width"] -justify right]
    set etopwidth [entry $sectionfr.etopwidth -textvariable sections::topwidth -bd 2 \
            -relief sunken]
    set lbottomwidth [label $sectionfr.lbottomwidth -text [= "Bottom Width"] -justify right]
    set ebottomwidth [entry $sectionfr.ebottomwidth -textvariable sections::bottomwidth \
            -bd 2 -relief sunken]
    set lheight [label $sectionfr.lheight -text [= "Height"] -justify right]
    set eheight [entry $sectionfr.eheight -textvariable sections::height -bd 2 -relief sunken]
    set bcalculate [button $sectionfr.bcalculate -text [= "Calculate"] -underline 0 \
            -command "sections::trap_sol_cal"]
    grid $ltopwidth -column 0 -row 0 -sticky nw
    grid $etopwidth -column 1 -row 0 -sticky we
    grid $lbottomwidth -column 0 -row 1 -sticky nw
    grid $ebottomwidth -column 1 -row 1 -sticky we
    grid $lheight -column 0 -row 2 -sticky nw
    grid $eheight -column 1 -row 2 -sticky we
    grid $bcalculate -column 0 -row 3 -pady 4 -columnspan 2
    if { $topwidth <= $bottomwidth } {
        bind $bcalculate <ButtonRelease> { set sections::values [list 7 TopWidth $sections::topwidth \
                    BottomWidth $sections::bottomwidth Height $sections::height];  \
                if  { ! [sections::errorcntrl $sections::values] } {
                set sections::cz [expr ((2.0*$sections::topwidth+$sections::bottomwidth)\
                /($sections::topwidth+$sections::bottomwidth))*($sections::height/3.0)] ; 
            $sections::yscale configure \
                -to [expr $sections::bottomwidth/2.0] \
                -from [expr -$sections::bottomwidth/2.0] \
                -tickinterval [expr -$sections::bottomwidth/2.0] \
                -resolution [expr -$sections::bottomwidth/200.0] ; \
                $sections::zscale configure -to [expr $sections::height-$sections::cz] \
                -from [expr -$sections::cz] \
                -tickinterval [expr -$sections::height/2.0] \
                -resolution [expr -$sections::height/200.0] 
            }
        }
    } else {
        bind $bcalculate <ButtonRelease> { set sections::values [list 7 TopWidth $sections::topwidth \
                    BottomWidth $sections::bottomwidth Height $sections::height];  \
                if  { ! [sections::errorcntrl $sections::values] } {
                set sections::cz [expr ((2*$sections::topwidth+$sections::bottomwidth) \
                /($sections::topwidth+$sections::bottomwidth))*($sections::height/3.0)] ; 
            $sections::yscale configure \
                -to [expr $sections::topwidth/2.0] \
                -from [expr -$sections::topwidth/2.0] \
                -tickinterval [expr -$sections::topwidth/2.0] \
                -resolution [expr -$sections::topwidth/200.0] ; \
                $sections::zscale configure -to [expr $sections::height-$sections::cz] \
                -from [expr -$sections::cz] \
                -tickinterval [expr -$sections::height/2.0] \
                -resolution [expr -$sections::height/200.0] }
        }
    }
    bind $etopwidth <KeyPress-Return> { set sections::values [list 7 TopWidth $sections::topwidth \
                BottomWidth $sections::bottomwidth Height $sections::height];  \
            if  { ! [sections::errorcntrl $sections::values] } { tkButtonInvoke $sections::bcalculate
            event generate $sections::bcalculate <ButtonRelease>}}
    bind $ebottomwidth <KeyPress-Return> { set sections::values [list 7 TopWidth $sections::topwidth \
                BottomWidth $sections::bottomwidth Height $sections::height];  \
            if  { ! [sections::errorcntrl $sections::values] } { tkButtonInvoke $sections::bcalculate
            event generate $sections::bcalculate <ButtonRelease>}}
    bind $eheight <KeyPress-Return> { set sections::values [list 7 TopWidth $sections::topwidth \
                BottomWidth $sections::bottomwidth Height $sections::height];  \
            if  { ! [sections::errorcntrl $sections::values] } { tkButtonInvoke $sections::bcalculate
            event generate $sections::bcalculate <ButtonRelease>}}
    $can delete all
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set xmarge [expr $x*0.1]
    set ymarge [expr $y*0.1]
    set a1 [expr $xmarge+($x-2*$xmarge-140)/2]
    set a2 [expr $y/2+100/2]
    set b1 [expr $xmarge+($x-2*$xmarge-100)/2]
    set b2 [expr $y/2-100/2]
    set c1 [expr $b1+100]
    set c2 [expr $y/2-100/2]
    set d1 [expr $a1+140]
    set d2 [expr $y/2+100/2]
    set vertexs "$a1 $a2 $b1 $b2 $c1 $c2 $d1 $d2"
    $can create polygon $vertexs -fill gray85 -outline black
}

proc sections::circ_sol { parent } {
    variable radius
    variable can
    variable yscale
    variable zscale
    variable cz
    
    set title2 [TitleFrame $parent.prop -relief groove -bd 2 \
            -text [= "Section Properties"] -side left]
    set sectionfr [$title2 getframe]
    grid $title2 -column 0 -row 0 -sticky nsew
    grid columnconf $sectionfr 1 -weight 1
    grid rowconf $sectionfr 2 -weight 1
    #set radius ""
    set lradius [label $sectionfr.lradius -text [= "Radius"] -justify left]
    set eradius [entry $sectionfr.eradius -textvariable sections::radius -bd 2 -relief sunken]
    set bcalculate [button $sectionfr.bcalculate -text [= "Calculate"] -underline 0 \
            -command "sections::circ_sol_cal" ]
    grid $lradius -column 0 -row 0 -sticky nwe
    grid $eradius -column 1 -row 0 -sticky we
    grid $bcalculate -column 0 -row 2 -pady 4 -columnspan 2
    bind $bcalculate <ButtonRelease> { set sections::values [list 3 Radius $sections::radius];  \
            if  { ! [sections::errorcntrl $sections::values] } { 
            set sections::cz $sections::radius] ; 
            $sections::yscale configure \
            -to [expr $sections::radius] \
                -from [expr -$sections::radius] \
                -tickinterval [expr -$sections::radius] \
                -resolution [expr -$sections::radius/200.0] ; \
                $sections::zscale configure -to [expr $sections::radius] \
                -from [expr -$sections::radius] \
                -tickinterval [expr -$sections::radius/2.0] \
                -resolution [expr -$sections::radius/200.0]
        }
    }
    bind $eradius <KeyPress-Return>  { set sections::values [list 3 Radius $sections::radius];  \
            if  { ! [sections::errorcntrl $sections::values] } { tkButtonInvoke $sections::bcalculate
            event generate $sections::bcalculate <ButtonRelease>}}
    $can delete all
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set x0 [expr $x/2-60]
    set y0 [expr ($y/2-60)]
    set x1 [expr $x0+2*60]
    set y1 [expr $y0+2*60]
    $can create oval $x0 $y0 $x1 $y1 -fill gray85 
}

proc sections::semicirc_sol { parent } {
    variable radius
    variable can
    variable yscale
    variable zscale
    variable cz
    
    set title2 [TitleFrame $parent.prop -relief groove -bd 2 \
            -text [= "Section Properties"] -side left]
    set sectionfr [$title2 getframe]
    grid $title2 -column 0 -row 0 -sticky nsew
    grid columnconf $sectionfr 1 -weight 1
    grid rowconf $sectionfr 2 -weight 1
    #set radius ""
    set lradius [label $sectionfr.lradius -text [= "Radius"] -justify left]
    set eradius [entry $sectionfr.eradius -textvariable sections::radius -bd 2 -relief sunken]
    set bcalculate [button $sectionfr.bcalculate -text [= "Calculate"] -underline 0 \
            -command "sections::semicirc_sol_cal" ]
    grid $lradius -column 0 -row 0 -sticky nwe
    grid $eradius -column 1 -row 0 -sticky we
    grid $bcalculate -column 0 -row 2 -pady 4 -columnspan 2
    bind $bcalculate <ButtonRelease> { set sections::values [list 3 Radius $sections::radius];  \
            if  { ! [sections::errorcntrl $sections::values] } { 
            set sections::cz [expr 4*$sections::radius/(3*$sections::pi)] ; 
            $sections::yscale configure \
            -to [expr $sections::radius] \
                -from [expr -$sections::radius] \
                -tickinterval [expr -$sections::radius] \
                -resolution [expr -$sections::radius/200.0] ; \
                $sections::zscale configure -to [expr $sections::radius-$sections::cz] \
                -from [expr -$sections::cz] \
                -tickinterval [expr -$sections::radius/2.0] \
                -resolution [expr -$sections::radius/200.0]
        }
    }
    bind $eradius <KeyPress-Return>  { set sections::values [list 3 Radius $sections::radius];  \
            if  { ! [sections::errorcntrl $sections::values] } { tkButtonInvoke $sections::bcalculate
            event generate $sections::bcalculate <ButtonRelease>}}
    $can delete all
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set x0 [expr $x/2-75]
    set y0 [expr ($y/2-75)+25]
    set x1 [expr $x0+2*75]
    set y1 [expr $y0+2*75]
    $can create arc $x0 $y0 $x1 $y1 -fill gray85 -extent 180 -start 0
}

proc sections::doublet { parent } {
    variable topwidth
    variable bottomwidth
    variable height
    variable wingsthick
    variable thick
    variable can
    variable yscale
    variable zscale
    variable cz
    
    set title2 [TitleFrame $parent.prop -relief groove -bd 2 \
            -text [= "Section Properties"] -side left]
    set sectionfr [$title2 getframe]
    grid $title2 -column 0 -row 0 -sticky nsew
    grid columnconf $sectionfr 1 -weight 1
    grid rowconf $sectionfr 5 -weight 1
    #set height ""
    #set topwidth ""
    #set bottomwidth ""
    #set wingsthick ""
    #set thick ""
    set ltopwidth [label $sectionfr.ltopwidth -text [= "Top Width"] -justify left]
    set etopwidth [entry $sectionfr.etopwidth \
            -textvariable sections::topwidth -bd 2 -relief sunken]
    set lbottomwidth [label $sectionfr.lbottomwidth -text [= "Bottom Width"] -justify left]
    set ebottomwidth [entry $sectionfr.ebottomwidth \
            -textvariable sections::bottomwidth -bd 2 -relief sunken]
    set lheight [label $sectionfr.lheight -text [= "Height"] -justify left]
    set eheight [entry $sectionfr.eheight -textvariable sections::height -bd 2 -relief sunken]
    set lwingsthick [label $sectionfr.lwingsthick -text [= "Wings Thick."] -justify left]
    set ewingsthick [entry $sectionfr.ewingsthick \
            -textvariable sections::wingsthick -bd 2 -relief sunken]
    set lthick [label $sectionfr.lthick -text [= "Central Thick."] -justify left]
    set ethick [entry $sectionfr.ethick \
            -textvariable sections::thick -bd 2 -relief sunken]
    set bcalculate [button $sectionfr.bcalculate -text [= "Calculate"] -underline 0 \
            -command "sections::doublet_cal" ]
    grid $ltopwidth -column 0 -row 0 -sticky nw
    grid $etopwidth -column 1 -row 0 -sticky we
    grid $lbottomwidth -column 0 -row 1 -sticky nw
    grid $ebottomwidth -column 1 -row 1 -sticky we
    grid $lheight -column 0 -row 2 -sticky nw
    grid $eheight -column 1 -row 2 -sticky we
    grid $lwingsthick -column 0 -row 3 -sticky nw
    grid $ewingsthick -column 1 -row 3 -sticky we
    grid $lthick -column 0 -row 4 -sticky nw
    grid $ethick -column 1 -row 4 -sticky we
    grid $bcalculate -column 0 -row 5 -pady 4 -columnspan 2
    if { $topwidth <= $bottomwidth } {
        bind $bcalculate <ButtonRelease> { set sections::values [list 11 TopWidth $sections::topwidth \
                    BottomWidth $sections::bottomwidth Height $sections::height \
                    WingsThick. $sections::wingsthick Thick. $sections::thick] ;  \
                if  { ! [sections::errorcntrl $sections::values] } {
                set sections::area [expr $sections::topwidth*$sections::wingsthick+ \
                $sections::bottomwidth*$sections::wingsthick+ \
                    ($sections::height-2*$sections::wingsthick)*$sections::thick]
                set sections::cz [expr $sections::height-(1.0/(2.0*$sections::area))* \
                (($sections::thick*pow($sections::height,2))+ \
                    pow($sections::wingsthick,2)*($sections::topwidth-$sections::thick)+ \
                    $sections::wingsthick*($sections::bottomwidth-$sections::thick)* \
                    (2*$sections::height-$sections::wingsthick))] ; 
            $sections::yscale configure \
                -to [expr $sections::bottomwidth/2.0] \
                -from [expr -$sections::bottomwidth/2.0] \
                -tickinterval [expr -$sections::bottomwidth/2.0] \
                -resolution [expr -$sections::bottomwidth/200.0] ; \
                $sections::zscale configure -to [expr $sections::height-$sections::cz] \
                -from [expr -$sections::cz] \
                -tickinterval [expr -$sections::height/2.0] \
                -resolution [expr -$sections::height/200.0] 
            }
        }
    } else {
        bind $bcalculate <ButtonRelease> { set sections::values [list 11 TopWidth $sections::topwidth \
                    BottomWidth $sections::bottomwidth Height $sections::height \
                    WingsThick. $sections::wingsthick Thick. $sections::thick] ;  \
                if  { ! [sections::errorcntrl $sections::values] } {
                set sections::area [expr $sections::topwidth*$sections::wingsthick+ \
                        $sections::bottomwidth*$sections::wingsthick+ \
                        ($sections::height-2*$sections::wingsthick)*$sections::thick]
                set sections::cz [expr $sections::height-(1.0/(2.0*$sections::area))* \
                        (($sections::thick*pow($sections::height,2))+ \
                        pow($sections::wingsthick,2)*($sections::topwidth-$sections::thick)+ \
                        $sections::wingsthick*($sections::bottomwidth-$sections::thick)* \
                        (2*$sections::height-$sections::wingsthick))] ; 
                $sections::yscale configure \
                    -to [expr $sections::topwidth/2.0] \
                -from [expr -$sections::topwidth/2.0] \
                    -tickinterval [expr -$sections::topwidth/2.0] \
                -resolution [expr -$sections::topwidth/200.0] ; \
                    $sections::zscale configure -to [expr $sections::height-$sections::cz] \
                -from [expr -$sections::cz] \
                    -tickinterval [expr -$sections::height/2.0] \
                -resolution [expr -$sections::height/200.0] 
            }
        }
    }
    bind $etopwidth <KeyPress-Return>  { set sections::values [list 11 TopWidth $sections::topwidth \
                BottomWidth $sections::bottomwidth Height $sections::height \
                WingsThick. $sections::wingsthick Thick. $sections::thick] ;   \
            if  { ! [sections::errorcntrl $sections::values] } { tkButtonInvoke $sections::bcalculate
            event generate $sections::bcalculate <ButtonRelease>}}
    bind $ebottomwidth <KeyPress-Return>  { set sections::values [list 11 TopWidth $sections::topwidth \
                BottomWidth $sections::bottomwidth Height $sections::height \
                WingsThick. $sections::wingsthick Thick. $sections::thick] ;   \
            if  { ! [sections::errorcntrl $sections::values] } { tkButtonInvoke $sections::bcalculate
            event generate $sections::bcalculate <ButtonRelease>}}
    bind $eheight <KeyPress-Return>  { set sections::values [list 11 TopWidth $sections::topwidth \
                BottomWidth $sections::bottomwidth Height $sections::height \
                WingsThick. $sections::wingsthick Thick. $sections::thick] ;   \
            if  { ! [sections::errorcntrl $sections::values] } { tkButtonInvoke $sections::bcalculate
            event generate $sections::bcalculate <ButtonRelease>}}
    bind $ewingsthick <KeyPress-Return> { set sections::values [list 11 TopWidth $sections::topwidth \
                BottomWidth $sections::bottomwidth Height $sections::height \
                WingsThick. $sections::wingsthick Thick. $sections::thick] ;   \
            if  { ! [sections::errorcntrl $sections::values] } { tkButtonInvoke $sections::bcalculate
            event generate $sections::bcalculate <ButtonRelease>}}
    bind $ethick <KeyPress-Return>  { set sections::values [list 11 TopWidth $sections::topwidth \
                BottomWidth $sections::bottomwidth Height $sections::height \
                WingsThick. $sections::wingsthick Thick. $sections::thick] ;   \
            if  { ! [sections::errorcntrl $sections::values] } { tkButtonInvoke $sections::bcalculate
            event generate $sections::bcalculate <ButtonRelease>}}
    $can delete all
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set a1 [expr ($x-$x*0.8)/2]
    set a2 [expr ($y-$y*0.8)/2]
    set b1 [expr $a1+$x*0.8]
    set b2 $a2
    set c1 $b1
    set c2 [expr $a2+$y*0.1]
    set d1 [expr $b1-$x*0.3]
    set d2 $c2
    set e1 $d1
    set e2 [expr $d2+$y*0.6]
    set f1 [expr $e1+$x*0.3]
    set f2 $e2
    set g1 $f1
    set g2 [expr $f2+$y*0.1]
    set h1 [expr $f1-$x*0.8]
    set h2 $g2
    set i1 $h1
    set i2 [expr $h2-$y*0.1]
    set j1 [expr $i1+$x*0.3]
    set j2 $i2
    set k1 $j1
    set k2 $d2
    set l1 [expr $k1-$x*0.3]
    set l2 $k2
    set vertexs "$a1 $a2 $b1 $b2 $c1 $c2 $d1 $d2 $e1 $e2 $f1 $f2 $g1 $g2 $h1 \
        $h2 $i1 $i2 $j1 $j2 $k1 $k2 $l1 $l2"
    $can create polygon $vertexs -fill gray85 -outline black
    
}

proc sections::refresh { } {
    variable sectiontype
    
    switch $sectiontype {
        "Rectangular Solid" { sections::rect_sol_cal }
        "Trapezoidal Solid" { sections::trap_sol_cal }
        "Circular Solid" { sections::circ_sol_cal }
        "SemiCircular Solid" { sections::semicirc_sol_cal }
        "Double T" { sections::doublet_cal }
        default { }    
    }
}

proc sections::rect_sol_cal { } {
    variable can
    variable width
    variable height
    variable area
    variable izz
    variable iyy
    variable iyz
    variable j
    variable oy
    variable oz
    variable strpos 
    variable pos   
    variable win_info
    
    if { [string trim $width] == "" || [string trim $height] == "" } {
        return ""
    }
    $can delete all
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set xmarge [expr $x*0.1]
    set ymarge [expr $y*0.2]
    set xscale [expr ($x-2*$xmarge)/$width]
    set yscale [expr ($y-2*$ymarge)/$height]
    if { $xscale <= $yscale } {
        set xdraw [expr $xscale*$width]
        set ydraw [expr $xscale*$height]
        set oydraw [expr $xscale*$oy]
        set ozdraw [expr $xscale*$oz]
    } else {
        set xdraw [expr $yscale*$width]
        set ydraw [expr $yscale*$height]
        set oydraw [expr $yscale*$oy]
        set ozdraw [expr $yscale*$oz]
    }
    set x0 [expr $xmarge+(($x-2*$xmarge)-$xdraw)/2]
    set y0 [expr $ymarge+(($y-2*$ymarge)-$ydraw)/2]
    set x1 [expr $x0+$xdraw]
    set y1 [expr $y0+$ydraw]
    $can create rectangle $x0 $y0 $x1 $y1 -fill gray
    $can create line [expr $oydraw+$x/2] [expr -$ozdraw+$y/2] [expr $oydraw+$x/2] \
        [expr $ymarge-15] -arrow last 
    $can create line [expr $x/2+$oydraw] [expr $y/2-$ozdraw] [expr $x-$xmarge+15] \
        [expr $y/2-$ozdraw] -arrow last
    $can create oval [expr $x/2-3] [expr $y/2-3] [expr $x/2+3] [expr $y/2+3] -fill red
    $can create text [expr $x/2+10+$oydraw] [expr $ymarge+10] -text "Z"
    $can create text [expr $x-$xmarge-10] [expr $y/2-10-$ozdraw] -text "Y"
    $can create text [expr $x/2-3] [expr $y/2+10] -text "G"
    set area [format %#g [expr $width*$height]]
    set iyy [expr (($width*pow($height,3))/12.0)+pow($oz,2)*$area]
    set izz [expr (($height*pow($width,3))/12.0)+pow($oy,2)*$area]
    set iyz [expr abs($oz)*abs($oy)*$area]
    set j [expr 0.3*pow($height,3)*pow($width,3)/(pow($height,2)+pow($width,2))]
    set area [format %#8.3g $area]
    set iyy [format %#8.3g $iyy]
    set izz [format %#8.3g $izz]
    set iyz [format %#8.3g $iyz]
    set j [format %#8.3g $iyy]
    set strpos(0) [list $x0 $y1 [expr -$width/2.0] [expr -$height/2.0]]
    set strpos(1) [list [expr $x/2] $y1 0.0 [expr -$height/2.0]]
    set strpos(2) [list $x1 $y1 [expr $width/2.0] [expr -$height/2.0]]
    set strpos(3) [list $x1 [expr $y/2] [expr $width/2.0] 0.0]
    set strpos(4) [list $x1 $y0 [expr $width/2.0] [expr $height/2.0]]
    set strpos(5) [list [expr $x/2] $y0 0.0 [expr $height/2.0]]
    set strpos(6) [list $x0 $y0 [expr -$width/2.0] [expr $height/2.0]]
    set strpos(7) [list $x0 [expr $y/2] [expr -$width/2.0] 0.0]
    set strpos(8) [list [expr $x/2] [expr $y/2] 0.0 0.0]
    set pos(0) 0
    set pos(1) 2
    set pos(2) 4
    set pos(3) 6
    for { set i 0 } { $i <=3 } { incr i } {
        $can create oval [expr [lindex $strpos($pos($i)) 0]-3] \
            [expr [lindex $strpos($pos($i)) 1]-3] \
            [expr [lindex $strpos($pos($i)) 0]+3] \
            [expr [lindex $strpos($pos($i)) 1]+3] \
            -fill yellow -tags stresstag
        $can create text [expr [lindex $strpos($pos($i)) 0]+10] \
            [expr [lindex $strpos($pos($i)) 1]-10] \
            -text [expr $i+1] -tags stresstag
        
    }
    set win_info  [list sections::sectiontype $sections::sectiontype \
            sections::width $sections::width \
            sections::height  $sections::height]
    
}

proc sections::trap_sol_cal { } {
    variable can
    variable topwidth
    variable bottomwidth
    variable height
    variable area 
    variable izz
    variable iyy
    variable iyz
    variable j
    variable oy
    variable oz
    variable strpos 
    variable pos 
    variable win_info   
    if { [string trim $topwidth] == "" || [string trim $height] == "" || [string trim $bottomwidth] == ""} {
        return ""
    }
    $can delete all
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set xmarge [expr $x*0.1]
    set ymarge [expr $y*0.2]
    if { $topwidth <= $bottomwidth } {
        set xscale [expr ($x-2*$xmarge)/$bottomwidth]
    } else {
        set xscale [expr ($x-2*$xmarge)/$topwidth]
    }
    set yscale [expr ($y-2*$ymarge)/$height]
    if { $xscale <= $yscale } {
        set topdraw [expr $xscale*$topwidth]
        set bottomdraw [expr $xscale*$bottomwidth]
        set ydraw [expr $xscale*$height]
        set oydraw [expr $xscale*$oy]
        set ozdraw [expr $xscale*$oz]
        set scale [expr double($xscale)]
    } else {
        set topdraw [expr $yscale*$topwidth]
        set bottomdraw [expr $yscale*$bottomwidth]
        set ydraw [expr $yscale*$height]
        set oydraw [expr $yscale*$oy]
        set ozdraw [expr $yscale*$oz]
        set scale [expr double($yscale)]
    }
    set cy [expr ((2*$topdraw+$bottomdraw)/($topdraw+$bottomdraw)) \
            *($ydraw/3.0)]
    set a1 [expr $xmarge+($x-2*$xmarge-$bottomdraw)/2]
    set a2 [expr $y/2+$cy]
    set b1 [expr $xmarge+($x-2*$xmarge-$topdraw)/2]
    set b2 [expr $a2-$ydraw]
    set c1 [expr $b1+$topdraw]
    set c2 [expr $a2-$ydraw]
    set d1 [expr $a1+$bottomdraw]
    set d2 [expr $y/2+$cy]
    set vertexs "$a1 $a2 $b1 $b2 $c1 $c2 $d1 $d2"
    $can create polygon $vertexs -fill gray -outline black
    $can create line [expr $x/2+$oydraw] [expr $y/2-$ozdraw] [expr $x/2+$oydraw] \
        [expr $ymarge-10] -arrow last
    $can create line [expr $x/2+$oydraw] [expr $y/2-$ozdraw] [expr $x-$xmarge+10] \
        [expr $y/2-$ozdraw] -arrow last
    $can create oval [expr $x/2-3] [expr $y/2-3] [expr $x/2+3] [expr $y/2+3] -fill red
    $can create text [expr $x/2+10+$oydraw] [expr $ymarge+10] -text "Z"
    $can create text [expr $x-$xmarge-10] [expr $y/2-10-$ozdraw] -text "Y"
    $can create text [expr $x/2-3] [expr $y/2+10] -text "G"
    set area [expr ($topwidth+$bottomwidth)*$height/2.0]
    set iyy [expr (pow($topwidth,2)+4*$topwidth*$bottomwidth+pow($bottomwidth,2)) \
            *(pow($height,3)/(36*($topwidth+$bottomwidth)))+pow($oz,2)*$area]
    set izz [expr ($height*($topwidth+$bottomwidth)*\
            (pow($topwidth,2)+pow($bottomwidth,2)))/48.0+pow($oy,2)*$area]
    set iyz [expr abs($oz)*abs($oy)*$area]
    if { $topwidth <= $bottomwidth } {
        set j [expr 0.3*pow($height,3)*pow($topwidth,3)/(pow($height,2)+pow($topwidth,2))]
    } else {
        set j [expr 0.3*pow($height,3)*pow($bottomwidth,3)/(pow($height,2)+pow($bottomwidth,2))]
    }
    set area [format %#8.3g $area]
    set iyy [format %#8.3g $iyy]
    set izz [format %#8.3g $izz]
    set iyz [format %#8.3g $iyz]
    set j [format %#8.3g $iyy]
    set cy [expr $cy/$scale]
    set strpos(0) [list $a1 $a2 [expr -$bottomwidth/2.0] [expr -$cy]]
    set strpos(1) [list [expr $x/2] $a2 0.0 [expr -$cy]]
    set strpos(2) [list $d1 $d2 [expr $bottomwidth/2.0] [expr -$cy]]
    if { $d1 < $c1 } {
        set strpos(3) [list [expr $d1+(abs($topdraw-$bottomdraw))/4.0] [expr $y/2] \
                [expr ($cy/(2.0*$height))*($topwidth-$bottomwidth)+$bottomwidth/2.0] 0.0]
    } else {
        set strpos(3) [list [expr $d1-(abs($topdraw-$bottomdraw))/4.0] [expr $y/2] \
                [expr ($cy/(2.0*$height))*($topwidth-$bottomwidth)+$bottomwidth/2.0] 0.0]
    }
    set strpos(4) [list $c1 $c2 [expr $topwidth/2.0] [expr $height-$cy]]
    set strpos(5) [list [expr $x/2] $c2 0.0 [expr $height-$cy]]
    set strpos(6) [list $b1 $b2 [expr -$topwidth/2.0] [expr $height-$cy]]
    if { $d1 < $c1 } {
        set strpos(7) [list [expr $b1+(abs($topdraw-$bottomdraw))/4.0] [expr $y/2] \
                [expr ($cy/(2.0*$height))*(-$topwidth+$bottomwidth)-$bottomwidth/2.0] 0.0]
    } else {
        set strpos(7) [list [expr $b1-(abs($topdraw-$bottomdraw))/4.0] [expr $y/2] \
                [expr ($cy/(2.0*$height))*(-$topwidth+$bottomwidth)-$bottomwidth/2.0] 0.0]
    }
    set strpos(8) [list [expr $x/2] [expr $y/2] 0.0 0.0]
    set pos(0) 0
    set pos(1) 2
    set pos(2) 4
    set pos(3) 6
    for { set i 0 } { $i <=3 } { incr i } {
        $can create oval [expr [lindex $strpos($pos($i)) 0]-3] \
            [expr [lindex $strpos($pos($i)) 1]-3] \
            [expr [lindex $strpos($pos($i)) 0]+3] \
            [expr [lindex $strpos($pos($i)) 1]+3] \
            -fill yellow -tags stresstag
        $can create text [expr [lindex $strpos($pos($i)) 0]+10] \
            [expr [lindex $strpos($pos($i)) 1]-10] \
            -text [expr $i+1] -tags stresstag
        
    }
    set win_info  [list sections::sectiontype $sections::sectiontype \
            sections::topwidth $sections::topwidth \
            sections::bottomwidth $sections::bottomwidth \
            sections::height  $sections::height]
}

proc sections::circ_sol_cal { } {
    variable can
    variable radius
    variable area 
    variable izz 
    variable iyy 
    variable iyz 
    variable j
    variable oy
    variable oz
    variable  pi
    variable strpos 
    variable pos
    variable win_info
    if { [string trim $radius] == "" } {
        return ""
    }
    $can delete all
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set xmarge [expr $x*0.1]
    set ymarge [expr $y*0.2]
    set xscale [expr ($x-2*$xmarge)/(2*$radius)]
    set yscale [expr ($y-2*$ymarge)/(2*$radius)]
    if { $xscale <= $yscale } {
        set radiusdraw [expr $xscale*$radius]
        set oydraw [expr $xscale*$oy]
        set ozdraw [expr $xscale*$oz]
    } else {
        set radiusdraw [expr $yscale*$radius]
        set oydraw [expr $yscale*$oy]
        set ozdraw [expr $yscale*$oz]
    }
    set x0 [expr $x/2-$radiusdraw]
    set y0 [expr $y/2-$radiusdraw]
    set x1 [expr $x0+2*$radiusdraw]
    set y1 [expr $y0+2*$radiusdraw]
    $can create oval $x0 $y0 $x1 $y1 -fill gray 
    $can create line [expr $x/2+$oydraw] [expr $y/2-$ozdraw] [expr $x/2+$oydraw] \
        [expr $ymarge-10] -arrow last
    $can create line [expr $x/2+$oydraw] [expr $y/2-$ozdraw]  [expr $x-$xmarge] \
        [expr $y/2-$ozdraw] -arrow last
    $can create oval [expr $x/2-3] [expr $y/2-3] [expr $x/2+3] [expr $y/2+3] -fill red
    $can create text [expr $x/2-5+$oydraw] [expr $ymarge+10] -text "Z"
    $can create text [expr $x-$xmarge-10] [expr $y/2-10-$ozdraw] -text "Y"
    $can create text [expr $x/2-3] [expr $y/2+10] -text "G"
    set area [expr $pi*pow($radius,2)]
    set iyy [expr $pi*pow($radius,4)/4.0+pow($oz,2)*$area]
    set izz [expr $pi*pow($radius,4)/4.0+pow($oy,2)*$area]
    set iyz [expr abs($oz)*abs($oy)*$area]
    set j [expr $pi*pow($radius,4)/2.0]
    set area [format %#8.3g $area]
    set iyy [format %#8.3g $iyy]
    set izz [format %#8.3g $izz]
    set iyz [format %#8.3g $iyz]
    set j [format %#8.3g $j]
    set strpos(0) [list $x0 [expr $y/2] [expr -$radius] \
            0.0 ]
    set strpos(1) [list [expr $x/2.0] [expr $y1] 0.0 \
            [expr -$radius]]
    set strpos(2) [list $x1 [expr $y/2.0] $radius \
            0.0 ]
    set strpos(3) [list [expr $x/2] [expr $y0] 0.0 $radius]
    set strpos(4) [list [expr $x/2] [expr $y/2] 0.0 0.0]
    set pos(0) 0
    set pos(1) 1
    set pos(2) 2
    set pos(3) 3
    for { set i 0 } { $i <=3 } { incr i } {
        $can create oval [expr [lindex $strpos($pos($i)) 0]-3] \
            [expr [lindex $strpos($pos($i)) 1]-3] \
            [expr [lindex $strpos($pos($i)) 0]+3] \
            [expr [lindex $strpos($pos($i)) 1]+3] \
            -fill yellow -tags stresstag
        $can create text [expr [lindex $strpos($pos($i)) 0]+10] \
            [expr [lindex $strpos($pos($i)) 1]-10] \
            -text [expr $i+1] -tags stresstag
        
    }
    set win_info  [list sections::sectiontype $sections::sectiontype \
            sections::radius $sections::radius]
}

proc sections::semicirc_sol_cal { } {
    variable can
    variable radius
    variable area 
    variable izz 
    variable iyy 
    variable iyz 
    variable j
    variable oy
    variable oz
    variable  pi
    variable strpos 
    variable pos
    variable win_info
    if { [string trim $radius] == "" } {
        return ""
    }
    $can delete all
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set xmarge [expr $x*0.1]
    set ymarge [expr $y*0.2]
    set xscale [expr ($x-2*$xmarge)/(2*$radius)]
    set yscale [expr ($y-2*$ymarge)/(2*$radius)]
    if { $xscale <= $yscale } {
        set radiusdraw [expr $xscale*$radius]
        set oydraw [expr $xscale*$oy]
        set ozdraw [expr $xscale*$oz]
    } else {
        set radiusdraw [expr $yscale*$radius]
        set oydraw [expr $yscale*$oy]
        set ozdraw [expr $yscale*$oz]
    }
    set x0 [expr $x/2-$radiusdraw]
    set y0 [expr $y/2-$radiusdraw+4*$radiusdraw/(3*$pi)]
    set x1 [expr $x0+2*$radiusdraw]
    set y1 [expr $y0+2*$radiusdraw]
    $can create arc $x0 $y0 $x1 $y1 -fill gray -extent 180 -start 0
    $can create line [expr $x/2+$oydraw] [expr $y/2-$ozdraw] [expr $x/2+$oydraw] \
        [expr $ymarge-10] -arrow last
    $can create line [expr $x/2+$oydraw] [expr $y/2-$ozdraw]  [expr $x-$xmarge+10] \
        [expr $y/2-$ozdraw] -arrow last
    $can create oval [expr $x/2-3] [expr $y/2-3] [expr $x/2+3] [expr $y/2+3] -fill red
    $can create text [expr $x/2-5+$oydraw] [expr $ymarge+10] -text "Z"
    $can create text [expr $x-$xmarge-10] [expr $y/2-10-$ozdraw] -text "Y"
    $can create text [expr $x/2-3] [expr $y/2+10] -text "G"
    set area [expr $pi*pow($radius,2)/2.0]
    set iyy [expr $pi*pow($radius,4)/8.0]
    set iyy [expr $iyy-(8/(9*$pi))*pow($radius,4)+pow($oz,2)*$area]
    set izz [expr ($pi*pow($radius,4)/8)+pow($oy,2)*$area]
    set iyz [expr abs($oz)*abs($oy)*$area]
    set j [expr $pi*pow($radius,4)/4.0]
    set area [format %#8.3g $area]
    set iyy [format %#8.3g $iyy]
    set izz [format %#8.3g $izz]
    set iyz [format %#8.3g $iyz]
    set j [format %#8.3g $j]
    set strpos(0) [list $x0 [expr $y/2+4*$radiusdraw/(3*$pi)] [expr -$radius] \
            [expr -4*$radius/(3*$pi)]]
    set strpos(1) [list [expr $x/2] [expr $y/2+4*$radiusdraw/(3*$pi)] 0.0 \
            [expr -4*$radius/(3*$pi)]]
    set strpos(2) [list $x1 [expr $y/2+4*$radiusdraw/(3*$pi)] $radius \
            [expr -4*$radius/(3*$pi)]]
    set strpos(3) [list [expr $x/2] [expr $y0] 0.0 [expr $radius-4*$radius/(3*$pi)]]
    set strpos(4) [list [expr $x/2] [expr $y/2] 0.0 0.0]
    set pos(0) 0
    set pos(1) 1
    set pos(2) 2
    set pos(3) 3
    for { set i 0 } { $i <=3 } { incr i } {
        $can create oval [expr [lindex $strpos($pos($i)) 0]-3] \
            [expr [lindex $strpos($pos($i)) 1]-3] \
            [expr [lindex $strpos($pos($i)) 0]+3] \
            [expr [lindex $strpos($pos($i)) 1]+3] \
            -fill yellow -tags stresstag
        $can create text [expr [lindex $strpos($pos($i)) 0]+10] \
            [expr [lindex $strpos($pos($i)) 1]-10] \
            -text [expr $i+1] -tags stresstag
        
    }
    set win_info  [list sections::sectiontype $sections::sectiontype \
            sections::radius $sections::radius]
}

proc sections::doublet_cal { } {
    variable can
    variable topwidth
    variable bottomwidth
    variable wingsthick
    variable thick
    variable height
    variable area 
    variable cz
    variable izz
    variable iyy
    variable iyz
    variable j
    variable oy
    variable oz
    variable strpos
    variable pos
    variable win_info 
    variable topname   
    if { [string trim $height] == "" || [string trim $topwidth] == "" || [string trim bottomwidth] == "" || [string trim $wingsthick] == ""} {
        return ""
    }
    $can delete all
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set xmarge [expr $x*0.1]
    set ymarge [expr $y*0.2]
    set h [expr $height-2*$wingsthick]
    if { $h <= 0.0 } {
        WarnWin [= "Thicknesses added up are greater than the section height"]
    }
    set area [expr $topwidth*$wingsthick+$bottomwidth*$wingsthick+$h*$thick]
    set cz [expr $height-(1.0/(2.0*$area))*(($thick*pow($height,2))+ \
            pow($wingsthick,2)*($topwidth-$thick)+ \
            $wingsthick*($bottomwidth-$thick)*(2*$height-$wingsthick))]
    if { $topwidth <= $bottomwidth } {
        set xscale [expr ($x-2*$xmarge)/$bottomwidth]
    } else {
        set xscale [expr ($x-2*$xmarge)/$topwidth]
    }
    set yscale [expr ($y-2*$ymarge)/$height]
    if { $xscale <= $yscale } {
        set topdraw [expr $xscale*$topwidth]
        set bottomdraw [expr $xscale*$bottomwidth]
        set ydraw [expr $xscale*$height]
        set wingsdraw [expr $xscale*$wingsthick]
        set thickdraw [expr $xscale*$thick]
        set hdraw [expr $xscale*$h]
        set czdraw [expr $xscale*$cz]
        set oydraw [expr $xscale*$oy]
        set ozdraw [expr $xscale*$oz]
    } else {
        set topdraw [expr $yscale*$topwidth]
        set bottomdraw [expr $yscale*$bottomwidth]
        set ydraw [expr $yscale*$height]
        set wingsdraw [expr $yscale*$wingsthick]
        set thickdraw [expr $yscale*$thick]
        set hdraw [expr $yscale*$h]
        set czdraw [expr $yscale*$cz]
        set oydraw [expr $yscale*$oy]
        set ozdraw [expr $yscale*$oz]
    }
    set a1 [expr $xmarge+($x-2*$xmarge-$topdraw)/2]
    set a2 [expr $y/2-($ydraw-$czdraw)]
    set b1 [expr $a1+$topdraw]
    set b2 $a2
    set c1 $b1
    set c2 [expr $a2+$wingsdraw]
    set d1 [expr $b1-($topdraw-$thickdraw)/2]
    set d2 $c2
    set e1 $d1
    set e2 [expr $d2+($ydraw-2*$wingsdraw)]
    set f1 [expr $e1+($bottomdraw-$thickdraw)/2]
    set f2 $e2
    set g1 $f1
    set g2 [expr $f2+$wingsdraw]
    set h1 [expr $f1-$bottomdraw]
    set h2 $g2
    set i1 $h1
    set i2 [expr $h2-$wingsdraw]
    set j1 [expr $i1+($bottomdraw-$thickdraw)/2]
    set j2 $i2
    set k1 $j1
    set k2 $d2
    set l1 [expr $k1-($topdraw-$thickdraw)/2]
    set l2 $k2
    set vertexs "$a1 $a2 $b1 $b2 $c1 $c2 $d1 $d2 $e1 $e2 $f1 $f2 $g1 $g2 $h1 \
        $h2 $i1 $i2 $j1 $j2 $k1 $k2 $l1 $l2"
    $can create polygon $vertexs -fill gray -outline black
    $can create line [expr $x/2+$oydraw] [expr $y/2-$ozdraw] [expr $x/2+$oydraw] \
        [expr $ymarge-10] -arrow last
    $can create line [expr $x/2+$oydraw] [expr $y/2-$ozdraw] [expr $x-$xmarge+10] \
        [expr $y/2-$ozdraw] -arrow last
    $can create oval [expr $x/2-3] [expr $y/2-3] [expr $x/2+3] [expr $y/2+3] -fill red
    $can create text [expr $x/2+10+$oydraw] [expr $ymarge+10] -text "Z"
    $can create text [expr $x-$xmarge-10] [expr $y/2-10-$ozdraw] -text "Y"
    $can create text [expr $x/2-3] [expr $y/2+10] -text "G"
    set iyy [expr (1.0/3.0)*($topwidth*pow($height-$cz,3)+$bottomwidth*pow($cz,3) \
            -($topwidth-$thick)*pow($height-$cz-$wingsthick,3) \
            -($bottomwidth-$thick)*pow($cz-$wingsthick,3))+pow($oz,2)*$area]
    set izz [expr (1.0/12.0)*($wingsthick*pow($topwidth,3)+($height-2*$wingsthick)*pow($thick,3)+ \
            $wingsthick*pow($bottomwidth,3))+pow($oy,2)*$area]
    set iyz [expr abs($oz)*abs($oy)*$area]
    set j [ expr 0.333*(($topwidth+$bottomwidth)*pow($wingsthick,3)+($height-2*$wingsthick)*pow($thick,3))]
    set area [format %#8.3g $area]
    set iyy [format %#8.3g $iyy]
    set izz [format %#8.3g $izz]
    set iyz [format %#8.3g $iyz]
    set j [format %#8.3g $iyy]
    set strpos(0) [list $h1 $h2 [expr -$bottomwidth/2.0] [expr -$cz]] 
    set strpos(1) [list [expr $x/2] $g2 0.0 [expr -$cz]] 
    set strpos(2) [list $g1 $g2 [expr $bottomwidth/2.0] [expr -$cz]] 
    set strpos(3) [list $f1 $f2 [expr $bottomwidth/2.0] [expr -$cz+$wingsthick]] 
    set strpos(4) [list $e1 $e2 [expr $thick/2.0] [expr -$cz+$wingsthick]] 
    set strpos(5) [list $d1 $d2 [expr $thick/2.0] [expr $height-$cz-$wingsthick]] 
    set strpos(6) [list $c1 $c2 [expr $topwidth/2.0] [expr $height-$cz-$wingsthick]] 
    set strpos(7) [list $b1 $b2 [expr $topwidth/2.0] [expr $height-$cz]] 
    set strpos(8) [list [expr $x/2] $a2 0.0 [expr $height-$cz]] 
    set strpos(9) [list $a1 $a2 [expr -$topwidth/2.0] [expr $height-$cz]]  
    set strpos(10) [list $l1 $l2 [expr -$topwidth/2.0] [expr $height-$cz-$wingsthick]] 
    set strpos(11) [list $k1 $k2 [expr -$thick/2.0] [expr $height-$cz-$wingsthick]] 
    set strpos(12) [list $j1 $j2 [expr -$thick/2.0] [expr -$cz+$wingsthick]]
    set strpos(13) [list $i1 $i2 [expr -$bottomwidth/2.0] [expr -$cz+$wingsthick]] 
    set strpos(14) [list [expr $x/2] [expr $y/2] 0.0 0.0]
    set pos(0) 0
    set pos(1) 2
    set pos(2) 7
    set pos(3) 9
    for { set i 0 } { $i <=3 } { incr i } {
        $can create oval [expr [lindex $strpos($pos($i)) 0]-3] \
            [expr [lindex $strpos($pos($i)) 1]-3] \
            [expr [lindex $strpos($pos($i)) 0]+3] \
            [expr [lindex $strpos($pos($i)) 1]+3] \
            -fill yellow -tags stresstag
        $can create text [expr [lindex $strpos($pos($i)) 0]+10] \
            [expr [lindex $strpos($pos($i)) 1]-10] \
            -text [expr $i+1] -tags stresstag
        
    }
    set win_info  [list sections::sectiontype $sections::sectiontype \
            sections::topwidth $sections::topwidth \
            sections::bottomwidth $sections::bottomwidth \
            sections::height  $sections::height \
            sections::thick $sections::thick \
            sections::wingsthick $sections::wingsthick]
}

proc sections::next { id } {
    
    
    variable can
    variable strpos
    variable pos 
    variable sectiontype
    variable check
    variable area
    if { $area == 0.0 || $area== ""} {
        return
    }
    switch $sectiontype {
        "Rectangular Solid" { set modulus 9 }
        "Trapezoidal Solid" { set modulus 9 }
        "Circular Solid" { set modulus 5 }
        "SemiCircular Solid" { set modulus 5 }
        "Double T" { set modulus 15 }
        default { }    
    }
    if { $check($id) == 1 } {
        $can delete stresstag
        set pos($id) [expr ($pos($id)+1)%$modulus]
        for { set i 0 } { $i <=3 } { incr i } {
            $can create oval [expr [lindex $strpos($pos($i)) 0]-3] \
                [expr [lindex $strpos($pos($i)) 1]-3] \
                [expr [lindex $strpos($pos($i)) 0]+3] \
                [expr [lindex $strpos($pos($i)) 1]+3] \
                -fill yellow -tags stresstag
            $can create text [expr [lindex $strpos($pos($i)) 0]+10] \
                [expr [lindex $strpos($pos($i)) 1]-10] \
                -text [expr $i+1] -tags stresstag
            
        }
    } 
}

proc sections::accepts { GDN STRUCT } {
    variable area 
    variable iyy
    variable izz
    variable iyz
    variable j
    variable pos
    variable strpos
    variable can 
    variable sectiontype
    variable win_info
    variable topname 
    if { $area == 0.0 || $area == ""} {
        WarnWin [= "Don't forget to press Calculate button before"]
        return
    }
    if { $area == "NaN" } {
        WarnWin [= "Please check the coordinates of the centroid"]
        return
    }
    DWLocalSetValue $GDN $STRUCT  "Area" [format %#.6g $area]
    DWLocalSetValue $GDN $STRUCT  "I1" [format %#.6g $izz]
    DWLocalSetValue $GDN $STRUCT  "I2" [format %#.6g $iyy]
    DWLocalSetValue $GDN $STRUCT  "I12" [format %#.6g $iyz]
    DWLocalSetValue $GDN $STRUCT  "Torsional_Constant" [format %#.6g $j]
    if { [info exists strpos(0)] } {
        set aux "#N# 8 \
            [format %#8.3g [lindex $strpos($pos(0)) 2]] \
            [format %#8.3g [lindex $strpos($pos(0)) 3]] \
            [format %#8.3g [lindex $strpos($pos(1)) 2]] \
            [format %#8.3g [lindex $strpos($pos(1)) 3]] \
            [format %#8.3g [lindex $strpos($pos(2)) 2]] \
            [format %#8.3g [lindex $strpos($pos(2)) 3]] \
            [format %#8.3g [lindex $strpos($pos(3)) 2]] \
            [format %#8.3g [lindex $strpos($pos(3)) 3]]"
        DWLocalSetValue $GDN $STRUCT  "Values" $aux
    }
    $can delete all
    destroy $topname    
    DWLocalSetValue $GDN $STRUCT  "win_info"  [base64::encode -wrapchar "" $win_info]
    
}

proc sections::cancel { GDN STRUCT } {
    variable area 
    variable iyy
    variable izz
    variable iyz
    variable can 
    variable sectiontype
    variable topname 
    $can delete all
    destroy $topname
    #     set area 0.0
    #     set izz 0.0
    #     set iyy 0.0
    #     set iyz 0.0
    #     set sectiontype ""
}

proc sections::errorcntrl { values } {
    variable topname
    
    set message ""
    
    array set prop [ lrange $values 1 end]
    foreach elem [array names prop] {
        if { [string is space $prop($elem) ] } {
            append message [= "%s cannot be left blank" $elem].\n
        } elseif { ! [string is double -strict $prop($elem) ] } {
            append message [= "'%s' is not a valid input for %s" $prop($elem) $elem].\n 
        }
    }
    if  { $message != "" } {
        WarnWin $message
        return 1
    }
    return 0
}

proc sections::linkenrtyscale { type } { 
    
    variable yscale
    variable zscale
    variable area
    variable izz
    variable iyy
    variable iyz
    variable oz
    variable oy
    variable j
    
    switch $type {
        "z" { 
            if { [string is double -strict $oz ] } { 
                sections::refresh
            } else {
                set area "NaN"
                set izz "NaN"
                set iyy "NaN"
                set iyz "NaN"
                set j "NaN"
            }
        }
        "y" {
            if { [string is double -strict $oy ] } { 
                sections::refresh
            } else {
                set area "NaN"
                set izz "NaN"
                set iyy "NaN"
                set iyz "NaN"
                set j "NaN"
            }
        }
    }
} 

