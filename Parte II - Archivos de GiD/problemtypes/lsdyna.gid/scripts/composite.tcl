
catch { package require tablelist }
package require base64
 
namespace eval Composite {
 
    variable edit_data {
       R0lGODlhGAAYAOMAAAICBK2tmo2NgOXlztXVvzY2MlxcWfLy2///////////
       /////////////////////yH5BAEKAAgALAAAAAAYABgAAAR/EMlJq704awu2
       BkDQeRVIDERBTibhnuPWuugwiLLw7vagfj4XoGcDHGIX46FAMBWHzcxwKQD1
       QIej9GAQDozgrDYJoA3PRzGO8/p+08pstERrFrPxw7x0HaT/R0gUZUR+Ygdf
       GwY2h2JVHlOGWYkreSiCMgRyBpiQep2VoCujEQA7
    }
    variable edit [image create photo -data [set edit_data]]


    
    variable delete_data {
       R0lGODlhDwAPAKEAAP8AAICAgAAAAP///yH+Dk1hZGUgd2l0aCBHSU1QACH5
       BAEKAAMALAAAAAAPAA8AAAIxnI+AAxDbXJIstnesvlOLj2XWJyzVWEKNYIUi
       wEbu+RnyW4vhmk4p3IOkcqYBsWgqAAA7
    }
    variable delete [image create photo -data [set delete_data]]
    
    variable e1 ""
    variable e2 ""
    variable nu12 ""
    variable g12 ""
    variable g23 ""
    variable g13 ""
    variable spweight ""
    variable t ""
    variable t_mat ""
    variable ang 0.0
    variable title ""
    variable matlist ""
    variable lamlist ""
    variable index -1
    variable lamindex -1
    variable currenttitle "mat 1"
    variable cbdatamat
    variable matname ""
    variable ID 1
    variable badd
    variable bnew
    variable bfr
    variable bedit
    variable bmodify
    variable bcancel
    variable lamadd
    variable lammodify
    variable lamcancel
    variable lamclear
    variable useangle 1 
    variable numlayers
    variable can
    variable table
    variable lamtable
    variable units N-m-kg
    variable currentunit N-m-kg
    variable unit2 "N/m\u00b2"
    variable unit3 "kg/m\u00b3"
    variable unit1 m
    variable massunit2 "kg/m\u00b2"
    variable spweightunit "N/m\u00b3"
    variable conv2
    variable dens
    variable length
    variable ef         
    variable er        
    variable densityf         
    variable densityr         
    variable nuf         
    variable nur  
    variable gf
    variable kg   
    variable re100        
    variable titlel
    variable vac                 
    variable cblayer 
    variable remass
    variable typel ""
    variable values
    variable names
    variable sc1 ""
    variable sc2 ""
    variable st1 ""
    variable st2 ""
    variable cort ""
    variable considermat 0
    variable isfiberesin 0
    variable topname 
    variable mathick
    variable lamtype ""
    variable seq
    variable show_t ""
    variable aux1 ""
    variable aux2 ""
    variable totalThick 0.0        
    variable flagF_R 0

}
proc Composite::calculateconvmatrix { } { 
    variable conv2
    variable dens
    variable length
    variable spweightconv

    set conv2(N-m-kg,N-m-kg) 1.0
    set conv2(N-m-kg,N-cm-kg) 1.0e-4
    set conv2(N-m-kg,N-mm-kg) 1.0e-6
    set conv2(N-m-kg,Kp-cm-utm) [expr 1.0e-4/9.81]
    
    set conv2(N-cm-kg,N-m-kg) 1.0e4
    set conv2(N-cm-kg,N-cm-kg) 1.0
    set conv2(N-cm-kg,N-mm-kg) 1.0e-2
    set conv2(N-cm,Kp-cm-utm) [expr 1.0/9.81] 
	    
    set conv2(N-mm-kg,N-m-kg) 1.0e6
    set conv2(N-mm-kg,N-cm-kg) 1.0e-2
    set conv2(N-mm-kg,N-mm-kg) 1.0
    set conv2(N-mm-kg,Kp-cm-utm) [expr 1.0e2/9.81] 
    
    set conv2(Kp-cm-kg,N-m-kg) [expr 1.0e4*9.81]
    set conv2(Kp-cm-kg,N-cm-kg) 9.81
    set conv2(Kp-cm-kg,N-mm-kg) [expr 1.0e-2*9.81]
    set conv2(Kp-cm-utm,Kp-cm-utm) 1.0

    set dens(N-m-kg,N-m-kg) 1.0
    set dens(N-m-kg,N-cm-kg) 1.0e-6
    set dens(N-m-kg,N-mm-kg) 1.0e-9
    set dens(N-m-kg,Kp-cm-utm) [expr 1.0e-6/9.8]  

    set dens(N-cm-kg,N-m-kg) 1.0e6
    set dens(N-cm-kg,N-cm-kg) 1.0
    set dens(N-cm-kg,N-mm-kg) 1.0e-3
    set dens(N-cm-kg,Kp-cm-utm) [expr 1.0/9.8] 
	    
    set dens(N-mm-kg,N-m-kg) 1.0e9
    set dens(N-mm-kg,N-cm-kg) 1.0e3
    set dens(N-mm-kg,N-mm-kg) 1.0
    set dens(N-mm-kg,Kp-cm-utm) [expr 1.0e3/9.8] 
    
    set dens(Kp-cm-utm,N-m-kg) [expr 1.0e6*9.8]
    set dens(Kp-cm-utm,N-cm-kg) [expr 1.0*9.8]
    set dens(Kp-cm-utm,N-mm-kg) [expr 1.0e-3*9.8]
    set dens(Kp-cm-utm,Kp-cm-utm) 1.0

    set length(N-m-kg,N-m-kg) 1.0
    set length(N-m-kg,N-cm-kg) 100.0
    set length(N-m-kg,N-mm-kg) 1000.0
    set length(N-m-kg,Kp-cm-kg) 100.0
    
    set length(N-cm-kg,N-m-kg) 1.0e-2
    set length(N-cm-kg,N-cm-kg) 1.0
    set length(N-cm-kg,N-mm-kg) 10.0
    set length(N-cm-kg,Kp-cm-utm) 1.0
    
    set length(N-mm-kg,N-m-kg) 1.0e-3
    set length(N-mm-kg,N-cm-kg) 0.1
    set length(N-mm-kg,N-mm-kg) 1.0
    set length(N-mm-kg,Kp-cm-utm) 0.1
    
     set length(Kp-cm-utm,N-m-kg) 1.0e-2
     set length(Kp-cm-utm,N-cm-kg) 1.0
     set length(Kp-cm-utm,m-kg) 10.0
     set length(Kp-cm-utm,Kp-cm-utm) 1.0
    
}
##############################################################
#Comunitaction with GiD                             #
##############################################################
proc Composite::ComunicateWithGiD { op args } {
    variable units
    variable matlist
    variable lamlist
    variable mathick
    variable totalThick
  
    switch $op {
	"INIT" {
	    catch { array unset mathick }
	    calculateconvmatrix
	    set PARENT [lindex $args 0]
	    upvar [lindex $args 1] ROW
	    set GDN [lindex $args 2]
	    set STRUCT [lindex $args 3]
	    set f [frame $PARENT.f]
	    InitWindow $f 
	    grid $f -row $ROW -column 0 -sticky nsew -columnspan 2 -pady 3 -padx 2
	    grid columnconf $f 0 -weight 1
	    grid rowconf $f 0 -weight 1
	    grid rowconf $PARENT $ROW -weight 1
	    grid columnconf $PARENT 0 -weight 1
	    upvar \#0 $GDN GidData
	    getvalues $GidData($STRUCT,VALUE,3) $GidData($STRUCT,VALUE,5) $GidData($STRUCT,VALUE,6) $GidData($STRUCT,VALUE,7) $GidData($STRUCT,VALUE,8)
	     
	    return ""
	 }
	 "SYNC" {
	    set GDN [lindex $args 0]
	    set STRUCT [lindex $args 1]
	    set values [ Composite::dump ]
	    set names [ Composite::infonames ]
	    DWLocalSetValue $GDN $STRUCT  "laminate_properties" $values
	    DWLocalSetValue $GDN $STRUCT  "win_info" $names
	    DWLocalSetValue $GDN $STRUCT  "numero_de_capas" [lindex $values 0]
	    DWLocalSetValue $GDN $STRUCT  "Units" $units
	    DWLocalSetValue $GDN $STRUCT  "Thickness" $totalThick
	    
	    if { $matlist != "" } {
		set aux [base64::encode -maxlen 100000 $matlist]
		set aux [join [split $aux ] " " ]
		DWLocalSetValue $GDN $STRUCT  "matlist" $aux
	    } else {
		 DWLocalSetValue $GDN $STRUCT  "matlist" 0
	    }
	    if  { $lamlist != "" } {
		set aux [base64::encode -maxlen 100000 $lamlist]
		set aux [join [split $aux ] " " ]
		DWLocalSetValue $GDN $STRUCT  "lamlist" $aux
	    } else {
		 DWLocalSetValue $GDN $STRUCT  "lamlist" 0
	    }
	    if { [array exists mathick] } {
		set mats [lsort -ascii [array names mathick]]
		set aux ""
		foreach mat $mats {
		    lappend aux $mat $mathick($mat)
		}
		set aux [base64::encode -maxlen 100000 $aux]
		set aux [join [split $aux ] " " ] 
		DWLocalSetValue $GDN $STRUCT  "mathick" $aux
	    } else {
		DWLocalSetValue $GDN $STRUCT  "mathick" 0
	    }
	    return ""
	}
    }
}

proc Composite::create_window { wp dict dict_units } {
    variable units
    variable matlist
    variable lamlist
    variable mathick
    variable totalThick

    package require dialogwin
    destroy $wp.steelsections
    set w [dialogwin_snit $wp.steelsections -title [_ "Composite laminate"]]
    set f [$w giveframe]
    
    catch { array unset mathick }
    calculateconvmatrix

    InitWindow $f

    grid columnconfigure $f 0 -weight 1
    grid rowconfigure $f 0 -weight 1

    if { [dict get $dict matlist] eq "" } {
	dict set dict matlist e0hTLUNhcmJfRXBveHkgMC4wMDAyNSAxLjQxZSswMTEgMS4yODExOGUrMDEwIDAuMzg1IDJlKzAxMCAyZSswMTAgMmUrMDEwIDE1MzM5LjEzIHVuZGVmIHVuZGVmIHVuZGVmIHVuZGVmIHVuZGVmfSB7RS1HbGFzc19FcG94eSAwLjAwMDMxNDEgMS44MWUrMDEwIDEuODE0MzFlKzAxMCAwLjM0NyAyLjk3MDNlKzAwOCA1LjkyNzg2ZSswMDggMi45NzAzZSswMDggMTc4OTcuMTg0IHVuZGVmIHVuZGVmIHVuZGVmIHVuZGVmIHVuZGVmfSB7TS1DYXJiX1BvbHkgMC4wMDAzMzY1NCA4LjIyZSswMTAgOC4yMTgzNWUrMDEwIDAuMzI4IDQuNTk2ODJlKzAwOCA4LjMwNTczZSswMDggNC41OTY4MmUrMDA4IDE1NDYyLjk3NiB1bmRlZiB1bmRlZiB1bmRlZiB1bmRlZiB1bmRlZn0ge0FyYW1pZF9Qb2x5IDAuMDAwMzMzMzMgMS45M2UrMDEwIDEuOTI2ODdlKzAxMCAwLjMzMCAzLjMyNDY0ZSswMDggNi40MjQ5NGUrMDA4IDMuMzI0NjRlKzAwOCAxMzExNi45MjMgdW5kZWYgdW5kZWYgdW5kZWYgdW5kZWYgdW5kZWZ9
	dict set dict mathick QXJhbWlkX1BvbHkgezAuMDAwMzMzMzMgMS4zZTExIDNlOSAxNDUwIDEyMDAgMC4zNTAgMC4zMTYgNS4xZTEwIDJlOCA2MCAwIDAuNiBSb3Zpbmd9IEUtR2xhc3NfRXBveHkgezAuMDAwMzE0MSA3LjNlMTAgMi42ZTkgMjU0MCAxMjAwIDAuMjUwIDAuNCAzZTkgMmU4IDY1IDAgMC43MCBNYXR9IEhTLUNhcmJfRXBveHkgezAuMDAwMjUwMDAwMDAwMDAwMDAwMDEgMi4zZTExIDIuNmU5IDE4MDAgMTIwMCAwLjM1MCAwLjQgMmUxMCAyZTEwIDcwLjAgMCAwLjcwIFVuaX0gTS1DYXJiX1BvbHkgezAuMDAwMzM2NTQgMy43ZTExIDNlOSAxOTAwIDEyMDAgMC4zNTAgMC4zMTYgNGUxMCAzZTggNjUgMCAwLjc1IE1hdH0=
    }

    set cmd [list getvalues]
    foreach i [list win_info Units matlist lamlist mathick] {
	lappend cmd [dict get $dict $i]
    }
    eval $cmd

    bind $w <Return> [list $w invokeok]
    set action [$w createwindow]
    while 1 {
	if { $action <= 0 } { 
	    destroy $w
	    return ""
	}
	set dict ""
	set values [dump]
	dict set dict "laminate_properties" $values
	dict set dict "win_info" [infonames]
	dict set dict "Layer_number" [lindex $values 0]
	dict set dict "Units" $units
	dict set dict "thickness" $totalThick
#         dict set dict "thickness" [lindex $values 43]

	if { $matlist != "" } {
	    set aux [base64::encode -maxlen 100000 $matlist]
	    set aux [join [split $aux ] " " ]
	    dict set dict "matlist" $aux
	} else {
	    dict set dict "matlist" 0
	}
	if  { $lamlist != "" } {
	    set aux [base64::encode -maxlen 100000 $lamlist]
	    set aux [join [split $aux ] " " ]
	    dict set dict "lamlist" $aux
	} else {
	    dict set dict "lamlist" 0
	}
	if { [array exists mathick] } {
	    set mats [lsort -ascii [array names mathick]]
	    set aux ""
	    foreach mat $mats {
		lappend aux $mat $mathick($mat)
	    }
	    set aux [base64::encode -maxlen 100000 $aux]
	    set aux [join [split $aux ] " " ] 
	    dict set dict "mathick" $aux
	} else {
	    dict set dict "mathick" 0
	}
	destroy $w
	return [list $dict $dict_units]
	#set action [$w waitforwindow]
    }
}

