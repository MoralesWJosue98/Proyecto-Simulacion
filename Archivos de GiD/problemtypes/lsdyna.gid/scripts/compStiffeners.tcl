
catch { package require tablelist }
package require base64 
 
namespace eval compStiff {
 
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
    variable ang ""
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
    variable unit5 "m4"
    variable unit2 "N/m\u00b2"
    variable unit4 "m\u00b2"
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
    variable considermat 0
    variable isfiberesin 0
    variable topname 
    variable mathick
    variable lamtype ""
    variable seq
    variable show_t ""
    variable aux1 ""
    variable aux2 ""
    variable laminates ""
    variable lamname
    variable elaminate
    variable laminatestable
    variable laminatesList ""

    variable cansection
    variable topwidth ""
    variable bottomwidth "" 
    variable height ""
    variable basewidth ""
    variable area 

    variable finalyoung 
    variable finalweight 
    variable f
    variable values2
    variable sectionlam ""
    variable matprop 

    variable younglist
    variable younglist2
    variable weightlist
    variable glist
    variable nulist
    variable heighlist
    
    variable anglist ""
    
    variable shear 
    variable iyy 
    variable izz 
    variable j 
    
    variable cbtoplamin
    variable cbbottomlam
    variable cbheightlam
    
    variable flagF_R 0
	
}

