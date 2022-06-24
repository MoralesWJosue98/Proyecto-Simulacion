namespace eval sections {
    variable sectiontype ""
    variable can
    variable width ""
    variable height ""
    variable topweight ""
    variable bottomweight ""
    variable diameter ""
    variable thickness ""
    variable wingsthick ""
    variable thick
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
    variable young ""
    variable mass ""
    variable maxstress 0.0
    variable shear ""
    variable matname "steel"
    variable last_units N-m-kg
    variable units N-m-kg
    variable unitshow "N/m\u00b2"
    variable unitmass  "N/m\u00b3"
    variable unitslength m
    variable section_data {
	R0lGODlhGAAYAKEAADMzMwAAAL6NkMzMzCH+Dk1hZGUgd2l0aCBHSU1QACH5
	BAEKAAMALAAAAAAYABgAAAJJnI+py+3fgJwy0KuA2Lx7AWTfyIXJRWKO1EnQ
	Wb6LJgSyCN5wrh+02Rv8goYhMbAB9mi8G6uknFFSFBzpExVeR9nLxOJ1EceP
	AgA7 
    }
    variable section [image create photo -data [set section_data]]
    variable bcalculate
    
}

proc sections::niceprint_g6 { number } {
    set number [format %.6g $number]
    regsub  {(?i)(e[+-]?)0([0-9]{2})} $number {\1\2} number
    return $number
}
proc sections::ComunicateWithGiDs { op args } {
    variable area 
    variable izz 
    variable iyy 
    variable iyz 
    variable young
    variable mass
    variable maxstress
    variable shear
    variable matname
    variable can
    #variable sectiontype ""    
    switch $op {
	"INIT" {
	    set PARENT [lindex $args 0]
	    upvar [lindex $args 1] ROW
	    set GDN [lindex $args 2]
	    set STRUCT [lindex $args 3]
	    set bshape [Button $PARENT.bshape -justify center \
		    -command "sections::initwindowsections [list $GDN $STRUCT]" \
		    -image $sections::section -width 50 \
		    -helptext [= "Defines the shape of the section"] ]
	    grid $bshape -row $ROW -column 1 -sticky nw -pady 3 -padx 2
	    upvar \#0 $GDN GidData
	    return ""
	}
	 "SYNC" {
	     set GDN [lindex $args 0]
	     set STRUCT [lindex $args 1]
	     return ""
	}
    }
}
proc sections::initwindowsections { GDN STRUCT } {
    variable can
    variable yscale
    variable zscale
    variable sectiontype 
    variable matname
    variable changing_matproperties

    if { [info exists changing_matproperties] } { unset changing_matproperties }

    set w .t
    InitWindow .t [= "Sections"]  PreLoadCasesWindowGeom LoadCaseWindow
    focus .t        
    grid columnconf .t 0 -weight 1
    grid rowconf .t 0 -weight 1
     ##############################################################
    #creating the notebook to organize the information           #
    ##############################################################
    set nb [NoteBook .t.notebook ]
    set page1 [$nb insert end page1 -text [= "Geometrical Properties"]]
    set page2 [$nb insert end page2 -text [= "Mechanical Properties"]]
    $nb raise page1
    grid $nb -sticky nsew
    grid columnconf $page1  0 -weight 1
    grid rowconf $page1 0 -weight 1
    grid columnconf $page2  0 -weight 1
    grid rowconf $page2 2 -weight 1
    set wingid [TitleFrame $page1.w -relief groove -bd 2 \
	    -text [= "Sections"] -side left]
    set fwingid [$wingid getframe]
    grid $wingid -sticky nsew
    grid columnconf $fwingid 0 -weight 1
    grid rowconf $fwingid 0 -weight 1
    set pw [PanedWindow $fwingid.pw -side top ]
    set pane1 [$pw add -weight 1]
    set lsection [label $pane1.lsection -text [= Section] -justify center]
    set listsection [list "Rectangular Solid" "Trapezoidal Solid" \
	    "Circular Solid" "SemiCircular Solid" "Tube" "Double T"]
    set cbsection [ComboBox $pane1.cbsection \
	    -textvariable sections::sectiontype \
	    -editable no -values $listsection]
    set title1 [TitleFrame $pane1.draw -relief groove -bd 2 \
	    -text [= "Visual Description"] -side left]
    set f1 [$title1 getframe]
    set can [canvas $f1.can -relief raised -bd 2 -width 200\
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
    label $f3.units1 -textvariable sections::unitslength
    set abyscaleup [ArrowButton $f3.abyscaleup -type arrow -dir right \
	    -helptext [= "Increase scale range"] -armcommand "sections::increasescale y"]
   set abyscaledown [ArrowButton $f3.abyscaledown -type arrow -dir left \
	    -helptext [= "Decrease scale range"] -armcommand "sections::decreasescale y"] 
    set yscale [scale $f3.ycscale -showvalue 0 -orient horizontal \
	    -command "sections::refresh;#" \
	    -width 10 -sliderlength 10 -from -100 -to 100 \
	    -variable sections::oy -digits 4 \
	    -tickinterval 50.0 -resolution 0.5 -length 100]
    set command "sections::linkenrtyscale y ;#"
    trace variable sections::oy w $command
    bind $eycenter <Destroy> [list trace vdelete sections::oy w $command]
    set lzcenter [label $f3.lzcenter -text [= "Z center"] -justify left]
    set ezcenter [Entry $f3.ezcenter -textvariable sections::oz \
	    -bd 2 -relief sunken]
    label $f3.units2 -textvariable sections::unitslength
     set abzscaleup [ArrowButton $f3.abzscaleup -type arrow -dir right \
	    -helptext [= "Increase scale range"] -armcommand "sections::increasescale z"]
   set abzscaledown [ArrowButton $f3.abzscaledown -type arrow -dir left \
	    -helptext [= "Decrease scale range"] -armcommand "sections::decreasescale z"] 
    set zscale [scale $f3.zcscale -showvalue 0 -orient horizontal \
	    -command "sections::refresh;#" \
	    -width 10 -sliderlength 10 -from -100 -to 100 \
	    -variable sections::oz -digits 4 \
	    -tickinterval 50.0 -resolution 0.5 -length 100]
     set command "sections::linkenrtyscale z ;#"
    trace variable sections::oz w $command
    bind $ezcenter <Destroy> [list trace vdelete sections::oz w $command]
    set bcentroid [button $f3.bcentroid -text [= Centroid] -underline 1 \
	    -command "set sections::oy 0.0 ; set sections::oz 0.0 ; sections::refresh;#"]
    set title4 [TitleFrame $pane1.inertia -relief groove -bd 2 \
	    -text [= "Moments of Inertia"] -side left -ipad 8]
    set f4 [$title4 getframe]
    set larea [label $f4.larea -text [= Area] -justify left]
    set earea [Entry $f4.earea -textvariable sections::area -editable no -relief groove \
	    -bd 2 -bg lightyellow -justify right]
    label $f4.units1 -textvariable sections::unitslength2
    set liyy [label $f4.liyy -text [= Iyy] -justify left]
    set eiyy [Entry $f4.eiyy -textvariable sections::iyy -editable no -relief groove -bd 2 \
	    -bg lightyellow -justify right]
    label $f4.units2 -textvariable sections::unitslength4
    set lizz [label $f4.lizz -text [= Izz] -justify left]
    set eizz [Entry $f4.eizz -textvariable sections::izz -editable no -relief groove -bd 2  \
	    -bg lightyellow -justify right]
    label $f4.units3 -textvariable sections::unitslength4
    set liyz [label $f4.liyz -text [= Iyz] -justify left]
    set eiyz [Entry $f4.eiyz -textvariable sections::iyz -editable no -relief groove -bd 2  \
	    -bg lightyellow -justify right]
    label $f4.units4 -textvariable sections::unitslength4
    set lj [label $f4.lj -text [= "  J"] -justify left]
    set ej [Entry $f4.ej -textvariable sections::j -editable no -relief groove -bd 2  \
	    -bg lightyellow -justify right]
    label $f4.units5 -textvariable sections::unitslength4
    set fbuttons [frame .t.fbuttons -bd 1 -relief groove ]
    set baccept [button $fbuttons.baccept -text [= OK] -width 10 \
	    -command [list sections::accepts $GDN $STRUCT]]
    set bsave [button $fbuttons.bsave -text [= "Save..."] -width 10 \
	    -command [list sections::accepts $GDN $STRUCT save]]
    set bcancel [button $fbuttons.bcancel -text [= Cancel] -width 10 \
	    -command "sections::cancel [list $GDN $STRUCT]"]
    grid $pw -column 0 -row 0 -sticky nsew
    grid columnconf $pane1 1 -weight 1
    grid rowconf $pane1 1 -weight 1
    grid $lsection -column 0 -row 0 -sticky we
    grid $cbsection -column 1 -row 0 -sticky we -pady 4 -padx 3
    grid $title1 -column 0 -row 1 -sticky nsew -columnspan 2 -padx 3
    grid columnconf $f1 0 -weight 1
    grid rowconf $f1 0 -weight 1
    grid $can -column 0 -row 0 -sticky nsew
    grid columnconf $pane2 0 -weight 1
    grid rowconf $pane2 4 -weight 1
    if { $sectiontype == "" } {
	grid $title2 -column 0 -row 0 -sticky nsew -padx 3
	grid columnconf $f2 0 -weight 1
	grid rowconf $f2 0 -weight 1
	grid $message -column 0 -row 0 
    } else {
	sections::type  $title2 $pane2 
    }
    grid $title3 -column 0 -row 1 -sticky nsew -padx 3
    grid columnconf $f3 1 -weight 1
    grid $lycenter -column 0 -row 0 -sticky ew
    grid $eycenter -column 1 -row 0 -sticky ew -padx "4 0"
    grid $f3.units1 -column 2 -row 0 -sticky w -padx "0 4"
    grid $abyscaledown -column 3 -row 0 -sticky e
    grid $abyscaleup -column 4 -row 0 -sticky w
    grid $yscale -column 0 -row 1 -sticky ew -columnspan 5
    grid $lzcenter -column 0 -row 2 -sticky ew
    grid $ezcenter -column 1 -row 2 -sticky ew -padx "4 0"
    grid $f3.units2 -column 2 -row 2 -sticky w -padx "0 4"
    grid $abzscaledown -column 3 -row 2 -sticky e
    grid $abzscaleup -column 4 -row 2 -sticky w
    grid $zscale -column 0 -row 3 -sticky ew -columnspan 5
    grid $bcentroid -column 1 -row 4 -sticky w -padx 40
    grid $title4 -column 0 -row 2 -sticky sew -columnspan 2 -padx 3
    grid columnconf $f4 1 -weight 1
    grid $larea -column 0 -row 0 -sticky ew -pady 2
    grid $earea -column 1 -row 0 -sticky ew -pady 2
    grid $f4.units1 -column 2 -row 0 -sticky w -pady 2
    grid $liyy -column 0 -row 1 -sticky ew -pady 2
    grid $eiyy -column 1 -row 1 -sticky ew -pady 2
    grid $f4.units2 -column 2 -row 1 -sticky w -pady 2
    grid $lizz -column 0 -row 2 -sticky ew -pady 2
    grid $eizz -column 1 -row 2 -sticky ew -pady 2
    grid $f4.units3 -column 2 -row 2 -sticky w -pady 2
    grid $liyz -column 0 -row 3 -sticky ew -pady 2
    grid $eiyz -column 1 -row 3 -sticky ew -pady 2
    grid $f4.units4 -column 2 -row 3 -sticky w -pady 2
    grid $lj -column 0 -row 4 -sticky ew -pady 2
    grid $ej -column 1 -row 4 -sticky ew -pady 2
    grid $f4.units5 -column 2 -row 4 -sticky w -pady 2
    bind $can <Configure> "sections::refresh"
    grid $fbuttons -column 0 -row 1 -sticky nsew -pady 8
    grid $baccept -column 0 -row 0 -sticky nsew -padx 5 -pady 4
    grid $bsave -column 1 -row 0 -sticky nsew -padx 5 -pady 4
    grid $bcancel -column 2 -row 0 -sticky nsew -padx 5 -pady 4
    $nb compute_size


     set mat [TitleFrame $page2.mat -relief groove -bd 2 \
	    -text [= "Material"] -side left -ipad 8]
    set fmat [$mat getframe]
    set lunits [label $fmat.lunits -text [= Units] -justify left]
    set cbunits [ComboBox $fmat.cbunits -textvariable sections::units -editable no -relief groove \
	    -bd 2 -justify right -values [list N-m-kg N-cm-kg N-mm-kg Kp-cm-utm]]
    set command "sections::matproperties ;#"
    trace add variable sections::units write $command
    bind $cbunits <Destroy> [list trace remove variable sections::units write $command]

    set lyoung [label $fmat.lyoung -text E -justify left]
    set eyoung [Entry $fmat.earea -textvariable sections::young -relief groove \
	    -bd 2 -justify left]
    set lyunit [label $fmat.lyunit -textvariable sections::unitshow -justify left -width 7]
    set lshear [label $fmat.lshear -text G -justify left]
    set eshear [Entry $fmat.eshear -textvariable sections::shear -relief groove \
	    -bd 2 -justify left]
    set lsunit [label $fmat.lsunit -textvariable sections::unitshow -justify left -width 7]
    set lmass [label $fmat.lmass -text [= "Specific Weight"] -justify left]
    set emass [Entry $fmat.emass -textvariable sections::mass -relief groove \
	    -bd 2 -justify left]
    set lmunit [label $fmat.lmunit -textvariable sections::unitmass -justify left -width 7]

    set lstress [label $fmat.lstress -text [= "Maximum stress"] -justify left]
    set estress [Entry $fmat.estress -textvariable sections::maxstress -relief groove \
	    -bd 2 -justify left]
    set lstunit [label $fmat.lstunit -textvariable sections::unitshow -justify left -width 7]

    set listmat [TitleFrame $page2.listmat -relief groove -bd 2 \
	    -text [= "Predefined Material"] -side left -ipad 8]
    set flist [$listmat getframe]
    set lname [label $flist.lname -text [= Name] -justify left]
    set materials [list "" steel titanium stainless "steel A37" "steel A42" "steel A52"]
    set cbname [ComboBox $flist.cbname -textvariable sections::matname -editable no -relief groove \
	    -bd 2 -justify right -values $materials]
    set command "sections::matproperties force_mat_name;#"
    trace add variable sections::matname write $command
    bind $cbname <Destroy> [list trace remove variable sections::matname write $command]

    grid $mat -column 0 -row 0 -sticky nsew
    grid $lunits -column 0 -row 0 -sticky ne
    grid $cbunits -column 1 -row 0 -sticky nsew
    grid $lyoung -column 0 -row 1 -sticky ne
    grid $eyoung -column 1 -row 1 -sticky nsew
    grid $lyunit -column 2 -row 1 -sticky ne 
    grid $lshear -column 0 -row 2 -sticky ne
    grid $eshear -column 1 -row 2 -sticky nsew
    grid $lsunit -column 2 -row 2 -sticky ne
    grid $lmass -column 0 -row 3 -sticky ne
    grid $emass -column 1 -row 3 -sticky nsew
    grid $lmunit -column 2 -row 3 -sticky ne
    grid $lstress -column 0 -row 4 -sticky ne
    grid $estress -column 1 -row 4 -sticky nsew
    grid $lstunit -column 2 -row 4 -sticky ne

    grid $listmat -column 0 -row 1 -sticky nsew
    grid $lname -column 0 -row 0 -sticky ne 
    grid $cbname -column 1 -row 0 -sticky nsew
    $nb compute_size
    set matname "steel"
    sections::matproperties 
    sections::ChangeUnitsLength 


    foreach i [list width height topwidth bottomwidth diameter thickness wingsthick \
		   thick oy oz unitslength] {
	variable $i
    }
    set NameL ""
    foreach i [regexp -inline -all {.[^-]*-|.[^-]*$} [DWLocalGetValue $GDN $STRUCT Name]] {
	lappend NameL [string trimright $i -]
    }
    set ipos -1
    foreach "oy oz" "0.0 0.0" break
    set props ""
    switch [lindex $NameL 0] {
	R { set props "width height"; set ipos 0 }
	Trapezoidal { set props "topwidth bottomwidth height" ; set ipos 1 }
	O { set props diameter ; set ipos 2 }
	TUBE { set props "diameter thickness" ; set ipos 3 }
	SO { set props "diameter" ; set ipos 4 }
	T { set props "topwidth bottomwidth height wingsthick thick" ; set ipos 5 }
    }
    set props [linsert $props 0 -]
    if { [llength $props] == [llength $NameL] } {
	foreach $props $NameL break
    } elseif { [llength $props]+2 == [llength $NameL] } {
	lappend props oy oz
	foreach $props $NameL break
    }
    set unitslength mm
    if { $ipos != -1 } {
	set sectiontype [lindex [list "Rectangular Solid" "Trapezoidal Solid" "Circular Solid" \
		                     "Tube" "SemiCircular Solid" "Double T"] $ipos]
	refresh
    }


    foreach i [list last_units units young shear mass maxstress] { variable $i }

    set units_out [DWLocalGetValue $GDN $STRUCT Units]
    set ipos [lsearch [list N-m-kg N-cm-kg N-mm-kg Kp-cm-utm] $units_out]
    set young [DWLocalGetValue $GDN $STRUCT E]
    set shear [DWLocalGetValue $GDN $STRUCT G]
    set mass [DWLocalGetValue $GDN $STRUCT "Specific_weight"]
    set maxstress [DWLocalGetValue $GDN $STRUCT "Maximum_stress"]
    set last_units ""
    set units [lindex [list N-m-kg N-cm-kg N-mm-kg Kp-cm-utm] $ipos]

    return $w
}

proc sections::type { window parent  } {
    variable sectiontype
    variable area ""
    variable izz ""
    variable iyy ""
    variable iyz ""
    variable j ""
    variable oy
    variable oz 

#     set oy 0.0
#     set oz 0.0
    destroy $window
    switch $sectiontype {
	"Rectangular Solid" { sections::rect_sol  $parent }
	"Trapezoidal Solid" { sections::trap_sol $parent }
	"Circular Solid" { sections::circ_sol $parent }
	"Tube" { sections::tube $parent }
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
    variable bcalculate

    set title2 [TitleFrame $parent.prop -relief groove -bd 2 \
	    -text [= "Section Properties"] -side left]
    set sectionfr [$title2 getframe]
    grid $title2 -column 0 -row 0 -sticky nsew -padx 3
    grid columnconf $sectionfr 1 -weight 1
    grid rowconf $sectionfr 2 -weight 1
    set lwidth [label $sectionfr.lwidth -text [= Width] -justify left ]
    set ewidth [entry $sectionfr.ewidth -textvariable sections::width -bd 2 -relief sunken]
    ComboBox $sectionfr.cb -textvariable sections::::unitslength -values "m dm cm mm" \
	-editable 0 -width 3 -modifycmd sections::ChangeUnitsLength
    set lheight [label $sectionfr.lheight -text [= Height] -justify left]
    set eheight [entry $sectionfr.eheight -textvariable sections::height -bd 2 -relief sunken]
    label $sectionfr.l1 -textvariable sections::::unitslength
    set bcalculate [button $sectionfr.bcalculate -text [= Calculate] -underline 0 \
		-command "sections::rect_sol_cal" ]
    grid $lwidth -column 0 -row 0 -sticky nwe
    grid $ewidth -column 1 -row 0 -sticky we
    grid $sectionfr.cb -column 2 -row 0 -sticky w
    grid $lheight -column 0 -row 1 -sticky nwe
    grid $eheight -column 1 -row 1 -sticky we
    grid $sectionfr.l1 -column 2 -row 1 -sticky w
    grid $bcalculate -column 0 -row 2 -pady 4 -columnspan 2
    bind $bcalculate <ButtonRelease> { set sections::values [list 5 Width $sections::width Height $sections::height];  \
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
    variable bcalculate

    set title2 [TitleFrame $parent.prop -relief groove -bd 2 \
	    -text [= "Section Properties"] -side left]
    set sectionfr [$title2 getframe]
    grid $title2 -column 0 -row 0 -sticky nsew -padx 3
    grid columnconf $sectionfr 1 -weight 1
    grid rowconf $sectionfr 4 -weight 1
    #set topwidth ""
    #set bottomwidth ""
    #set height ""
    set ltopwidth [label $sectionfr.ltopwidth -text "Top Width" -justify right]
    set etopwidth [entry $sectionfr.etopwidth -textvariable sections::topwidth -bd 2 \
	    -relief sunken]
    ComboBox $sectionfr.cb -textvariable sections::::unitslength -values "m dm cm mm" \
	-editable 0 -width 3 -modifycmd sections::ChangeUnitsLength
    set lbottomwidth [label $sectionfr.lbottomwidth -text [= "Bottom Width"] -justify right]
    set ebottomwidth [entry $sectionfr.ebottomwidth -textvariable sections::bottomwidth \
	    -bd 2 -relief sunken]
    label $sectionfr.l1 -textvariable sections::::unitslength
    set lheight [label $sectionfr.lheight -text [= Height] -justify right]
    label $sectionfr.l2 -textvariable sections::::unitslength
    set eheight [entry $sectionfr.eheight -textvariable sections::height -bd 2 -relief sunken]
    set bcalculate [button $sectionfr.bcalculate -text [= Calculate] -underline 0 \
		-command "sections::trap_sol_cal"]
    grid $ltopwidth -column 0 -row 0 -sticky nw
    grid $etopwidth -column 1 -row 0 -sticky we
    grid $sectionfr.cb -column 2 -row 0 -sticky w
    grid $lbottomwidth -column 0 -row 1 -sticky nw
    grid $ebottomwidth -column 1 -row 1 -sticky we
    grid $sectionfr.l1 -column 2 -row 1 -sticky w
    grid $lheight -column 0 -row 2 -sticky nw
    grid $eheight -column 1 -row 2 -sticky we
    grid $sectionfr.l1 -column 2 -row 2 -sticky w
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
    variable diameter
    variable can
    variable yscale
    variable zscale
    variable cz
    variable bcalculate

    set title2 [TitleFrame $parent.prop -relief groove -bd 2 \
	    -text [= "Section Properties"] -side left]
    set sectionfr [$title2 getframe]
    grid $title2 -column 0 -row 0 -sticky nsew
    grid columnconf $sectionfr 1 -weight 1
    grid rowconf $sectionfr 2 -weight 1
    #set diameter ""
    set ldiameter [label $sectionfr.ldiameter -text [= Diameter] -justify left]
    set ediameter [entry $sectionfr.ediameter -textvariable sections::diameter -bd 2 -relief sunken]
    set bcalculate [button $sectionfr.bcalculate -text [= Calculate] -underline 0 \
		-command "sections::circ_sol_cal" ]
    ComboBox $sectionfr.cb -textvariable sections::::unitslength -values "m dm cm mm" \
	-editable 0 -width 3 -modifycmd sections::ChangeUnitsLength
    grid $ldiameter -column 0 -row 0 -sticky nwe
    grid $ediameter -column 1 -row 0 -sticky we
    grid $sectionfr.cb -column 2 -row 0 -sticky w
    grid $bcalculate -column 0 -row 2 -pady 4 -columnspan 2
    bind $bcalculate <ButtonRelease> { set sections::values [list 3 Diameter $sections::diameter];  \
	    if  { ! [sections::errorcntrl $sections::values] } { 
		set r [expr {$sections::diameter/2.0}]
		set sections::cz $r
		$sections::yscale configure \
		    -to $r \
		    -from [expr -$r] \
		    -tickinterval [expr -$r] \
		    -resolution [expr -$r/200.0] ; \
		    $sections::zscale configure -to [expr $r] \
		    -from [expr -$r] \
		    -tickinterval [expr -$r/2.0] \
		    -resolution [expr -$r/200.0]
	    }
    }
    bind $ediameter <KeyPress-Return>  { set sections::values [list 3 Diameter $sections::diameter];  \
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

proc sections::tube { parent } {
    variable diameter
    variable thickness
    variable can
    variable yscale
    variable zscale
    variable cz
    variable bcalculate

    set title2 [TitleFrame $parent.prop -relief groove -bd 2 \
	    -text [= "Section Properties"] -side left]
    set sectionfr [$title2 getframe]
    grid $title2 -column 0 -row 0 -sticky nsew
    grid columnconf $sectionfr 1 -weight 1
    grid rowconf $sectionfr 2 -weight 1
    #set diameter ""
    set ldiameter [label $sectionfr.ldiameter -text [= Diameter] -justify left]
    set ediameter [entry $sectionfr.ediameter -textvariable sections::diameter -bd 2 -relief sunken]
    ComboBox $sectionfr.cb -textvariable sections::::unitslength -values "m dm cm mm" \
	-editable 0 -width 3 -modifycmd sections::ChangeUnitsLength
    set lthick [label $sectionfr.lthick -text [= Thickness] -justify left]
    set ethick [entry $sectionfr.ethick -textvariable sections::thickness -bd 2 -relief sunken]
    label $sectionfr.l1 -textvariable sections::::unitslength

    set bcalculate [button $sectionfr.bcalculate -text [= Calculate] -underline 0 \
		-command "sections::tube_cal" ]
    grid $ldiameter -column 0 -row 0 -sticky nwe
    grid $ediameter -column 1 -row 0 -sticky we
    grid $sectionfr.cb -column 2 -row 0 -sticky w
    grid $lthick -column 0 -row 1 -sticky nwe
    grid $ethick -column 1 -row 1 -sticky we
    grid $sectionfr.l1 -column 2 -row 1 -sticky w
    grid $bcalculate -column 0 -row 2 -pady 4 -columnspan 2
    bind $bcalculate <ButtonRelease> {
	set sections::values [list "" Diameter $sections::diameter Thickness $sections::thickness]
	if  { ! [sections::errorcntrl $sections::values] } { 
	    set r [expr {$sections::diameter/2.0}]
	    set sections::cz $r 
	    $sections::yscale configure \
		-to [expr $r] \
		-from [expr -$r] \
		-tickinterval [expr -$r] \
		-resolution [expr -$r/200.0] ; \
		$sections::zscale configure -to [expr $r] \
		-from [expr -$r] \
		-tickinterval [expr -$r/2.0] \
		-resolution [expr -$r/200.0]
	}
    }
    bind $ediameter <KeyPress-Return>  {
	set sections::values [list "" Diameter $sections::diameter Thickness $sections::thickness]
	if  { ! [sections::errorcntrl $sections::values] } {
	    tkButtonInvoke $sections::bcalculate
	    event generate $sections::bcalculate <ButtonRelease>
	}
    }
    bind $ethick <KeyPress-Return> [bind $ediameter <KeyPress-Return>]
    $can delete all
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set x0 [expr $x/2-60]
    set y0 [expr ($y/2-60)]
    set x1 [expr $x0+2*60]
    set y1 [expr $y0+2*60]
    $can create oval $x0 $y0 $x1 $y1 -fill gray85 
    set x0_i [expr $x/2-55]
    set y0_i [expr ($y/2-55)]
    $can create oval $x0_i $y0_i [expr $x0_i+2*55] [expr $y0_i+2*55] \
	-fill [$can cget -background] 
}

proc sections::semicirc_sol { parent } {
    variable diameter
    variable can
    variable yscale
    variable zscale
    variable cz
    variable bcalculate

    set title2 [TitleFrame $parent.prop -relief groove -bd 2 \
	    -text [= "Section Properties"] -side left]
    set sectionfr [$title2 getframe]
    grid $title2 -column 0 -row 0 -sticky nsew -padx 3
    grid columnconf $sectionfr 1 -weight 1
    grid rowconf $sectionfr 2 -weight 1
    #set diameter ""
    set ldiameter [label $sectionfr.ldiameter -text [= Diameter] -justify left]
    set ediameter [entry $sectionfr.ediameter -textvariable sections::diameter \
		       -bd 2 -relief sunken]
    ComboBox $sectionfr.cb -textvariable sections::::unitslength -values "m dm cm mm" \
	-editable 0 -width 3 -modifycmd sections::ChangeUnitsLength

    set bcalculate [button $sectionfr.bcalculate -text [= Calculate] -underline 0 \
		-command "sections::semicirc_sol_cal" ]
    grid $ldiameter -column 0 -row 0 -sticky nwe
    grid $ediameter -column 1 -row 0 -sticky we
    grid $sectionfr.cb -column 2 -row 0 -sticky w
    grid $bcalculate -column 0 -row 2 -pady 4 -columnspan 2
    bind $bcalculate <ButtonRelease> { set sections::values [list 3 Diameter $sections::diameter] ;  \
	    if  { ! [sections::errorcntrl $sections::values] } { 
		set r [expr {$diameter/2.0}]
		set sections::cz [expr 4*$r/(3*$sections::pi)]
		$sections::yscale configure \
		    -to [expr $r] \
		    -from [expr -$r] \
		    -tickinterval [expr -$r] \
		    -resolution [expr -$r/200.0] ; \
		    $sections::zscale configure -to [expr $r-$sections::cz] \
		    -from [expr -$sections::cz] \
		    -tickinterval [expr -$r/2.0] \
		    -resolution [expr -$r/200.0]
	    }
    }
    bind $ediameter <KeyPress-Return>  { set sections::values [list 3 Diameter $sections::diameter];  \
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
    variable bcalculate

    set title2 [TitleFrame $parent.prop -relief groove -bd 2 \
	    -text [= "Section Properties"] -side left]
    set sectionfr [$title2 getframe]
    grid $title2 -column 0 -row 0 -sticky nsew -padx 3
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
    ComboBox $sectionfr.cb -textvariable sections::::unitslength -values "m dm cm mm" \
	-editable 0 -width 3 -modifycmd sections::ChangeUnitsLength
    set lbottomwidth [label $sectionfr.lbottomwidth -text [= "Bottom Width"] -justify left]
    set ebottomwidth [entry $sectionfr.ebottomwidth \
	    -textvariable sections::bottomwidth -bd 2 -relief sunken]
    label $sectionfr.l1 -textvariable sections::::unitslength
    set lheight [label $sectionfr.lheight -text [= Height] -justify left]
    set eheight [entry $sectionfr.eheight -textvariable sections::height -bd 2 -relief sunken]
    label $sectionfr.l2 -textvariable sections::::unitslength
    set lwingsthick [label $sectionfr.lwingsthick -text [= "Wings Thick."] -justify left]
    set ewingsthick [entry $sectionfr.ewingsthick \
	    -textvariable sections::wingsthick -bd 2 -relief sunken]
    label $sectionfr.l3 -textvariable sections::::unitslength
    set lthick [label $sectionfr.lthick -text [= "Central Thick."] -justify left]
    set ethick [entry $sectionfr.ethick \
	    -textvariable sections::thick -bd 2 -relief sunken]
    label $sectionfr.l4 -textvariable sections::::unitslength
    set bcalculate [button $sectionfr.bcalculate -text [= Calculate] -underline 0 \
		-command "sections::doublet_cal" ]
    grid $ltopwidth -column 0 -row 0 -sticky nw
    grid $etopwidth -column 1 -row 0 -sticky we
    grid $sectionfr.cb -column 2 -row 0 -sticky w
    grid $lbottomwidth -column 0 -row 1 -sticky nw
    grid $ebottomwidth -column 1 -row 1 -sticky we
    grid $sectionfr.l1 -column 2 -row 1 -sticky w
    grid $lheight -column 0 -row 2 -sticky nw
    grid $eheight -column 1 -row 2 -sticky we
    grid $sectionfr.l2 -column 2 -row 2 -sticky w
    grid $lwingsthick -column 0 -row 3 -sticky nw
    grid $ewingsthick -column 1 -row 3 -sticky we
    grid $sectionfr.l3 -column 2 -row 3 -sticky w
    grid $lthick -column 0 -row 4 -sticky nw
    grid $ethick -column 1 -row 4 -sticky we
    grid $sectionfr.l4 -column 2 -row 4 -sticky w
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
		WingsThick. $sections::wingsthick Thick. $sections::thick] ;   \
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
	"Tube" { sections::tube_cal }
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
    variable oy
    variable oz
    variable j
    variable Wy
    variable Wz
    variable Aty
    variable Atz
    
  
    if { ![string is double -strict $height] || ![string is double -strict $width] } {
	return 
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
    $can create text [expr $x/2+10+$oydraw] [expr $ymarge+10] -text Z
    $can create text [expr $x-$xmarge-10] [expr $y/2-10-$ozdraw] -text Y
    $can create text [expr $x/2-3] [expr $y/2+10] -text G
    set area [niceprint_g6 [expr $width*$height]]
    set iyy [niceprint_g6 [expr (($width*pow($height,3))/12.0)+pow($oz,2)*$area]]
    set izz [niceprint_g6 [expr (($height*pow($width,3))/12.0)+pow($oy,2)*$area]]
    set iyz [niceprint_g6 [expr abs($oz)*abs($oy)*$area]]
    set j [niceprint_g6 [expr 0.3*pow($height,3)*pow($width,3)/(pow($height,2)+pow($width,2))]]

    set Wy [expr {$iyy/(.5*$height+abs($oz))}]
    set Wz [expr {$izz/(.5*$width+abs($oy))}]
    set Aty $area
    set Atz $area
   
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
    variable Wy
    variable Wz
    variable Aty
    variable Atz
       
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
    $can create text [expr $x/2+10+$oydraw] [expr $ymarge+10] -text Z
    $can create text [expr $x-$xmarge-10] [expr $y/2-10-$ozdraw] -text Y
    $can create text [expr $x/2-3] [expr $y/2+10] -text G
    set area [niceprint_g6 [expr ($topwidth+$bottomwidth)*$height/2.0]]
    set iyy [niceprint_g6 [expr (pow($topwidth,2)+4*$topwidth*$bottomwidth+pow($bottomwidth,2)) \
	    *(pow($height,3)/(36*($topwidth+$bottomwidth)))+pow($oz,2)*$area]]
    set izz [niceprint_g6 [expr ($height*($topwidth+$bottomwidth)*\
	    (pow($topwidth,2)+pow($bottomwidth,2)))/48.0+pow($oy,2)*$area]]
    set iyz [niceprint_g6 [expr abs($oz)*abs($oy)*$area]]
    if { $topwidth <= $bottomwidth } {
	set j [niceprint_g6 [expr 0.3*pow($height,3)*pow($topwidth,3)/(pow($height,2)+\
		                                                           pow($topwidth,2))]]
    } else {
	set j [niceprint_g6 [expr 0.3*pow($height,3)*pow($bottomwidth,3)/(pow($height,2)+\
		                                                              pow($bottomwidth,2))]]
    }
    set cy [expr $cy/$scale]

    set Wy 0.0
    set Wz 0.0
    set Aty 0.0
    set Atz 0.0
    
}
proc sections::circ_sol_cal { } {
    variable can
    variable diameter
    variable area 
    variable izz 
    variable iyy 
    variable iyz 
    variable j
    variable oy
    variable oz
    variable  pi
    variable Wy
    variable Wz
    variable Aty
    variable Atz
    
    if {![string is double -strict $diameter]  } {
	return
    }
    set r [expr {$diameter/2.0}]
    $can delete all
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set xmarge [expr $x*0.1]
    set ymarge [expr $y*0.2]
    set xscale [expr ($x-2*$xmarge)/($diameter)]
    set yscale [expr ($y-2*$ymarge)/($diameter)]
    if { $xscale <= $yscale } {
	set diameterdraw [expr $xscale*$diameter]
	set oydraw [expr $xscale*$oy]
	set ozdraw [expr $xscale*$oz]
    } else {
	set diameterdraw [expr $yscale*$r]
	set oydraw [expr $yscale*$oy]
	set ozdraw [expr $yscale*$oz]
    }
    set x0 [expr $x/2-$diameterdraw]
    set y0 [expr $y/2-$diameterdraw]
    set x1 [expr $x0+2*$diameterdraw]
    set y1 [expr $y0+2*$diameterdraw]
    $can create oval $x0 $y0 $x1 $y1 -fill gray 
    $can create line [expr $x/2+$oydraw] [expr $y/2-$ozdraw] [expr $x/2+$oydraw] \
	    [expr $ymarge-10] -arrow last
    $can create line [expr $x/2+$oydraw] [expr $y/2-$ozdraw]  [expr $x-$xmarge] \
	    [expr $y/2-$ozdraw] -arrow last
    $can create oval [expr $x/2-3] [expr $y/2-3] [expr $x/2+3] [expr $y/2+3] -fill red
    $can create text [expr $x/2-5+$oydraw] [expr $ymarge+10] -text Z
    $can create text [expr $x-$xmarge-10] [expr $y/2-10-$ozdraw] -text Y
    $can create text [expr $x/2-3] [expr $y/2+10] -text G
    set area [expr $pi*pow($r,2)]
    set iyy [expr $pi*pow($r,4)/4.0+pow($oz,2)*$area]
    set izz [expr $pi*pow($r,4)/4.0+pow($oy,2)*$area]
    set iyz [expr abs($oz)*abs($oy)*$area]
    set j [expr $pi*pow($r,4)/2.0]
    set area [niceprint_g6 $area]
    set iyy [niceprint_g6 $iyy]
    set izz [niceprint_g6 $izz]
    set iyz [niceprint_g6 $iyz]
    set j [niceprint_g6 $j]

    set Wy [expr {1.0*$iyy/($r+abs($oz))}]
    set Wz [expr {1.0*$izz/($r+abs($oy))}]
    set Aty $area
    set Atz $area

       
}

proc sections::tube_cal { } {
    variable can
    variable diameter
    variable thickness
    variable area 
    variable izz 
    variable iyy 
    variable iyz 
    variable j
    variable oy
    variable oz
    variable  pi
    variable Wy
    variable Wz
    variable Aty
    variable Atz
    
    if {![string is double -strict $diameter] || ![string is double -strict $thickness] } {
	return
    }
    $can delete all
    set r [expr {$diameter/2.0}]

    set r1 $r
    set r2 [expr {$r-$thickness}]

    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set xmarge [expr $x*0.1]
    set ymarge [expr $y*0.2]
    set xscale [expr ($x-2*$xmarge)/(2*$r1)]
    set yscale [expr ($y-2*$ymarge)/(2*$r1)]
    if { $xscale <= $yscale } {
	set scale $xscale
    } else { set scale $yscale }
    
    set r1d [expr $scale*$r1]
    set r2d [expr $scale*$r2]
    set oydraw [expr $scale*$oy]
    set ozdraw [expr $scale*$oz]

    set x0 [expr $x/2-$r1d]
    set y0 [expr $y/2-$r1d]
    set x1 [expr $x0+2*$r1d]
    set y1 [expr $y0+2*$r1d]
    $can create oval $x0 $y0 $x1 $y1 -fill gray
    foreach "x0_r2 y0_r2" [list [expr {$x/2-$r2d}] [expr {$y/2-$r2d}]] break
    $can create oval $x0_r2 $y0_r2 [expr {$x0_r2+2*$r2d}] [expr {$y0_r2+2*$r2d}] \
	-fill [$can cget -background]
    $can create line [expr $x/2+$oydraw] [expr $y/2-$ozdraw] [expr $x/2+$oydraw] \
	    [expr $ymarge-10] -arrow last
    $can create line [expr $x/2+$oydraw] [expr $y/2-$ozdraw]  [expr $x-$xmarge] \
	    [expr $y/2-$ozdraw] -arrow last
    $can create oval [expr $x/2-3] [expr $y/2-3] [expr $x/2+3] [expr $y/2+3] -fill red
    $can create text [expr $x/2-5+$oydraw] [expr $ymarge+10] -text Z
    $can create text [expr $x-$xmarge-10] [expr $y/2-10-$ozdraw] -text Y
    $can create text [expr $x/2-3] [expr $y/2+10] -text G
    set area [expr {$pi*pow($r1,2)-$pi*pow($r2,2)}]
    set iyy [expr $pi/4.0*(pow($r1,4)-pow($r2,4))+pow($oz,2)*$area]
    set izz [expr $pi/4.0*(pow($r1,4)-pow($r2,4))+pow($oy,2)*$area]
    set iyz [expr abs($oz)*abs($oy)*$area]
    set j [expr {$pi*(pow($r1,4)-pow($r2,4))/2.0}]
    set area [niceprint_g6 $area]
    set iyy [niceprint_g6 $iyy]
    set izz [niceprint_g6 $izz]
    set iyz [niceprint_g6 $iyz]
    set j [niceprint_g6 $j]

    set Wy [expr {1.0*$iyy/($r+abs($oz))}]
    set Wz [expr {1.0*$izz/($r+abs($oy))}]
    set Aty $area
    set Atz $area
    
}

proc sections::semicirc_sol_cal { } {
    variable can
    variable diameter
    variable area 
    variable izz 
    variable iyy 
    variable iyz 
    variable oy
    variable oz
    variable  pi
    variable j
    variable Wy
    variable Wz
    variable Aty
    variable Atz
    
     if { ![string is double -strict $diameter] } {
	return 
    }
    $can delete all
    set r [expr {$diameter/2.0}]
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set xmarge [expr $x*0.1]
    set ymarge [expr $y*0.2]
    set xscale [expr ($x-2*$xmarge)/($diameter)]
    set yscale [expr ($y-2*$ymarge)/($diameter)]
    if { $xscale <= $yscale } {
	set diameterdraw [expr $xscale*$r]
	set oydraw [expr $xscale*$oy]
	set ozdraw [expr $xscale*$oz]
    } else {
	set diameterdraw [expr $yscale*$r]
	set oydraw [expr $yscale*$oy]
	set ozdraw [expr $yscale*$oz]
    }
    set x0 [expr $x/2-$diameterdraw]
    set y0 [expr $y/2-$diameterdraw+4*$diameterdraw/(3*$pi)]
    set x1 [expr $x0+2*$diameterdraw]
    set y1 [expr $y0+2*$diameterdraw]
    $can create arc $x0 $y0 $x1 $y1 -fill gray -extent 180 -start 0
    $can create line [expr $x/2+$oydraw] [expr $y/2-$ozdraw] [expr $x/2+$oydraw] \
	    [expr $ymarge-10] -arrow last
    $can create line [expr $x/2+$oydraw] [expr $y/2-$ozdraw]  [expr $x-$xmarge+10] \
	    [expr $y/2-$ozdraw] -arrow last
    $can create oval [expr $x/2-3] [expr $y/2-3] [expr $x/2+3] [expr $y/2+3] -fill red
    $can create text [expr $x/2-5+$oydraw] [expr $ymarge+10] -text Z
    $can create text [expr $x-$xmarge-10] [expr $y/2-10-$ozdraw] -text Y
    $can create text [expr $x/2-3] [expr $y/2+10] -text G
    set area [niceprint_g6 [expr $pi*pow($r,2)/2.0]]
    set iyy [niceprint_g6 [expr $pi*pow($r,4)/8.0]]
    set iyy [niceprint_g6 [expr $iyy-(8/(9*$pi))*pow($r,4)+pow($oz,2)*$area]]
    set izz [niceprint_g6 [expr ($pi*pow($r,4)/8.0)+pow($oy,2)*$area]]
    set iyz [niceprint_g6 [expr abs($oz)*abs($oy)*$area]]
    set j [niceprint_g6 [expr $pi*pow($r,4)/4.0]]

    set Wy 0.0
    set Wz 0.0
    set Aty 0.0
    set Atz 0.0

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
    variable Wy
    variable Wz
    variable Aty
    variable Atz
    
     if {![string is double -strict $height]  || ![string is double -strict $topwidth]  \
	||![string is double -strict $bottomwidth]  || ![string is double -strict $wingsthick] \
	||![string is double -strict  $thick] } {
	return 
    }
    $can delete all
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set xmarge [expr $x*0.1]
    set ymarge [expr $y*0.2]
    set h [expr $height-2*$wingsthick]
    if { $h <= 0.0 } {
	WarnWin [= "Thicknesses added up are greater than the section height "] .t
    }
    set area [niceprint_g6 [expr $topwidth*$wingsthick+$bottomwidth*$wingsthick+$h*$thick]]
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
    $can create text [expr $x/2+10+$oydraw] [expr $ymarge+10] -text Z
    $can create text [expr $x-$xmarge-10] [expr $y/2-10-$ozdraw] -text Y
    $can create text [expr $x/2-3] [expr $y/2+10] -text G
    set iyy [niceprint_g6 [expr (1.0/3.0)*($topwidth*pow($height-$cz,3)+$bottomwidth*pow($cz,3) \
	    -($topwidth-$thick)*pow($height-$cz-$wingsthick,3) \
	    -($bottomwidth-$thick)*pow($cz-$wingsthick,3))+pow($oz,2)*$area]]
    set izz [niceprint_g6 [expr (1.0/12.0)*($wingsthick*pow($topwidth,3)+($height-2*$wingsthick)*\
		                                pow($thick,3)+ \
	    $wingsthick*pow($bottomwidth,3))+pow($oy,2)*$area]]
    set iyz [niceprint_g6 [expr abs($oz)*abs($oy)*$area]]
    set j [niceprint_g6 [ expr 0.333*(($topwidth+$bottomwidth)*pow($wingsthick,3)+\
		                          ($height-2*$wingsthick)*pow($thick,3))]]

    set maxwidth [expr {($topwidth>$bottomwidth)?$topwidth:$bottomwidth}]
    set Wy [expr {1.0*$iyy/($height+abs($oz))}]
    set Wz [expr {1.0*$izz/($maxwidth+abs($oy))}]
    set Aty $area
    set Atz $area

   
}

# what = ok ; save
proc sections::accepts { GDN STRUCT { what ok } } {
    variable area 
    variable iyy
    variable izz
    variable iyz
    variable young
    variable mass
    variable maxstress
    variable shear
    variable matname
    variable units
    variable unitslength
    variable j
    variable can
    variable diameter
    variable thickness
    variable width
    variable topwidth
    variable bottomwidth
    variable height
    variable topwidth
    variable height
    variable wingsthick
    variable thick
    variable sectiontype
    variable oy
    variable oz
    variable Wy
    variable Wz
    variable Aty
    variable Atz
     
    if { [errorcntrl [list 7 E $young G $shear \
	[= "Specific Weight"] $mass [= "Maximum stress"] $maxstress]] } { 
	return 
    }
    if { $area == "NaN" } {
	WarnWin [= " Please check the coordinates of the centroid."] .t
	return
    }
    if { $area == 0.0 || $area == ""} {
	WarnWin [= "Don't forget to press Calculate button before"] .t
	return
    }
    
    set ipos [lsearch [list N-m-kg N-cm-kg N-mm-kg Kp-cm-utm] $units]
    set fac_out [lindex [list 1 100 1e3 100] $ipos]
    set ipos2 [lsearch [list m dm cm mm] $unitslength]
    set fac_out [expr {$fac_out*[lindex [list 1 1e-1 1e-2 1e-3] $ipos2]}]
    set fac_mm [lindex [list 1e3 1e2 10 1] $ipos2]
    set fac_out2 [expr {$fac_out*$fac_out}]
    set fac_out3 [expr {$fac_out*$fac_out*$fac_out}]
    set fac_out4 [expr {$fac_out*$fac_out*$fac_out*$fac_out}]
    set units_out [lindex [list N-m-kg N-cm-kg N-mm-kg Kp-cm-utm] $ipos]
    DWLocalSetValue $GDN $STRUCT  "Units" $units_out
    
    DWLocalSetValue $GDN $STRUCT  "Area" [niceprint_g6 [expr {$area*$fac_out2}]]
    DWLocalSetValue $GDN $STRUCT  "Inertia_y" [niceprint_g6 [expr {$iyy*$fac_out4}]]
    DWLocalSetValue $GDN $STRUCT  "Inertia_z" [niceprint_g6 [expr {$izz*$fac_out4}]]
    DWLocalSetValue $GDN $STRUCT  "J" [niceprint_g6 [expr {$j*$fac_out4}]]
    DWLocalSetValue $GDN $STRUCT  "E" [niceprint_g6 $young]
    DWLocalSetValue $GDN $STRUCT  "G" [niceprint_g6 $shear]
    DWLocalSetValue $GDN $STRUCT  "Specific_weight" [niceprint_g6 $mass]
    
    DWLocalSetValue $GDN $STRUCT  "W_y" [niceprint_g6 [expr {$Wy*$fac_out3}]]
    DWLocalSetValue $GDN $STRUCT  "W_z" [niceprint_g6 [expr {$Wz*$fac_out3}]]
    DWLocalSetValue $GDN $STRUCT  "Aty" [niceprint_g6 [expr {$Aty*$fac_out2}]]
    DWLocalSetValue $GDN $STRUCT  "Atz" [niceprint_g6 [expr {$Atz*$fac_out2}]]
    DWLocalSetValue $GDN $STRUCT  "Maximum_stress" [niceprint_g6 $maxstress]
    switch $sectiontype {
	"Rectangular Solid" {
	    set Name R
	    set props "width height"
	}
	"Trapezoidal Solid" {
	    set Name "Trapezoidal" 
	    set props "topwidth bottomwidth height"
	}
	"Circular Solid" {
	    set Name O
	    set props diameter
	}
	"Tube" {
	    set Name TUBE
	    set props "diameter thickness"
	}
	"SemiCircular Solid" {
	    set Name SO
	    set props diameter
	}
	"Double T" {
	    set Name T
	    set props "topwidth bottomwidth height wingsthick thick"
	}
	default {
	    error [= "unknown section type '%s'" $sectiontype]
	}
    }
    foreach i $props {
	append Name "-[expr {[set $i]*$fac_mm}]"
    }
    if { $oy != 0.0 || $oz != 0.0 } {
	append Name "-[expr {$oy*$fac_mm}]-[expr {$oz*$fac_mm}]"
    }
    DWLocalSetValue $GDN $STRUCT Name $Name 
    
    if { $what eq "ok" } {
	$can delete all
	set area 0.0
	set izz 0.0
	set iyy 0.0
	set iyz 0.0
	set j 0.0
	destroy .t
    } else {
	set filename [file join $::ProblemTypePriv(problemtypedir) scripts \
		steelsections-custom.csv]
	set txt [= "Steel section will be saved. To access it, use Data->Steel properties.\n"]
	append txt [= "Check file '%s' for details" $filename]
	set w [dialogwin_snit .t._ask -title [_ "Save steel section"] -entrytype entry \
		-entrytext $txt -entrylabel [_ "Enter steel section name:"] \
		-entryvalues [list $Name] -entrydefault $Name]
	set action [$w createwindow]
	while 1 {
	    if { $action <= 0 } { 
		destroy $w
		return
	    }
	    set newname [string trim [$w giveentryvalue]]
	    if { [string length $newname] < 2 } {
		$self warnwin [_ "Name must have 2 or more characters"]
	    } else { break }
	    set action [$w waitforwindow]
	}
	destroy $w
	# name A Iy Iz Iyz J Wy Wz Aty Atz Yg Zg Comments
	set err [catch { open $filename a } fout]
	if { $err } {
	    snit_messageBox -message [= "Could not save. Check file permissions (%s)" \
		    $fout]
	    return
	}
	set l [list $newname]
	
	set ul2 ${unitslength}2
	set ul3 ${unitslength}3
	set ul4 ${unitslength}4
	foreach "v unit" [list area $ul2 iyy $ul4 izz $ul4 iyz $ul4 j $ul4 Wy $ul3 \
		Wz $ul3 Aty $ul2 Atz $ul2 "" "" ""] {
	    if { $v eq "" } {
		lappend l ""
	    } else {
		set $v [format %.6g [SteelSections::ConvertValuesToSI [set $v] $unit]]
		lappend l [set $v]
	    }
	}
	lappend l "Generated by RamSeries"
	puts $fout [join $l ";"]
	close $fout

	# to reload the data of the steel sections window
	SteelSections::PrepareToReloadData
    }
}
proc sections::cancel { GDN STRUCT } {
    variable area 
    variable iyy
    variable izz
    variable iyz
    variable can 
    variable young
    variable mass
    variable shear
    variable matname
    variable j
   
    $can delete all
    set area 0.0
    set izz 0.0
    set iyy 0.0
    set iyz 0.0
    set j 0.0
    #set young 0.0
    #set shear 0.0
    #set matname ""
    #set mass 0.0
    #set untis N-m-kg    

    destroy .t
    
}
proc sections::errorcntrl { values } {
    set message ""

    array set prop [ lrange $values 1 end]
    foreach elem [array names prop] {
	if { [string is space $prop($elem) ] } {
	    append message " $elem cannot be left blank.\n"
	} elseif { ! [string is double -strict $prop($elem) ] } {
	    append message " \"$prop($elem)\" is not a valid input for $elem. \n" 
	}
    }
    if  { $message != "" } {
	WarnWin $message .t
	return 1
    }
    return 0
}

proc sections::ChangeUnitsLength {} {
    variable unitslength
    variable unitslength2
    variable unitslength4

    set unitslength2 $unitslength\u00b2
    set unitslength4 $unitslength\u2074

}

# force_mat_name: =no ; =force_mat_name
proc sections::matproperties { { force_mat_name no } } {

    variable matname
    variable young
    variable shear
    variable mass
    variable maxstress
    variable last_units
    variable units 
    variable unitshow
    variable unitmass
    variable changing_matproperties

    if { [info exists changing_matproperties] } { return }
    set changing_matproperties 1

    if { $last_units eq "" } { set last_units $units }

    set matprop(steel) [list 2.1e11 8.1e10 76900 0.0]
    set matprop(titanium) [list 1.1e11 4.6e10 42112 0.0]
    set matprop(stainless) [list 2.0e11 7.9e10 53234 0.0]
    set "matprop(steel A37)" [list 2.1e11 8.1e10 76900 235.2e6]
    set "matprop(steel A42)" [list 2.1e11 8.1e10 76900 254.83e6]
    set "matprop(steel A52)" [list 2.1e11 8.1e10 76900 352.8e6]

    if { $force_mat_name eq "force_mat_name" } {
	if { $matname eq "" } {
	    set last_units $units
	    unset changing_matproperties
	    return
	}
	set last_units "N-m-kg"
	foreach "young shear mass maxstress" $matprop($matname) break
    }
    if { $last_units ne "N-m-kg" } {
	switch  $last_units {
	    "N-cm-kg" { foreach "fac_stress fac_pp" [list 1e4 1e6] break }
	    "N-mm-kg" { foreach "fac_stress fac_pp" [list 1e6 1e9] break }
	    "Kp-cm-utm" {
		foreach "fac_stress fac_pp" [list [expr {1e4*9.81}] \
		        [expr {1e6*9.81}]] break
	    }
	}
	foreach i [list young shear maxstress] {
	    set $i [expr {$fac_stress*[set $i]}]
	}
	set mass [expr {$fac_pp*$mass}]
    }
    set eps 1e-5
    if { $force_mat_name ne "force_mat_name" } {
	set found 0
	foreach mat [array names matprop] {
	    if { abs($young-[lindex $matprop($mat) 0]) <= $eps*$young && \
		abs($shear-[lindex $matprop($mat) 1]) <= $eps*$shear && \
		abs($mass-[lindex $matprop($mat) 2]) <= $eps*$mass && \
		abs($maxstress-[lindex $matprop($mat) 3]) <= $eps*$maxstress } {
		set matname $mat
		set found 1
		break
	    }
	}
	if { !$found } { set matname "" }
    }
    if { $units ne "N-m-kg" } {
	switch  $units {
	    "N-cm-kg" { foreach "fac_stress fac_pp" [list 1e-4 1e-6] break }
	    "N-mm-kg" { foreach "fac_stress fac_pp" [list 1e-6 1e-9] break }
	    "Kp-cm-utm" {
		foreach "fac_stress fac_pp" [list [expr {1e-4/9.81}] \
		        [expr {1e-6/9.81}]] break
	    }
	}
	foreach i [list young shear maxstress] {
	    set $i [expr {$fac_stress*[set $i]}]
	}
	set mass [expr {$fac_pp*$mass}]
    }
    foreach i [list young shear maxstress mass] {
	set $i [niceprint_g6 [set $i]]
    }
    switch  $units {
	"N-m-kg" { foreach "unitshow unitmass" "N/m\u00b2 N/m\u00b3" break }
	"N-cm-kg" { foreach "unitshow unitmass" "N/cm\u00b2 N/cm\u00b3" break }
	"N-mm-kg" { foreach "unitshow unitmass" "N/mm\u00b2 N/mm\u00b3" break }
	"Kp-cm-utm" { foreach "unitshow unitmass" "Kp/cm\u00b2 Kp/cm\u00b3" break }
    }
    set last_units $units
    unset changing_matproperties
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

proc sections::increasescale { type } {
    variable yscale
    variable zscale
    
    switch $type {
	"y" {
	    array set param [list to [expr 2*[$yscale cget -to]] \
		    from [expr 2*[$yscale cget -from]] \
		    tickinterval  [expr 2*[$yscale cget -tickinterval]] \
		    resolution  [expr 2*[$yscale cget -resolution]]]
	    
	    $yscale configure -to $param(to) -from $param(from) -tickinterval $param(tickinterval) \
		-resolution $param(resolution) 
	}
	"z" { 
	    array set param [list to [expr 2*[$zscale cget -to]] \
		    from [expr 2*[$zscale cget -from]] \
		    tickinterval  [expr 2*[$zscale cget -tickinterval]] \
		    resolution  [expr 2*[$zscale cget -resolution]]]
	    
	    $zscale configure -to $param(to) -from $param(from) -tickinterval $param(tickinterval) \
		-resolution $param(resolution) 
	}
    }
}
proc sections::decreasescale { type } {
    variable yscale
    variable zscale
    
    switch $type {
	"y" {
	    array set param [list to [expr [$yscale cget -to]/2] \
		    from [expr [$yscale cget -from]/2] \
		    tickinterval  [expr [$yscale cget -tickinterval]/2] \
		    resolution  [expr [$yscale cget -resolution]/2]]
	    
	    $yscale configure -to $param(to) -from $param(from) -tickinterval $param(tickinterval) \
		-resolution $param(resolution) 
	}
	"z" { 
	    array set param [list to [expr [$zscale cget -to]/2] \
		    from [expr [$zscale cget -from]/2] \
		    tickinterval  [expr [$zscale cget -tickinterval]/2] \
		    resolution  [expr [$zscale cget -resolution]/2]]
	    
	    $zscale configure -to $param(to) -from $param(from) -tickinterval $param(tickinterval) \
		-resolution $param(resolution) 
	}
    }
}