proc Composite::InitWindow { top }  {
    variable cbdatamat
    variable badd
    variable bnew
    variable bfr
    variable bedit
    variable bmodify
    variable bcancel
    variable lamadd
    variable lammodify
    variable lamcancel
    variable can
    variable matlist
    variable table
    variable lamtable 
    variable lamclear
    variable lamtype
    variable totalThick 0.0
    

    ##############################################################
    #creating the notebook to organize the information           #
    ##############################################################
    set nb [NoteBook $top.notebook]
    set page2 [$nb insert end page2 -text [= "Materials"]]
    set page1 [$nb insert end page1 -text [= "Laminate"]]
    $nb raise page2
    grid $nb -column 0 -row 0 -sticky nsew
    grid columnconf $page1 0 -weight 1
    grid rowconf $page1 0 -weight 1
    grid columnconf $page2 0 -weight 1
    grid rowconf $page2 0 -weight 1
 
    ##############################################################
    #creating the page for materials information "Materials"     #
    ##############################################################
   
    set table ""
    set pw [PanedWindow $page2.pw -side left ]
    set pane1 [$pw add -weight 0]


    set title1 [TitleFrame $pane1.data -relief groove -bd 2 -ipad 6 \
	    -text [= "Layers Data Entry"] -side left]
    set f1 [$title1 getframe]
    set bgcolor [$f1 cget -background]

    # changed the DisabledBackground to be an option so as to work with tk8.3
    option add *Entry*DisabledBackground $bgcolor
    set lunitsmat [label $f1.lunitsmat -text [= Units] -justify left]
    set cbunitsmat [ComboBox $f1.cbunitsmat -textvariable Composite::units -editable no \
	    -justify left -values [list N-m-kg N-cm-kg N-mm-kg Kp-cm-utm] -width 5]
    set command "Composite::unitsproc ;#"
    trace variable Composite::units w $command
    bind $cbunitsmat <Destroy> [list trace vdelete Composite::units w $command]
    set ldatatitle [label $f1.ldatatitle -text [= "Name"] -justify left ]
    set edatatitle [entry $f1.edatatitle -textvariable Composite::title -width 8 \
	    -justify left  -bd 2 -relief sunken -bg white ] 
    bind $top <<fiber-resin>> "+ $edatatitle configure -state disabled "
    bind $top <<normal>> "+ $edatatitle configure -state normal "
    set lthick [label $f1.ldatat -text [= "Thickness"] -justify left ]
    set ethick [entry $f1.edatat -textvariable Composite::t_mat -width 4 \
	    -justify left -bd 2 -relief sunken -validate focusout \
	    -vcmd {string is double %P} -invcmd { WarnWin [= "Entry is not a number"]} \
	    -bg white ]
    bind $top <<fiber-resin>> "+ $ethick configure -state disabled "
    bind $top <<normal>> "+ $ethick configure -state normal "
    set lunitthick [label $f1.lunitthick -textvariable Composite::unit1 -width 7]
    set ldatae1 [label $f1.ldatae1 -text [= E1] -justify left]
    set edatae1 [entry $f1.edatae1 -textvariable Composite::e1 -width 12 \
	    -justify left -bd 2 -relief sunken]
    bind $top <<fiber-resin>> "+ $edatae1 configure -state disabled "
    bind $top <<normal>> "+ $edatae1 configure -state normal "
    set lunite1 [label $f1.lunite1 -textvariable Composite::unit2 -width 7]
    set ldatae2 [label $f1.ldatae2 -text [= E2] -justify left]
    set edatae2 [entry $f1.edatae2 -textvariable Composite::e2 -width 12 \
	    -justify left -bd 2 -relief sunken]
    bind $top <<fiber-resin>> "+ $edatae2 configure -state disabled "
    bind $top <<normal>> "+ $edatae2 configure -state normal "
    set lunite2 [label $f1.lunite2 -textvariable Composite::unit2 -width 7]
    set ldatanu12 [label $f1.ldatanu12 -text [= "\u03BD12"] -justify left ]
    set edatanu12 [entry $f1.edatanu12 -textvariable Composite::nu12 -width 12 \
	    -justify left -width 8 -bd 2 -relief sunken]
    bind $top <<fiber-resin>> "+ $edatanu12 configure -state disabled "
    bind $top <<normal>> "+ $edatanu12 configure -state normal "
    set ldatag12 [label $f1.ldatag12 -text [= G12] -justify left ]
    set edatag12 [entry $f1.edatag12 -textvariable Composite::g12 -width 12 \
	    -justify left -bd 2 -relief sunken]
    bind $top <<fiber-resin>> "+ $edatag12 configure -state disabled "
    bind $top <<normal>> "+ $edatag12 configure -state normal "
    set lunitg12 [label $f1.lunitg12 -textvariable Composite::unit2 -justify left]
    set ldatag13 [label $f1.ldatag13 -text [= G13] -justify left -width 7]
    set edatag13 [entry $f1.edatag13 -textvariable Composite::g13 -width 12 \
	    -justify left -bd 2 -relief sunken]
    bind $top <<fiber-resin>> "+ $edatag13 configure -state disabled "
    bind $top <<normal>> "+ $edatag13 configure -state normal "
    set lunitg13 [label $f1.lunitg13 -textvariable Composite::unit2 -justify left -width 7]
    set ldatag23 [label $f1.ldatag23 -text [= G23] -justify left ]
    set edatag23 [entry $f1.edatag23 -textvariable Composite::g23 -width 12 \
	    -justify left -bd 2 -relief sunken]
    bind $top <<fiber-resin>> "+ $edatag23 configure -state disabled "
    bind $top <<normal>> "+ $edatag23 configure -state normal "
    set lunitg23 [label $f1.lunitg23 -textvariable Composite::unit2 -justify left -width 7 ]
    set ldataspweight [label $f1.ldataspweight -text [= "Specific Weight"] -justify left ]
    set edataspweight [entry $f1.edataspweight -textvariable Composite::spweight -width 12 \
	    -justify left -bd 2 -relief sunken]
    bind $top <<fiber-resin>> "+ $edataspweight configure -state disabled "
    bind $top <<normal>> "+ $edataspweight configure -state normal "
    set lunitspweight [label $f1.lunitspweight  -textvariable Composite::spweightunit -justify left -width 7 ]

    set lType [label $f1.ldatatype -text [= "Lam. Type"] -justify left ]
    set eType [ComboBox $f1.edatatype -textvariable Composite::lamtype -width 8 \
	    -editable no -values [list Uni Mat Roving] -validate focusout -relief sunken]
    bind $top <<fiber-resin>> "+ $eType configure -state disabled "
    bind $top <<normal>> "+ $eType configure -state normal "

    set title11 [TitleFrame  $pane1.failure -relief groove -bd 2 -ipad 6 \
	    -text [= "Failure Theory (Tsai-Wu)"] -side left]
    set f11 [$title11 getframe]
    set checkmat [checkbutton $f11.checkmat -variable Composite::considermat \
	    -takefocus 0 -text [= "Calculate Security\nFactor (PostProcess)"]]
    set lstress [label $f11.lstress -text [= "Allowable Stresses"] -justify left]
    set lsc1 [Label $f11.lsc1 -text [= Sc1] -justify left -helptext [= "Allowable compression stress in direction 1" ]]
    set esc1 [entry $f11.esc1 -textvariable Composite::sc1  -width 7\
	    -justify left -bd 2 -relief sunken]
#     bind $esc1 <FocusOut> Composite::updatestress

    bind $top <<fiber-resin>> "+ $esc1 configure -state disabled "
    bind $top <<normal>> "+ $esc1 configure -state normal "

    set lunitsc1 [label $f11.lunitsc1 -textvariable Composite::unit2 -justify left -width 7 ]

    set lsc2 [Label $f11.lsc2 -text [= Sc2] -justify left -helptext [= "Allowable compression stress in direction 2"]]
    set esc2 [entry $f11.esc2 -textvariable Composite::sc2 -width 7\
	    -justify left -bd 2 -relief sunken]
    set lunitsc2 [label $f11.lunitsc2 -textvariable Composite::unit2 -justify left -width 7 ]

    bind $top <<fiber-resin>> "+ $esc2 configure -state disabled "
    bind $top <<normal>> "+ $esc2 configure -state normal "
  
    set lst1 [Label $f11.lst1 -text [= St1] -justify left -helptext [= "Allowable traction stress in direction 1"]]
    set est1 [entry $f11.est1 -textvariable Composite::st1 -width 7\
	    -justify left -bd 2 -relief sunken]
    set lunitst1 [label $f11.lunitst1 -textvariable Composite::unit2 -justify left -width 7]

    bind $top <<fiber-resin>> "+ $est1 configure -state disabled "
    bind $top <<normal>> "+ $est1 configure -state normal "

    set lst2 [Label $f11.lst2 -text [= St2] -justify left -helptext [= "Allowable traccion stress in direction 2"]]
    set est2 [entry $f11.est2 -textvariable Composite::st2 -width 7\
	    -justify left -bd 2 -relief sunken]
    set lunitst2 [label $f11.lunitst2 -textvariable Composite::unit2 -justify left -width 7 ]

    bind $top <<fiber-resin>> "+ $est2 configure -state disabled "
    bind $top <<normal>> "+ $est2 configure -state normal "

    set lcort [Label $f11.lcort -text [= T] -justify left -helptext [= "Allowable shear stress"]]
    set ecort [entry $f11.ecort -textvariable Composite::cort -width 7\
	    -justify left -bd 2 -relief sunken]
    set lunitcort [label $f11.lunitcort -textvariable Composite::unit2 -justify left -width 7] 

    bind $top <<fiber-resin>> "+ $ecort configure -state disabled "
    bind $top <<normal>> "+ $ecort configure -state normal "

    set bgcolor [$f1 cget -background] 
    Composite::failureupdate $esc1 $esc2 $est1 $est2 $ecort $bgcolor
    set command "Composite::failureupdate $esc1 $esc2 $est1 $est2 $ecort $bgcolor ;#"
    trace variable Composite::considermat w $command
    bind $f11.checkmat <Destroy> [list trace vdelete Composite::considermat w $command]
    
    grid $pw  -sticky nsew 
    grid rowconf $pw 1 -weight 1
    grid columnconf $pw 0 -weight 1
    grid columnconf $pane1 0 -weight 1
    grid rowconf $pane1 0 -weight 1
    
    grid $title1 -column 0 -row 0 -padx 2 -pady 2 -sticky nsew
#     grid rowconf $f1 4 -weight 1
    grid $ldatatitle -column 0 -row 0
    grid $edatatitle -column 1 -row 0 -columnspan 3 -sticky nswe
    grid $lthick -column 4 -row 0 
    grid $ethick -column 5 -row 0  -sticky nsew
    grid $lunitthick -column 6 -row 0 
    grid $lunitsmat -column 6 -row 0 
    grid $cbunitsmat -column 7 -row 0 -sticky nsew
    grid $ldatae1 -column 0 -row 1
    grid $edatae1 -column 1 -row 1 -sticky nswe
    grid $lunite1 -column 2 -row 1
    grid $ldatae2 -column 3 -row 1
    grid $edatae2 -column 4 -row 1 -sticky nswe
    grid $lunite2 -column 5 -row 1
    grid $ldatanu12 -column 6 -row 1 
    grid $edatanu12 -column 7 -row 1 -sticky nswe
    grid $ldatag12 -column 0 -row 2
    grid $edatag12 -column 1 -row 2 -sticky nswe
    grid $lunitg12 -column 2 -row 2
    grid $ldatag13 -column 3 -row 2
    grid $edatag13 -column 4 -row 2 -sticky nswe
    grid $lunitg13 -column 5 -row 2
    grid $ldatag23 -column 6 -row 2
    grid $edatag23 -column 7 -row 2 -sticky nswe
    grid $lunitg23 -column 8 -row 2 -sticky nw
    grid $ldataspweight -column 0 -row 3
    grid $edataspweight -column 1 -row 3 -sticky nswe
    grid $lunitspweight -column 2 -row 3 -sticky nw
    grid $lType -column 3 -row 3
    grid $eType -column 4 -row 3 -sticky nswe
    
    grid $title11 -column 0 -row 1  -padx 2 -pady 2 -sticky nsew
    grid rowconf $f11 8 -weight 1
    grid $checkmat -column 0 -row 0 -sticky sw
    grid $lsc1 -column 1 -row 0 -sticky se
    grid $esc1 -column 2 -row 0 -sticky sew
    grid $lunitsc1 -column 3 -row 0 -sticky swe
    grid $lsc2 -column 4 -row 0 -sticky swe
    grid $esc2 -column 5 -row 0 -sticky sew
    grid $lunitsc2 -column  6 -row 0 -sticky swe
    grid $lcort -column 7 -row 0 -sticky swe
    grid $ecort -column 8 -row 0 -sticky sew
    grid $lunitcort -column 9 -row 0 -sticky swe
    grid $lst1 -column 1 -row 1 -sticky en
    grid $est1 -column 2 -row 1 -sticky new
    grid $lunitst1 -column 3 -row 1 -sticky nwe
    grid $lst2 -column 4 -row 1 -sticky nwe
    grid $est2 -column 5 -row 1 -sticky new
    grid $lunitst2 -column 6 -row 1 -sticky new

    
    set pane2 [$pw add -weight 1]
    set title2 [TitleFrame $pane2.table -relief groove -bd 2 -text [= "Materials List"] \
	    -side left ]
    set f2 [$title2 getframe]
    set sw [ScrolledWindow $f2.scroll -scrollbar both ]
    set table [tablelist::tablelist $sw.table \
	    -columns [list 0 [= "Name"] 0 [= "Thick"] 0 [= "E1"] 0 [= "E2"] \
		0 "\u03BD12" 0 [= "G12"] 0 [= "G23"] 0 [= "G13"] 0 [= "SpecifWeight"] \
		0 [= "Sc1"] 0 [= "Sc2"] 0 [= "St1"] 0 "St2" 0 "T" 0 [= "Type"]] \
	    -height 3 -width 50 -stretch all -background white \
	    -listvariable Composite::matlist]
    $sw setwidget $table
    bind [$table bodypath] <Double-ButtonPress-1> [list Composite::edit \
	    $table $top]
    set bbox [ButtonBox $f2.bbox1 -spacing 0 -padx 1 -pady 1 -homogeneous 0 ]
    $bbox add -image $Composite::edit -width 24 \
	    -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	    -helptext [= "Edit material"] -command [list Composite::edit $table $top]
    $bbox add -image $Composite::delete -width 24 \
	    -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	    -helptext [= "Delete material"] -command "Composite::delete $table $edatatitle"
    set buttonfr [frame $pane1.bfr]
    set badd [button $buttonfr.badd -text [= Add]  -width 10 -underline 0 \
	    -command "Composite::add $table $edatae1 $edatatitle $top" ]
    bind $badd <ButtonRelease> {
	if { $Composite::considermat == 1 } { 
	    set Composite::values [list "$Composite::e1" "$Composite::e2" "$Composite::g13" "$Composite::g12" "$Composite::g23" \
		    "$Composite::nu12"  "$Composite::sc1" "$Composite::sc2" "$Composite::st1" "$Composite::st2" \
		    "$Composite::cort" "$Composite::spweight"]
	    set Composite::names [list E1 E2 G13 G12 G23 nu12 Sc1 Sc2 St1 St2 T SpecifWeight]
	} else {
	    set Composite::values [list "$Composite::e1" "$Composite::e2" "$Composite::g13" "$Composite::g12" "$Composite::g23" \
		"$Composite::nu12"]
	    set Composite::names [list E1 E2 G13 G12 G23 nu12]
	}
	Composite::errorcntrl $Composite::values $Composite::names $Composite::can
    }
    set bnew [button $buttonfr.bnew -text New  -width 10 -underline 0 \
	    -command "Composite::add $table $edatae1 $edatatitle $top" ]
    bind $bnew <ButtonRelease> {
	 if { $Composite::considermat == 1 } { 
	    set Composite::values [list "$Composite::e1" "$Composite::e2" "$Composite::g13" "$Composite::g12" "$Composite::g23" \
		    "$Composite::nu12"  "$Composite::sc1" "$Composite::sc2" "$Composite::st1" \
		    "$Composite::st2" "$Composite::cort" "$Composite::spweight"]
	    set Composite::names [list E1 E2 G13 G12 G23 nu12 Sc1 Sc2 St1 St2 T SpecifWeight]
	} else {
	    set Composite::values [list "$Composite::e1" "$Composite::e2" "$Composite::g13" "$Composite::g12" "$Composite::g23" \
		"$Composite::nu12" "$Composite::spweight"]
	    set Composite::names [list E1 E2 G13 G12 G23 nu12 SpecifWeight]
	}
	Composite::errorcntrl $Composite::values $Composite::names $Composite::can
	set Composite::index -1
    } 
    set bmodify [button $buttonfr.modify -text [= Modify]  -width 10 -underline 0 \
	    -command "Composite::add $table $edatae1 $edatatitle $top" ]
     bind $bmodify <ButtonRelease> {
	 if { $Composite::considermat == 1 } { 
	    set Composite::values [list "$Composite::e1" "$Composite::e2" "$Composite::g13" "$Composite::g12" "$Composite::g23" \
		    "$Composite::nu12"  "$Composite::sc1" "$Composite::sc2" "$Composite::st1" \
		    "$Composite::st2" "$Composite::cort" "$Composite::spweight"]
	    set Composite::names [list E1 E2 G13 G12 G23 nu12 Sc1 Sc2 St1 St2 T SpecifWeight]
	} else {
	    set Composite::values [list "$Composite::e1" "$Composite::e2" "$Composite::g13" "$Composite::g12" "$Composite::g23" \
		"$Composite::nu12" "$Composite::spweight"]
	    set Composite::names [list E1 E2 G13 G12 G23 nu12 SpecifWeight]
	}
	Composite::errorcntrl $Composite::values $Composite::names $Composite::can
    } 
    set bcancel [button $buttonfr.cancel -text [= Cancel]  -width 10 -underline 0 \
	    -command "Composite::cancel $table $edatae1 $top"]
    set bfr [button $f1.bfr -text [= Fiber-Resin] -width 10 -underline 0 \
	    -command "Composite::fiber-resin $top" ]

    set bedit [button $f1.bedit -text [= Edit-Data] -width 10 -underline 0 \
	    -command [list Composite::Edit-Data $table $top] ]

    #bind $top <<disable-edit>> "+ $bedit configure -state disable"
    #bind $top <<show-edit>> "+ $bedit configure -state normal "

    grid $bfr -column 4 -row 4 -columnspan 3 -pady 3 -sticky nw

    grid $bedit -column 6 -row 4 -columnspan 3 -pady 3 -sticky nw
    grid remove $bedit

    grid $buttonfr -column 0 -row 2  -pady 6 -sticky nsew
    grid $badd -column 0 -row 0 -pady 3 -padx 3 -sticky nw
    grid $bnew -column 0 -row 0 -pady 3 -padx 3 -sticky nw
    grid $bmodify -column 1 -row 0 -pady 3 -padx 3 -sticky nw
    grid $bcancel -column 2 -row 0 -pady 3 -padx 3 -sticky nw
    grid remove $bnew
    grid remove $bmodify
    grid remove $bcancel
    bind $top <Alt-KeyPress-a> "+ tkButtonInvoke $badd"                
    bind $top <Alt-KeyPress-n> "+ tkButtonInvoke $bnew"
    bind $top <Alt-KeyPress-m> "+ tkButtonInvoke $bmodify"
    bind $top <Alt-KeyPress-c> "+ tkButtonInvoke $bcancel"
    bind $top <Alt-KeyPress-f> "+ tkButtonInvoke $bfr"
    grid columnconf $pane2  0 -weight 1
    grid rowconf $pane2 0 -weight 1
    grid columnconf $pane1  0 -weight 1
    
    grid $title2 -column 0 -row 0 -padx 2 -pady 2 -sticky nsew 
    grid columnconf $f2  0 -weight 1
    grid rowconf $f2 0 -weight 1


    grid $sw -column 0 -row 0 -sticky nsew
    grid $bbox -column 0 -row 1 -sticky nw
    #$nb compute_size
    ##############################################################
    #creating the page for laminate information "Laminate"       #
    ##############################################################
    
    set pw [PanedWindow $page1.pw -side top ]
    set pane1 [$pw add -weight 1]

    set title1 [TitleFrame $pane1.data -relief groove -bd 2 \
	    -text [= "Data Entry"] -side left]
    set f1 [$title1 getframe]
#     set lunitslam [label $f1.lunitslam -text [= Units] -justify left]
#     set cbunitslam [ComboBox $f1.cbunitslam -textvariable Composite::units -editable no \
#             -justify left -values [list N-m-kg N-cm-kg N-mm-kg Kp-cm-utm]]
#     set command "Composite::unitsproc ;#"
#     trace variable Composite::units w $command
#     bind $cbunitslam <Destroy> [list trace vdelete Composite::units w $command]
    
    set edataang [entry $f1.edataang -textvariable Composite::ang -width 4 \
	    -justify left -bd 2 -relief sunken -state normal -bg white]
    set unitang [label $f1.unitang -text degrees -justify left]
    set bgcolor [$f1 cget -background]
    
    set useangle 0
    set check [checkbutton $f1.chdata -variable Composite::useangle \
	    -takefocus 0 -text [= "Fiber Angle"] -activebackground white]
#     Composite::update $edataang $bgcolor
    
    set ldatamat [label $f1.ldatamat -text [= "Material"] -justify left ]
    set cbdatamat [ComboBox $f1.cbdatamat -textvariable Composite::matname  \
	    -values "" -editable no] 
    $cbdatamat configure -text "" 
    
    set ldataspin [label $f1.ldataspin -text [= "Number of layers"] -justify left]
    set edatat [entry $f1.edatat -textvariable Composite::t -width 4 \
	    -justify left -bd 2 -relief sunken -state disabled]
    set lunithick [label $f1.lunithick -textvariable Composite::unit1 -justify left -width 5 ]
   

########################################
## secuencias de laminados #############
    
    set lamseq [label $f1.lamseq -text [= "Sequence"] -justify left ]
    set cbseq [ComboBox $f1.cbseq -textvariable Composite::seq -editable no \
	    -values [list [= "User"] \[45,-45\]s \[45,-45\] \[0,45,-45\] \[0,90\]] \
	    -helptext [= "Fixed laminate sequence"] ]
    $cbseq configure -text "" 
    
    set spin [SpinBox $f1.spdata -textvariable Composite::numlayers \
	    -range "1 1000 1" -width 2 -takefocus 1 ]
    $spin configure -text 1  

    set flag 1    
    set command "Composite::seqlaminate [list $cbseq $bgcolor $ldataspin $check $edataang $spin];#"
    trace variable Composite::seq w $command
    bind $f1.cbseq <Destroy> [list trace vdelete Composite::seq w $command]
    
    set command "Composite::update [list $edataang $bgcolor $flag];#"
    trace variable Composite::useangle w $command
    bind $f1.chdata <Destroy> [list trace vdelete Composite::useangle w $command]
    
    set command "Composite::frmathick [list $edatat $lamseq $cbseq $ldataspin $cbseq $check $spin];#"
    trace variable Composite::matname w $command
    bind $f1.cbdatamat <Destroy> [list trace vdelete Composite::matname w $command]
   


#     set spin [SpinBox $f1.spdata -textvariable Composite::numlayers \
#             -range "1 1000 1" -width 2 -takefocus 1 -modifycmd "Composite::thickCalc $edatat"]
#     set ldatat [label $f1.ldatat -text [= "Thickness"] -justify left ]

    

    set ldatat [label $f1.ldatat -text [= "Thickness"] -justify left ]
    
    set modifycmd "Composite::thickCalc $edatat $spin;#"
    trace variable Composite::numlayers w $modifycmd
    bind $spin <Destroy> [list trace vdelete Composite::numlayers w $modifycmd]
    

#     if {$cbseq == [= "User"]} {
#         Composite::update $edataang $bgcolor $flag
#     } elseif {$cbseq != [= "User"]} {
#         Composite::update $edataang $bgcolor $flag
#         $ldataspin configure -text [= "Number of Sequences"]
#     }
################################################
    
    $check configure -state disabled -activebackground grey
    $edataang configure -state disabled

      

#   [lindex $mathick($matname) 0]

    grid $pw  -sticky nsew 
    grid columnconf $pw  1 -weight 1
    grid rowconf $pw 0 -weight 1
    grid columnconf $pane1  0 -weight 1
    grid rowconf $pane1 1 -weight 1
    grid $title1 -column 0 -row 0 -padx 2 -pady 2 -sticky nsew
    grid rowconf $f1 5 -weight 1
    grid columnconf $f1 3 -weight 1        
    
#     grid $lunitslam -column 0 -row 0 -sticky nw 
#     grid $cbunitslam -column 1 -row 0 -sticky nsew -columnspan 3 -pady 3
    grid $ldatamat -column 0 -row 1 -sticky nw
    grid $cbdatamat -column 1 -row 1 -columnspan 3 -sticky nsew
    
    grid $lamseq -column 0 -row 2 -sticky nw
    grid $cbseq -column 1 -row 2 -columnspan 3 -sticky nsew
    
    grid $ldataspin -column 0 -row 3 -sticky nw
    grid $spin -column 1 -row 3 -sticky nswe
    grid $ldatat -column 2 -row 3 -sticky nw
    grid $edatat -column 3 -row 3 -sticky nswe
    grid $lunithick -column 4 -row 3 -sticky nw
    grid $check -column 0 -row 4 -sticky nw
    grid $edataang -column 1 -row 4 -sticky nw
    grid $unitang -column 2 -row 4 -sticky nw
    
	
    set pane2 [$pw add -weight 1]
    set title2 [TitleFrame $pane2.table -relief groove -bd 2 -text [= "Laminate Composition"] \
	    -side left ]
    set f2 [$title2 getframe]
    set sw [ScrolledWindow $f2.scroll -scrollbar both ]
    set lamtable [tablelist::tablelist $sw.table \
	    -columns [list 0 [= "Material"] 0 [= "Angle"] 0 [= "Thick"] 0 [= "Layers"]] \
	    -height 10 -width 30 -stretch all -background white -labelbg lightyellow \
	    -listvariable Composite::lamlist -selectmode extended]
    $sw setwidget $lamtable
    set bbox [ButtonBox $f2.bbox1 -spacing 0 -padx 1 -pady 1 -homogeneous 0 ]
    $bbox add -image $Composite::edit -width 24 \
	    -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	    -helptext [= "Edit layer"] -command "Composite::lamedit $lamtable"
    $bbox add -image $Composite::delete -width 24 \
	    -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	    -helptext [= "Delete layer"] -command "Composite::lamdelete $lamtable $cbdatamat"
    
    set lamadd [button $f1.badd -text [= Add]  -underline 1 -width 10 \
	    -command "Composite::lamadd $lamtable $cbdatamat"]
     bind $lamadd <ButtonRelease> {
	if { $Composite::matname == "" } {
	    WarnWin [= "Select a material"]
	    catch { vwait $Composite::matname }
	}
	set Composite::values [list "$Composite::t"]
	set Composite::names Thickness
	Composite::errorcntrl $Composite::values $Composite::names $Composite::can
	if { $Composite::useangle == 1 } { 
	    set Composite::values [list "$Composite::ang"]
	    set Composite::names Angle
	    Composite::errorcntrl $Composite::values $Composite::names $Composite::can
	}
    }
    set lamclear [button $f1.bclear -text [= "Clear All"] -width 10 -underline 2 \
	    -command "Composite::lamclear $lamtable"]
    set lammodify [button $f1.bmodify -text [= Modify]  -width 10 -underline 1 \
	    -command "Composite::lamadd $lamtable $cbdatamat"]
    set lamcancel [button $f1.bcancel -text [= Cancel]  -width 10 -underline 2 \
	    -command "Composite::lamcancel $lamtable $cbdatamat"]
    
    grid $lamadd -column 0 -row 5 -padx 2 -pady 6
    grid $lamclear -column 2 -row 5 -columnspan 2 -pady 6 -sticky nw
    grid $lammodify -column 0 -row 5 -columnspan 2 -pady 6 -sticky nw
    grid $lamcancel -column 2 -row 5 -columnspan 2 -pady 6 -sticky nw
    
    grid remove $lammodify
    grid remove $lamcancel
    bind $top <Alt-KeyPress-d> "tkButtonInvoke $lamadd"                
    bind $top <Alt-KeyPress-o> "tkButtonInvoke $lammodify"
    bind $top <Alt-KeyPress-n> "tkButtonInvoke $lamcancel"
    bind $top <Alt-KeyPress-e> "tkButtonInvoke $lamclear"          
    
    bind [$lamtable bodypath] <Double-ButtonPress-1> { Composite::lamedit $Composite::lamtable }
    bind [$lamtable bodypath] <ButtonPress-3> "Composite::popupmenu $lamtable %X %Y" 
    grid columnconf $pane2  0 -weight 1
    grid rowconf $pane2 0 -weight 1
    grid columnconf $pane2  0 -weight 1
    
    grid $title2 -column 0 -row 0 -padx 2 -pady 2 -sticky nsew 
    grid columnconf $f2  0 -weight 1
    grid rowconf $f2 0 -weight 1


    grid $sw -column 0 -row 0 -sticky nsew
    grid $bbox -column 0 -row 1 -sticky nw
    ##############################################################
    #creating canvas                                             #
    ##############################################################
    set title3 [TitleFrame $pane1.canvas -relief groove -bd 2 -text [= "Visual Description"] \
	    -side left ]
    set f3 [$title3 getframe]
    set can [canvas $f3.can -relief flat -bd 1 -width 100 -height 50 -bg white \
	    -highlightbackground black]

    set lTotalThick [label $f3.lTotalThick -text [= "Total Lam. Thickness (m)"] -justify left ]
    set eTotalThick [entry $f3.eTotalThick -textvariable Composite::totalThick -width 12 \
	    -justify left -bd 2 -relief sunken -state normal -bg white -state disabled]
#     set unitTotalThick [label $f3.unitTotalThick -text "m" -justify left]
    
    grid $title3 -column 0 -row 1 -sticky nsew
    grid columnconf $f3 0 -weight 1
    grid rowconf $f3 0 -weight 1
    grid $can -column 0 -row 0 -sticky nsew
    grid $lTotalThick -column 0 -row 1 -sticky nsw
    grid $eTotalThick -column 0 -row 2 -sticky nsw
#     grid $unitTotalThick -column 1 -row 2 -sticky nsw

    bind $can <Configure> "Composite::refresh $can"

    $nb compute_size

} 