proc compStiff::calculateconvmatrix { } { 
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
proc compStiff::ComunicateWithGiD { op args } {
    variable units
    variable matlist
    variable lamlist
    variable mathick
    variable laminates
    variable laminatesList
    variable lamname
    
    variable topwidth 
    variable bottomwidth 
    variable height
    variable basewidth  
    variable area 

    variable toplamin
    variable bottomlam
    variable heightlam
    
    variable finalyoung
    variable finalweight
    variable f
    variable matprop

    variable shear
    variable iyy
    variable izz
    variable j
    
  
    switch $op {
	"INIT" {
	    catch { array unset mathick }
	    compStiff::calcuateconvmatirx
	    set PARENT [lindex $args 0]
	    upvar [lindex $args 1] ROW
	    set GDN [lindex $args 2]
	    set STRUCT [lindex $args 3]
	    set f [frame $PARENT.f]
#             set lamlist ""
#             set laminates ""
	    
	    InitWindow $f 

	    grid $f -row $ROW -column 0 -sticky nsew -columnspan 2 -pady 3 -padx 2
	    grid columnconf $f 0 -weight 1
	    grid rowconf $f 0 -weight 1
	    grid rowconf $PARENT $ROW -weight 1
	    grid columnconf $PARENT 0 -weight 1
	    upvar \#0 $GDN GidData
	    getvalues $GidData($STRUCT,VALUE,2) $GidData($STRUCT,VALUE,18) $GidData($STRUCT,VALUE,15) \
		$GidData($STRUCT,VALUE,16) $GidData($STRUCT,VALUE,17) $GidData($STRUCT,VALUE,14)
	    return ""
	 }
	 "SYNC" {
	    set GDN [lindex $args 0]
	    set STRUCT [lindex $args 1]
	    set values [ compStiff::dump ]
	    set names [ compStiff::infonames ]
	    
	    if { $area != ""} {
		DWLocalSetValue $GDN $STRUCT  "win_info" $names
		DWLocalSetValue $GDN $STRUCT  "numero_de_capas" [lindex $values 0]
		DWLocalSetValue $GDN $STRUCT  "area" [format %8.4g $area]  
		DWLocalSetValue $GDN $STRUCT  "e" [format %8.4g $finalyoung] 
		DWLocalSetValue $GDN $STRUCT  "Units" $units
		DWLocalSetValue $GDN $STRUCT  "section_prop" [list $topwidth $toplamin $bottomwidth \
		        $bottomlam  $height $heightlam $basewidth $shear]               

		DWLocalSetValue $GDN $STRUCT  "section_info" [list $area $iyy $izz $j $finalyoung $shear]
		DWLocalSetValue $GDN $STRUCT  "weight" [expr $finalweight]
		DWLocalSetValue $GDN $STRUCT  "iyy" [format %8.4g $iyy]
		DWLocalSetValue $GDN $STRUCT  "izz" [format %8.4g $izz]
		DWLocalSetValue $GDN $STRUCT  "j" [format %8.4g $j]
		DWLocalSetValue $GDN $STRUCT  "g" [format %8.4g $shear]
		DWLocalSetValue $GDN $STRUCT  "mat_prop" $matprop

		if {$laminates != ""} {
		    set aux [base64::encode -maxlen 100000 $laminates]
		    set aux [join [split $aux ] " " ]
		    DWLocalSetValue $GDN $STRUCT  "laminates" $aux
		} else {
		    DWLocalSetValue $GDN $STRUCT  "laminates" 0
		}
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
	    } else {
		DWLocalSetValue $GDN $STRUCT  "win_info" $names
		DWLocalSetValue $GDN $STRUCT  "Units" $units
		                                
		if {$laminates != ""} {
		    set aux [base64::encode -maxlen 100000 $laminates]
		    set aux [join [split $aux ] " " ]
		    DWLocalSetValue $GDN $STRUCT  "laminates" $aux
		} else {
		    DWLocalSetValue $GDN $STRUCT  "laminates" 0
		}
		
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
		
	    }
	    return ""
	}
    }
}


#         "CLOSE" {
#             set height ""
#             set bottomwidth ""
#             set topwidth ""
#             set basewidth ""
#             set lamlist ""
#             set laminatesList ""
#             set area ""
#             set iyy ""
#             set izz ""
#             set j ""
#             set shear ""
#             set finalyoung ""
#             set finalweight ""
#             set layerlist ""
#             set laminates ""
# 
#             set heightlam ""
#             set toplamin ""
#             set bottomlam ""
#             return ""        
#         }   

 
proc compStiff::create_window { wp dict dict_units } {
    variable units
    variable matlist
    variable lamlist
    variable mathick
    variable laminates
    variable matprop

    variable f

    package require dialogwin
    destroy $wp.steelsections
    set w [dialogwin_snit $wp.steelsections -title [_ "Composite naval stiffeners"]]
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
    foreach i [list win_info units matlist lamlist mathick laminates] {
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
#         dict set dict "laminate_properties" $values
	dict set dict "win_info" [infonames]
#         dict set dict "numero_de_capas" [lindex $values 0]
	dict set dict "units" $units
	dict set dict "area" [lindex $matprop 0]
	set weight [lindex $matprop 6]
	dict set dict "weight" [lindex $matprop 6]
	dict set dict "iyy" [lindex $matprop 1]
	dict set dict "izz" [lindex $matprop 2]
	dict set dict "e" [lindex $matprop 5]
	dict set dict "j" [lindex $matprop 4]
	dict set dict "g" [lindex $matprop 3]

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

 
proc compStiff::InitWindow { top }  {
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
    variable cansection
    variable lamname
    variable elaminate
    variable laminatestable

    variable cbtoplamin
    variable cbbottomlam
    variable cbheightlam
   

    ##############################################################
    #creating the notebook to organize the information           #
    ##############################################################
    set nb [NoteBook $top.notebook -height 300 -width 550 ]
    set page2 [$nb insert end page2 -text [= "Materials"]]
    set page1 [$nb insert end page1 -text [= "Laminate"]]
    set page3 [$nb insert end page3 -text [= "Section"]]
    $nb raise page2
    grid $nb -column 0 -row 0 -sticky nsew
    grid columnconf $page1 0 -weight 1
    grid rowconf $page1 0 -weight 1
    grid columnconf $page2 0 -weight 1
    grid rowconf $page2 0 -weight 1
    grid columnconf $page3 0 -weight 1
    grid rowconf $page3 0 -weight 1
    ##############################################################
    #creating the page for materials information "Materials"     #
    ##############################################################
   
    set table ""
    set pw [PanedWindow $page2.pw -side left ]
    set pane1 [$pw add -weight 0]


    set title1 [TitleFrame $pane1.data -relief groove -bd 2 -ipad 6 \
	    -text [= "Data Entry"] -side left]
    set f1 [$title1 getframe]
    set bgcolor [$f1 cget -background]

    # changed the DisabledBackground to be an option so as to work with tk8.3
    option add *Entry*DisabledBackground $bgcolor
    set lunitsmat [label $f1.lunitsmat -text [= Units] -justify left]
    set cbunitsmat [ComboBox $f1.cbunitsmat -textvariable compStiff::units -editable no \
	    -justify left -values [list N-m-kg N-cm-kg N-mm-kg Kp-cm-utm] -width 5]
    set command "compStiff::unitsproc ;#"
    trace variable compStiff::units w $command
    bind $cbunitsmat <Destroy> [list trace vdelete compStiff::units w $command]
    set ldatatitle [label $f1.ldatatitle -text [= "Name"] -justify left ]
    set edatatitle [entry $f1.edatatitle -textvariable compStiff::title -width 8 \
	    -justify left  -bd 2 -relief sunken -bg white ] 
    bind $top <<fiber-resin>> "+ $edatatitle configure -state disabled "
    bind $top <<normal>> "+ $edatatitle configure -state normal "
    set lthick [label $f1.ldatat -text [= "Thickness"] -justify left ]
    set ethick [entry $f1.edatat -textvariable compStiff::t_mat -width 4 \
	    -justify left -bd 2 -relief sunken -validate focusout \
	    -vcmd {string is double %P} -invcmd { WarnWin [= "Entry is not a number"]} \
	    -bg white ]
    bind $top <<fiber-resin>> "+ $ethick configure -state disabled "
    bind $top <<normal>> "+ $ethick configure -state normal "
    set lunitthick [label $f1.lunitthick -textvariable compStiff::unit1 -width 7]
    set ldatae1 [label $f1.ldatae1 -text [= E1] -justify left]
    set edatae1 [entry $f1.edatae1 -textvariable compStiff::e1 -width 12 \
	    -justify left -bd 2 -relief sunken]
    bind $top <<fiber-resin>> "+ $edatae1 configure -state disabled "
    bind $top <<normal>> "+ $edatae1 configure -state normal "
    set lunite1 [label $f1.lunite1 -textvariable compStiff::unit2 -width 7]
    set ldatae2 [label $f1.ldatae2 -text [= E2] -justify left]
    set edatae2 [entry $f1.edatae2 -textvariable compStiff::e2 -width 12 \
	    -justify left -bd 2 -relief sunken]
    bind $top <<fiber-resin>> "+ $edatae2 configure -state disabled "
    bind $top <<normal>> "+ $edatae2 configure -state normal "
    set lunite2 [label $f1.lunite2 -textvariable compStiff::unit2 -width 7]
    set ldatanu12 [label $f1.ldatanu12 -text [= nu12] -justify left ]
    set edatanu12 [entry $f1.edatanu12 -textvariable compStiff::nu12 -width 12 \
	    -justify left -width 8 -bd 2 -relief sunken]
    bind $top <<fiber-resin>> "+ $edatanu12 configure -state disabled "
    bind $top <<normal>> "+ $edatanu12 configure -state normal "
    set ldatag12 [label $f1.ldatag12 -text [= G12] -justify left ]
    set edatag12 [entry $f1.edatag12 -textvariable compStiff::g12 -width 12 \
	    -justify left -bd 2 -relief sunken]
    bind $top <<fiber-resin>> "+ $edatag12 configure -state disabled "
    bind $top <<normal>> "+ $edatag12 configure -state normal "
    set lunitg12 [label $f1.lunitg12 -textvariable compStiff::unit2 -justify left]
    set ldatag13 [label $f1.ldatag13 -text [= G13] -justify left -width 7]
    set edatag13 [entry $f1.edatag13 -textvariable compStiff::g13 -width 12 \
	    -justify left -bd 2 -relief sunken]
    bind $top <<fiber-resin>> "+ $edatag13 configure -state disabled "
    bind $top <<normal>> "+ $edatag13 configure -state normal "
    set lunitg13 [label $f1.lunitg13 -textvariable compStiff::unit2 -justify left -width 7]
    set ldatag23 [label $f1.ldatag23 -text [= G23] -justify left ]
    set edatag23 [entry $f1.edatag23 -textvariable compStiff::g23 -width 12 \
	    -justify left -bd 2 -relief sunken]
    bind $top <<fiber-resin>> "+ $edatag23 configure -state disabled "
    bind $top <<normal>> "+ $edatag23 configure -state normal "
    set lunitg23 [label $f1.lunitg23 -textvariable compStiff::unit2 -justify left -width 7 ]
    set ldataspweight [label $f1.ldataspweight -text [= "Specific Weight"] -justify left ]
    set edataspweight [entry $f1.edataspweight -textvariable compStiff::spweight -width 12 \
	    -justify left -bd 2 -relief sunken]
    bind $top <<fiber-resin>> "+ $edataspweight configure -state disabled "
    bind $top <<normal>> "+ $edataspweight configure -state normal "
    set lunitspweight [label $f1.lunitspweight  -textvariable compStiff::spweightunit -justify left -width 7 ]

    set lType [label $f1.ldatatype -text [= "Lam. Type"] -justify left ]
    set eType [ComboBox $f1.edatatype -textvariable compStiff::lamtype -width 8 \
	    -editable no -values [list Uni Mat Roving] -validate focusout -relief sunken]

#     set eType [entry $f1.edatatype -textvariable compStiff::lamtype -width 4 \
#             -justify left -bd 2 -relief sunken -validate focusout \
#             -vcmd {string is double %P} -invcmd { WarnWin [= "Entry is not a number"]} \
#             -bg white ]
    bind $top <<fiber-resin>> "+ $eType configure -state disabled "
    bind $top <<normal>> "+ $eType configure -state normal "


    
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

    
    set pane2 [$pw add -weight 1]
    set title2 [TitleFrame $pane2.table -relief groove -bd 2 -text [= "Materials List"] \
	    -side left ]
    set f2 [$title2 getframe]
    set sw [ScrolledWindow $f2.scroll -scrollbar both ]
    set table [tablelist::tablelist $sw.table \
	    -columns [list 0 [= "Name"] 0 [= "Thick"] 0 [= "E1"] 0 [= "E2"] \
		0 [= "\u03BD12"] 0 [= "G12"] 0 [= "G23"] 0 [= "G13"] 0 [= "SpecifWeight"] 0 [= "Type"]] \
	    -height 3 -width 50 -stretch all -background white \
	    -listvariable compStiff::matlist]
    $sw setwidget $table
    bind [$table bodypath] <Double-ButtonPress-1> [list compStiff::edit \
	    $table $top]
    set bbox [ButtonBox $f2.bbox1 -spacing 0 -padx 1 -pady 1 -homogeneous 0 ]
    $bbox add -image $compStiff::edit -width 24 \
	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	-helptext [= "Edit material"] -command [list compStiff::edit $table $top]
    $bbox add -image $compStiff::delete -width 24 \
	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	-helptext [= "Delete material"] -command "compStiff::delete $table $edatatitle"
    set buttonfr [frame $pane1.bfr]
    set badd [button $buttonfr.badd -text [= Add]  -width 10 -underline 0 \
	    -command "compStiff::add $table $edatae1 $edatatitle $top" ]
    bind $badd <ButtonRelease> {
	set compStiff::values [list "$compStiff::e1" "$compStiff::e2" "$compStiff::g13" "$compStiff::g12" "$compStiff::g23" \
		"$compStiff::nu12" "$compStiff::spweight"]
	set compStiff::names [list E1 E2 G13 G12 G23 nu12 SpecifWeight]
	
	    compStiff::errorcntrl $compStiff::values $compStiff::names $compStiff::can
    }
    set bnew [button $buttonfr.bnew -text New  -width 10 -underline 0 \
	    -command "compStiff::add $table $edatae1 $edatatitle $top" ]
    bind $bnew <ButtonRelease> {
	set compStiff::values [list "$compStiff::e1" "$compStiff::e2" "$compStiff::g13" "$compStiff::g12" "$compStiff::g23" \
		"$compStiff::nu12" "$compStiff::spweight"]
	set compStiff::names [list E1 E2 G13 G12 G23 nu12 SpecifWeight]
	compStiff::errorcntrl $compStiff::values $compStiff::names $compStiff::can
	set compStiff::index -1
    } 
    set bmodify [button $buttonfr.modify -text [= Modify]  -width 10 -underline 0 \
	    -command "compStiff::add $table $edatae1 $edatatitle $top" ]
    bind $bmodify <ButtonRelease> {
	set compStiff::values [list "$compStiff::e1" "$compStiff::e2" "$compStiff::g13" "$compStiff::g12" "$compStiff::g23" \
		"$compStiff::nu12" "$compStiff::spweight"]
	set compStiff::names [list E1 E2 G13 G12 G23 nu12 SpecifWeight]
	compStiff::errorcntrl $compStiff::values $compStiff::names $compStiff::can
    } 
    set bcancel [button $buttonfr.cancel -text [= Cancel]  -width 10 -underline 0 \
	    -command "compStiff::cancel $table $edatae1 $top"]
    set bfr [button $f1.bfr -text [= Fiber-Resin] -width 10 -underline 0 \
	    -command "compStiff::fiber-resin $top" ]
    
    set bedit [button $f1.bedit -text [= Edit-Data] -width 10 -underline 0 \
	    -command [list compStiff::Edit-Data $table $top] ]
     
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
    
    set titlelam0 [TitleFrame $pane1.titlelam0 -relief groove -bd 2 \
	    -text [= "Laminate"] -side left]
    set flam0 [$titlelam0 getframe]
    set llaminate [label $flam0.llaminate -text [= "Laminate Name"] -justify left ]
    set elaminate [entry $flam0.cblaminate -textvariable compStiff::lamname \
	    -justify left -bd 2 -relief sunken ]
	
    set title1 [TitleFrame $pane1.data -relief groove -bd 2 \
	    -text [= "Layers Data Entry"] -side left]
    set f1 [$title1 getframe]
#     set lunitslam [label $f1.lunitslam -text [= Units] -justify left]
#     set cbunitslam [ComboBox $f1.cbunitslam -textvariable compStiff::units -editable no \
#             -justify left -values [list N-m-kg N-cm-kg N-mm-kg Kp-cm-utm]]
#     set command "compStiff::unitsproc ;#"
#     trace variable compStiff::units w $command
#     bind $cbunitslam <Destroy> [list trace vdelete compStiff::units w $command]
    
    set edataang [entry $f1.edataang -textvariable compStiff::ang -width 4 \
	    -justify left -bd 2 -relief sunken -state normal -bg white]
    set unitang [label $f1.unitang -text degrees -justify left]
    set bgcolor [$f1 cget -background]
    
    set useangle 0
    set check [checkbutton $f1.chdata -variable compStiff::useangle \
	    -takefocus 0 -text [= "Fiber Angle"] -activebackground white]
    #     Composite::update $edataang $bgcolor
    
    set ldatamat [label $f1.ldatamat -text [= "Material"] -justify left ]
    set cbdatamat [ComboBox $f1.cbdatamat -textvariable compStiff::matname  \
	    -values "" -editable no] 
    $cbdatamat configure -text "" 
    
    set ldataspin [label $f1.ldataspin -text [= "Number of layers"] -justify left]
    set edatat [entry $f1.edatat -textvariable compStiff::t -width 4 \
	    -justify left -bd 2 -relief sunken -state disabled]
    set lunithick [label $f1.lunithick -textvariable compStiff::unit1 -justify left -width 5 ]
   

########################################
## secuencias de laminados #############
    
    set lamseq [label $f1.lamseq -text [= "Sequence"] -justify left ]
    set cbseq [ComboBox $f1.cbseq -textvariable compStiff::seq -editable no \
	    -values [list [= "User"] \[45,-45\]s \[45,-45\] \[0,45,-45\] \[0,90\]] \
	    -helptext [= "Fixed laminate sequence"] ]
    $cbseq configure -text "" 
    
    set spin [SpinBox $f1.spdata -textvariable compStiff::numlayers \
	    -range "1 1000 1" -width 2 -takefocus 1 ]
    $spin configure -text 1  

    set flag 1    
    set command "compStiff::seqlaminate [list $cbseq $bgcolor $ldataspin $check $edataang $spin];#"
    trace variable compStiff::seq w $command
    bind $f1.cbseq <Destroy> [list trace vdelete compStiff::seq w $command]
    
    set command "compStiff::update [list $edataang $bgcolor $flag];#"
    trace variable compStiff::useangle w $command
    bind $f1.chdata <Destroy> [list trace vdelete compStiff::useangle w $command]
    
    set command "compStiff::frmathick [list $edatat $lamseq $cbseq $ldataspin $cbseq $check $spin];#"
    trace variable compStiff::matname w $command
    bind $f1.cbdatamat <Destroy> [list trace vdelete compStiff::matname w $command]
     
    set ldatat [label $f1.ldatat -text [= "Thickness"] -justify left ]
    
    set modifycmd "compStiff::thickCalc $edatat $spin;#"
    trace variable compStiff::numlayers w $modifycmd
    bind $spin <Destroy> [list trace vdelete compStiff::numlayers w $modifycmd]
    
    $check configure -state disabled -activebackground grey
    $edataang configure -state disabled

    grid $pw  -sticky nsew 
    grid columnconf $pw  1 -weight 1
    grid rowconf $pw 0 -weight 1
    grid columnconf $pane1  0 -weight 1
    grid rowconf $pane1 1 -weight 0
    grid rowconf $pane1 0 -weight 0
    grid rowconf $pane1 2 -weight 1
    
    grid $titlelam0 -column 0 -row 0 -padx 2 -pady 2 -sticky nsew
    grid rowconf $flam0 1 -weight 0
    grid columnconf $flam0  2 -weight 1
    grid $llaminate -column 0 -row 0 -sticky w
    grid $elaminate -column 1 -row 0 -columnspan 1 -sticky we     

    grid $title1 -column 0 -row 1 -padx 2 -pady 2 -sticky nsew
    grid rowconf $f1 5 -weight 0
    grid columnconf $f1 3 -weight 1   
    
#     grid $lunitslam -column 0 -row 0 -sticky nw 
#     grid $cbunitslam -column 1 -row 0 -sticky nsew -columnspan 3 -pady 3
    grid $ldatamat -column 0 -row 0 -sticky nw
    grid $cbdatamat -column 1 -row 0 -columnspan 3 -sticky nsew
    
    grid $lamseq -column 0 -row 1 -sticky nw
    grid $cbseq -column 1 -row 1 -columnspan 3 -sticky nsew
    
    grid $ldataspin -column 0 -row 2 -sticky nw
    grid $spin -column 1 -row 2 -sticky nswe
    grid $ldatat -column 2 -row 2 -sticky nw
    grid $edatat -column 3 -row 2 -sticky nswe
    grid $lunithick -column 4 -row 2 -sticky nw
    grid $check -column 0 -row 3 -sticky nw
    grid $edataang -column 1 -row 3 -sticky nw
    grid $unitang -column 2 -row 3 -sticky nw
    
	
    set pane2 [$pw add -weight 1]
    set title2 [TitleFrame $pane2.table -relief groove -bd 2 -text [= "Laminate Composition"] \
	    -side left ]
    set f2 [$title2 getframe]
    set sw [ScrolledWindow $f2.scroll -scrollbar both ]
    set lamtable [tablelist::tablelist $sw.table \
	    -columns [list 0 [= "Material"] 0 [= "Angle"] 0 [= "Thick"] 0 [= "Layers"]] \
	    -height 40 -width 30 -stretch all -background white \
	    -listvariable compStiff::lamlist -selectmode extended]
    $sw setwidget $lamtable
    set bbox [ButtonBox $f2.bbox1 -spacing 0 -padx 1 -pady 1 -homogeneous 0 ]
    $bbox add -image $compStiff::edit -width 24 \
	    -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	    -helptext [= "Edit layer"] -command "compStiff::lamedit $lamtable"
    $bbox add -image $compStiff::delete -width 24 \
	    -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	    -helptext [= "Delete layer"] -command "compStiff::lamdelete $lamtable $cbdatamat"
    
    set lamadd [button $f1.badd -text [= Add]  -underline 1 -width 10 \
	    -command "compStiff::lamadd $lamtable $cbdatamat"]
     bind $lamadd <ButtonRelease> {
	if { $compStiff::matname == "" } {
	    WarnWin [= "Select a material"]
	    catch { vwait $compStiff::matname }
	}
	set compStiff::values [list "$compStiff::t"]
	set compStiff::names Thickness
	compStiff::errorcntrl $compStiff::values $compStiff::names $compStiff::can
	if { $compStiff::useangle == 1 } { 
	    set compStiff::values [list "$compStiff::ang"]
	    set compStiff::names Angle
	    compStiff::errorcntrl $compStiff::values $compStiff::names $compStiff::can
	}
    }
    

#### distintos laminadosss
    set titlelam20 [TitleFrame $pane2.table0 -relief groove -bd 2 -text [= "Laminates"] \
	    -side left ]
    set flam20 [$titlelam20 getframe]
    set swlam0 [ScrolledWindow $flam20.scrolllam0 -scrollbar both ]
    set laminatestable [tablelist::tablelist $swlam0.table01 \
	    -columns [list  0 [= "Laminate"] 0 [= "Thickness"] ] \
	    -height 5 -width 30 -stretch all -background white \
	    -listvariable compStiff::laminates]
    $swlam0 setwidget $laminatestable
    set bbox0 [ButtonBox $flam20.bbox0 -spacing 0 -padx 1 -pady 1 -homogeneous 0 ]
#     $bbox0 add -image $compStiff::edit -width 24 \
#             -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
#             -helptext [= "Edit layer"] -command "compStiff::laminatesedit $laminatestable"
    $bbox0 add -image $compStiff::delete -width 24 \
	    -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	    -helptext [= "Delete laminate"] -command "compStiff::laminatesdelete $laminatestable $elaminate"

    set new [button $flam0.bnew0 -text [= New]  -underline 0 -width 5 \
	    -command "compStiff::new $lamtable $laminatestable $elaminate"]
#     bind $new <ButtonRelease> {  
#         if { ! [info exists compStiff::lamprop($compStiff::lamname)] } {
#             WarnWin [= "Enter some layers to create a laminate shell"] $compStiff::f
#             #tk_messageBox -message "Enter some layers to create a lamiante shell"  -type ok
#         }
#     }
######################

    set lamclear [button $f1.bclear -text [= "Clear All"] -width 10 -underline 2 \
	    -command "compStiff::lamclear $lamtable $laminatestable"]
    set lammodify [button $f1.bmodify -text [= Modify]  -width 10 -underline 1 \
	    -command "compStiff::lamadd $lamtable $cbdatamat"]
    set lamcancel [button $f1.bcancel -text [= Cancel]  -width 10 -underline 2 \
	    -command "compStiff::lamcancel $lamtable $cbdatamat"] 
   


    grid $lamadd -column 0 -row 4 -padx 2 -pady 6
    grid $lamclear -column 2 -row 4 -columnspan 2 -pady 6 -sticky nw
    grid $lammodify -column 0 -row 4 -columnspan 2 -pady 6 -sticky nw
    grid $lamcancel -column 2 -row 4 -columnspan 2 -pady 6 -sticky nw
    
    grid remove $lammodify
    grid remove $lamcancel
    bind $top <Alt-KeyPress-d> "tkButtonInvoke $lamadd"                
    bind $top <Alt-KeyPress-o> "tkButtonInvoke $lammodify"
    bind $top <Alt-KeyPress-n> "tkButtonInvoke $lamcancel"
    bind $top <Alt-KeyPress-e> "tkButtonInvoke $lamclear"          
    
    bind [$lamtable bodypath] <Double-ButtonPress-1> { compStiff::lamedit $compStiff::lamtable }
    bind [$lamtable bodypath] <ButtonPress-3> "compStiff::popupmenu $lamtable %X %Y" 
    grid columnconf $pane2  0 -weight 1
    grid rowconf $pane2 0 -weight 1
    grid columnconf $pane2  0 -weight 1
    
    grid $title2 -column 0 -row 0 -padx 2 -pady 2 -sticky nsew 
    grid columnconf $f2  0 -weight 1
    grid rowconf $f2 0 -weight 1
    
    grid $titlelam20 -column 0 -row 1 -padx 2 -pady 2 -sticky nsew 
    grid columnconf $flam20  0 -weight 1
    grid rowconf $flam20 0 -weight 1


    grid $sw -column 0 -row 0 -sticky nsew
    grid $bbox -column 0 -row 1 -sticky nw
    grid $swlam0 -column 0 -row 0 -sticky nsew
    grid $bbox0 -column 0 -row 1 -sticky nw

    grid $new -column 2 -row 0 -padx 4
    bind $top <Alt-KeyPress-n> "tkButtonInvoke $new" 

    ##############################################################
    #creating canvas                                             #
    ##############################################################
    set title3 [TitleFrame $pane1.canvas -relief groove -bd 2 -text [= "Visual Description"] \
	    -side left ]
    set f3 [$title3 getframe]
    set can [canvas $f3.can -relief flat -bd 1 -width 100 -height 50 -bg white \
	    -highlightbackground black]
    grid $title3 -column 0 -row 2 -sticky nsew
    grid columnconf $f3 0 -weight 1
    grid rowconf $f3 0 -weight 1
    grid $can -column 0 -row 0 -sticky nsew
    bind $can <Configure> "compStiff::refresh $can"

   ##############################################################
    #creating the page for information "Section"     #
    ##############################################################
    set pwsection [PanedWindow $page3.pwsection -side top ]
    set panesection1 [$pwsection add -weight 1]
    set titlesection1 [TitleFrame $panesection1.draw -relief groove -bd 2 \
	    -text [= "Visual Description"] -side left]
    set fsection1 [$titlesection1 getframe]
    
    set cansection [canvas $fsection1.can -relief raised -bd 2 -width 100 -height 120 -bg white]
    set panesection2 [$pwsection add -weight 0]
    set titlesection2 [TitleFrame $panesection2.prop -relief groove -bd 2 \
	    -text [= "Section Properties"] -side left]
    set fsection2 [$titlesection2 getframe]
    set lunitsect [label $fsection2.lunitsect -text [= Units] -justify left]
    set cbunitsect [ComboBox $fsection2.cbunitsect -textvariable compStiff::units -editable no \
	    -justify left -values [list N-m-kg N-cm-kg N-mm-kg Kp-cm-utm] -width 5]
    set command "compStiff::unitsproc ;#"
    trace variable compStiff::units w $command
    bind $cbunitsect <Destroy> [list trace vdelete compStiff::units w $command]

    set ltopwidth [label $fsection2.ltopwidth -text [= "Top Width"] -justify right]
    set etopwidth [entry $fsection2.etopwidth -textvariable compStiff::topwidth -bd 2 \
	    -relief sunken -width 6]
    set lunittop [label $fsection2.lunittop -textvariable compStiff::unit1 -justify left]
    set ltoplamin [label $fsection2.ltoplamin -text [= "Laminate"] -justify right]
    set cbtoplamin [ComboBox $fsection2.cbtoplamin -textvariable compStiff::toplamin  \
	    -values "" -editable no -width 6]

    set lbottomwidth [label $fsection2.lbottomwidth -text [= "Bottom Width"] -justify right]
    set ebottomwidth [entry $fsection2.ebottomwidth -textvariable compStiff::bottomwidth \
	    -bd 2 -relief sunken -width 6]
    set lunitbottom [label $fsection2.lunitbottom -textvariable compStiff::unit1 -justify left]
    set lbottomlam [label $fsection2.lbottomlam -text [= "Laminate"] -justify right]
    set cbbottomlam [ComboBox $fsection2.cbbottomlam -textvariable compStiff::bottomlam  \
	    -values "" -editable no -width 6]

    set lheight [label $fsection2.lheightc -text [= "Height"] -justify right]
    set eheight [entry $fsection2.eheightc -textvariable compStiff::height -bd 2 -relief sunken \
	    -width 6]
    set lunitheight [label $fsection2.lunitheight -textvariable compStiff::unit1 -justify left]
    set lheightlam [label $fsection2.lheightlam -text [= "Laminate"] -justify right]
    set cbheightlam [ComboBox $fsection2.cbheightlam -textvariable compStiff::heightlam  \
	    -values "" -editable no -width 6]

    set lbasewidth [label $fsection2.lbasewidth -text [= "Base Width"] -justify right]
    set ebasewidth [entry $fsection2.ebasewidth -textvariable compStiff::basewidth -bd 2 -relief sunken \
	    -width 6]
    set lunitbase [label $fsection2.lunitbase -textvariable compStiff::unit1 -justify left]

    set titlesection21 [ TitleFrame $panesection2.shear -relief groove -bd 2 \
	    -text [= "Core Properties"] -side left -ipad 8]
    set fsection21 [$titlesection21 getframe]
    set lshear [ label $fsection21.lshear -text [= "Shear Modulus"] -justify left]
    set eshear [ Entry $fsection21.eshear -textvariable compStiff::shear -bd 2 -relief sunken \
	    -width 6 ]
    set lunitshear [label $fsection21.lunitshear -textvariable compStiff::unit2 -justify left]


    set titlesection3 [TitleFrame $panesection2.inertia -relief groove -bd 2 \
	    -text [= "Section Properties"] -side left -ipad 8]
    set fsection3 [$titlesection3 getframe]
    set bcalculate [button $fsection3.bcalculatec -text [= Calculate] -underline 0 \
		-command "compStiff::trap_sol_cal"]
    
    bind $bcalculate <ButtonRelease> {
	set compStiff::values2 "6 $compStiff::topwidth $compStiff::bottomwidth $compStiff::height \
	    $compStiff::basewidth $compStiff::shear "  
	compStiff::errorcntrl2 $compStiff::values2
    }
    
    set larea [label $fsection3.larea -text [= "Area"] -justify left]
    set earea [Entry $fsection3.earea -textvariable compStiff::area -editable no -relief groove \
	    -bd 2 -bg lightyellow -justify right]
    set lunitarea [label $fsection3.lunitarea -textvariable compStiff::unit4 -justify left]

    set lizz [label $fsection3.lizz -text [= "Izz"] -justify left]
    set eizz [Entry $fsection3.eizz -textvariable compStiff::izz -editable no -relief groove -bd 2 \
	    -bg lightyellow -justify right]
    set lunitizz [label $fsection3.lunitizz -textvariable compStiff::unit5 -justify left]


    set liyy [label $fsection3.liyy -text [= "Iyy"] -justify left]
    set eiyy [Entry $fsection3.eiyy -textvariable compStiff::iyy -editable no -relief groove -bd 2 \
	    -bg lightyellow -justify right]
    set lunitiyy [label $fsection3.lunitiyy -textvariable compStiff::unit5 -justify left]
    

    set lw [label $fsection3.lw -text [= "Spec. Weight"] -justify left]
    set ew [Entry $fsection3.ew -textvariable compStiff::finalweight -editable no -relief groove -bd 2  \
	    -bg lightyellow -justify right]
    set lunitew [label $fsection3.lunitew -textvariable compStiff::spweightunit -justify left]

    set letot [label $fsection3.letot -text [= "E"] -justify left]
    set eetot [Entry $fsection3.eetot -textvariable compStiff::finalyoung -editable no -relief groove -bd 2  \
	    -bg lightyellow -justify right]
    set lunitetot [label $fsection3.lunitetot -textvariable compStiff::unit2 -justify left]

    set lJ [label $fsection3.lJ -text [= "J"] -justify left]
    set eJ [Entry $fsection3.eJ -textvariable compStiff::j -editable no -relief groove -bd 2  \
	    -bg lightyellow -justify right]
    set luniteJ [label $fsection3.luniteJ -textvariable compStiff::unit5 -justify left]

    
    grid $pwsection -column 0 -row 0 -sticky nsew
    grid columnconf $panesection1 0 -weight 1
    grid rowconf $panesection1 0 -weight 1
    grid $titlesection1 -column 0 -row 0 -sticky nsew 
    grid columnconf $fsection1 0 -weight 1
    grid rowconf $fsection1 0 -weight 1
    grid $cansection -column 0 -row 0 -sticky nsew
    grid columnconf $panesection2 0 -weight 1
    grid rowconf $panesection2 2 -weight 1
    grid $titlesection2 -column 0 -row 0 -sticky nsew
    grid columnconf $fsection2 1 -weight 1
    grid rowconf $fsection2 6 -weight 1
    grid $lunitsect -column 0 -row 0 -sticky nw
    grid $cbunitsect -column 1 -row 0 -sticky we -columnspan 4

    grid $ltopwidth -column 0 -row 1 -sticky nw
    grid $etopwidth -column 1 -row 1 -sticky we
    grid $lunittop -column 2 -row 1 -sticky nw
    grid $ltoplamin -column 3 -row 1 -sticky nw
    grid $cbtoplamin -column 4 -row 1 -sticky we

    grid $lbottomwidth -column 0 -row 2 -sticky nw
    grid $ebottomwidth -column 1 -row 2 -sticky we
    grid $lunitbottom -column 2 -row 2 -sticky nw
    grid $lbottomlam -column 3 -row 2 -sticky nw
    grid $cbbottomlam -column 4 -row 2 -sticky we

    grid $lheight -column 0 -row 3 -sticky nw
    grid $eheight -column 1 -row 3 -sticky we
    grid $lunitheight -column 2 -row 3 -sticky nw
    grid $lheightlam -column 3 -row 3 -sticky nw
    grid $cbheightlam -column 4 -row 3 -sticky we

    grid $lbasewidth -column 0 -row 4 -sticky nw
    grid $ebasewidth -column 1 -row 4 -sticky nsew
    grid $lunitbase -column 2 -row 4 -sticky nw

    grid $titlesection21 -column 0 -row 1 -sticky nsew
    grid columnconf $fsection21 1 -weight 1
    grid $lshear -column 0 -row 0 -sticky ew
    grid $eshear -column 1 -row 0 -sticky ew 
    grid $lunitshear -column 2 -row 0 -sticky nw
   
    grid $titlesection3 -column 0 -row 2 -sticky nsew
    grid columnconf $fsection3 1 -weight 1
    grid $bcalculate -column 1 -row 0 -pady 4 -columnspan 2
    
    grid $larea -column 0 -row 1 -sticky ew -pady 2
    grid $earea -column 1 -row 1 -sticky ew -pady 2
    grid $lunitarea -column 2 -row 1 -sticky ew -pady 2
    
    grid $liyy -column 0 -row 2 -sticky ew -pady 2
    grid $eiyy -column 1 -row 2 -sticky ew -pady 2
    grid $lunitiyy -column 2 -row 2 -sticky ew -pady 2

    grid $lizz -column 0 -row 3 -sticky ew -pady 2
    grid $eizz -column 1 -row 3 -sticky ew -pady 2
    grid $lunitizz -column 2 -row 3 -sticky ew -pady 2

    grid $lw -column 0 -row 4 -sticky ew -pady 2
    grid $ew -column 1 -row 4 -sticky ew -pady 2
    grid $lunitew -column 2 -row 4 -sticky ew -pady 2

    grid $letot -column 0 -row 5 -sticky ew -pady 2
    grid $eetot -column 1 -row 5 -sticky ew -pady 2
    grid $lunitetot -column 2 -row 5 -sticky ew -pady 2
    
    grid $lJ -column 0 -row 6 -sticky ew -pady 2
    grid $eJ -column 1 -row 6 -sticky ew -pady 2
    grid $luniteJ -column 2 -row 6 -sticky ew -pady 2

    $nb compute_size
    bind $cansection <Configure> "compStiff::refreshtop"
    bind $etopwidth <KeyPress-Return> "focus $ebottomwidth"
    bind $ebottomwidth <KeyPress-Return> "focus $eheight"
    bind $eheight <KeyPress-Return> "tkButtonInvoke $bcalculate"

} 


##############################################################
#              Añadir un laminado nuevo              #
##############################################################
proc compStiff::new {lamtable laminatestable elaminate} {
#     variable numlayers  
    variable lamindex
#     variable canlam
#     variable layername
    variable matprop   
#     variable lamprop
    variable lamname 
#     variable comprop
    variable lamlist
    variable cbtoplamin
    variable cbbottomlam
    variable cbheightlam
    variable laminatesList
    variable matlist
variable younglist
variable younglist2
variable weightlist
variable glist
variable nulist
variable heighlist

    set younglist ""
    set weightlist "" 
    set younglist2 ""
    set glist ""
    set nulist ""
    set heightlist ""

    variable laminates

#     variable f

    set laminateAux ""
    set lamtableItems [$lamtable index end]
    set layersList [$lamtable get 0 $lamtableItems] 
    
    if {$lamname == ""} {
	WarnWin [= "Please enter a name for the laminate"] $compStiff::f
	return ""
    }
    if { $layersList == "" } {
	WarnWin [= "Enter some layers to create a laminate shell"] $compStiff::f
	return ""
    }
    if {$laminatesList != ""} {
	foreach laminatillo $laminatesList {
	    if {[lindex $laminatillo 0] == $lamname} {
		WarnWin [= "There is a laminate with the same name already. \nPlease choose another name"] $compStiff::f
		return "" 
	    } 
	}
    }
    
    set thickLamin 0.0
    foreach layers $layersList {
	set thickLamin [expr $thickLamin + [lindex $layers 2]] 
	lappend heightlist [lindex $layers 2]
#         set thickEachLam [expr [lindex $layers 2]/[lindex $layers 3]]
	foreach mat $matlist {
	    if { [lindex $layers 0] == "[lindex $mat 0]" } {
		lappend younglist [lindex $mat 2]
		lappend weightlist [lindex $mat 8]
		lappend younglist2 [lindex $mat 3]
		lappend glist [lindex $mat 5]
		lappend nulist [lindex $mat 4]

#                 for { set i 1 } { $i <= [lindex $layers 3] } { incr i } {
#                     lappend heightlist $thickEachLam    
#                     lappend younglist [lindex $mat 2]
#                     lappend weightlist [lindex $mat 8]
#                     lappend younglist2 [lindex $mat 3]
#                     lappend glist [lindex $mat 5]
#                     lappend nulist [lindex $mat 4]
#                 }

		break
	    }
	}
    }
    set thickLamin [format %.5g $thickLamin]
    lappend laminateAux $lamname $thickLamin $younglist $younglist2 \
	$weightlist $glist $nulist $heightlist
    lappend laminatesList $laminateAux
   
    set lamToInsert [list $lamname $thickLamin ]
    $laminatestable insert end $lamToInsert 
    $laminatestable see end
   
 
    set compnames ""
    set ipos1 0
    while { [lindex $laminates $ipos1] != "" } {
	set aux [lindex $laminates $ipos1]
	lappend compnames [lindex $aux 0]
	set ipos1 [ expr $ipos1+1 ]
    }
    

    $cbtoplamin configure -values $compnames
    $cbbottomlam configure -values $compnames
    $cbheightlam configure -values $compnames
    

}


##############################################################
#              establecer secuencia de laminado              #
##############################################################               
proc compStiff::seqlaminate { cbseq bgcolor ldataspin check edataang spin} {
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

proc compStiff::thickCalc { edatat spin } {
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
proc compStiff::failureupdate { entry1 entry2 entry3 entry4 entry5 bgcolor } {
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
proc compStiff::updatestress { } {
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
proc compStiff::add { table entry entrytitle parent} {
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
		catch { grid remove $compStiff::bmodify}
		return
	    }
	}
    }
    
      
# ###################################################
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
#         if { $typel != " " } {
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
	if {$flagF_R == 1} { 
	    set lamtype $typel 
	    $table insert end "[list $title "$t" [format %.8g $e1] \
		    [format %.8g $e2] [format %4.3f $nu12] [format %.8g $g12] \
		    [format %.8g $g23] [format %.8g $g13] [format %.8g $spweight] "$typel"]"
	} else {
	    set typel $lamtype
	    $table insert end "[list $title "$t_mat" [format %.8g $e1] \
		    [format %.8g $e2] [format %4.3f $nu12] [format %.8g $g12] \
		    [format %.8g $g23] [format %.8g $g13] [format %.8g $spweight] "$lamtype"]"
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
	set spweight ""
	set flagF_R 0
	catch { grid $compStiff::badd }
	catch { grid remove $compStiff::bmodify }
	catch { grid remove $compStiff::bcancel }     
	catch { grid remove $compStiff::bnew }
    } else {

#         foreach mat $matlist {
#             if {$title == "[lindex $mat 0]"} {
#                 set typel [lindex $mat 9]
#                 break
#             }
#         }

	$table delete $index 
	
	$table insert $index "[list $title "$t_mat" [format %.8g $e1] \
		[format %.8g $e2] [format %4.3f $nu12] [format %.8g $g12] \
		[format %.8g $g23] [format %.8g $g13] [format %.8g $spweight] $lamtype]"
	
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
	catch {  grid $compStiff::badd }
	catch {  grid remove $compStiff::bmodify }
	catch {  grid remove $compStiff::bcancel }
	catch {  grid remove $compStiff::bnew } 
	
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
    catch { grid remove $compStiff::bedit }

}                
##############################################################
#     Edit row  intro tablelist of materials               #
##############################################################
proc compStiff::edit { table parent } {
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
	set typel [lindex $entry 9]
	set lamtype $typel
	
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
	catch { grid $compStiff::bmodify }
	catch { grid $compStiff::bcancel }
	catch { grid $compStiff::bnew }
	catch { grid remove $compStiff::badd }
	
	if { $compStiff::isfiberesin == 1 } {
	   grid $compStiff::bedit
	} else {
	   catch { grid remove $compStiff::bedit }
	}

    }
} 
##############################################################
#     Cancel edit process intro tablelist of materials       #
##############################################################
proc compStiff::cancel { table entry parent } {
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
    set spweight ""
    set index -1
    catch { grid $compStiff::badd }
    catch { grid remove $compStiff::bmodify }
    catch { grid remove $compStiff::bcancel }     
    catch { grid remove $compStiff::bnew }
    focus $entry
    event generate $parent <<normal>>
}
##############################################################
#   Delete  a row  intro tablelist of materials              #
##############################################################
proc compStiff::delete { table widget} {
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
    eval [compStiff::refresh $can ]
    focus $widget
    
    $table see end
    set ID [llength $matlist]
    incr ID
    set title "mat $ID"
    set currenttitle $title
    set title ""

}
##############################################################
#           Delete a row intro tablelist of laminate         #
##############################################################
proc compStiff::lamdelete { table widget} {
    variable can
    variable cbdatamat
    variable matlist
    variable heightlist
    variable younglist
    variable weightlist

    set indexs "" 
    for { set i [expr [llength [$table curselection ]]-1] } { $i >=0 } { incr i -1} {
	lappend indexs [ lindex [$table curselection ] $i]
	}
    foreach index $indexs {
	$table delete $index
    }

#     foreach index $indexs {
#         $table delete $index
#         set heightlist [lreplace $heightlist $index $index] 
#         set younglist [lreplace $younglist $index $index] 
#         set weightlist [lreplace $weightlist $index $index] 
#     }   

    set matnames ""
    set ipos1 0
    while { [lindex $matlist $ipos1] != "" } {
	set aux [lindex $matlist $ipos1]
	lappend matnames [lindex $aux 0]
	set ipos1 [ expr $ipos1+1 ]
    }
    $cbdatamat configure -values $matnames
    eval [compStiff::refresh $can ]
    catch { focus $widget }
}
##############################################################
#         Dump result intro tablelist of laminate            #
##############################################################
proc compStiff::lamadd { table entry } {
    variable t         
    variable ang         
    variable matname         
    variable numlayers  
    variable useangle
    variable lamindex
    variable can  
    variable seq
    variable lamtype
    variable sectionlam
#     variable height
    
    variable mathick
    variable matlist
    variable nlayerlist
    variable heightlist
    variable younglist
    variable weightlist
    
    variable younglist2
    variable glist
    variable nulist
    variable anglist
    

    set sectionlam $matname
#     set height 0.0
   
    
    if { $lamindex == ""} {
	set lamindex -1
    }
    if { $lamindex == -1 } {
# Las listas de propiedades las voy a crear cuando se crea cada laminado (compStiff::new)
#         foreach mat $matlist {
#             if { $matname == "[lindex $mat 0]" } {
#                 lappend younglist [lindex $mat 2]
#                 lappend weightlist [lindex $mat 8]
#                 lappend younglist2 [lindex $mat 3]
#                 lappend glist [lindex $mat 5]
#                 lappend nulist [lindex $mat 4]
#                 break
#             }
#         }
	if { $useangle == 1 } {
	    set t [expr double($t)]
	    set ang [expr double($ang)]
	    $table insert end "{$matname} [format %5.2f $ang] [format %6f $t] \
		$numlayers"
	    lappend nlayerlist $numlayers
	    lappend heightlist $t
	    lappend anglist $ang
	} elseif {($lamtype == "Roving" && $seq != [= "User"]) \
	    || ($lamtype == "Uni" && $seq != [= "User"])} {  
	    set t [expr double($t)]
	    if {$seq == "\[45,-45\]s"} {
		set ang $seq
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*4]"
		lappend nlayerlist [expr $numlayers*4]
		lappend heightlist $t
		lappend anglist $ang
	    } elseif {$seq == "\[45,-45\]"} {
		set ang $seq
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*2]"
		lappend nlayerlist [expr $numlayers*2]
		lappend heightlist $t
		lappend anglist $ang
	    } elseif {$seq == "\[0,45,-45\]"} {
		set ang $seq
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*3]"
		lappend nlayerlist [expr $numlayers*3]
		lappend heightlist $t
		lappend anglist $ang
	    } elseif {$seq == "\[0,90\]"} {
		set ang $seq
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*2]"
		lappend nlayerlist [expr $numlayers*2]
		lappend heightlist $t
		lappend anglist $ang
	    }
	} else {
	    set t [expr double($t)]
	    $table insert end "{$matname} 0.0 [format %6f $t] \
		$numlayers"
	    lappend nlayerlist $numlayers
	    lappend heightlist $t
	    lappend anglist $ang
	}
	$table see end
    } 
    if { $lamindex != -1 } {
#         foreach mat $matlist {
#             if { $matname == "[lindex $mat 0]" } {
#                 set younglist [lreplace $younglist $lamindex $lamindex [lindex $mat 2]]
#                 set weightlist [lreplace $weightlist $lamindex $lamindex [lindex $mat 8]]
#                 set younglist2 [lreplace $younglist2 $lamindex $lamindex [lindex $mat 3]]
#                 set nulist [lreplace $nulist $lamindex $lamindex [lindex $mat 4]]
#                 set glist [lreplace $glist $lamindex $lamindex [lindex $mat 5]]
#                 break
#             }
#         }
	$table delete $lamindex
	if { $useangle == 1 } {
	    set t [expr double($t)]
	    set ang [expr double($ang)]
	    $table insert $lamindex "{$matname} [format %5.2f $ang] [format %6f $t] \
		    $numlayers"
	    set nlayerlist [lreplace $nlayerlist $lamindex $lamindex $numlayers]
	    set heightlist [lreplace $heightlist $lamindex $lamindex $t]
	    set anglist [lreplace $anglist $lamindex $lamindex $ang]
	} elseif {($lamtype == "Roving" && $seq != [= "User"]) \
	    || ($lamtype == "Uni" && $seq != [= "User"])} {  
	    set t [expr double($t)]
	    if {$seq == "\[45,-45\]s"} {
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*4]"
		set nlayerlist [lreplace $nlayerlist $lamindex $lamindex $numlayers]
		set heightlist [lreplace $heightlist $lamindex $lamindex $t]
		set anglist [lreplace $anglist $lamindex $lamindex $seq]
	    } elseif {$seq == "\[45,-45\]"} {
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*2]"
		set nlayerlist [lreplace $nlayerlist $lamindex $lamindex $numlayers]
		set heightlist [lreplace $heightlist $lamindex $lamindex $t]
		set anglist [lreplace $anglist $lamindex $lamindex $seq]
	    } elseif {$seq == "\[0,45,-45\]"} {
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*3]"
		set nlayerlist [lreplace $nlayerlist $lamindex $lamindex $numlayers]
		set heightlist [lreplace $heightlist $lamindex $lamindex $t]
		set anglist [lreplace $anglist $lamindex $lamindex $seq]
	    } elseif {$seq == "\[0,90\]"} {
		$table insert end "{$matname} $ang [format %6f $t] \
		    [expr $numlayers*2]"
		set nlayerlist [lreplace $nlayerlist $lamindex $lamindex $numlayers]
		set heightlist [lreplace $heightlist $lamindex $lamindex $t]
		set anglist [lreplace $anglist $lamindex $lamindex $seq]
	    }
	    
	} else {  
	    set t [expr double($t)]
	    $table insert $lamindex "{$matname} 0.0 [format %6f $t] \
		    $numlayers"
	    set nlayerlist [lreplace $nlayerlist $lamindex $lamindex $numlayers]
	    set heightlist [lreplace $heightlist $lamindex $lamindex $t]
	    set anglist [lreplace $anglist $lamindex $lamindex $seq]
	}
	
	$table see $lamindex
	set lamindex -1
	set t ""        
	set ang ""        
	set matname ""        
	set numlayers 1
	eval [compStiff::refresh $can ]
	focus $entry
	grid remove $compStiff::lammodify
	grid remove $compStiff::lamcancel
	grid $compStiff::lamadd
	grid $compStiff::lamclear
    }

    set t ""        
    set ang ""        
    set matname ""        
    set numlayers 1
    eval [compStiff::refresh $can ]
    focus $entry
}                
##############################################################
#       Edit a row into tablelist of laminate                #
###############################################################
proc compStiff::lamedit { table } {
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
	
	grid $compStiff::lammodify
	grid $compStiff::lamcancel
	grid remove $compStiff::lamadd
	grid remove $compStiff::lamclear
    }
} 
##############################################################
#        Cancel edit process into tablelist laminate         #
##############################################################
proc compStiff::lamcancel { table } {
 variable matname
 variable t         
 variable ang         
 variable numlayers         
 variable useangle         
 variable lamindex         
    
    $table see end
    set matname ""
    set t ""        
    set ang ""        
    set numlayers 1        
    set lamindex -1
    set useangle 1
    grid remove $compStiff::lammodify
    grid remove $compStiff::lamcancel 
    grid $compStiff::lamadd
    grid $compStiff::lamclear
    focus $entry
}