##############################################################
#              establecer secuencia de laminado              #
##############################################################               
proc Composite::seqlaminate { cbseq bgcolor ldataspin check edataang spin} {
    variable seq
    variable ang

    $spin configure -text "1"

    if {$seq == [= "User"] || $seq == ""} {
	$ldataspin configure -text [= "Number of layers"]
	$check configure -state normal -activebackground white
    } elseif {$seq != [= "User"] } {
	$ldataspin configure -text [= "Number of Sequences"]
	$check configure -state disabled -activebackground grey
	$edataang configure -state disabled
    }
}

proc Composite::thickCalc { edatat spin } {
    variable numlayers
    variable t
    variable seq
    variable matname
    variable mathick
    variable matlist
#     variable typel
    
    if { [info exists mathick($matname) ] } {
	set lamtype [lindex $mathick($matname) 12]
	set t1 [lindex $mathick($matname) 0]
	set n $numlayers
	
	if {($seq != [= "User"] && $lamtype == "Uni") \
	    || ($seq != [= "User"] && $lamtype == "Roving")} {
	    if {$seq == "\[45,-45\]s"} {
		set t [expr 4*$t1*$n]
	    } elseif {$seq == "\[45,-45\]"} {
		set t [expr 2*$t1*$n]
	    } elseif {$seq == "\[0,45,-45\]"} {
		set t [expr 3*$t1*$n]
	    } elseif {$seq == "\[0,90\]"} {
		set t [expr 2*$t1*$n]
	    }
	    set t [format %.5g $t]
	    $edatat configure -state disabled
	} elseif {($seq == [= "User"] && $lamtype == "Uni") \
	    || ($seq == [= "User"] && $lamtype == "Roving") || \
	    $lamtype == "Uni"} {
	    set t [expr $n*$t1]
	    set t [format %.5g $t]
	    $edatat configure -state disabled
	} else {
	    set t [expr $n*$t1]
	    set t [format %.5g $t]
	    $edatat configure -state disabled  
	}
    } else {
	foreach mat $matlist {
	    if { $matname == "[lindex $mat 0]" } {
		set lamtype [lindex $mat 14]
		set lam2 $lamtype
		set t1 [lindex $mat 1]
		set n $numlayers
		if {($seq != [= "User"] && $lam2 == "Uni") \
		    || ($seq != [= "User"] && $lam2 == "Roving")} {
		    if {$seq == "\[45,-45\]s"} {
		        set t [expr 4*$t1*$n]
		    } elseif {$seq == "\[45,-45\]"} {
		        set t [expr 2*$t1*$n]
		    } elseif {$seq == "\[0,45,-45\]"} {
		        set t [expr 3*$t1*$n]
		    } elseif {$seq == "\[0,90\]"} {
		        set t [expr 2*$t1*$n]
		    }
		    set t [format %.5g $t]
		    $edatat configure -state disabled
		} elseif {($seq == [= "User"] && $lam2 == "Uni") \
		    || ($seq == [= "User"] && $lam2 == "Roving") || \
		    $lam2 == "Uni"} {
		    set t [expr $n*$t1]
		    set t [format %.5g $t]
		    $edatat configure -state disabled
		    #         return 
		} else {
		    set t [expr $n*$t1]
		    set t [format %.5g $t]
		    $edatat configure -state disabled
		}
		break
	    }
	}
    }
    #     $edatat configure -state normal  
}



##############################################################
#              update Failure theory frame                   #
##############################################################
proc Composite::failureupdate { entry1 entry2 entry3 entry4 entry5 bgcolor } {
  variable considermat
  variable sc1
  variable sc2
  variable st1
  variable st2
  variable cort
	     
#      set sc1 ""; set sc2 "" ; set st1 "" ; set st2 "" ; set cort ""                
     foreach entry [list $entry1 $entry2 $entry3 $entry4 $entry5] {   
	if { $considermat == 1 } {
	    $entry configure -bg white -state normal
	} else {
	    $entry configure -state disabled
	     set sc1 ""; set sc2 "" ; set st1 "" ; set st2 "" ; set cort ""      
	}
    }
}
##############################################################
#              update Failure theory entries                      #
##############################################################
proc Composite::updatestress { } {
  variable sc1
  variable sc2
  variable st1
  variable st2
  variable cort
    set sc2 $sc1
    set st1 $sc1
    set st2 $sc1
    set cort $sc1
}
##############################################################
#dump result into tablelist for materials                    #
##############################################################
proc Composite::add { table entry entrytitle parent} {
    variable t_mat
    variable t
    variable e1         
    variable e2         
    variable nu12         
    variable g12         
    variable g23         
    variable g13 
    variable spweight 
    variable ID         
    variable title 
    variable index                   
    variable currenttitle   
    variable matlist   
    variable cbdatamat
    variable sc1
    variable sc2
    variable st1
    variable st2
    variable cort   
    variable considermat 
    variable show_t
    variable aux1
    variable aux2
    variable typel
    variable lamtype
    variable flagF_R

#     set e1 [expr double($e1)]
#     set e2 [expr double($e2)]
#     set nu12 [expr double($nu12)]
#     set g12 [expr double($g12)]
#     set g13 [expr double($g13)]
#     set g23 [expr double($g23)] 
    
     if { $index == ""} {
	set index -1
    }
    set matnames ""
    set ipos1 0
    while { [lindex $matlist $ipos1] != "" } {
	set aux [lindex $matlist $ipos1]
	lappend matnames [lindex $aux 0]
	set ipos1 [ expr $ipos1+1 ]
    }

   foreach name $matnames {
	if { $title == $name }  {
	    if { $index == -1 } {
		WarnWin [= "Another Material with this name already exists.\nPlease select a different name"] $table 
		focus $entrytitle
		$entrytitle selection range 0 end 
		catch { grid remove $Composite::bmodify}
		return
	    }
	}
    }

#     ###################################################
#     # asignación del espesor según cómo se introduzca #
#     ###################################################
#     foreach mat $matlist {
#         if { $title == "[lindex $mat 0]" } {
#             set auxmat [lindex $mat 1]
#             #             set typelamaux [lindex $mat 14]
#             break
#         }
#     }
#     
#     ## cuando entra de primeras ##
#     if {$show_t == ""} {
#         set aux1 $t
#         set aux2 $t_mat
#         if { $typel != "" } {
#             set typelamaux $typel
#         } else {
#             set typelamaux ""
#         }
#         
#         if { $t_mat == "" && $t != "" } {
#             ##introducido desde fiber-resin
#             set t_mat 0.0
#             set show_t $t
#             set aux1 $t
#             set aux2 $t_mat
#         } elseif { $t_mat != "" && $t == "" } {
#             ##introducido "a mano"
#             set t 0.0
#             set show_t $t_mat
#             set aux1 $t
#             set aux2 $t_mat
#         } elseif { $t_mat != "" && $t != "" } {
#             ##si se modifica un material de los iniciales
#             
#             ## al ser modificado ##
#             if { $t_mat != $auxmat } {
#                 set show_t $t_mat
#                 set aux2 $t_mat
#             }
#             if { $t != $auxmat } {
#                 set show_t $t
#                 set aux1 $t
#                 ## si no se modifica el espesor ##
#             } else {
#                 set show_t $t
#             }
#         }
#     } else {
#         foreach mat $matlist {
#             if { $title == "[lindex $mat 0]" } {
#                 set typelamaux [lindex $mat 14]
#                 ## al ser modificado ##
#                 if { $t_mat != $aux2 } {
#                     set show_t $t_mat
#                     set aux2 $t_mat
#                 } elseif { $t != $aux1 } {
#                     set show_t $t
#                     set aux1 $t
#                 } elseif { $t != $auxmat } {
#                     set show_t $t
#                     set aux1 $t
#                 } elseif { $t_mat != $auxmat } {
#                     set show_t $t_mat
#                     set aux2 $t_mat
#                 }
#                 break
#             } else {
#                 set typelamaux $typel
#                 set show_t $t
#             }
#         }
#         
#     }
    
    ####################################################
    
    if { $index == -1 } {
	if {$flagF_R ==1} {
	    set lamtype $typel
	    if { $considermat == 1 } { 
		$table insert end "[list $title "$t" [format %.8g $e1] \
		        [format %.8g $e2] [format %4.3f $nu12] [format %.8g $g12] \
		        [format %.8g $g23] [format %.8g $g13] [format %.8g $spweight] [format %.8g $sc1] \
		        [format %.8g $sc2] [format %.8g $st1] [format %.8g $st2] [format %.8g $cort] "$typel"]"
	    } else {
		$table insert end "[list $title "$t" [format %8.3g $e1] \
		        [format %.8g $e2] [format %4.3f $nu12] [format %.8g $g12] \
		        [format %.8g $g23] [format %.8g $g13] [format %.8g $spweight] 0.0 \
		        0.0 0.0 0.0 0.0 "$typel"]"
	    }
	} else {
	    set typel $lamtype
	    if { $considermat == 1 } { 
		$table insert end "[list $title "$t_mat" [format %.8g $e1] \
		        [format %.8g $e2] [format %4.3f $nu12] [format %.8g $g12] \
		        [format %.8g $g23] [format %.8g $g13] [format %.8g $spweight] [format %.8g $sc1] \
		        [format %.8g $sc2] [format %.8g $st1] [format %.8g $st2] [format %.8g $cort] "$lamtype"]"
	    } else {
		$table insert end "[list $title "$t_mat" [format %8.3g $e1] \
		        [format %.8g $e2] [format %4.3f $nu12] [format %.8g $g12] \
		        [format %.8g $g23] [format %.8g $g13] [format %.8g $spweight] 0.0 \
		        0.0 0.0 0.0 0.0 "$lamtype"]"
	    }
	}

	$table see end
	incr ID
#         set title "mat $ID"
#         set currenttitle $title
	set title ""
	set t_mat ""
	set t ""
	set e1 ""        
	set e2 ""        
	set nu12 ""        
	set g12 ""        
	set g13 ""        
	set g23 ""
	set sc1 ""
	set sc2  ""
	set st1 ""
	set st2  ""
	set cort ""
	set spweight ""
	set flagF_R 0
	catch { grid $Composite::badd }
	catch { grid remove $Composite::bmodify }
	catch { grid remove $Composite::bcancel }     
	catch { grid remove $Composite::bnew }
    } else {
	foreach mat $matlist {
	    if {$title == "[lindex $mat 0]"} {
		set typel [lindex $mat 14]
		break
	    }
	}
	$table delete $index 
	if { $considermat == 1 } { 
	    $table insert $index "[list $title "$t_mat" [format %.8g $e1] \
		    [format %.8g $e2] [format %4.3f $nu12] [format %.8g $g12] \
		    [format %.8g $g23] [format %.8g $g13] [format %.8g $spweight] [format %.8g $sc1] \
		    [format %.8g $sc2] [format %.8g $st1] [format %.8g $st2] [format %.8g $cort] "$lamtype"]"
	} else {
	    $table insert $index "[list $title "$t_mat" [format %.8g $e1] \
		    [format %.8g $e2] [format %4.3f $nu12] [format %.8g $g12] \
		    [format %.8g $g23] [format %.8g $g13] [format %.8g $spweight] 0.0 \
		    0.0 0.0 0.0 0.0 "$lamtype"]"
	}
	$table see $index
#         set title $currenttitle
	set currenttitle $title
	set title ""
	set t ""
	set t_mat ""
	set e1 ""        
	set e2 ""        
	set nu12 ""        
	set g12 ""        
	set g13 ""        
	set g23 ""
	set sc1 ""
	set sc2  ""
	set st1 ""
	set st2  ""
	set cort ""
	set typel ""
	set index -1
	set spweight ""
	set flagF_R 0
	catch {  grid $Composite::badd }
	catch {  grid remove $Composite::bmodify }
	catch {  grid remove $Composite::bcancel }
	catch { grid remove $Composite::bnew } 
	
    }
    set matnames ""
    set ipos1 0
    while { [lindex $matlist $ipos1] != "" } {
	set aux [lindex $matlist $ipos1]
	lappend matnames [lindex $aux 0]
	set ipos1 [ expr $ipos1+1 ]
    }
    $cbdatamat configure -values $matnames
    focus $entry
    event generate $parent <<normal>>
    catch { grid remove $Composite::bedit }

}                
##############################################################
#     Edit row  intro tablelist of materials               #
##############################################################
proc Composite::edit { table parent } {
    variable t
    variable t_mat
    variable e1         
    variable e2         
    variable nu12         
    variable g12         
    variable g23         
    variable g13 
    variable spweight  
    variable sc1
    variable sc2
    variable st1
    variable st2
    variable cort  
    variable title        
    variable index
    variable currenttitle 
    variable considermat 
    variable ef         
    variable er        
    variable densityf         
    variable densityr         
    variable nuf         
    variable nur 
    variable gf
    variable gr  
    variable re100        
    variable titlel
    variable vac                 
    variable remass
    variable typel   
    variable mathick
    variable isfiberesin
    variable matlist
    
   variable lamtype
    
    set currenttitle "$title" 
    set index [$table curselection]
    if { $index != "" } {
	set entry ""
	foreach i [$table get $index] {
	    lappend entry [string trim $i]
	}
	set title [lindex $entry 0]
	set t_mat [lindex $entry 1]
	set t [lindex $entry 1]
	set e1 [lindex $entry 2]
	set e2 [lindex $entry 3]
	set nu12 [lindex $entry 4]
	set g12 [lindex $entry 5]
	set g13 [lindex $entry 7]
	set g23 [lindex $entry 6]
	set spweight [lindex $entry 8]
	set typel [lindex $entry 14]
	set lamtype $typel
	if { [lindex $entry 9] == "0.0" || [lindex $entry 9]=="undef" } { 
	    set sc1 "0.0"
	    set sc2 "0.0"
	    set st1 "0.0"
	    set st2 "0.0"
	    set cort "0.0"
	    set considermat 0
	} else {
	    set sc1 [lindex $entry 9]
	    set sc2 [lindex $entry 10]
	    set st1 [lindex $entry 11]
	    set st2 [lindex $entry 12]
	    set cort [lindex $entry 13]
	    set considermat 1
	}
	if { [info exists mathick($title) ] } {
	    set titlel "$title"
	    set ef [lindex $mathick($title) 1]
	    set er [lindex $mathick($title) 2]
	    set densityf [lindex $mathick($title) 3]
	    set densityr [lindex $mathick($title) 4]
	    set nuf [lindex $mathick($title) 5]
	    set nur [lindex $mathick($title) 6]
	    set gf [lindex $mathick($title) 7]
	    set gr [lindex $mathick($title) 8]
	    set re100 [lindex $mathick($title) 9]
	    set vac [lindex $mathick($title) 10]
	    set remass [lindex $mathick($title) 11]
	    set typel [lindex $mathick($title) 12]
	    event generate $parent <<fiber-resin>>
	    set isfiberesin 1
	} else {
	    event generate $parent <<normal>>
	    set isfiberesin 0
	}
	catch { grid $Composite::bmodify }
	catch { grid $Composite::bcancel }
	catch { grid $Composite::bnew }
	catch { grid remove $Composite::badd }
	
	if { $Composite::isfiberesin == 1 } {
	   grid $Composite::bedit
	} else {
	   catch { grid remove $Composite::bedit }
	}

    }
} 
##############################################################
#     Cancel edit process intro tablelist of materials       #
##############################################################
proc Composite::cancel { table entry parent } {
    variable t_mat
    variable t
    variable e1         
    variable e2         
    variable nu12         
    variable g12         
    variable g23         
    variable g13
    variable sc1
    variable sc2
    variable st1
    variable st2
    variable cort     
    variable title        
    variable index
    variable currenttitle
    variable spweight 
    $table see end
    set title $currenttitle
    set t_mat ""
    set t ""
    set e1 ""        
    set e2 ""        
    set nu12 ""        
    set g12 ""        
    set g13 ""        
    set g23 ""
    set sc1 ""
    set sc2  ""
    set st1 ""
    set st2  ""
    set cort ""
    set spweight ""
    set index -1
    catch { grid $Composite::badd }
    catch { grid remove $Composite::bmodify }
    catch { grid remove $Composite::bcancel }     
    catch { grid remove $Composite::bnew }
    focus $entry
    event generate $parent <<normal>>
}
##############################################################
#   Delete  a row  intro tablelist of materials              #
##############################################################
proc Composite::delete { table widget} {
    variable can
    variable cbdatamat
    variable matlist
    variable lamlist
    variable ID
    variable title
    variable currenttitle

    set entry [$table curselection]
    set currentmat [lindex [$table get $entry] 0]
    foreach lam $lamlist {
	if { $currentmat == [lindex $lam 0] } {
	    set tt [= "This material (%s) is used in laminate sequence\n" \
		    $currentmat]
	    append tt [= "Are you sure you want to delete it?"]
	    set retval [tk_dialogRAMFull .gid.tempwinw [= {Dialog window}] \
		    $tt "" "" gidquestionhead 0 OK Cancel]
	if { $retval == 1 } { return }
	set putyes yes 
	}
    }
    if { $entry != "" } {
	if { [string index $entry 0] > [string index $entry end]} {
	$table delete [string index $entry end] [string index $entry 0]
	$table see [string index $entry end]
	}
	if { [string index $entry 0] <=  [string index $entry end]} {
	$table delete [string index $entry 0] [string index $entry end]
	$table see [string index $entry 0]
	}
    }   
    
    set matnames ""
    set ipos1 0
    while { [lindex $matlist $ipos1] != "" } {
	set aux [lindex $matlist $ipos1]
	lappend matnames [lindex $aux 0]
	set ipos1 [ expr $ipos1+1 ]
    }
    $cbdatamat configure -values $matnames
    eval [Composite::refresh $can ]
    focus $widget
    
    $table see end
    set ID [llength $matlist]
    incr ID
    set title "mat $ID"
    set currenttitle $title
    set title ""

}