##############################################################
#           Delete a row intro tablelist of laminate         #
##############################################################
proc compStiff::laminatesdelete {table widget} {
    variable laminatesList
    variable cbtoplamin
    variable cbbottomlam
    variable cbheightlam

    set entry [$table curselection]
    set row [$table get $entry]
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
    set compname [lindex $row 0]
    
    set lamIndex 0
    foreach laminatillo $laminatesList {
	set auxlam [lindex $laminatillo 0] 
	if {$auxlam == $compname} {
	    set laminatesList [lreplace $laminatesList $lamIndex $lamIndex ]
	    break
	}
	set lamIndex [expr $lamIndex + 1]
    }
    
    set names [list $cbtoplamin $cbbottomlam $cbheightlam] 
    foreach cb $names {
	set aux ""
	set cbvalues [$cb cget -values] 
	foreach value $cbvalues {
	    if { $value != $compname } {
		lappend aux $value
	    }
	}
	$cb configure -values $aux    
    }
    focus $widget

}

# ##############################################################
# #           Edit a row intro tablelist of laminate         #
# ##############################################################
# proc compStiff::laminatesedit {} {
#     return ""
# }

##############################################################
#              update Fiber angle entry                      #
##############################################################
proc compStiff::update { entry bgcolor flag} {
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
	    set ang ""
	}
    } elseif {$flag == 1} {
	if { ($useangle ==1 && $lamtype == "Uni" && $seq == [= "User"]) \
	    || ($useangle ==1 && $lamtype == "Roving" && $seq == [= "User"]) \
	    || ($useangle ==1 && $lamtype == "")} {
	    $entry configure -bg white -state normal
	} else {
	    $entry configure -state disabled
	    set ang ""
	}
    }
    
}