proc Composite::TotalThickCalc {} {
    variable totalThick
    variable lamlist
    variable matlist
    
    set totT 0.0
    
    foreach layer $lamlist {
	set matname [lindex $layer 0]
	set totT [expr $totT + [lindex $layer 2]*[lindex $layer 3]]
	
    }
    
    set totalThick [format %.5g $totT]
    return $totT
    
}



##############################################################
#           Delete a row intro tablelist of laminate         #
##############################################################
proc Composite::lamdelete { table widget} {
    variable can
    variable cbdatamat
    variable matlist

    set flagTotThick 0
    set indexs "" 

    for { set i [expr [llength [$table curselection ]]-1] } { $i >=0 } { incr i -1} {
	lappend indexs [ lindex [$table curselection ] $i]
	}
    foreach index $indexs {
	$table delete $index
    }   
    set matnames ""
    set ipos1 0
    while { [lindex $matlist $ipos1] != "" } {
	set aux [lindex $matlist $ipos1]
	lappend matnames [lindex $aux 0]
	set ipos1 [ expr $ipos1+1 ]
    }
    $cbdatamat configure -values $matnames
    eval [Composite::refresh $can ]
    catch { focus $widget }

    TotalThickCalc 


}
##############################################################
#         Dump result intro tablelist of laminate            #
##############################################################
proc Composite::lamadd { table entry } {
    variable t         
    variable ang         
    variable matname         
    variable numlayers  
    variable useangle
    variable lamindex
    variable can  
    variable seq
    variable lamtype

    if { $lamindex == ""} {
	set lamindex -1
    }
    if { $lamindex == -1 } {
	if { $useangle == 1 } {
	    set t [expr double($t)]
	    set ang [expr double($ang)]
	    $table insert end "{$matname} [format %5.2f $ang] [format %6f $t] \
		$numlayers"
	} elseif {($lamtype == "Roving" && $seq != [= "User"]) \
	    || ($lamtype == "Uni" && $seq != [= "User"])} {  
	    set t [expr double($t)]
	    if {$seq == "\[45,-45\]s"} {
		set ang $seq
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*4]"
	    } elseif {$seq == "\[45,-45\]"} {
		set ang $seq
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*2]"
	    } elseif {$seq == "\[0,45,-45\]"} {
		set ang $seq
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*3]"
	    } elseif {$seq == "\[0,90\]"} {
		set ang $seq
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*2]"
	    }
	    
	} else {
	    set t [expr double($t)]
	    $table insert end "{$matname} 0.0 [format %6f $t] \
		$numlayers"
	}
	$table see end
    } 
    if { $lamindex != -1 } {
	$table delete $lamindex
	if { $useangle == 1 } {
	    set t [expr double($t)]
	    set ang [expr double($ang)]
	    $table insert $lamindex "{$matname} [format %5.2f $ang] [format %6f $t] \
		    $numlayers"
		        
	} elseif {($lamtype == "Roving" && $seq != [= "User"]) \
	    || ($lamtype == "Uni" && $seq != [= "User"])} {  
	    set t [expr double($t)]
	    if {$seq == "\[45,-45\]s"} {
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*4]"
	    } elseif {$seq == "\[45,-45\]"} {
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*2]"
	    } elseif {$seq == "\[0,45,-45\]"} {
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*3]"
	    } elseif {$seq == "\[0,90\]"} {
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*2]"
	    }
	    
	} else {  
	    set t [expr double($t)]
	    $table insert $lamindex "{$matname} 0.0 [format %6f $t] \
		    $numlayers"
		                    
	}
	$table see $lamindex
	set lamindex -1
	set t ""        
	set ang 0.0       
	set matname ""        
	set numlayers 1
	eval [Composite::refresh $can ]
	focus $entry
	grid remove $Composite::lammodify
	grid remove $Composite::lamcancel
	grid $Composite::lamadd
	grid $Composite::lamclear
    }
    set t ""        
    set ang 0.0        
    set matname ""        
    set numlayers 1
    eval [Composite::refresh $can ]
    focus $entry

    TotalThickCalc 

}                
##############################################################
#       Edit a row into tablelist of laminate                #
###############################################################
proc Composite::lamedit { table } {
    variable matname          
    variable t         
    variable ang         
    variable numlayers         
    variable useangle         
    variable lamindex
    variable lamtype
    variable seq
    
    set lamindex [$table curselection]
    if { [llength $lamindex] > 1} {
	WarnWin [= "It is only possible edit one row at the same time"] $table 
	return
    } 
    if { $lamindex != "" } {
	set entry [$table get $lamindex]
	set matname [lindex $entry 0]
	set t [lindex $entry 2]
	set ang [lindex $entry 1]
	set seq [lindex $entry 1]
	if {$lamtype != "Mat"} {
	    if {$seq == "\[45,-45\]s"} {
		set numlayers [expr [lindex $entry 3]/4]
	    } elseif {$seq == "\[45,-45\]" || $seq == "\[0,90\]"} {
		set numlayers [expr [lindex $entry 3]/2]
	    } elseif {$seq == "\[0,45,-45\]"} {
		set numlayers [expr [lindex $entry 3]/3]
	    }
	} else {
	    set numlayers [lindex $entry 3]
	}
	grid $Composite::lammodify
	grid $Composite::lamcancel
	grid remove $Composite::lamadd
	grid remove $Composite::lamclear
    }
} 
##############################################################
#        Cancel edit process into tablelist laminate         #
##############################################################
proc Composite::lamcancel { table entry } {
 variable matname
 variable t         
 variable ang         
 variable numlayers         
 variable useangle         
 variable lamindex         
    
    $table see end
    set matname ""
    set t ""        
    set ang 0.0        
    set numlayers 1        
    set lamindex -1
    set useangle 1
    grid remove $Composite::lammodify
    grid remove $Composite::lamcancel 
    grid $Composite::lamadd
    grid $Composite::lamclear
    focus $entry
}

##############################################################
#              update Fiber angle entry                      #
##############################################################
proc Composite::update { entry bgcolor flag} {
    variable useangle         
    variable ang 
    variable lamtype
#     variable matname
    variable seq
    
    if {$flag == 0} {
	if { ($useangle ==1 && $lamtype == "Uni") \
	    || ($useangle ==1 && $lamtype == "Roving" ) \
	    || ($useangle ==1 && $lamtype == "")} {
	    $entry configure -bg white -state normal
	} else {
	    $entry configure -state disabled
	    set ang 0.0
	}
    } elseif {$flag == 1} {
	if { ($useangle ==1 && $lamtype == "Uni" && $seq == [= "User"]) \
	    || ($useangle ==1 && $lamtype == "Roving" && $seq == [= "User"]) \
	    || ($useangle ==1 && $lamtype == "") } {
	    $entry configure -bg white -state normal
	} else {
	    $entry configure -state disabled
	    set ang 0.0
	}
    }
    
}


##############################################################
#               Clear all values into laminate page          #
##############################################################
proc Composite::lamclear { table } {
    variable can
    variable lamlist
    $table delete 0 end
    set lamlist ""
    eval [Composite::refresh $can]
}

##############################################################
#          Draw visual description of sandwich               #
##############################################################
proc Composite::refresh { can } {
    variable lamlist       
    variable matlist 
    $can delete all
    set x [ winfo width $can ]
    set y [ winfo height $can ]
    set y [expr $y-16.0]
    set thick ""
    set t 0
    set matnames ""
    set ipos 0
    set aux ""
    set lamcolors ""
    set colors "moccasin green blue yellow pink gold azure orange violet \
	    brown darkgreen darkblue red cyan magenta DeepPink gray firebrick honeydew \
	    HotPink ivory IndianRed khaki lavender LawnGreen LightSalmon LightSeaGreen \
	    linen maroon MistyRose navy PaleGoldenrod peru plum purple SeaGreen SkyBlue \
	    thistle tomato turquoise wheat YellowGreen"


    $can create line [expr {$x-30}] [expr {.5*$y}] [expr {$x-30}] [expr {$y-15}] \
	-fill black -width 2 -arrow last
    $can create text [expr {$x-25}] [expr {$y-15}] -text "Z'" -anchor sw


    foreach mat $matlist {
	lappend aux [lindex $mat 0]
	lappend aux [lindex $colors $ipos]
	set ipos [expr $ipos+1]
    }
    array set matcolors $aux
    foreach mat $lamlist {
	set numlayer [lindex $mat 3]
	set t [expr $t+[lindex $mat 2]*$numlayer]
	if { $numlayer > 0 } {
	    for { set j 0 } { $j < $numlayer } { incr j } {
		lappend thick [lindex $mat 2]
		lappend matnames [lindex $mat 0]
		lappend lamcolors $matcolors([lindex $mat 0])
	    }
	    }
    }
    set yi 8.0
    set ipos 0
    foreach ti $thick {
	lappend yi [expr [lindex $yi $ipos]+($y*$ti)/$t]
	set ipos [expr $ipos+1]
    }
   
    set x0 25.0
    set x1 [expr $x-125.0]

    set n [expr [llength $yi]-1]
    for { set i 0 } { $i < $n } {incr i 1 } {
	$can create rectangle $x0 [lindex $yi $i] $x1 [lindex $yi [expr $i+1]] \
		-fill [lindex $lamcolors $i]
    }
    if { $lamlist == "" } {
	$can delete all
    } else {
	set yleg [font metrics current -linespace]
	set xleg [expr $x1+8] 
	set ipos 0
	foreach mat $matlist {
	    $can create rectangle $xleg [expr [lindex $yi 0]+$ipos*$yleg] [expr $xleg+10] \
		    [expr [lindex $yi 0]+($ipos+1)*$yleg] -fill $matcolors([lindex $mat 0])
	    $can create text [expr $xleg+14] [expr [lindex $yi 0]+$ipos*$yleg] \
		    -text [lindex $mat 0] -justify right -anchor nw
	    set ipos [expr $ipos+1] 
	}
    }    
}


##############################################################
#       Comunication with GiD: dump results into GiD         #
##############################################################
proc Composite::dump { } {
    variable matlist
    variable lamlist
    variable considermat
    variable totalThick
    set values ""
    set numlayer 0
    foreach layer $lamlist {
	set numlayer [expr $numlayer+[lindex $layer 3]]
    }
    lappend values $numlayer
 
##########################
    
    foreach layer $lamlist {
	set matname [lindex $layer 0]
	set numlayer [lindex $layer 3]
	set angulin [lindex $layer 1]
	foreach mat $matlist {
	    set currentmat [lindex $mat 0]
	    if { $matname == $currentmat } {
		set t_aux [expr [lindex $layer 2]/$numlayer]
		if { $angulin == "\[45,-45\]"} {
		    set j 0
		    for { set i 0 } { $i < $numlayer } { incr i } {
		        if {$i == $j } {
		            set angulin [expr 45.0]
		            set j [expr $j + 2]
		        } else {
		            set angulin [expr -45.0]
		        }
		        if { [lindex $mat 9] != "0.0" && [lindex $mat 9] != "undef"} {
		            lappend values [lindex $mat 2] [lindex $mat 3] \
		                [lindex $mat 4] [lindex $mat 5] [lindex $mat 6] \
		                [lindex $mat 7] [lindex $mat 9] [lindex $mat 10] [lindex $mat 11] \
		                [lindex $mat 12] [lindex $mat 13] $angulin $t_aux \
		                [lindex $mat 8]
		        } else {
		            lappend values [lindex $mat 2] [lindex $mat 3] \
		                [lindex $mat 4] [lindex $mat 5] [lindex $mat 6] \
		                [lindex $mat 7] 0.0 0.0 0.0 0.0 0.0 $angulin $t_aux \
		                [lindex $mat 8]
		        } 
		    }
		} elseif { $angulin == "\[0,90\]"} {
		    set j 0
		    for { set i 0 } { $i < $numlayer } { incr i } {
		        if {$i ==  $j } {
		            set angulin [expr 0.0]
		            set j [expr $j + 2]
		        } else {
		            set angulin [expr 90.0]
		        }
		        if { [lindex $mat 9] != "0.0" && [lindex $mat 9] != "undef"} {
		            lappend values [lindex $mat 2] [lindex $mat 3] \
		                [lindex $mat 4] [lindex $mat 5] [lindex $mat 6] \
		                [lindex $mat 7] [lindex $mat 9] [lindex $mat 10] [lindex $mat 11] \
		                [lindex $mat 12] [lindex $mat 13] $angulin $t_aux \
		                [lindex $mat 8]
		        } else {
		            lappend values [lindex $mat 2] [lindex $mat 3] \
		                [lindex $mat 4] [lindex $mat 5] [lindex $mat 6] \
		                [lindex $mat 7] 0.0 0.0 0.0 0.0 0.0 $angulin $t_aux \
		                [lindex $mat 8]
		        } 
		    }
		} elseif { $angulin == "\[45,-45\]s"} {
		    set j 0
		    set k 1
		    set l 2
		    set m 3
		    for { set i 0 } { $i < $numlayer } { incr i } {
		        if {$i == $j } {
		            set angulin [expr 45.0]
		            set j [expr $j + 4]
		        } elseif { $i == $k } {
		            set angulin [expr -45.0]
		            set k [expr $k + 4]
		        } elseif { $i == $l } {
		            set angulin [expr -45.0]
		            set l [expr $l + 4]
		        } elseif { $i == $m } {
		            set angulin [expr 45.0]
		            set m [expr $m + 4]
		        }
		        if { [lindex $mat 9] != "0.0" && [lindex $mat 9] != "undef"} {
		            lappend values [lindex $mat 2] [lindex $mat 3] \
		                [lindex $mat 4] [lindex $mat 5] [lindex $mat 6] \
		                [lindex $mat 7] [lindex $mat 9] [lindex $mat 10] [lindex $mat 11] \
		                [lindex $mat 12] [lindex $mat 13] $angulin $t_aux \
		                [lindex $mat 8]
		        } else {
		            lappend values [lindex $mat 2] [lindex $mat 3] \
		                [lindex $mat 4] [lindex $mat 5] [lindex $mat 6] \
		                [lindex $mat 7] 0.0 0.0 0.0 0.0 0.0 $angulin $t_aux \
		                [lindex $mat 8]
		        } 
		    }
		} elseif { $angulin == "\[0,45,-45\]"} {
		    set j 0
		    set k 1
		    set l 2
		    for { set i 0 } { $i < $numlayer } { incr i } {
		        if {$i == $j } {
		            set angulin [expr 0.0]
		            set j [expr $j + 3]
		        } elseif { $i == $k } {
		            set angulin [expr 45.0]
		            set k [expr $k + 3]
		        } elseif { $i == $l } {
		            set angulin [expr 45.0]
		            set l [expr $l + 3]
		        } 
#                         set layer [list [lindex $layer 0] $angulin [lindex $layer 2] [lindex $layer 3]]
		        if { [lindex $mat 9] != "0.0" && [lindex $mat 9] != "undef"} {
		            lappend values [lindex $mat 2] [lindex $mat 3] \
		                [lindex $mat 4] [lindex $mat 5] [lindex $mat 6] \
		                [lindex $mat 7] [lindex $mat 9] [lindex $mat 10] [lindex $mat 11] \
		                [lindex $mat 12] [lindex $mat 13] $angulin $t_aux \
		                [lindex $mat 8]
		        } else {
		            lappend values [lindex $mat 2] [lindex $mat 3] \
		                [lindex $mat 4] [lindex $mat 5] [lindex $mat 6] \
		                [lindex $mat 7] 0.0 0.0 0.0 0.0 0.0 $angulin $t_aux \
		                [lindex $mat 8]
		        } 
		    }
		} else {
		    for { set i 0 } { $i < $numlayer } { incr i } {
		        if { [lindex $mat 9] != "0.0" && [lindex $mat 9] != "undef"} {
		            lappend values [lindex $mat 2] [lindex $mat 3] \
		                [lindex $mat 4] [lindex $mat 5] [lindex $mat 6] \
		                [lindex $mat 7] [lindex $mat 9] [lindex $mat 10] [lindex $mat 11] \
		                [lindex $mat 12] [lindex $mat 13] [lindex $layer 1] [lindex $layer 2] \
		                [lindex $mat 8]
		        } else {
		            lappend values [lindex $mat 2] [lindex $mat 3] \
		                [lindex $mat 4] [lindex $mat 5] [lindex $mat 6] \
		                [lindex $mat 7] 0.0 0.0 0.0 0.0 0.0 [lindex $layer 1] [lindex $layer 2] \
		                [lindex $mat 8]
		        } 
		    }
		}
	    }
	}
    }
    
#     lappend values $totalThick
    set values [join $values]
    return $values
}

#############################################################################
#Comuniation with GiD: Create a list of materials names for open window     #
#############################################################################
proc Composite::infonames { } {
    variable matlist
    variable lamlist
    
    set nameslist ""
    
    foreach layer $lamlist {
	set matname [lindex $layer 0]
	set numlayer [lindex $layer 3]
	lappend nameslist $matname
	lappend nameslist $numlayer
    }
    lappend nameslist end
    return $nameslist
}
##############################################################################
#   Comunication with GiD: get the values of sandwich to show intro window    #
##############################################################################
proc Composite::getvalues { names matunit mat lam matfr} {
    variable cbdatamat
    variable can
    variable matlist ""
    variable lamlist ""
    variable units ""
    variable mathick
    set cbvalues ""
    set units $matunit
    if { $mat != 0 } { 
	set matlist [base64::decode $mat]
    }
    if { $lam !=0 } {
	set lamlist  [base64::decode $lam]
    } 
    if { $matfr != 0 } {
	array set mathick  [base64::decode $matfr]
    }
    set i -1
    foreach mat $matlist {
	incr i
	lappend cbvalues [lindex $mat 0]
	set kk [array get mathick [lindex $mat 0]]
	set kk2 [lindex $kk 1]
	set kk3 [lindex $kk2 12]
	set j $mat
	lappend j $kk3
	set matlist [lreplace $matlist $i $i $j]
    }
  
    $cbdatamat configure -values $cbvalues
    Composite::refresh $can
} 

proc Composite::unitsproc { } {

    variable units
    variable unit2
    variable unit3
    variable unit1
    variable massunit2
    variable spweightunit
    variable currentunit
    variable conv2 
    variable dens
    variable length 
    
    variable t_mat
    variable t

    variable e1         
    variable e2         
    variable g12         
    variable g23         
    variable g13 
    variable spweight
    
     variable sc1
    variable sc2
    variable st1
    variable st2
    variable cort
    
    variable ef         
    variable er 
    variable gr
    variable gf       
    variable densityf         
    variable densityr         
    variable remass
    
    variable table
    variable matlist
    variable lamtable

    switch $units {
	"N-m-kg" {
	    set unit2 "N/m\u00b2"
	    set unit3 "kg/m\u00b3"
	    set unit1 m
	    set massunit2 "kg/m\u00b2"
	    set spweightunit "N/m\u00b3"
	    set grav 9.8
	}
	"N-cm-kg" {
	     set unit1 cm
	    set unit2 "N/cm\u00b2"
	    set unit3 "kg/cm\u00b3"
	    set massunit2 "kg/cm\u00b2"
	    set spweightunit "N/cm\u00b3"
	    set grav 980
	}
	"N-mm-kg" {
	     set unit1 mm
	    set unit2 "N/mm\u00b2"
	    set unit3 "kg/mm\u00b3"
	    set unit1 mm
	    set massunit2 "kg/mm\u00b2"
	    set spweightunit "N/mm\u00b3"
	    set grav 9800
	}
	"Kp-cm-utm" {
	     set unit1 cm
	    set unit2 "Kp/cm\u00b2"
	    set unit3 "kg/cm\u00b3"
	     set massunit2 "kg/cm\u00b2"
	    set spweightunit "Kp/cm\u00b3"
	    set grav 100
	}
    }
    catch { set e1 [string trim [format %.8g [expr $e1*$conv2($currentunit,$units)]]] }
    catch { set e2 [string trim [format %.8g [expr $e2*$conv2($currentunit,$units)]]]  }
    catch { set g12 [string trim [format %.8g [expr $g12*$conv2($currentunit,$units)]]]  }
    catch { set g13 [string trim [format %.8g [expr $g13*$conv2($currentunit,$units)]]]  }
    catch { set g23 [string trim [format %.8g [expr $g23*$conv2($currentunit,$units)]]]  }
    catch { set ef [string trim [format %.8g [expr $ef*$conv2($currentunit,$units)]] ] }
    catch { set er [string trim [format %.8g [expr $er*$conv2($currentunit,$units)]]]  }
    catch { set gr [string trim [format %.8g [expr $gr*$conv2($currentunit,$units)]]]  }
    catch { set gf [string trim [format %.8g [expr $gf*$conv2($currentunit,$units)]]]  }
    catch { set  densityf [string trim [format %.8g [expr $densityf*$dens($currentunit,$units)]]]  } 
    catch { set  densityr [string trim [format %.8g [expr $densityr*$dens($currentunit,$units)]]]  }
    catch {set remass [string trim [format %.8g [expr $remass*$conv2($currentunit,$units)]]] }
    catch { set t [string trim [ format %.8g [expr $t*$length($currentunit,$units)]]] }
    catch { set t_mat [string trim [ format %.8g [expr $t*$length($currentunit,$units)]]] }
    catch { set sc1 [string trim [ format %.8g [expr $sc1*$conv2($currentunit,$units)]]] }
    catch { set sc2 [string trim [ format %.8g [expr $sc2*$conv2($currentunit,$units)]]] }
    catch { set st1 [string trim [ format %.8g [expr $st1*$conv2($currentunit,$units)]]] }
    catch { set st2 [string trim [ format %.8g [expr $st2*$conv2($currentunit,$units)]]] }
    catch { set cort [string trim [ format %.8g [expr $cort*$conv2($currentunit,$units)]]] }
    catch {set spweight [string trim [format %.8g [expr $spweight*$grav*$dens($currentunit,$units)]]]}


    #Modifico Materials List
    set list_materials [$table get 0 end]
    set indice 0
    foreach imat $list_materials {       
	set title_aux [lindex $imat 0]
	set thick_aux [lindex $imat 1]
	set e1_aux [lindex $imat 2]
	set e2_aux [lindex $imat 3]
	set nu12_aux [lindex $imat 4]
	set g12_aux [lindex $imat 5]
	set g23_aux [lindex $imat 6]
	set g13_aux [lindex $imat 7]
	set spweight_aux [lindex $imat 8]
	set sc1_aux [lindex $imat 9]
	set sc2_aux [lindex $imat 10]
	set st1_aux [lindex $imat 11]
	set st2_aux [lindex $imat 12]
	set tmat_aux [lindex $imat 13]
	set MatRovUni [lindex $imat 14] 

	$table delete $indice
	
	catch { set thick_aux [expr $thick_aux*$length($currentunit,$units)] }
	catch { set e1_aux [expr $e1_aux*$conv2($currentunit,$units)] }
	catch { set e2_aux [expr $e2_aux*$conv2($currentunit,$units)] }
	catch { set g12_aux [expr $g12_aux*$conv2($currentunit,$units)] }
	catch { set g23_aux [expr $g23_aux*$conv2($currentunit,$units)] }
	catch { set g13_aux [expr $g13_aux*$conv2($currentunit,$units)] }
	catch { set spweight_aux [expr $spweight_aux*$grav*$dens($currentunit,$units)] } 

	set IsFailModel 0
	if { $sc1_aux != "0.0" } {
	    catch { set sc1_aux [expr $sc1_aux*$conv2($currentunit,$units)] }
	    catch { set sc2_aux [expr $sc2_aux*$conv2($currentunit,$units)] }
	    catch { set st1_aux [expr $st1_aux*$conv2($currentunit,$units)] }
	    catch { set st2_aux [expr $st2_aux*$conv2($currentunit,$units)] }
	    catch { set tmat_aux [expr $tmat_aux*$conv2($currentunit,$units)] }
	    set IsFailModel 1
	}

	if { $IsFailModel == 1 } { 
	    $table insert $indice "[list $title_aux [format %.8g $thick_aux] [format %.8g $e1_aux] \
		    [format %.8g $e2_aux] [format %4.3f $nu12_aux] [format %.8g $g12_aux] \
		    [format %.8g $g23_aux] [format %.8g $g13_aux] [format %.8g $spweight_aux] \
		    $sc1_aux $sc2_aux $st1_aux $st2_aux $tmat_aux $MatRovUni]"
	} else {
	     $table insert $indice "[list $title_aux [format %.8g $thick_aux] [format %.8g $e1_aux] \
		    [format %.8g $e2_aux] [format %4.3f $nu12_aux] [format %.8g $g12_aux] \
		    [format %.8g $g23_aux] [format %.8g $g13_aux] [format %.8g $spweight_aux] \
		    0.0 0.0 0.0 0.0 0.0 $MatRovUni]"
	}
	set indice [expr $indice+1]
    }

    #Modifico Laminate List
    set list_laminate [$lamtable get 0 end]
    set indice 0
    foreach imat $list_laminate {       
	set title_aux [lindex $imat 0]
	set angle_aux [lindex $imat 1]
	set thick_aux [lindex $imat 2]
	set numlayer_aux [lindex $imat 3]

	$lamtable delete $indice
	catch { set thick_aux [expr $thick_aux*$length($currentunit,$units)] }
	$lamtable insert $indice "[list title_aux [format %5.2f $angle_aux] [format %6f $thick_aux] \
		     $numlayer_aux]"
	set indice [expr $indice+1]
    }
    

    set currentunit $units
}    