##############################################################
#               Clear all values into laminate page          #
##############################################################
proc compStiff::lamclear { table laminatestable} {
    variable can
    variable lamlist
    variable lamname
    variable laminatesList

    $table delete 0 end
    set lamlist ""
    $laminatestable delete 0 end
    set laminatesList ""
    set lamname ""

    eval [compStiff::refresh $can]
}

proc compStiff::refreshtop { } {
    variable topwidth
    variable bottomwidth
    variable height
#     variable basewidth
   
    
    if { $topwidth == "" || $bottomwidth == "" || $height == ""  } {
	compStiff::trap_sol
    } else {
	compStiff::refreshtopcan 
    }


} 
proc compStiff::trap_sol { } {
    variable cansection   
    
    $cansection delete all
    set x [ winfo width $cansection ]
    set y [ winfo height $cansection ]
    set x [expr $x/2]
    set y [expr $y/2]
   
    set dir [file join $::lsdynaPriv(problemtypedir) images sectionstiffener.gif]
    set image [image create photo -file $dir]
    $cansection create image $x $y -image $image -anchor center
}

proc compStiff::refreshtopcan {} {
    variable cansection
    variable topwidth
    variable bottomwidth
    variable basewidth
    variable height


    $cansection delete all
    set x [ winfo width $cansection ]
    set y [ winfo height $cansection ]
    set xmarge [expr $x*0.1]
    set ymarge [expr $y*0.2]
    set xscale [expr ($x-2*$xmarge)/$bottomwidth]
    set yscale [expr ($y-2*$ymarge)/$height]
    if { $xscale <= $yscale } {
	set topdraw [expr $xscale*$topwidth]
	set bottomdraw [expr $xscale*$bottomwidth]
	set ydraw [expr $xscale*$height]
	set basedraw [expr $xscale*$bottomwidth]    
    } else {
	set topdraw [expr $yscale*$topwidth]
	set bottomdraw [expr $yscale*$bottomwidth]
	set ydraw [expr $yscale*$height]
	set basedraw [expr $xscale*$bottomwidth] 
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
    $cansection create polygon $vertexs -fill gray -outline black
    $cansection create line [expr $x/2-$basedraw/2] [expr $y/2+$cy] [expr $x/2+$basedraw/2] \
	[expr $y/2+$cy] -width 4 
    $cansection create line [expr $x/2] [expr $y/2] [expr $x/2] \
	[expr $ymarge-10] -arrow last
    $cansection create line [expr $x/2] [expr $y/2] [expr $x-$xmarge+10] \
	[expr $y/2] -arrow last
    $cansection create oval [expr $x/2-3] [expr $y/2-3] [expr $x/2+3] [expr $y/2+3] -fill red
    $cansection create text [expr $x/2+10] [expr $ymarge+10] -text Y
    $cansection create text [expr $x-$xmarge-10] [expr $y/2-10] -text Z
    $cansection create text [expr $x/2-3] [expr $y/2+10] -text G
    
}

proc compStiff::trap_sol_cal { } {
    variable cansection
    variable topwidth
    variable bottomwidth
    variable basewidth
    variable height
    variable area 
    variable finalyoung
    variable finalweight
#     variable younglist
#     variable nlayerlist
#     variable heightlist
#     variable weightlist
    variable matprop
    variable units

#     variable younglist2
#     variable glist
#     variable nulist
#     variable anglist

    variable shear
    variable iyy
    variable izz
    variable j

    variable laminatesList

    if { $topwidth == 0.0 || $bottomwidth == 0.0 || $height == 0.0  } {
	compStiff::trap_sol
    } else {
	
	$cansection delete all
	set x [ winfo width $cansection ]
	set y [ winfo height $cansection ]
	set xmarge [expr $x*0.1]
	set ymarge [expr $y*0.2]
	set xscale [expr ($x-2*$xmarge)/$bottomwidth]
	set yscale [expr ($y-2*$ymarge)/$height]
	if { $xscale <= $yscale } {
	    set topdraw [expr $xscale*$topwidth]
	    set bottomdraw [expr $xscale*$bottomwidth]
	    set ydraw [expr $xscale*$height]
	    set basedraw [expr $xscale*$bottomwidth]    
	} else {
	    set topdraw [expr $yscale*$topwidth]
	    set bottomdraw [expr $yscale*$bottomwidth]
	    set ydraw [expr $yscale*$height]
	    set basedraw [expr $xscale*$bottomwidth] 
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
	$cansection create polygon $vertexs -fill gray -outline black
	$cansection create line [expr $x/2-$basedraw/2] [expr $y/2+$cy] [expr $x/2+$basedraw/2] \
	    [expr $y/2+$cy] -width 4 
	$cansection create line [expr $x/2] [expr $y/2] [expr $x/2] \
	    [expr $ymarge-10] -arrow last
	$cansection create line [expr $x/2] [expr $y/2] [expr $x-$xmarge+10] \
	    [expr $y/2] -arrow last
	$cansection create oval [expr $x/2-3] [expr $y/2-3] [expr $x/2+3] [expr $y/2+3] -fill red
	$cansection create text [expr $x/2+10] [expr $ymarge+10] -text Y
	$cansection create text [expr $x-$xmarge-10] [expr $y/2-10] -text Z
	$cansection create text [expr $x/2-3] [expr $y/2+10] -text G
    }

   
    foreach laminatillo $laminatesList {
	set young1List [lindex $laminatillo 2]
	set young2List [lindex $laminatillo 3]
	set weightList [lindex $laminatillo 4]
	set hiList [lindex $laminatillo 7]

	if {[lindex $laminatillo 0] == $compStiff::toplamin} {
	    set etop [lindex $laminatillo 1]
	    set young1aux 0.0
	    set haux 0.0
	    set spfweight 0.0
	    for { set i 0 } { $i < [llength $young1List] } {incr i 1 } {
		set young1aux [expr $young1aux + \
		        [lindex $young1List $i]*[lindex $hiList $i]]
		set haux [expr $haux + [lindex $hiList $i]]
		set spfweight [expr $spfweight + \
		        [lindex $weightList $i]*[lindex $hiList $i]]
	    } 
	    set young1top [expr $young1aux/$haux]
	    set spfWtop [expr $spfweight*$topwidth]
	}
	if {[lindex $laminatillo 0] == $compStiff::bottomlam} {
	    set ebase [lindex $laminatillo 1]
	    set young1aux 0.0
	    set haux 0.0
	    set spfweight 0.0
	    for { set i 0 } { $i < [llength $young1List] } {incr i 1 } {
		set young1aux [expr $young1aux + [lindex $young1List $i]*[lindex $hiList $i]]
		set haux [expr $haux + [lindex $hiList $i]]
		set spfweight [expr $spfweight + \
		        [lindex $weightList $i]*[lindex $hiList $i]]
	    } 
	    set young1bottom [expr $young1aux/$haux]
	    set spfWbottom [expr $spfweight*$bottomwidth]
	}
	if {[lindex $laminatillo 0] == $compStiff::heightlam} {
	    set eheight [lindex $laminatillo 1]
	    set young1aux 0.0
	    set haux 0.0
	    set spfweight 0.0
	    for { set i 0 } { $i < [llength $young1List] } {incr i 1 } {
		set young1aux [expr $young1aux + [lindex $young1List $i]*[lindex $hiList $i]]
		set haux [expr $haux + [lindex $hiList $i]]
		set spfweight [expr $spfweight + \
		        [lindex $weightList $i]*[lindex $hiList $i]]
	    } 
	    set young1height [expr $young1aux/$haux]
	    set spfWheight [expr $spfweight*$topwidth]
	}
    }

    
    set area [expr $topwidth*$etop+$basewidth*$ebase+$height*2*$eheight]
    set ccy [expr $etop*$topwidth*($height-$etop/2.0)+$eheight*($height-$etop-$ebase)*($height+$ebase-$etop)/2.0+\
	    $basewidth*pow($ebase,2)/2 ]
    set ccy [expr $ccy/($topwidth*$etop+2*$eheight*$height+$basewidth*$ebase)]
    set iyy [expr pow($etop,3)*$topwidth/12.0+$etop*$topwidth*pow($height-$etop/2.0-$ccy,2)+\
	    pow($height-$etop-$ebase,3)*$eheight/6.0+($height-$etop-$ebase)*2*$eheight*pow(($height-$etop+$ebase)/2.0-$ccy,2)+\
	    pow($ebase,3)*$basewidth/12.0+$ebase*$basewidth*pow($ccy-$ebase/2.0,2)]
    set izz [expr (1.0/12.0)*($etop*pow($topwidth,3)+($height-$etop-$ebase)*pow(2*$eheight,3)+ \
	    $ebase*pow($basewidth,3))]
    set iyz 0.0
    set j [ expr 0.333*($topwidth*pow($etop,3)+$basewidth*pow($ebase,3)+($height-$etop-$ebase)*pow($eheight*2,3))]
    set area [format %8.3g $area]
    set iyy [format %8.3g $iyy]
    set izz [format %8.3g $izz ]
    set j [format %8.3g $j]

#     set ei [expr [lindex $comprop($toplamin) 1]*(pow($etop,3)*$topwidth/12.0+$etop*$topwidth*pow($height-$etop/2.0-$ccy,2))+\
#             [lindex $comprop($heightlam) 1]*(pow($height-$etop-$ebase,3)*$eheight/6.0+($height-$etop-$ebase)*2*$eheight*pow(($height-$etop+$ebase)/2.0-$ccy,2))+\
#             [lindex $comprop($bottomlam) 1]*(pow($ebase,3)*$basewidth/12.0+$ebase*$basewidth*pow($ccy-$ebase/2.0,2))]

    set ei [expr $young1top*(pow($etop,3)*$topwidth/12.0+$etop*$topwidth*pow($height-$etop/2.0-$ccy,2))+\
	    $young1bottom*(pow($height-$etop-$ebase,3)*$eheight/6.0+($height-$etop-$ebase)*2*$eheight*pow(($height-$etop+$ebase)/2.0-$ccy,2))+\
	    $young1height*(pow($ebase,3)*$basewidth/12.0+$ebase*$basewidth*pow($ccy-$ebase/2.0,2))]

    set finalyoung [expr $ei/$iyy]
    set finalyoung [format %8.3g $finalyoung]
#     set finalweight [expr [lindex $comprop($toplamin) 3]+[lindex $comprop($bottomlam) 3]+[lindex $comprop($heightlam) 2]]

# Considero muy pequeño el peso específico del core (de momento) y no lo tengo en cuenta.
    set finalweight [expr ($spfWheight+$spfWtop+$spfWbottom)/$area]
    set finalweight [format %8.3g $finalweight]
    set matprop [list $area $iyy $izz $shear $j $finalyoung $finalweight]

#############
#     if {$height == 0.0} {
#         foreach i $heightlist {
#             set height [expr $height + $i ] 
#         }  
#         set height [format %6f $height]
#     }
#     set finalyoung 0.0
#     for { set i 0 } { $i < [llength $younglist] } {incr i 1 } { 
#         set finalyoung [expr $finalyoung + [lindex $younglist $i]*[lindex $heightlist $i]]
#     }
#     set finalyoung [expr $finalyoung/$height]
#     
#     set finalweight 0.0
#     for { set i 0 } { $i < [llength $weightlist] } {incr i 1 } { 
#         set finalweight [expr $finalweight + [lindex $weightlist $i]]
#     }
#     
#     if {$bottomwidth < $topwidth} {
#         WarnWin [= "You are trying something without sense, or at least, unusual"] 
#         return
#     } elseif {$bottomwidth == $topwidth} {
#         set izz [expr $topwidth*pow($height,3)/12]
#         set iyy [expr $height*pow($topwidth,3)/12]
#         set area [expr $topwidth*$height] 
#     } elseif { $bottomwidth > $topwidth && [llength $younglist] != 1} {
#         set izz [expr pow($height,3)/(($bottomwidth+$topwidth)*36)*\
#                 (9*pow(($bottomwidth+$topwidth),2)-2*pow(($bottomwidth+2*$topwidth),2))]
#         set iyy [expr $height*pow($topwidth,3)/12 + $height/($bottomwidth-$topwidth)*(pow($bottomwidth,4)/6 + \
#                 pow($topwidth,4)/32 - $bottomwidth*pow($topwidth,3)/12)]
#         set diff [expr $bottomwidth - $topwidth]
#         set pend [expr 2*$height/$diff]
#         set h [lindex $heightlist 0]
#         set dh [expr $h/$pend]
#         set area [expr $topwidth*$h + $dh*$h]
#         for {set i 1} { $i < [llength $heightlist] } {incr i 1 } {
#             set hi [lindex $heightlist $i]
#             set dhi [expr $hi/$pend]
#             set dh [expr $dhi + $dh]
#             set area [expr $area + (2*$dh+$dhi+$topwidth)*$hi]
#         }
#     } else {
#         set izz [expr pow($height,3)/(($bottomwidth+$topwidth)*36)*\
#                 (9*pow(($bottomwidth+$topwidth),2)-2*pow(($bottomwidth+2*$topwidth),2))]
#         set iyy [expr $height*pow($topwidth,3)/12 + $height/($bottomwidth-$topwidth)*(pow($bottomwidth,4)/6 + \
#                 pow($topwidth,4)/32 - $bottomwidth*pow($topwidth,3)/12)]
#         
#         set diff [expr $bottomwidth - $topwidth]
#         set pend [expr 2*$height/$diff]
#         set h [lindex $heightlist 0]
#         set dh [expr $h/$pend]
#         set area [expr $topwidth*$h + $dh*$h]
#     }
    
### bucles para el cálculo de J (n/m^2) según Miravete ###
# 
#     set j 0.0
#     set r1 1
#     set r2 2
#     set r3 3
#     set r4 4
#     set dvdo 0.0
#     set dvdo2 0.0
#     set dvsor 0.0
#     set z0 [expr -$height/2.0]
#     
#     for {set i 0} {$i < [llength $younglist]} {incr i 1} {
#         set g12 [lindex $glist $i]
#         set nu [lindex $nulist $i]
#         set e1 [lindex $younglist $i] 
#         set e2 [lindex $younglist2 $i]     
#         set hk [expr [lindex $heightlist $i]/[lindex $nlayerlist $i]]
#         set angi [lindex $anglist $i]
#         
#         for {set k 1} {$k <= [lindex $nlayerlist $i]} {incr k 1} {
#             if {$angi == "\[45,-45\]"} {
#                 set m [expr 0.7071*pow(-1,$k-1)]
#                 set n 0.7071
#             } elseif {$angi == "\[0,90\]"} {
#                 set n 0.0
#                 if {$k==$r1} {
#                     set m 1.0
#                     set r1 [expr $r1+1]
#                 } elseif {$k==$r2} {
#                     set m -1.0
#                     set r2 [expr $r2+2]
#                 }
#             } elseif {$angi == "\[0,45,-45\]"} {
#                 if {$k==$r1} {
#                     set m 1.0
#                     set n 0.0
#                     set r1 [expr $r1+3]
#                 } elseif {$k==$r2} {
#                     set m 0.7071
#                     set n $m
#                     set r2 [expr $r2+3]
#                 } elseif {$k==$r3} {
#                     set m -0.7071
#                     set n 0.7071
#                     set r3 [expr $r3+3]
#                 }
#             } elseif {$angi == "\[45,-45\]s"} {
#                 set n 0.7071
#                 if {$k==$r1 || $k==$r4} {
#                     set m 0.7071
#                     set r1 [expr $r1+4]
#                     set r4 [expr $r4+4]
#                 } elseif {$k==$r2 || $k==$r3} {
#                     set m 0.7071
#                     set r2 [expr $r2+4]
#                     set r3 [expr $r3+4]
#                 } 
#             } else {
#                 if {$angi == ""} {
#                     set angi 0.0
#                 }
#                 set m [expr cos($angi)]
#                 set n [expr sin($angi)]
#             }
#             
#             set var1 [expr 2*$m*$m*$n*$n*($nu*($e2-$e1)+2*$g12)]
#             set q11 [expr pow($m,4)*$e1 + $var1 + pow($n,4)*$e2]
#             set q22 [expr pow($n,4)*$e1 + $var1 + pow($m,4)*$e2]
#             set q12 [expr (pow($m,4)-pow($n,4))*$e2+$m*$m*$n*$n*($e1+$e2-4*$g12)]
# 
#             if {$i==0} {
#                 set zk [expr $z0+$hk]
#                 set diff1 [expr pow($z0,3)]
#                 set diff2 [expr pow($zk,3)]
#             } else {
#                 set diff1 [expr pow($zk,3)]
#                 set zk [expr $zk+$hk]
#                 set diff2 [expr pow($zk,3)]
#             }
#             set Diff [expr $diff2-$diff1]
#             set dvdo [expr $q11*$Diff+$dvdo]
#             set dvdo2 [expr $q12*$Diff+$dvdo2]
#             set dvsor [expr $q22*$Diff+$dvsor]
#         }
#     }
#     set j [expr $bottomwidth*(0.33333*$dvdo-0.11111*$dvdo2*$dvdo2)/(0.33333*$dvsor)]
# 
    
##################################################

### Cálculo de J (m^4) como momento torsor
#     
#     set j 0.0
#     set coefslist [list 0.141 0.196 0.229 0.249 0.263 0.281 0.299 0.312]
#     set interplist [list 1 1.5 2 2.5 3 4 6 10]
#     
#     if {$height < [expr $bottomwidth/10.0]} {
#         set j [expr $bottomwidth*pow($height,3)/3]
#     } else {
#         set interp [expr $bottomwidth/$height]
#         for { set i 0 } {$i < 7} {incr i 1} {
#             if { $interp <= [lindex $interplist [expr $i+1]] &&  $interp >= [lindex $interplist $i]} {
#                 set beta [expr ([lindex $coefslist [expr $i+1]]-[lindex $coefslist $i])/([lindex $interplist [expr $i+1]]- \
#                         [lindex $interplist $i])*($interp - [lindex $interplist $i]) + [lindex $coefslist $i] ]
#                 break
#             } else {
#                 set beta 10 
#             }
#         }
#         set j [expr $beta*$bottomwidth*pow($height,3)]
#     }
# 
# ##################################################
#     
#     set area [format %8.3g $area]
#     set iyy [format %8.3g $iyy]
#     set izz [format %8.3g $izz]
#     set finalyoung [format %8.3g $finalyoung]
#     set finalweight [format %8.3g $finalweight]
#     set j [format %8.3g $j]
#     
#     set e $finalyoung
#     set weight $finalweight
# 
#     set shear 1.0
#     set g $shear
#     

#     set matprop [list $e $iyy $izz $g $j $weight $area]
    

}



##############################################################
#          Draw visual description of sandwich               #
##############################################################
proc compStiff::refresh { can } {
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
#       Comunication with GiD: dump results intro GiD         #
##############################################################
proc compStiff::dump { } {
    variable matlist
    variable lamlist
    variable considermat
    set values ""
    set numlayer 0
    foreach layer $lamlist {
	set numlayer [expr $numlayer+[lindex $layer 3]]
    }
    lappend values $numlayer
 
##########################
#prrrueba sec laminados ##
    
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
    set values [join $values]
#     set values [join $values]
    return $values
}

#############################################################################
#Comuniation with GiD: Create a list of materials names for open window     #
#############################################################################
proc compStiff::infonames { } {
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
proc compStiff::getvalues { names matunit mat lam matfr lamins} {
    package require base64

    variable cbdatamat
    variable can
    variable matlist ""
    variable lamlist ""
    variable laminates ""
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
    if { $lamins != 0 } {
	set laminates  [base64::decode $lamins]
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

    set matlistAux ""
    foreach mati $matlist {
	set mati [lreplace $mati 9 13]
	lappend matlistAux $mati
    }
    set matlist $matlistAux
  
    $cbdatamat configure -values $cbvalues
    compStiff::refresh $can
} 

proc compStiff::unitsproc { } {

    variable units
    variable unit4 
    variable unit5
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
	    set unit5 "m4"
	    set unit4 "m\u00b2"
	    set unit2 "N/m\u00b2"
	    set unit3 "kg/m\u00b3"
	    set unit1 m
	    set massunit2 "kg/m\u00b2"
	    set spweightunit "N/m\u00b3"
	    set grav 9.8
	}
	"N-cm-kg" {
	    set unit5 "cm4"
	    set unit4 "cm\u00b2"
	    set unit1 cm
	    set unit2 "N/cm\u00b2"
	    set unit3 "kg/cm\u00b3"
	    set massunit2 "kg/cm\u00b2"
	    set spweightunit "N/cm\u00b3"
	    set grav 980
	}
	"N-mm-kg" {
	    set unit5 "mm4"
	    set unit4 "mm\u00b2"
	    set unit1 mm
	    set unit2 "N/mm\u00b2"
	    set unit3 "kg/mm\u00b3"
	    set unit1 mm
	    set massunit2 "kg/mm\u00b2"
	    set spweightunit "N/mm\u00b3"
	    set grav 9800
	}
	"Kp-cm-utm" {
	    set unit5 "cm4"
	    set unit4 "cm\u00b2"
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
	set MatRovUni [lindex $imat 9]

	$table delete $indice
	
	catch { set thick_aux [expr $thick_aux*$length($currentunit,$units)] }
	catch { set e1_aux [expr $e1_aux*$conv2($currentunit,$units)] }
	catch { set e2_aux [expr $e2_aux*$conv2($currentunit,$units)] }
	catch { set g12_aux [expr $g12_aux*$conv2($currentunit,$units)] }
	catch { set g23_aux [expr $g23_aux*$conv2($currentunit,$units)] }
	catch { set g13_aux [expr $g13_aux*$conv2($currentunit,$units)] }
	catch { set spweight_aux [expr $spweight_aux*$grav*$dens($currentunit,$units)] } 

	
	$table insert $indice "[list $title_aux [format %.8g $thick_aux] [format %.8g $e1_aux] \
		[format %.8g $e2_aux] [format %4.3f $nu12_aux] [format %.8g $g12_aux] \
		[format %.8g $g23_aux] [format %.8g $g13_aux] [format %.8g $spweight_aux] $MatRovUni]"
	
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

proc compStiff::fiber-resin { parent } {
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
    set eef [entry $ff.eef -textvariable compStiff::ef -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitef [label $ff.lunitef -textvariable compStiff::unit2 -width 7]
    set ldensityf [label $ff.ldensityf -text [= "Density"] -justify left]
    set edensityf [entry $ff.edensityf -textvariable compStiff::densityf -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitdenf [label $ff.lunitdenf -textvariable compStiff::unit3 -width 7]
    set lnuf [label $ff.lnuf -text [= "Possion coef."] -justify left ]
    set enuf [entry $ff.enuf -textvariable compStiff::nuf -width 8 \
	    -justify left -width 8 -bd 2 -relief sunken ]
    set lgf [label $ff.lgf -text [= "Shear Modulus"] -justify left ]
    set egf [entry $ff.egf -textvariable compStiff::gf -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitgf [label $ff.lunitgf -textvariable compStiff::unit2 -width 7]

    set titler [TitleFrame $matpage2.rdata -relief groove -bd 2 -ipad 6 \
	    -text [= "Resin"] -side left]
    set fr [$titler getframe]
    set ler [label $fr.lef -text [= "Young Modulus"] -justify left ]
    set eer [entry $fr.eef -textvariable compStiff::er -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set luniter [label $fr.luniter -textvariable compStiff::unit2 -width 7]
    set ldensityr [label $fr.ldensityr -text [= "Density"] -justify left]
    set edensityr [entry $fr.edensityr -textvariable compStiff::densityr -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitdenr [label $fr.lunitdenr -textvariable compStiff::unit3 -width 7]
    set lnur [label $fr.lnur -text [= "Possion coef."] -justify left ]
    set enur [entry $fr.enur -textvariable compStiff::nur -width 8 \
	    -justify left -width 8 -bd 2 -relief sunken ]
     set lgr [label $fr.lgf -text [= "Shear Modulus"] -justify left ]
    set egr [entry $fr.egf -textvariable compStiff::gr -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitgr [label $fr.lunitgr -textvariable compStiff::unit2 -width 7]

    set titlel1 [TitleFrame $topname.ldata -relief groove -bd 2 -ipad 6 \
	    -text [= "Material"] -side left]
    set fl [$titlel1 getframe]
    set lunitsmat [label $fl.lunitsmat -text [= Units] -justify left]
    set cbunitsmat [ComboBox $fl.cbunitsmat -textvariable compStiff::units -editable no \
	    -justify left -values [list N-m-kg N-cm-kg N-mm-kg Kp-cm-utm] -width 5]
    set command " ;#"
    trace variable Composite::units w $command
    bind $cbunitsmat <Destroy> [list trace vdelete compStiff::units w $command]
    set ltitlel [label $fl.ltitlel -text [= Name] -justify left ]
    set etitlel [entry $fl.etitlel -textvariable compStiff::titlel -width 8 \
	    -justify left  -bd 2 -relief sunken  ] 
    focus $etitlel
    set ltypel [label $fl.lef -text [= "Layer Type"] -justify left ]
    set cbtypel [ComboBox $fl.cbtypel -textvariable compStiff::typel -width 8 \
	    -editable no -values [list Uni Mat Roving]]
    set lre100 [Label $fl.lre100 -text [= "% Reinforcement"] -justify left \
	    -helptext [= "% of Reinforcement per unit mass.\nIt must be between 0 and 100"]]
    set ere100 [entry $fl.ere100 -textvariable compStiff::re100 -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lvac [Label $fl.lvac -text [= "Vaccum Index"] -justify left \
	    -helptext [= "It must be between 0 and 1"]]
    set evac [entry $fl.evac -textvariable compStiff::vac -width 8 \
	    -justify left -width 8 -bd 2 -relief sunken ]
    set lremass [Label $fl.lremass -text [= "Mass of Reinforcement"] -justify left \
	    -helptext [= "Mass of R."]]
    set eremass [entry $fl.eremass -textvariable compStiff::remass -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitmass [label $fl.lunitmass -textvariable compStiff::massunit2 -width 7]
    
    set fbuttons [frame $topname.fbuttons -bd 2 -relief sunken]
    set badd [button $fbuttons.badd -text [= Add]  -underline 0 -width 10 \
	    -command "compStiff::fradd $topname $parent"]
    set bcancel [button $fbuttons.bcancel -text [= Cancel]  -underline 0 -width 10 \
	    -command "compStiff::frcancel $topname"]
     
    bind $badd <ButtonRelease> {
	set compStiff::values [list "$compStiff::ef" "$compStiff::nuf" "$compStiff::densityf" "$compStiff::gf"\
		"$compStiff::er" "$compStiff::nur" "$compStiff::densityr" "$compStiff::gr" "$compStiff::vac" "$compStiff::remass"\
		"$compStiff::re100"]
	set compStiff::names [list FiberYoungModulus FiberPoisson FiberDensity FiberShearModulus\
		ResinYoungModulus ResinPoisson ResinDensity ResinShearModulus Vaccum MassReinf Reinforcement]
	compStiff::errorcntrl $compStiff::values $compStiff::names $compStiff::topname
    }

    $cbtypel configure -modifycmd "compStiff::combochange"

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

proc compStiff::combochange { } {
    variable re100 
    variable vac                 
    variable remass
    variable typel  

    if {$compStiff::typel == "Uni"} {
	set compStiff::re100 65
	set compStiff::vac 0.0
	set compStiff::remass 0.7
    } elseif {$compStiff::typel == "Mat"} {
	set compStiff::re100 30
	set compStiff::vac 0.0
	set compStiff::remass 0.6
    } elseif {$compStiff::typel  == "Roving"} {
	set compStiff::re100 50
	set compStiff::vac 0.0
	set compStiff::remass 0.8
    } elseif {$compStiff::typel  == "" } {
	set compStiff::re100 ""
	set compStiff::vac ""
	set compStiff::remass ""        
    }

}

proc compStiff::fradd { top parent} { 

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
	    set kk2 [lreplace $mat 9 9 $typel]
	    set matlist [lreplace $matlist $i $i $kk2]
	    break
	}
    }
    set flagF_R 1
  
}
proc compStiff::frcancel { top } {
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

proc compStiff::errorcntrl {values names window} {
    set message ""
    foreach val $values {
	if { ! [string is double -strict $val]} {
	    set message "Following errors have been found:\n"
	    break
	}
    }
    set names_length [llength $names]
    for {set ii 0} {$ii< $names_length} {incr ii} {
	  if { ! [string is double -strict [lindex $values $ii]] } {
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

proc compStiff::errorcntrl2 { values2 } {
    set message ""
    variable f

    if {[llength $values2] != [lindex $values2 0]  } {
	set message [= "Some entries are blank.\nPlease check for errors\n"] 
    }
    set values [string range $values2 1 end]
    foreach elem $values2 {
	if { ! [string is double -strict $elem ] || $elem < 0.0 } {
	    append message [= "%s is not a valid input. \n" $elem]
	}
	if { $elem < 0.0 } {
	    append message [= "Entries must be non-negative \n" $elem]
	}
    }
    if  { $message != "" } {
	WarnWin $message $f
	#tk_messageBox -message $message -type ok        
	return 1
    }
    return 0
}

proc compStiff::frmathick { ethick lamseq cbseq ldataspin cbseq check spin} {
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
	set ang ""
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
	    $check configure -state normal -activebackground grey
	}
    } else {
	foreach mat $matlist {
	    if { $matname == "[lindex $mat 0]" } {
		set lamtype [lindex $mat 9]
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
		    $check configure -state normal -activebackground grey
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

proc compStiff::popupmenu { parent x y } {
    variable lamtable 
    catch { destroy $parent.menu }
    set menu [menu $parent.menu -type normal ]
    $menu add command -label [= Paste] -command compStiff::poppaste
    $menu add command -label [= Sym+Paste] -command compStiff::popsympaste
    $menu add command -label [= Delete] -command "compStiff::lamdelete $lamtable {}"
    tk_popup $menu $x $y
   
} 

proc compStiff::poppaste { } {
    variable lamtable 
    variable can
    variable heightlist
    variable younglist
    variable weightlist
    
    set indexs [$lamtable curselection ]
    foreach index $indexs {
	$lamtable insert end [$lamtable get $index]
	lappend heightlist [lindex $heightlist $index]
	lappend younglist [lindex $younglist $index]
	lappend weightlist [lindex $weightlist $index]
    }
    compStiff::refresh $can
}
proc compStiff::popsympaste { } {
    variable lamtable 
    variable can
    variable heightlist
    variable younglist
    variable weightlist

    set indexs ""
    for { set i [expr [llength [$lamtable curselection ]]-1] } { $i >=0 } { incr i -1} {
	lappend indexs [ lindex [$lamtable curselection ] $i]
    }  
    foreach index $indexs {
	$lamtable insert end [$lamtable get $index]
	lappend heightlist [lindex $heightlist $index]
	lappend younglist [lindex $younglist $index]
	lappend weightlist [lindex $weightlist $index]
    }
    compStiff::refresh $can
}

proc compStiff::Edit-Data { table parent } {
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
	    set vac ""
	    set remass ""
	    set typel ""
	    set mathick($title) [list $esp $ef $er $densityf $densityr $nuf $nur $gf  $gr $re100 $vac $remass $typel]
	    catch { array unset mathick }
	}

	event generate $parent <<normal>>

	set isfiberesin 0
	catch { grid remove $compStiff::bedit}
     
	catch { grid $compStiff::bmodify }
	catch { grid $compStiff::bcancel }
	catch { grid $compStiff::bnew }
	catch { grid remove $compStiff::badd }
	
    }
}

namespace eval naval_stiffeners {

variable compStiffinate

}
proc naval_stiffeners::initbuttons { op args } {

variable compStiffinate  
    switch $op {
	"INIT" {
	    set PARENT [lindex $args 0]
	    upvar [lindex $args 1] ROW
	    set GDN [lindex $args 2]
	    set STRUCT [lindex $args 3]
	    set lcompStiff [label $PARENT.lcompStiff -text [= "Naval Stiffener"] -justify left]
	    set bcompStiff [Button $PARENT.bcompStiff -text [= "Create/Edit"] -helptext \
		    [= "Open a window to create or to edit\na new naval composite material stiffener"] \
		    -command naval_stiffeners::ViewMaterial]
	    set cbcompStiff [ComboBox $PARENT.cbcompStiff -textvariable naval_stiffeners::compStiffinate \
		    -editable false -values ""]
	    $cbcompStiff configure -postcommand "naval_stiffeners::updatecbcompStiff $cbcompStiff"
	    grid $lcompStiff -column 0 -row $ROW -sticky ne -pady 10
	    grid $cbcompStiff -column 1 -row $ROW -sticky nw -pady 10
	    grid $bcompStiff -column 1 -row [expr $ROW+1] -sticky nw

	    if { $compStiffinate == "" } {
		foreach elem [ .central.s info materials] {
		    if { [.central.s info materials $elem BOOK] == "Naval_Stiffeners" } {
		        set compStiffinate $elem
		        break
		    }
		}
	    }
	 
	}
	"SYNC" {
	    set GDN [lindex $args 0]
	    set STRUCT [lindex $args 1]
	    upvar \#0 $GDN GidData 
	    if { $compStiffinate != "" } {
	    DWLocalSetValue $GDN $STRUCT  "Stiffener" $compStiffinate
	    } else {
		WarnWin [= "Select a stiffener before assigning condition" ]
	    }

	}
	"CLOSE" {
	    set compStiffinate ""    
	}
    }
}
proc naval_stiffeners::updatecbcompStiff { cb } {
    variable compStiffinate

    set values ""
    set aux [ .central.s info materials]
     foreach elem $aux {
	if { [.central.s info materials $elem BOOK] == "Naval_Stiffeners" } {
	    lappend values  $elem
	}
    }
    $cb configure -values $values
} 
proc naval_stiffeners::ViewMaterial {} {
    variable compStiffinate

    set GDN [GidOpenMaterials Naval_Stiffeners]
}