proc Composite::fiber-resin { parent } {
    global tkPriv tcl_platform
    variable topname
    variable ef         
    variable er        
    variable densityf         
    variable densityr         
    variable nuf         
    variable nur 
    variable gf
    variable gr  
    variable re100        
    variable titlel
    variable vac                 
    variable remass
    variable typel   
    variable title
    variable mathick
    variable matlist
    variable matname
    variable currenttitle
    
    set currenttitle "$title" 


    if {$currenttitle != ""} {
	foreach mat $matlist {
	    if {$currenttitle == "[lindex $mat 0]"} {
		set lamtypeaux [lindex $mat 14]
		break
	    }
	}
    } 

 
    if { [info exists mathick($title) ] } {
	set titlel "$title"
	set ef [lindex $mathick($title) 1]
	set er [lindex $mathick($title) 2]
	set densityf [lindex $mathick($title) 3]
	set densityr [lindex $mathick($title) 4]
	set nuf [lindex $mathick($title) 5]
	set nur [lindex $mathick($title) 6]
	set gf [lindex $mathick($title) 7]
	set gr [lindex $mathick($title) 8]
	set re100 [lindex $mathick($title) 9]
	set vac [lindex $mathick($title) 10]
	set remass [lindex $mathick($title) 11]
	set typel [lindex $mathick($title) 12]
    } elseif {"$currenttitle" == "" } {
	set titlel "E-Glass/Epoxy"
	set ef 73.0e9
	set er 2.6e9
	set densityf 2540
	set densityr 1200
	set nuf 0.25
	set nur 0.4
	set gf 28.0e9
	set gr 1.4e9
	set remass ""
	set re100 ""  
	set typel ""
	set vac ""
    } else { 
	set titlel "$currenttitle"
	set ef ""
	set er ""
	set densityf ""
	set densityr ""
	set nuf ""
	set nur ""
	set gf ""
	set gr ""
	set re100 ""
	set vac ""
	set remass ""
	set typel "[lindex $mat 14]"
    }

 
      
    
    
#     else {
#         set ef "" ; set nuf "" ; set densityf "" ; set er "" ; set nur "" ; set densityr "" ; set vac "" ; set titlel ""
#         set remass "" ; set re100 ""  ; set typel ""; set gf ""; set gr ""
#     }
     
    set topname $parent.fr
    catch {destroy $topname}
    toplevel $topname
    wm withdraw $topname
    
    wm title $topname Fiber-Resin
    if { $tcl_platform(platform) == "windows" } {
	wm transient $topname [winfo toplevel [winfo parent $topname]]
    }
       
    grid columnconf $topname 0 -weight 1
    grid rowconf $topname 0 -weight 1
   
    set matnb [NoteBook $topname.matnb ]
    set matpage1 [$matnb insert end page1 -text [= "Fiber"]]
    set matpage2 [$matnb insert end page2 -text [= "Resin"] ]
    $matnb raise page1
    set titlef [TitleFrame $matpage1.fdata -relief groove -bd 2 -ipad 6 \
	    -text [= "Fiber"] -side left]
    set ff [$titlef getframe]
    set lef [label $ff.lef -text [= "Young Modulus"] -justify left ]
    set eef [entry $ff.eef -textvariable Composite::ef -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitef [label $ff.lunitef -textvariable Composite::unit2 -width 7]
    set ldensityf [label $ff.ldensityf -text [= "Density"] -justify left]
    set edensityf [entry $ff.edensityf -textvariable Composite::densityf -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitdenf [label $ff.lunitdenf -textvariable Composite::unit3 -width 7]
    set lnuf [label $ff.lnuf -text [= "Possion coef."] -justify left ]
    set enuf [entry $ff.enuf -textvariable Composite::nuf -width 8 \
	    -justify left -width 8 -bd 2 -relief sunken ]
    set lgf [label $ff.lgf -text [= "Shear Modulus"] -justify left ]
    set egf [entry $ff.egf -textvariable Composite::gf -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitgf [label $ff.lunitgf -textvariable Composite::unit2 -width 7]

    set titler [TitleFrame $matpage2.rdata -relief groove -bd 2 -ipad 6 \
	    -text [= "Resin"] -side left]
    set fr [$titler getframe]
    set ler [label $fr.lef -text [= "Young Modulus"] -justify left ]
    set eer [entry $fr.eef -textvariable Composite::er -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set luniter [label $fr.luniter -textvariable Composite::unit2 -width 7]
    set ldensityr [label $fr.ldensityr -text [= "Density"] -justify left]
    set edensityr [entry $fr.edensityr -textvariable Composite::densityr -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitdenr [label $fr.lunitdenr -textvariable Composite::unit3 -width 7]
    set lnur [label $fr.lnur -text [= "Possion coef."] -justify left ]
    set enur [entry $fr.enur -textvariable Composite::nur -width 8 \
	    -justify left -width 8 -bd 2 -relief sunken ]
     set lgr [label $fr.lgf -text [= "Shear Modulus"] -justify left ]
    set egr [entry $fr.egf -textvariable Composite::gr -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitgr [label $fr.lunitgr -textvariable Composite::unit2 -width 7]

    set titlel1 [TitleFrame $topname.ldata -relief groove -bd 2 -ipad 6 \
	    -text [= "Material"] -side left]
    set fl [$titlel1 getframe]
    set lunitsmat [label $fl.lunitsmat -text [= Units] -justify left]
    set cbunitsmat [ComboBox $fl.cbunitsmat -textvariable Composite::units -editable no \
	    -justify left -values [list N-m-kg N-cm-kg N-mm-kg Kp-cm-utm] -width 5]
    set command " ;#"
    trace variable Composite::units w $command
    bind $cbunitsmat <Destroy> [list trace vdelete Composite::units w $command]
    set ltitlel [label $fl.ltitlel -text [= Name] -justify left ]
    set etitlel [entry $fl.etitlel -textvariable Composite::titlel -width 8 \
	    -justify left  -bd 2 -relief sunken  ] 
    focus $etitlel
    set ltypel [label $fl.lef -text [= "Layer Type"] -justify left ]
    set cbtypel [ComboBox $fl.cbtypel -textvariable Composite::typel -width 8 \
	    -editable no -values [list Uni Mat Roving]]
    set lre100 [Label $fl.lre100 -text [= "% Reinforcement"] -justify left \
	    -helptext [= "% of Reinforcement per unit mass.\nIt must be between 0 and 100"]]
    set ere100 [entry $fl.ere100 -textvariable Composite::re100 -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lvac [Label $fl.lvac -text [= "Vaccum Index"] -justify left \
	    -helptext [= "It must be between 0 and 1"]]
    set evac [entry $fl.evac -textvariable Composite::vac -width 8 \
	    -justify left -width 8 -bd 2 -relief sunken ]
    set lremass [Label $fl.lremass -text [= "Mass of Reinforcement"] -justify left \
	    -helptext [= "Mass of R."]]
    set eremass [entry $fl.eremass -textvariable Composite::remass -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitmass [label $fl.lunitmass -textvariable Composite::massunit2 -width 7]
    
    set fbuttons [frame $topname.fbuttons -bd 2 -relief sunken]
    set badd [button $fbuttons.badd -text [= Add]  -underline 0 -width 10 \
	    -command "Composite::fradd $topname $parent"]
    set bcancel [button $fbuttons.bcancel -text [= Cancel]  -underline 0 -width 10 \
	    -command "Composite::frcancel $topname"]
     
    bind $badd <ButtonRelease> {
	set Composite::values [list "$Composite::ef" "$Composite::nuf" "$Composite::densityf" "$Composite::gf"\
		"$Composite::er" "$Composite::nur" "$Composite::densityr" "$Composite::gr" "$Composite::vac" "$Composite::remass"\
		"$Composite::re100"]
	set Composite::names [list FiberYoungModulus FiberPoisson FiberDensity FiberShearModulus\
		ResinYoungModulus ResinPoisson ResinDensity ResinShearModulus Vaccum MassReinf Reinforcement]
	Composite::errorcntrl $Composite::values $Composite::names $Composite::topname
    }

    $cbtypel configure -modifycmd "Composite::combochange"

    grid $titlel1 -column 0 -row 0 -padx 2 -pady 2 -sticky nsew
    grid rowconf $fl 6 -weight 1
    grid columnconf $fl 1 -weight 1
    grid $lunitsmat -column 0 -row 0 -sticky nswe
    grid $cbunitsmat -column 1 -row 0 -sticky nswe 
    grid $ltitlel -column 0 -row 1 -sticky nswe
    grid $etitlel -column 1 -row 1 -sticky nswe
    grid $ltypel -column 0 -row 2 -sticky nswe
    grid $cbtypel -column 1 -row 2 -sticky nswe
    grid $lre100 -column 0 -row 3 -sticky nswe
    grid $ere100 -column 1 -row 3 -sticky nswe
    grid $lvac -column 0 -row 4 -sticky nsew
    grid $evac -column 1 -row 4 -sticky nswe
    grid $lremass -column 0 -row 5 -sticky nswe
    grid $eremass -column 1 -row 5 -sticky nswe
    grid $lunitmass -column 2 -row 5 -sticky nswe
    
    grid $matnb -column 1 -row 0 -sticky nsew
    grid columnconf $matpage1  0 -weight 1
    grid rowconf $matpage1 0 -weight 1
    grid columnconf $matpage2  0 -weight 1
    grid rowconf $matpage2 0 -weight 1

    grid $titlef -column 0 -row 0 -sticky nsew
    grid rowconf $ff 4 -weight 1
    grid columnconf $ff 1 -weight 1
    grid $lef -column 0 -row 0 -sticky nswe
    grid $eef -column 1 -row 0  -sticky nswe
    grid $lunitef -column 2 -row 0 -sticky nswe
    grid $ldensityf -column 0 -row 1 -sticky nswe
    grid $edensityf -column 1 -row 1 -sticky nswe
    grid $lunitdenf -column 2 -row 1 -sticky nswe
    grid $lnuf -column 0 -row 2 -sticky nswe
    grid $enuf -column 1 -row 2 -sticky nswe
    grid $lgf -column 0 -row 3 -sticky nswe
    grid $egf -column 1 -row 3 -sticky nsew
    grid $lunitgf -column 2 -row 3 -sticky nsew

    grid $titler -column 0 -row 0  -sticky nsew
    grid rowconf $fr 4 -weight 1
    grid columnconf $fr 1 -weight 1
    grid $ler -column 0 -row 0 -sticky nswe
    grid $eer -column 1 -row 0  -sticky nswe
    grid $luniter -column 2 -row 0 -sticky nswe
    grid $ldensityr -column 0 -row 1 -sticky nswe
    grid $edensityr -column 1 -row 1 -sticky nswe
    grid $lunitdenr -column 2 -row 1 -sticky nswe
    grid $lnur -column 0 -row 2 -sticky nswe
    grid $enur -column 1 -row 2 -sticky nswe
    grid $lgr -column 0 -row 3 -sticky nswe
    grid $egr -column 1 -row 3 -sticky nsew
    grid $lunitgr -column 2 -row 3 -sticky nsew
    
    grid $fbuttons -column 0 -row 1 -sticky nswe -columnspan 2 -pady 6
    grid $badd -column 0 -row 0 -pady 3 -padx 10
    grid $bcancel -column 1 -row 0 -pady 3 -padx 10

    $matnb compute_size

# set xpos [ expr [winfo x  [winfo toplevel $parent]]+50]
# set ypos [ expr [winfo y  [winfo toplevel  $parent]]+[winfo height [winfo toplevel  $parent]]/2-[winfo reqheight $topname]/2]
# wm geometry $topname +$xpos+$ypos

#    wm withdraw $topname
#     update idletasks
    set xpos [ expr [winfo x  $parent]+[winfo width $parent]/2-[winfo reqwidth $topname]/2+100]
    set ypos [ expr [winfo y  $parent]+[winfo height $parent]/2-[winfo reqheight $topname]/2]

    wm geometry $topname +$xpos+$ypos
    ::update idletasks
    wm deiconify $topname

}

proc Composite::combochange { } {
    variable re100 
    variable vac                 
    variable remass
    variable typel  

    if {$Composite::typel == "Uni"} {
	set Composite::re100 65
	set Composite::vac 0.0
	set Composite::remass 0.7
    } elseif {$Composite::typel == "Mat"} {
	set Composite::re100 30
	set Composite::vac 0.0
	set Composite::remass 0.6
    } elseif {$Composite::typel  == "Roving"} {
	set Composite::re100 50
	set Composite::vac 0.0
	set Composite::remass 0.8
    } elseif {$Composite::typel  == "" } {
	set Composite::re100 ""
	set Composite::vac ""
	set Composite::remass ""        
    }

}

proc Composite::fradd { top parent} { 

    variable ef         
    variable er        
    variable densityf         
    variable densityr         
    variable nuf         
    variable nur 
    variable gf
    variable gr  
    variable re100        
    variable titlel
    variable vac                 
    variable remass
    variable typel   
   
    variable title
    variable t
    variable e1         
    variable e2         
    variable nu12         
    variable g12         
    variable g23         
    variable g13   
    
    variable mathick
    variable badd

    variable spweight
    variable isfiberesin

    variable matlist
    
    variable flagF_R
    
    set message ""
    if { $vac >= 1 || $vac <0 } {
	set message  [= "Vaccum Index must be between 0 and 1\n"]      
	set command1 vac    
    }
    if { $nur >= 0.5 } {
	append message [= "Poisson coef. for Resin has to be smaller than 0.5\n"]
	 set command2 nur
    }
     if { $nuf >= 0.5 } {
	append message [= "Poisson coef. for Fiber has to be smaller than 0.5\n"]
	 set command3 nuf
    }
    if { $re100>100 || $re100<0 } {
	set message  [= "%Reinforcement must be between 0 and 100\n"]      
	set command4 re100
    }

    set re [expr $re100/100.0]
    
    set volume [expr ($re*(1-$vac)/($re+(1-$re)*$densityf/$densityr))]
    if { $volume > 1 } {
	append message [= "Please, check the consistency of the following values:\n-%Reinforcement\n-Vaccum Index\n-Fiber Density\n-Fiber Resin"]
	set command5 re100
    }

    if { $message != "" } { 
	WarnWin $message
	catch { vwait $command1 }
	catch { vwait $command2 }
	catch { vwait $command3 }
	catch { vwait $command4 }
	catch { vwait $command5 }
    }             
    

    set e1u [expr $volume*$ef+(1-$volume)*$er]
    set e2u [expr ($er/(1-pow($nur,2)))*((1+0.85*pow($volume,2))/(pow(1-$volume,1.25)+$volume*$er/($ef*(1-pow($nur,2)))))]
    #set esp [expr ($remass/(1-$vac))*(1/$densityf+(1-$re)/($re*$densityr))*pow(10,-6)]
    set esp [expr ($remass/(1-$vac))*(1/$densityf+(1-$re)/($re*$densityr))]
    set t [format %.5g $esp]
#     set nu12 [format %f [expr {$nuf*(1-$re)+$nur*$re}]]
    set nu12 [format %f [expr {$nur*(1-$volume)+$nuf*$volume}]]
#     set g12 [format %g [expr {$gr/double($re+(1-$re)*$gr/$gf)}]]
    set g12 [format %g [expr { $gr*(1 + 0.6*sqrt($volume))/(pow(1-$volume,1.25) + $er*$volume/$ef) }]]
    set g13 $g12
    set aux [expr double(3-4.0*$nur+double($gr)/$gf)/4.0*(1-$nur)] 
    set g23 [format %g [expr {($gr*((1-$re)+$aux*$re))/($aux*$re+(1-$re)*$gr/$gf)}]]
 
    set spweight [expr ($volume*$densityf+(1-$volume-$vac)*$densityr)*9.8]
		  
    switch $typel {
	"Uni" {
	    if { $e1u < $e2u } {
		set title "$titlel"
		set e1 $e2u
		set e2 $e1u
	    } else {
		set title "$titlel"
		set e1 $e1u
		set e2 $e2u                                     
	    }
	}
	"Mat" {
#             set title "$titlel"
#             set e1 [expr 3.0*$e1u/8.0+5.0*$e2u/8.0]
#             set e2 [expr 3.0*$e1u/8.0+5.0*$e2u/8.0]
	    set title "$titlel"
	    set em [expr 3.0*$e1u/8.0+5.0*$e2u/8.0]
	    set e1 $em
	    set e2 $em
	    
##Formulación libro:
# set em [expr $volume*(0.35556*$ef + 2*$er) + 0.8889*er ]
# set g12 [expr $volume*(1.3334*$ef + 0.75*$er) + 0.3334*$er]
# set nu12 0.3334
# set e1 $em
# set e2 $em
##
	}
	"Roving" {
##Formulación libro(suponiendo que se está considerando un Roving equilibrado):
# set er [expr $volume*(0.5*$ef + 1.5*$er) + er ]
# set g12 [expr $er/(pow(1+4*$volume),0.3334)]
# set nu12 [expr g12/er]
# set e1 $er
# set e2 $er
##
	    set k [expr $e1u/($e1u+$e2u)]
	    set e1ro [expr $k*$e1u+(1-$k)*$e2u]
	    set e2ro [expr (1-$k)*$e1u+$k*$e2u]
	    if  { $e1ro < $e2ro } {
		set title "$titlel"
		set e1 $e1ro
		set e2 $e1ro               
	    } else {
		set title "$titlel"
		set e1 $e2ro
		set e2 $e2ro
	    }
	}
    }
    set e1 [format %g $e1]
    set e2 [format %g $e2]
    set mathick($title) [list $t $ef $er $densityf $densityr $nuf $nur $gf  $gr $re100 $vac $remass $typel]
    
    destroy $top
    event generate $parent <<fiber-resin>>
    set isfiberesin 1
    
    set i -1
    foreach mat $matlist {
	incr i
	if { $title == "[lindex $mat 0]" } {
	    set kk2 [lreplace $mat 14 14 $typel]
	    set matlist [lreplace $matlist $i $i $kk2]
	    break
	}
    }

    set flagF_R 1
  
}
proc Composite::frcancel { top } {
#     variable ef         
#     variable er        
#     variable densityf         
#     variable densityr         
#     variable nuf         
#     variable nur   
#     variable re100        
#     variable titlel
#     variable vac                 
#     variable remass
#     variable typel
#     variable gf
#     variable gr
#     variable t ""
#     variable e1 ""         
#     variable e2 ""        
#     variable nu12  ""        
#     variable g12 ""        
#     variable g23 ""         
#     variable g13 ""
#     variable spweight ""
#     variable title        
#     variable currenttitle
#     set title $currenttitle
#     set ef "" ; set nuf "" ; set densityf "" ; set er "" ; set nur "" ; set densityr "" ; set vac "" ; set titlel ""
#     set remass "" ; set re100 ""  ; set typel ""; set gf ""; set gr ""
    
    destroy $top
}

proc Composite::errorcntrl {values names window} {
    set message ""
    foreach val $values {
	if { ! [string is double -strict $val]} {
	    set message "Following errors have been found:\n"
	    break
	}
    }
    set names_length [llength $names]
    for {set ii 0} {$ii<$names_length} {incr ii} {
	  if { ! [string is double -strict [lindex $values $ii]]  } {
	      append message "[lindex $names $ii]: Input is not valid ([lindex $values $ii])\n"
	  }
    }
    
    if  { $message != "" } {
	WarnWin $message $window
	#tk_messageBox -message $message -type ok        
	return 1
    }
    return 0
}

proc Composite::frmathick { ethick lamseq cbseq ldataspin cbseq check spin} {
    variable mathick
    variable t
    variable useangle
    variable matname
    variable ang
    variable matlist
    variable lamtype
    variable seq
    variable typel

    $spin configure -text "1"
  
    if { [info exists mathick($matname) ] } { 
	set useangle 0
	set ang 0.0
	set lamtype [lindex $mathick($matname) 12]
	#         set t [format %.5g [lindex $mathick($matname) 0]]
	if {($lamtype == "Uni" && $seq != [= "User"]) \
	    || ($lamtype == "Roving" && $seq != [= "User"])} {
	    $lamseq configure -text [= "Sequence"]
	    $ldataspin configure -text [= "Number of sequences"]
	    $cbseq configure -state normal 
	    set t [format %.5g [lindex $mathick($matname) 0]] 
	    $ethick configure -state disabled 
	    $check configure -state disabled -activebackground grey
	} elseif {($lamtype == "Uni" && $seq == [= "User"]) \
	    || ($lamtype == "Roving" && $seq == [= "User"])} {
	    $lamseq configure -text [= "Sequence"]
	    $ldataspin configure -text [= "Number of layers"]
	    $cbseq configure -state normal  
	    set t [format %.5g [lindex $mathick($matname) 0]] 
	    $ethick configure -state disabled
	    $check configure -state normal -activebackground white
	} elseif { $lamtype == "Mat" } {
	    $lamseq configure -text [= "No sequence"]
	    $ldataspin configure -text [= "Number of layers"]
	    $cbseq configure -state disabled
	    set t [format %.5g [lindex $mathick($matname) 0]]
	    $ethick configure -state disabled
	    $cbseq configure -text "" 
	    $check configure -state disabled -activebackground grey
	} else {
	    $lamseq configure -text [= "No sequence"]
	    $ldataspin configure -text [= "Number of layers"]
	    $cbseq configure -state disabled
	    set t [format %.5g [lindex $mathick($matname) 0]]
	    $ethick configure -state disabled
	    $cbseq configure -text "" 
#             $check configure -state disabled -activebackground grey
	    $check configure -state normal -activebackground white
	}
    } else {
	foreach mat $matlist {
	    if { $matname == "[lindex $mat 0]" } {
		set lamtype [lindex $mat 14]
		set lam2 $lamtype
		if {($lam2 == "Uni" && $seq != [= "User"]) \
		    || ($lam2 == "Roving" && $seq != [= "User"])} {
		    $lamseq configure -text [= "Sequence"]
		    $ldataspin configure -text [= "Number of sequences"]
		    $cbseq configure -state normal 
		    set t [format %.5g [lindex $mat 1]]
		    $ethick configure -state disabled 
		    $check configure -state disabled -activebackground grey
		} elseif {($lam2 == "Uni" && $seq == [= "User"]) \
		    || ($lam2 == "Roving" && $seq == [= "User"])} {
		    $lamseq configure -text [= "Sequence"]
		    $ldataspin configure -text [= "Number of layers"]
		    $cbseq configure -state normal  
		    set t [format %.5g [lindex $mat 1]] 
		    $ethick configure -state disabled  
		    $check configure -state normal -activebackground white
		} elseif { $lamtype == "Mat" } {
		    $lamseq configure -text [= "No sequence"]
		    $ldataspin configure -text [= "Number of layers"]
		    $cbseq configure -state disabled
		    set t [format %.5g [lindex $mat 1]]
		    $ethick configure -state disabled
		    $cbseq configure -text "" 
		    $check configure -state disabled -activebackground grey
		} else {
		    $lamseq configure -text [= "No sequence"]
		    $ldataspin configure -text [= "Number of layers"]
		    $cbseq configure -state disabled
		    set t [format %.5g [lindex $mat 1]]
		    $ethick configure -state disabled
		    $cbseq configure -text "" 
#                     $check configure -state disabled -activebackground grey
		    $check configure -state normal -activebackground white
		}
		break
	    }
	}
	#         $ethick configure -state normal
    }
}
##############################################################################
#   
# 
#                              Pop up menu of laminate table    #
# 
# 
##############################################################################

proc Composite::popupmenu { parent x y } {
    variable lamtable 
    catch { destroy $parent.menu }
    set menu [menu $parent.menu -type normal ]
    $menu add command -label [= Paste] -command Composite::poppaste
    $menu add command -label [= Sym+Paste] -command Composite::popsympaste
    $menu add command -label [= Delete] -command "Composite::lamdelete $lamtable {}"
    tk_popup $menu $x $y
   
} 

proc Composite::poppaste { } {
    variable lamtable 
    variable can
    set indexs [$lamtable curselection ]
    foreach index $indexs {
	$lamtable insert end [$lamtable get $index]
    }
    Composite::refresh $can
}
proc Composite::popsympaste { } {
    variable lamtable 
    variable can
    set indexs ""
    for { set i [expr [llength [$lamtable curselection ]]-1] } { $i >=0 } { incr i -1} {
	lappend indexs [ lindex [$lamtable curselection ] $i]
    }  
    foreach index $indexs {
	$lamtable insert end [$lamtable get $index]
    }
    Composite::refresh $can
}

proc Composite::Edit-Data { table parent } {
    variable t_mat
    variable t
    variable e1         
    variable e2         
    variable nu12         
    variable g12         
    variable g23         
    variable g13 
    variable spweight  
    variable sc1
    variable sc2
    variable st1
    variable st2
    variable cort  
    variable title        
    variable index
    variable currenttitle 
    variable considermat 
    variable ef         
    variable er        
    variable densityf         
    variable densityr         
    variable nuf         
    variable nur 
    variable gf
    variable gr  
    variable re100        
    variable titlel
    variable vac                 
    variable remass
    variable typel   
    variable mathick
    variable isfiberesin
    
    set currenttitle "$title" 
    set index [$table curselection]
    if { $index != "" } {
	set entry ""
	foreach i [$table get $index] {
	    lappend entry [string trim $i]
	}
	set title [lindex $entry 0]
	set t_mat [lindex $entry 1]
	set t $t_mat
	set e1 [lindex $entry 2]
	set e2 [lindex $entry 3]
	set nu12 [lindex $entry 4]
	set g12 [lindex $entry 5]
	set g13 [lindex $entry 7]
	set g23 [lindex $entry 6]
	set spweight [lindex $entry 8]
	if { [lindex $entry 9] == "0.0" } { 
	    set sc1 "0.0"
	    set sc2 "0.0"
	    set st1 "0.0"
	    set st2 "0.0"
	    set cort "0.0"
	    set considermat 0
	} else {
	    set sc1 [lindex $entry 9]
	    set sc2 [lindex $entry 10]
	    set st1 [lindex $entry 11]
	    set st2 [lindex $entry 12]
	    set cort [lindex $entry 13]
	    set considermat 1
	}


	if { [info exists mathick($title) ] } {
	    set titlel ""
	    set esp ""
	    set ef ""
	    set er ""
	    set densityf ""
	    set densityr ""
	    set nuf ""
	    set nur ""
	    set gf ""
	    set gr ""
	    set re100 ""
	    set  vac ""
	    set remass ""
	    set typel ""
	    set mathick($title) [list $esp $ef $er $densityf $densityr $nuf $nur $gf  $gr $re100 $vac $remass $typel]
	    catch { array unset mathick }
	}

	event generate $parent <<normal>>

	set isfiberesin 0
	catch { grid remove $Composite::bedit}
     
	catch { grid $Composite::bmodify }
	catch { grid $Composite::bcancel }
	catch { grid $Composite::bnew }
	catch { grid remove $Composite::badd }
	
    }
}

namespace eval laminatebuttons {

variable laminate

}
proc laminatebuttons::initbuttons { op args } {
    variable laminate
 
    switch $op {
	"INIT" {
	    set PARENT [lindex $args 0]
	    upvar [lindex $args 1] ROW
	    set GDN [lindex $args 2]
	    set STRUCT [lindex $args 3]
	    set llaminate [label $PARENT.llaminate -text [= "Laminate"] -justify left]
	    set blaminate [Button $PARENT.blaminate -text [= "Create/Edit"] -helptext \
		               [= "Open a window to create or edit\na new laminate shell"] \
		               -command laminatebuttons::ViewMaterial]
	    set cblaminate [ComboBox $PARENT.cblaminate -textvariable laminatebuttons::laminate \
		    -editable false -values ""]
	    $cblaminate configure -postcommand "laminatebuttons::updatecblaminate $cblaminate"
	    grid $llaminate -column 0 -row $ROW -sticky ne -pady 10
	    grid $cblaminate -column 1 -row $ROW -sticky nw -pady 10
	    grid $blaminate -column 1 -row [expr $ROW+1] -sticky nw

	    if { $laminate == "" } {
		foreach elem [ .central.s info materials] {
		    if { [.central.s info materials $elem BOOK] == "Laminate_shell" } {
		        set laminate $elem
		        break
		    }
		}
	    }
	}
	"SYNC" {
	    set GDN [lindex $args 0]
	    set STRUCT [lindex $args 1]
	    upvar \#0 $GDN GidData 
	    if { $laminate != "" } {
	    DWLocalSetValue $GDN $STRUCT  "Laminate" $laminate
	    } else {
		WarnWin [= "Select a laminate shell before assigning condition"]
	    }

	}
	"CLOSE" {
	    set laminate ""    
	}
    }
}
proc laminatebuttons::updatecblaminate { cb } {
    variable laminate

    set values ""
    set aux [ .central.s info materials]
     foreach elem $aux {
	if { [.central.s info materials $elem BOOK] == "Laminate_shell" } {
	    lappend values  $elem
	}
    }
    $cb configure -values $values
} 

proc laminatebuttons::ViewMaterial {} {
    variable laminate

    set GDN [GidOpenMaterials Laminate_shell]
}

     
