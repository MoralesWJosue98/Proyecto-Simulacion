
package require base64

namespace eval stiffeners {
 
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

   
    variable baddlayer
    variable bnewlayer
    variable bmodifylayer
    variable bcancellayer
    variable layeradd
    variable layercancel
    variable layermodify
    variable lamadd
    variable lammodify
    variable lamcancel
    variable canlam
    variable er 
    variable ef 
    variable nur 
    variable nuf 
    variable densityf 
    variable densityr 
    variable re100 
    variable remass 
    variable vac 
    variable titlel
    variable index -1
    variable layersList
    variable lamlist
    variable matprop
    variable numlayers
    variable layer -1
    variable layername
    variable cblayer
    variable cblaminate
    variable lamname
    variable comprop
    variable lamprop
    variable lamindex -1
    variable layerindex -1
    variable listlayer
    variable listlam
    variable cansection
    variable topwidth ""
    variable bottomwidth ""
    variable height ""
    variable basewidth ""
    variable area 
    variable izz
    variable iyy
    variable iyz
    variable j
    variable cbtoplamin
    variable cbbottomlam
    variable cbheightlam
    variable toplamin
    variable bottomlam
    variable heightlam
    variable laminatesList
    variable shear
    variable values
    variable f
    variable finalyoung ""
    variable mattable
    variable layertable
    variable lamtable 
    variable elaminate
    variable units "N-m-kg"
    variable currentunit "N-m-kg"
    variable unit2 "N/m\u00b2"
    variable unit3 "kg/m\u00b3"
    variable unit1 "m"
    variable massunit2 "kg/m\u00b2"
    variable conv2
    variable length
    variable dens
}
proc stiffeners::calculateconvmatrix { } { 
    variable conv2
    variable length
    variable dens

    set conv2(N-m-kg,N-m-kg) 1.0
    set conv2(N-m-kg,N-cm-kg) 1.0e-4
    set conv2(N-m-kg,N-mm-kg) 1.0e-6
    set conv2(N-m-kg,Kp-cm-utm) [expr 1.0e-4/9.81]
    
    set conv2(N-cm-kg,N-m-kg) 1.0e4
    set conv2(N-cm-kg,N-cm-kg) 1.0
    set conv2(N-cm-kg,N-mm-kg) 1.0e-2
    set conv2(N-cm-kg,Kp-cm-utm) [expr 1.0/9.81] 
	    
    set conv2(N-mm-kg,N-m-kg) 1.0e6
    set conv2(N-mm-kg,N-cm-kg) 1.0e2
    set conv2(N-mm-kg,N-mm-kg) 1.0
    set conv2(N-mm-kg,Kp-cm-utm) [expr 1.0e2/9.81] 
    
    set conv2(Kp-cm-utm,N-m-kg) [expr 1.0e4*9.81]
    set conv2(Kp-cm-utm,N-cm-kg) 9.81
    set conv2(Kp-cm-utm,N-mm-kg) [expr 1.0e-2*9.81]
    set conv2(Kp-cm-utm,Kp-cm-utm) 1.0
    
    set length(N-m-kg,N-m-kg) 1.0
    set length(N-m-kg,N-cm-kg) 100.0
    set length(N-m-kg,N-mm-kg) 1000.0
    set length(N-m-kg,Kp-cm-utm) 100.0
    
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
     set length(Kp-cm-utm,N-mm-kg) 10.0
     set length(Kp-cm-utm,Kp-cm-utm) 1.0
    
    set dens(N-m-kg,N-m-kg) 1.0
    set dens(N-m-kg,N-cm-kg) 1.0e-6
    set dens(N-m-kg,N-mm-kg) 1.0e-9
    set dens(N-m-kg,Kp-cm-utm) 1.0e-6
    
    set dens(N-cm-kg,N-m-kg) 1.0e6
    set dens(N-cm-kg,N-cm-kg) 1.0
    set dens(N-cm-kg,N-mm-kg) 1.0e-3
    set dens(N-cm-kg,Kp-cm-utm) 1.0 
	    
    set dens(N-mm-kg,N-m-kg) 1.0e9
    set dens(N-mm-kg,N-cm-kg) 1.0e3
    set dens(N-mm-kg,N-mm-kg) 1.0
    set dens(N-mm-kg,Kp-cm-utm) 1.0e3 
    
    set dens(Kp-cm-utm,N-m-kg) 1.0e6
    set dens(Kp-cm-utm,N-cm-kg) 1.0
    set dens(Kp-cm-utm,N-mm-kg) 1.0e-3
    set dens(Kp-cm-utm,Kp-cm-utm) 1.0
 
}
proc stiffeners::ComunicateWithGiD { op args } {
    variable f
    variable matprop
    variable lamprop
    variable comprop
    variable layersList
    variable lamlist
    variable laminatesList
    variable topwidth 
    variable bottomwidth 
    variable height 
    variable toplamin
    variable bottomlam
    variable heightlam
    variable basewidth 
    variable shear
    variable lamname
    variable area 
    variable izz
    variable iyy
    variable iyz
    variable j
    variable finalyoung
    variable finalweight
    variable units

 
   switch $op {
	"INIT" {
	    stiffeners::calculateconvmatrix
	    set PARENT [lindex $args 0]
	    upvar [lindex $args 1] ROW
	    set GDN [lindex $args 2]
	    set STRUCT [lindex $args 3]
	    set f [frame $PARENT.f]
	    set lamlist ""
	    set layersList ""
	    set laminatesList ""
	    stiffeners::initwindow $f 
	    grid $f -row $ROW -column 0 -sticky nsew -columnspan 2 -pady 3 -padx 2
	    grid columnconf $f 0 -weight 1
	    grid rowconf $f 0 -weight 1
	    grid rowconf $PARENT $ROW -weight 1
	    grid columnconf $PARENT 0 -weight 1
	    upvar \#0 $GDN GidData
	     if { $GidData($STRUCT,VALUE,2) != 0 } {
		stiffeners::getvalues $GDN $STRUCT
	     }
	     return ""
	 }
	 "SYNC" {
	    set GDN [lindex $args 0]
	    set STRUCT [lindex $args 1]
	    upvar \#0 $GDN GidData 
	    if { $area != ""} {
		DWLocalSetValue $GDN $STRUCT  "section_prop" [list $topwidth $toplamin $bottomwidth \
		        $bottomlam  $height $heightlam $basewidth $shear]
		DWLocalSetValue $GDN $STRUCT  "mat_prop" [array get matprop ]
		DWLocalSetValue $GDN $STRUCT  "lam_prop" [array get lamprop ]
		DWLocalSetValue $GDN $STRUCT  "comp_prop" [array get comprop ]
		set aux [base64::encode -maxlen 100000 $layersList]
		set aux [join [split $aux ] " " ]
		DWLocalSetValue $GDN $STRUCT  "layer" $aux
		set aux [base64::encode -maxlen 100000 $laminatesList]
		set aux [join [split $aux ] " " ]
		DWLocalSetValue $GDN $STRUCT  "laminates" $aux
		DWLocalSetValue $GDN $STRUCT  "section_info" [list $area $iyy $izz $j $finalyoung $shear]
		DWLocalSetValue $GDN $STRUCT  "area" [format %8.4g $area]            
		DWLocalSetValue $GDN $STRUCT  "iyy" [format %8.4g $iyy]
		DWLocalSetValue $GDN $STRUCT  "izz" [format %8.4g $izz]
		DWLocalSetValue $GDN $STRUCT  "j" [format %8.4g $j]
		DWLocalSetValue $GDN $STRUCT  "g" [format %8.4g $shear]
		DWLocalSetValue $GDN $STRUCT  "e" [format %8.4g $finalyoung]
		switch $units {
		   N-m-kg { set grav 9.8 }
		   N-cm-kg { set grav 980 }
		   N-mm-kg { set grav 9800 }
		   Kp-cm-utm { set grav 100 }
		}
		DWLocalSetValue $GDN $STRUCT  "weight" [expr $grav*$finalweight]
		DWLocalSetValue $GDN $STRUCT  "units" $units

	    }
	    return ""
	}
	"CLOSE" {
	    array unset matprop
	    array unset comprop
	    array unset lamprop
	    set basewidth ""
	    set height ""
	    set bottomwidth ""
	    set topwidth ""
	    set lamlist ""
	    set layersList ""
	    set laminatesList ""
	    set heightlam ""
	    set toplamin ""
	    set bottomlam ""
	    set shear ""
	    set lamname ""
	    set area ""
	    set iyy ""
	    set izz ""
	    set iyz ""
	    set j ""
	    return ""        
	}       
    }
}

proc stiffeners::create_window { wp dict dict_units } {
    variable f
    variable matprop
    variable lamprop
    variable comprop
    variable layersList
    variable lamlist
    variable laminatesList
    variable topwidth 
    variable bottomwidth 
    variable height 
    variable toplamin
    variable bottomlam
    variable heightlam
    variable basewidth 
    variable shear
    variable lamname
    variable area 
    variable izz
    variable iyy
    variable iyz
    variable j
    variable finalyoung
    variable finalweight
    variable units

    package require dialogwin
    destroy $wp.steelsections
    set w [dialogwin_snit $wp.steelsections -title [_ "Composite laminate"]]
    set f [$w giveframe]
    
    array unset matprop
    array unset comprop
    array unset lamprop
    set basewidth ""
    set height ""
    set bottomwidth ""
    set topwidth ""
    set lamlist ""
    set layersList ""
    set laminatesList ""
    set heightlam ""
    set toplamin ""
    set bottomlam ""
    set shear ""
    set lamname ""
    set area ""
    set iyy ""
    set izz ""
    set iyz ""
    set j ""
    
#     set lamlist ""
#     set layersList ""
#     set laminatesList ""
    calculateconvmatrix

    initwindow $f
    
    grid columnconfigure $f 0 -weight 1
    grid rowconfigure $f 0 -weight 1

    getvalues_dict $dict

    bind $w <Return> [list $w invokeok]
    set action [$w createwindow]
    while 1 {
	if { $action <= 0 } { 
	    destroy $w
	    return ""
	}
	set dict ""
	if { $area != ""} {
	    dict set dict sectionprop [list $topwidth $toplamin $bottomwidth \
		    $bottomlam $height $heightlam $basewidth $shear]
	    foreach i [list matprop lamprop comprop] {
		dict set dict $i [array get $i]
	    }
	    foreach i [list layersList laminatesList] {
		set aux [base64::encode -maxlen 100000 [set $i]]
		set aux [join [split $aux ] " " ]
		dict set dict $i $aux
	    }
	    regexp {(\w+)-(\w+)-(\w+)} $units {} F L Mass

#             switch $units {
#                 N-m-kg { set grav 9.8 }
#                 N-cm-kg { set grav 980 }
#                 N-mm-kg { set grav 9800 }
#                 Kp-cm-utm { set grav 100 }
#             }
	    set grav 9.8
	    set weight [expr $grav*$finalweight]


	    foreach i [list area iyy izz j shear finalyoung weight] \
		n [list Area Inertia_y Inertia_z J G E Specific_weight] \
		u [list $L^2 $L^4 $L^4 $L^4 $F/$L^2 $F/$L^2 $F/$L^3] {
		dict set dict $n [format %8.4g [set $i]]
		dict set dict_units $n $u
	    }
	    dict set dict Units $units
	}
	destroy $w
	return [list $dict $dict_units]
	#set action [$w waitforwindow]
    }
}

proc stiffeners::initwindow { top }  {
    variable cblayer
    variable cblaminate
    variable baddlayer
    variable bnewlayer
    variable bmodifylayer
    variable bcancellayer
    variable lamadd
    variable lammodify
    variable lamcancel
    variable layeradd
    variable layercancel
    variable layermodify
    variable canlam
    variable cansection
    variable lamname
    variable cbtoplamin
    variable cbbottomlam
    variable cbheightlam
    variable mattable
    variable layertable
    variable lamtable 
    variable elaminate
    
    ##############################################################
    #creating the notebook to organize the information           #
    ##############################################################
    
    set nb [NoteBook $top.notebook -height 200 -width 200 ]
    set page1 [$nb insert end page1 -text [= Materials]]
    set page2 [$nb insert end page2 -text [= Laminate] ]
    set page3 [$nb insert end page3 -text [= Section]]
    $nb raise page1
    grid $nb -sticky nsew
    grid columnconf $page1  0 -weight 1
    grid rowconf $page1 0 -weight 1
    grid columnconf $page2  0 -weight 1
    grid rowconf $page2 0 -weight 1
    grid columnconf $page3  0 -weight 1
    grid rowconf $page3 0 -weight 1
    ##############################################################
    #creating the page for layer information "Materials"     #
    ##############################################################
    set table ""
    set pw [PanedWindow $page1.pw -side left ]
    set pane1 [$pw add -weight 0]

    set matnb [NoteBook $pane1.matnb ]
    set matpage1 [$matnb insert end page1 -text [= "Fiber"]]
    set matpage2 [$matnb insert end page2 -text [= "Resin"] ]
    $matnb raise page1
    set titlef [TitleFrame $matpage1.fdata -relief groove -bd 2 -ipad 6 \
	    -text [= "Fiber"] -side left]
    set ff [$titlef getframe]
    set lef [label $ff.lef -text [= "Young Modulus"] -justify left ]
    set eef [entry $ff.eef -textvariable stiffeners::ef -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitef [label $ff.lunitef -textvariable stiffeners::unit2 -width 7]
    set ldensityf [label $ff.ldensityf -text [= "Density"] -justify left]
    set edensityf [entry $ff.edensityf -textvariable stiffeners::densityf -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitdenf [label $ff.lunitdenf -textvariable stiffeners::unit3 -width 7]
    set lnuf [label $ff.lnuf -text [= "Poisson coef."] -justify left ]
    set enuf [entry $ff.enuf -textvariable stiffeners::nuf -width 8 \
	    -justify left -width 8 -bd 2 -relief sunken ]
    
    set titler [TitleFrame $matpage2.rdata -relief groove -bd 2 -ipad 6 \
	    -text [= "Resin"] -side left]
    set fr [$titler getframe]
    set ler [label $fr.lef -text [= "Young Modulus"] -justify left ]
    set eer [entry $fr.eef -textvariable stiffeners::er -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set luniter [label $fr.luniter -textvariable stiffeners::unit2 -width 7]
    set ldensityr [label $fr.ldensityr -text [= "Density"] -justify left]
    set edensityr [entry $fr.edensityr -textvariable stiffeners::densityr -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitdenr [label $fr.lunitdenr -textvariable stiffeners::unit3 -width 7]
    set lnur [label $fr.lnur -text [= "Poisson coef."] -justify left ]
    set enur [entry $fr.enur -textvariable stiffeners::nur -width 8 \
	    -justify left -width 8 -bd 2 -relief sunken ]
      
    set titlel [TitleFrame $pane1.ldata -relief groove -bd 2 -ipad 6 \
	    -text [= "Layer"] -side left]
    set fl [$titlel getframe]
    set lunitsmat [label $fl.lunitsmat -text [= Units] -justify left]
    set cbunitsmat [ComboBox $fl.cbunitsmat -textvariable stiffeners::units -editable no \
	    -justify left -values [list N-m-kg N-cm-kg N-mm-kg Kp-cm-utm] -width 5]
    set command "stiffeners::unitsproc ;#"
    trace variable stiffeners::units w $command
    bind $cbunitsmat <Destroy> [list trace vdelete stiffeners::units w $command]
    set ltitlel [label $fl.ltitlel -text [= Name] -justify left ]
    set etitlel [entry $fl.etitlel -textvariable stiffeners::titlel -width 8 \
	    -justify left  -bd 2 -relief sunken  ] 
    set ltypel [label $fl.lef -text [= "Layer Type"] -justify left ]
    set cbtypel [ComboBox $fl.cbtypel -textvariable stiffeners::typel -width 8 \
	    -editable no -values [list Uni Mat Roving]]
    set lre100 [Label $fl.lre100 -text [= "% Reinforcement"] -justify left \
	    -helptext [= "% of Reinforcement per unit mass"]]
    set ere100 [entry $fl.ere100 -textvariable stiffeners::re100 -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lvac [label $fl.lvac -text [= "Vaccum Index"] -justify left ]
    set evac [entry $fl.evac -textvariable stiffeners::vac -width 8 \
	    -justify left -width 8 -bd 2 -relief sunken ]
    set lremass [Label $fl.lremass -text [= "Mass of Reinforcement"] -justify left \
	    -helptext [= "Mass of R."]]
    set eremass [entry $fl.eremass -textvariable stiffeners::remass -width 8 \
	    -justify left -bd 2 -relief sunken ]
    set lunitmass [label $fl.lunitmass -textvariable stiffeners::massunit2 -width 7]
    grid $pw  -sticky nsew 
    grid rowconf $pw 1 -weight 1
    grid columnconf $pw 0 -weight 1
    grid columnconf $pane1 1 -weight 1
    grid rowconf $pane1 0 -weight 1
    
    grid $titlel -column 0 -row 0 -padx 2 -pady 2 -sticky nsew
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
	
    set pane2 [$pw add -weight 1]
    set titlet [TitleFrame $pane2.table -relief groove -bd 2 -text [= "Materials List"] \
	    -side left ]
    set ft [$titlet getframe]
    set layersw [ScrolledWindow $ft.scroll -scrollbar both ]
    set mattable [tablelist::tablelist $layersw.mattable \
	    -columns [list 0 [= "Name"] 0 [= "E(F)"] 0 [= "nu(F)"] 0 [= "Dens(F)"] \
	    0 [= "E(R)"] 0 [= "nu(R)"] 0 [= "Dens(R)"] 0 [= "Type"]\
	    0 [= "% Reinf"] 0 [= "Vaccum"] 0 [= "Mass"]] \
	    -height 3 -width 80 -stretch all -background white \
	    -listvariable stiffeners::layersList]
    $layersw setwidget $mattable
   
    set bbox [ButtonBox $ft.bbox1 -spacing 0 -padx 1 -pady 1 -homogeneous 0 ]
    $bbox add -image $stiffeners::edit -width 24 \
	    -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	    -helptext [= "Edit layer"] -command "stiffeners::matedit $mattable"
    $bbox add -image $stiffeners::delete -width 24 \
	    -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	    -helptext [= "Delete layer"] -command "stiffeners::matdelete $mattable"
    
    bind [$mattable bodypath] <Double-ButtonPress-1> { stiffeners:::matedit $stiffeners::mattable }
    
    set bframe [frame $pane1.bframe ]
    set baddlayer [button $bframe.baddlayer -text [= Add]  -width 10 -underline 0 \
	    -command "stiffeners::matadd $mattable $etitlel $etitlel" ]
     set bnewlayer [button $bframe.bnewlayer -text [= New]  -width 10 -underline 0 \
	    -command "stiffeners::matadd $mattable $etitlel $etitlel" ]
    set bmodifylayer [button $bframe.modifylayer -text [= Modify]  -width 10 -underline 0 \
	    -command "stiffeners::matadd $mattable $etitlel $etitlel" ]
    set bcancellayer [button $bframe.cancellayer -text [= Cancel]  -width 10 -underline 0 \
	    -command "stiffeners::matcancel $mattable $etitlel"]
    bind $baddlayer <ButtonRelease> { 
	set stiffeners::values "10 $stiffeners::ef $stiffeners::densityf $stiffeners::nuf $stiffeners::er $stiffeners::densityr \
		$stiffeners::nur $stiffeners::re100 $stiffeners::remass $stiffeners::vac"
       stiffeners::errorcntrl $stiffeners::values 
    } 
     bind $bnewlayer <ButtonRelease> { 
	set stiffeners::values "10 $stiffeners::ef $stiffeners::densityf $stiffeners::nuf $stiffeners::er $stiffeners::densityr \
		$stiffeners::nur $stiffeners::re100 $stiffeners::remass $stiffeners::vac"
	stiffeners::errorcntrl $stiffeners::values 
	set stiffeners::index -1
    } 
    bind $bmodifylayer <ButtonRelease> { 
	set stiffeners::values "10 $stiffeners::ef $stiffeners::densityf $stiffeners::nuf $stiffeners::er $stiffeners::densityr \
	$stiffeners::nur $stiffeners::re100 $stiffeners::remass $stiffeners::vac"
	stiffeners::errorcntrl $stiffeners::values 
    } 
    grid $bframe -column 0 -row 1 -columnspan 2 -sticky nsew
    grid $baddlayer -column 0 -row 0 -pady 6 
    grid $bnewlayer -column 0 -row 0 -padx 6 -pady 6
    grid $bmodifylayer -column 1 -row 0 -padx 6 -pady 6 
    grid $bcancellayer -column 2 -row 0 -padx 6 -pady 6
    grid remove $bnewlayer
    grid remove $bmodifylayer
    grid remove $bcancellayer
    bind $top <Alt-KeyPress-a> "tkButtonInvoke $baddlayer"                
    bind $top <Alt-KeyPress-m> "tkButtonInvoke $bmodifylayer"
    bind $top <Alt-KeyPress-c> "tkButtonInvoke $bcancellayer"
    
    grid columnconf $pane2  0 -weight 1
    grid rowconf $pane2 0 -weight 1
    grid columnconf $pane2  0 -weight 1
    
    grid $titlet -column 0 -row 0 -padx 2 -pady 2 -sticky nsew 
    grid columnconf $ft  0 -weight 1
    grid rowconf $ft 0 -weight 1


    grid $layersw -column 0 -row 0 -sticky nsew
    grid $bbox -column 0 -row 1 -sticky nw
    #$nb compute_size
    ##############################################################
    #creating the page for laminate information "Laminate"     #
    ##############################################################
    
    set pwlam [PanedWindow $page2.pwlam -side top ]
    set panelam1 [$pwlam add -weight 0]

    set titlelam0 [TitleFrame $panelam1.titlelam0 -relief groove -bd 2 \
	    -text [= "Laminate"] -side left]
    set flam0 [$titlelam0 getframe]
    set llaminate [label $flam0.llaminate -text [= "Laminate"] -justify left ]
    set elaminate [entry $flam0.cblaminate -textvariable stiffeners::lamname \
	    -justify left -bd 2 -relief sunken ]
    grid $pwlam  -sticky nsew 
    grid columnconf $pwlam 1 -weight 1
    grid rowconf $pwlam 0 -weight 1
    grid columnconf $panelam1  0 -weight 1
    grid rowconf $panelam1 2 -weight 1
    grid $titlelam0 -column 0 -row 0 -padx 2 -pady 2 -sticky nsew
    grid rowconf $flam0 1 -weight 1
    grid columnconf $flam0  2 -weight 1
    grid $llaminate -column 0 -row 0 -sticky w
    grid $elaminate -column 1 -row 0 -columnspan 1 -sticky we
    
    set titlelam1 [TitleFrame $panelam1.titlelam1 -relief groove -bd 2 \
	    -text [= "Material"] -side left]
    set flam1 [$titlelam1 getframe]
    set llayer [label $flam1.llayer -text [= "Layer"] -justify right ]
    set cblayer [ComboBox $flam1.cb -textvariable stiffeners::layername  \
	    -values "" -editable no]
    set lspinlayer [label $flam1.lspinlayer -text [= "Number of layers"] -justify left]
    set spinlayer [SpinBox $flam1.splayer -textvariable stiffeners::numlayers \
	    -range "1 1000 1" -width 2 -takefocus 1]
    
    grid $titlelam1 -column 0 -row 1 -padx 2 -pady 2 -sticky nsew
    grid rowconf $flam1 4 -weight 1
    grid columnconf $flam1  4 -weight 1
    grid $llayer -column 0 -row 0 -sticky e
    grid $cblayer -column 1 -row 0 -columnspan 2 -sticky nwse
    grid $lspinlayer -column 0 -row 1 -sticky w
    grid $spinlayer -column 1 -row 1 -sticky we
    
    set panelam2 [$pwlam add -weight 1]
    set titlelam20 [TitleFrame $panelam2.table0 -relief groove -bd 2 -text [= "Laminate Properties"] \
	    -side left ]
    set flam20 [$titlelam20 getframe]
    set swlam0 [ScrolledWindow $flam20.scrolllam0 -scrollbar both ]
    set lamtable [tablelist::tablelist $swlam0.table \
	    -columns [list  0 [= "Laminate"] 0 [= "E"] 0 [= "Thickness"] ] \
	    -height 5 -width 30 -stretch all -background white \
	    -listvariable stiffeners::laminatesList]
    $swlam0 setwidget $lamtable
	 
    set titlelam2 [TitleFrame $panelam2.table -relief groove -bd 2 -text [= "Laminate Composition"] \
	    -side left ]
    set flam2 [$titlelam2 getframe]
    set swlayer [ScrolledWindow $flam2.scrolllam -scrollbar both ]
    set layertable [tablelist::tablelist $swlayer.lamtable \
	    -columns [list 0 [= "Layer"] 0 [= "E"] 0 [= "Thickness"] 0 [= "Num.of layers"]] \
	    -height 5 -width 30 -stretch all -background white \
	    -listvariable stiffeners::lamlist]
    $swlayer setwidget $layertable
     
    bind [$lamtable bodypath] <Double-ButtonPress-1> { 
	stiffeners:::lamedit $stiffeners::layertable $stiffeners::lamtable $stiffeners::elaminate
    }
    bind [$layertable bodypath] <Double-ButtonPress-1> { stiffeners:::layeredit $stiffeners::layertable }

    
    set new [button $flam0.bnew -text [= New]  -underline 0 -width 5 \
	    -command "stiffeners::new $layertable $lamtable $elaminate"]
     bind $new <ButtonRelease> {  
	if { ! [info exists stiffeners::lamprop($stiffeners::lamname)] } {
	    WarnWin [= "Enter some layers to create a laminate shell"] $stiffeners::f
	    #tk_messageBox -message "Enter some layers to create a lamiante shell"  -type ok
	}
    }
    grid $new -column 2 -row 0 -padx 4
    bind $top <Alt-KeyPress-n> "tkButtonInvoke $new" 
     
    set bbox0 [ButtonBox $flam20.bbox0 -spacing 0 -padx 1 -pady 1 -homogeneous 0 ]
    $bbox0 add -image $stiffeners::edit -width 24 \
	    -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	    -helptext [= "Edit laminate shell"] -command "stiffeners::lamedit $layertable $lamtable $elaminate"
    $bbox0 add -image $stiffeners::delete -width 24 \
	    -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	    -helptext [= "Delete laminate shell"] -command "stiffeners::lamdelete $lamtable $elaminate"
    
    $nb itemconfigure page2 -raisecmd "stiffeners::raise $layertable $lamtable $elaminate"
    $nb itemconfigure page3 -raisecmd "stiffeners::raise $layertable $lamtable $elaminate"
    
    set bbox [ButtonBox $flam2.bbox1 -spacing 0 -padx 1 -pady 1 -homogeneous 0 ]
    $bbox add -image $stiffeners::edit -width 24 \
	    -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	    -helptext [= "Edit layer"] -command "stiffeners::layeredit $layertable"
    $bbox add -image $stiffeners::delete -width 24 \
	    -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	    -helptext [= "Delete layer"] -command "stiffeners::layerdelete $layertable $cblayer"
     set layeradd [button $flam1.badd -text [= Add]  -underline 1 -width 5 \
	    -command "stiffeners::layeradd $layertable $cblayer"]
    set layermodify [button $flam1.bmodify -text [= Modify]  -width 5 -underline 1 \
	    -command "stiffeners::layeradd $layertable $cblayer"]
    set layercancel [button $flam1.bcancel -text [= Cancel]  -width 5 -underline 2 \
	    -command "stiffeners::layercancel $layertable $cblayer"]
    bind $layeradd <ButtonRelease> {
	if { $stiffeners::lamname == "" } {
	   WarnWin  [= "First enter a name for laminate shell"]  $stiffeners::f
	    #tk_messageBox -message "First enter a name for laminate shell"  -type ok
	}
	if { $stiffeners::lamname != "" && $stiffeners::layername == "" } {
	    WarnWin [= "Select a layer"]  $stiffeners::f
	    #tk_messageBox -message "Select a layer"  -type ok 
	}   
    }
    grid $layeradd -column 2 -row 1 -padx 2 -pady 6 -sticky we -padx 6
    grid $layermodify -column 0 -row 2 -columnspan 2 -pady 6 -sticky nw
    grid $layercancel -column 1 -row 2 -columnspan 2 -pady 6 -sticky nw
    grid remove $layermodify
    grid remove $layercancel
    bind $top <Alt-KeyPress-d> "tkButtonInvoke $layeradd"                
    bind $top <Alt-KeyPress-o> "tkButtonInvoke $layermodify"
    bind $top <Alt-KeyPress-n> "tkButtonInvoke $layercancel"
	      
    grid columnconf $panelam2  0 -weight 1
    grid rowconf $panelam2 1 -weight 1
    grid columnconf $panelam2  0 -weight 1
    
    grid $titlelam20 -column 0 -row 0 -padx 2 -pady 2 -sticky nsew 
    grid columnconf $flam20  0 -weight 1
    grid rowconf $flam20 0 -weight 1
    grid $swlam0 -column 0 -row 0 -sticky nsew
    grid $bbox0 -column 0 -row 1 -sticky nw

    grid $titlelam2 -column 0 -row 1 -padx 2 -pady 2 -sticky nsew 
    grid columnconf $flam2  0 -weight 1
    grid rowconf $flam2 0 -weight 1
    grid $swlayer -column 0 -row 0 -sticky nsew
    grid $bbox -column 0 -row 1 -sticky nw
    #$nb compute_size
    ##############################################################
    #creating canvas                                             #
    ##############################################################
    set titlelam3 [TitleFrame $panelam1.canvas -relief groove -bd 2 -text [= "Visual Description"] \
	    -side left ]
    set flam3 [$titlelam3 getframe]
    set canlam [canvas $flam3.can -relief raised -bd 1 -width 200 -height 100 -bg white]
    grid $titlelam3 -column 0 -row 2 -sticky nsew
    grid columnconf $flam3 0 -weight 1
    grid rowconf $flam3 0 -weight 1
    grid $canlam -column 0 -row 0 -sticky nsew
    bind $canlam <Configure> "stiffeners::drawlam $canlam"
    ##############################################################
    #creating the page for information "section"     #
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
    set cbunitsect [ComboBox $fsection2.cbunitsect -textvariable stiffeners::units -editable no \
	    -justify left -values [list N-m-kg N-cm-kg N-mm-kg Kp-cm-utm] -width 5]
    set command "stiffeners::unitsproc ;#"
    trace variable stiffeners::units w $command
    bind $cbunitsect <Destroy> [list trace vdelete stiffeners::units w $command]

    set ltopwidth [label $fsection2.ltopwidth -text [= "Top Width"] -justify right]
    set etopwidth [entry $fsection2.etopwidth -textvariable stiffeners::topwidth -bd 2 \
	    -relief sunken -width 6]
    set lunittop [label $fsection2.lunittop -textvariable stiffeners::unit1 -justify left]
    set ltoplamin [label $fsection2.ltoplamin -text [= "Laminate"] -justify right]
    set cbtoplamin [ComboBox $fsection2.cbtoplamin -textvariable stiffeners::toplamin  \
	    -values "" -editable no -width 6]
    set lbottomwidth [label $fsection2.lbottomwidth -text [= "Bottom Width"] -justify right]
    set ebottomwidth [entry $fsection2.ebottomwidth -textvariable stiffeners::bottomwidth \
	    -bd 2 -relief sunken -width 6]
    set lunitbottom [label $fsection2.lunitbottom -textvariable stiffeners::unit1 -justify left]
    set lbottomlam [label $fsection2.lbottomlam -text [= "Laminate"] -justify right]
    set cbbottomlam [ComboBox $fsection2.cbbottomlam -textvariable stiffeners::bottomlam  \
	    -values "" -editable no -width 6]
    set lheight [label $fsection2.lheightc -text [= Height] -justify right]
    set eheight [entry $fsection2.eheightc -textvariable stiffeners::height -bd 2 -relief sunken \
	    -width 6]
    set lunitheight [label $fsection2.lunitheight -textvariable stiffeners::unit1 -justify left]
    set lheightlam [label $fsection2.lheightlam -text [= "Laminate"] -justify right]
    set cbheightlam [ComboBox $fsection2.cbheightlam -textvariable stiffeners::heightlam  \
	    -values "" -editable no -width 6]
    set lbasewidth [label $fsection2.lbasewidth -text [= "Base Width"] -justify right]
    set ebasewidth [entry $fsection2.ebasewidth -textvariable stiffeners::basewidth -bd 2 -relief sunken \
	    -width 6]
    set lunitbase [label $fsection2.lunitbase -textvariable stiffeners::unit1 -justify left]
    set titlesection21 [ TitleFrame $panesection2.shear -relief groove -bd 2 \
	    -text [= "Core Properties"] -side left -ipad 8]
    set fsection21 [$titlesection21 getframe]
    set lshear [ label $fsection21.lshear -text [= "Shear Modulus"] -justify left]
    set eshear [ Entry $fsection21.eshear -textvariable stiffeners::shear -bd 2 -relief sunken \
	    -width 6 ]
    set lunitshear [label $fsection21.lunitshear -textvariable stiffeners::unit2 -justify left]

    set titlesection3 [TitleFrame $panesection2.inertia -relief groove -bd 2 \
	    -text [= "Section Properties"] -side left -ipad 8]
    set fsection3 [$titlesection3 getframe]
    set bcalculate [button $fsection3.bcalculatec -text [= Calculate] -underline 0 \
		-command "stiffeners::trap_sol_cal"]

    bind $bcalculate <ButtonRelease> {
	set stiffeners::values "6 $stiffeners::topwidth $stiffeners::bottomwidth $stiffeners::height $stiffeners::basewidth $stiffeners::shear"  
	stiffeners::errorcntrl $stiffeners::values
	if {  $stiffeners::toplamin == "" || $stiffeners::bottomlam == "" || $stiffeners::heightlam == "" } {
	    WarnWin [= "Some parts of the stiffener \nhaven't got any laminate shell assigned"]  $stiffeners::f
	    #tk_messageBox -message "Some parts of the stiffener \nhaven't got any laminate shell assigned"  -type ok
	}
    }

    set larea [label $fsection3.larea -text [= Area] -justify left]
    set earea [Entry $fsection3.earea -textvariable stiffeners::area -editable no -relief groove \
	    -bd 2 -bg lightyellow -justify right]
    set liyy [label $fsection3.liyy -text [= Iyy] -justify left]
    set eiyy [Entry $fsection3.eiyy -textvariable stiffeners::iyy -editable no -relief groove -bd 2 \
	    -bg lightyellow -justify right]
    set lizz [label $fsection3.lizz -text [= Izz] -justify left]
    set eizz [Entry $fsection3.eizz -textvariable stiffeners::izz -editable no -relief groove -bd 2  \
	    -bg lightyellow -justify right]
    set liyz [label $fsection3.liyz -text [= Iyz] -justify left]
    set eiyz [Entry $fsection3.eiyz -textvariable stiffeners::iyz -editable no -relief groove -bd 2  \
	    -bg lightyellow -justify right]
    set lj [label $fsection3.ljiyz -text J -justify left]
    set ej [Entry $fsection3.ej -textvariable stiffeners::j -editable no -relief groove -bd 2  \
	    -bg lightyellow -justify right]
    
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
    grid $liyy -column 0 -row 2 -sticky ew -pady 2
    grid $eiyy -column 1 -row 2 -sticky ew -pady 2
    grid $lizz -column 0 -row 3 -sticky ew -pady 2
    grid $eizz -column 1 -row 3 -sticky ew -pady 2
    grid $liyz -column 0 -row 4 -sticky ew -pady 2
    grid $eiyz -column 1 -row 4 -sticky ew -pady 2
    grid $lj -column 0 -row 5 -sticky ew -pady 2
    grid $ej -column 1 -row 5 -sticky ew -pady 2
    $nb compute_size
    bind $cansection <Configure> "stiffeners::refresh"
    bind $etopwidth <KeyPress-Return> "focus $ebottomwidth"
    bind $ebottomwidth <KeyPress-Return> "focus $eheight"
    bind $eheight <KeyPress-Return> "tkButtonInvoke $bcalculate"
     if { ! [info exists layersList] || $layersList eq "" } { 
	stiffeners::initlayertable $mattable $etitlel
    }
}
proc stiffeners::initlayertable { table entry } { 
    
    variable ef         
    variable er        
    variable densityf         
    variable densityr         
    variable nuf         
    variable nur   
    variable re100        
    variable titlel
    variable vac                 
    variable remass
    variable typel
    variable units

    variable conv2
    variable length
    variable dens
    
    set layers(E-Glass_Epoxy) [list 7.3e10 0.25 2.54e3 2.6e9 0.40 1.20e3 Mat 65 0.0 0.7]
    set layers(Aramid_Poly) [list 1.3e11 0.35 1.45e3 3.0e9 0.316 1.20e3  Roving 60 0.0 0.6]
    set layers(HS-Carb_Epoxy) [list 2.3e11 0.35 1.80e3 2.6e9 0.40 1.20e3 Uni 70 0.0 0.7]
    set layers(HM-Carb_Poly) [list 3.7e11 0.35 1.90e3 3.0e9 0.316 1.20e3 Mat 65 0.0 0.75]
    set names [array names layers]
    foreach name $names { 
	set ef [lindex $layers($name) 0]       
	set er [lindex $layers($name) 3]         
	set densityf [lindex $layers($name) 2]         
	set densityr [lindex $layers($name) 5]  
	set nuf [lindex $layers($name) 1]           
	set nur [lindex $layers($name) 4]     
	set re100 [lindex $layers($name) 7]          
	set titlel $name
	set vac [lindex $layers($name) 8]                   
	set remass [lindex $layers($name) 9]  
	set typel [lindex $layers($name) 6]

	catch { set ef [expr $ef*$conv2(N-m-kg,$units)] }
	catch { set er [expr $er*$conv2(N-m-kg,$units)] }  
	catch { set  densityf [expr $densityf*$dens(N-m-kg,$units)] } 
	catch { set  densityr [expr $densityr*$dens(N-m-kg,$units)] }
	catch { set remass [expr $remass*$conv2(N-m-kg,$units)] }
	stiffeners::matadd $table $entry $entry
    }
}




proc stiffeners::matadd { table entry entrytitle } {
    variable ef         
    variable er        
    variable densityf         
    variable densityr         
    variable nuf         
    variable nur   
    variable re100        
    variable titlel
    variable vac                 
    variable cblayer 
    variable index  
    variable remass
    variable layersList 
    variable typel   
    variable baddlayer
    variable bmodifylayer
    variable bcancellayer

    set message ""
    if { $ef <=0.0 || $er <=0.0 } {
	set message  [= "Young modulus must be positive\n"]      
	set command1 ef    
    }

    if { $densityf <=0.0 || $densityf <=0.0 } {
	set message  [= "Density must be positive\n"]      
	set command2 densityf    
    }

    if { $vac >= 1 || $vac <0 } {
	set message  [= "Vaccum Index must be between 0 and 1\n"]      
	set command3 vac    
    }
    if { $nur >= 0.5 || $nur <=0.0 } {
	append message [= "Poisson coef. for Resin has to be smaller than 0.5\n"]
	 set command4 nur
    }
     if { $nuf >= 0.5 || $nuf <=0.0 } {
	append message [= "Poisson coef. for Fiber has to be smaller than 0.5\n"]
	 set command5 nuf
    }
    if { $re100>100 || $re100<0 } {
	set message  [= "%Reinforcement must be between 0 and 100\n"]      
	set command6 re100
    }
    
    set ipos1 0
    set matnames ""    
    while { [lindex $layersList $ipos1] != "" } {
	set aux [lindex $layersList $ipos1]
	lappend matnames [lindex $aux 0]
	set ipos1 [ expr $ipos1+1 ]
    }
   
    foreach name $matnames {
	if { $titlel == $name }  {
	    if { $index == -1 } {
		WarnWin [= "Another Material with this name already exists.\nPlease select a different name"] $table 
		focus $entrytitle
		$entrytitle selection range 0 end 
		catch { grid remove $stiffeners::bmodifylayer }
		return
	    }
	}
    }

    if { $message != "" } { 
	WarnWin $message
	catch { vwait $command1 }
	catch { vwait $command2 }
	catch { vwait $command3 }
	catch { vwait $command4 }
	catch { vwait $command5 }
	catch { vwait $command6 }
    } 
		  
    if { $index == -1 } {
	$table insert end "[list $titlel [format %.5g $ef] \
		[format %4.3f $nuf] [format %.5g $densityf] [format %.5g $er] \
		[format %4.3f $nur] [format %.5g $densityr] $typel [format %4.1f $re100] \
		[format %4.3f $vac] [format %4.2f $remass]]"
	$table see end
	stiffeners::matproperties
	catch { grid $stiffeners::baddlayer }
	catch { grid remove $stiffeners::bnewlayer }
	catch { grid remove $stiffeners::bmodifylayer }
	catch { grid remove $stiffeners::bcancellayer }
    } else {
	$table delete $index 
	$table insert $index "[list $titlel [format %.5g $ef] \
		[format %4.3f $nuf] [format %.5g $densityf] [format %.5g $er] \
		[format %4.3f $nur] [format %.5g $densityr] $typel [format %4.1f $re100] \
		[format %4.3f $vac] [format %4.2f $remass]]"
	stiffeners::matproperties
	$table see $index
	set index -1
	 catch { grid $stiffeners::baddlayer }
	 catch { grid remove $stiffeners::bnewlayer }
	 catch { grid remove $stiffeners::bmodifylayer }
	 catch { grid remove $stiffeners::bcancellayer }
    }
    set titlel ""
    set ef ""        
    set er ""        
    set nuf ""
    set nur ""
    set densityf ""
    set densityr ""
    set re100 ""
    set vac ""
    set remass ""
    set typel ""
    set matnames ""
    set ipos1 0
    while { [lindex $layersList $ipos1] != "" } {
	set aux [lindex $layersList $ipos1]
	lappend matnames [lindex $aux 0]
	set ipos1 [ expr $ipos1+1 ]
    }
    $cblayer configure -values $matnames
    focus $entry
}        

proc stiffeners::matedit { table } {
    variable ef         
    variable er        
    variable densityf         
    variable densityr         
    variable nuf         
    variable nur   
    variable re100        
    variable titlel
    variable vac                 
    variable index  
    variable remass
    variable layersList 
    variable typel   
     
    set index [$table curselection]
    if { $index != "" } {
	set list [$table get $index]
	set titlel [lindex $list 0]
	set ef [lindex $list 1]
	set nuf [lindex $list 2]
	set densityf [lindex $list 3]
	set er [lindex $list 4]
	set nur [lindex $list 5]
	set densityr [lindex $list 6]
	set typel [lindex $list 7]
	set re100 [lindex $list 8]
	set vac [lindex $list 9]
	set remass [lindex $list 10]
	grid $stiffeners::bnewlayer
	grid $stiffeners::bmodifylayer
	grid $stiffeners::bcancellayer
	
	grid remove $stiffeners::baddlayer
    }
} 
proc stiffeners::matcancel { table entry } {
     variable ef         
    variable er        
    variable densityf         
    variable densityr         
    variable nuf         
    variable nur   
    variable re100        
    variable titlel
    variable vac                 
    variable cblayer 
    variable index  
    variable remass
    variable typel    
    $table see end
     set titlel ""
    set ef ""
    set nuf ""
    set densityf ""
    set er ""
    set nur ""
    set densityr ""
    set typel ""
    set re100 ""
    set vac ""
    set remass ""
    grid $stiffeners::baddlayer
    grid remove $stiffeners::bnewlayer
    grid remove $stiffeners::bmodifylayer
    grid remove $stiffeners::bcancellayer     
    focus $entry
}
##############################################################
#delte  result into tablelist layers     #
##############################################################
proc stiffeners::matdelete { table } {
    variable cblayer

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
    
    set matname [lindex $row 0]
    set cbvalues [$cblayer cget -values]
    set aux ""
    foreach value $cbvalues {
	if { $value != $matname } {
	    lappend aux $value
	}
    }
    $cblayer configure -values $aux
}

##############################################################
#calculate layer properties     #
##############################################################
proc stiffeners::matproperties { } {

    variable ef         
    variable er        
    variable densityf         
    variable densityr         
    variable nuf         
    variable nur   
    variable re100        
    variable titlel
    variable vac                 
    variable cblayer 
    variable index  
    variable remass
    variable layersList 
    variable typel   
    variable matprop

  
    set re [expr $re100/100.0]    

    set volume [expr ($re*(1-$vac)/($re+(1-$re)*$densityf/$densityr))]

    set e1u [expr $volume*$ef+(1-$volume)*$er]
    set e2u [expr ($er/(1-pow($nur,2)))*((1+0.85*pow($volume,2))/(pow(1-$volume,1.25)+$volume*$er/($ef*(1-pow($nur,2)))))]
    # set esp [expr ($remass/(1-$vac))*(1/$densityf+(1-$re)/($re*$densityr))*pow(10,-3)]
    set esp [expr ($remass/(1-$vac))*(1/$densityf+(1-$re)/($re*$densityr))]
    set weight [expr $remass/1000.0*(1+(100.0-$re)/$re)]
    switch $typel {
	"Uni" {
	    if { $e1u < $e2u } {
		set matprop($titlel) [list $titlel [format %#9.3g $e1u] [format %#5.4g $esp] $weight]
	    } else {
		set matprop($titlel) [list $titlel [format %#9.3g $e2u] [format %#5.4g $esp] $weight]
	    }
	}
	"Mat" {
	    set  matprop($titlel) [list $titlel  [format %#9.3g [expr 3.0*$e1u/8.0+5.0*$e2u/8.0]] [format %#5.4g $esp] $weight]
	}
	"Roving" {
	    set k [expr $e1u/($e1u+$e2u)]
	    set e1ro [expr $k*$e1u+(1-$k)*$e2u]
	    set e2ro [expr (1-$k)*$e1u+$k*$e2u]
	    if  { $e1ro < $e2ro } {
		set matprop($titlel) [list $titlel [format %#9.3g $e1ro] [format %#5.4g $esp]  $weight]
	    } else {
		set matprop($titlel) [list $titlel [format %#9.3g $e2ro]  [format %#5.4g $esp]  $weight]
	    }
	}
    }
}
	
##############################################################
#           Delete a row intro tablelist of laminate  composition       #
##############################################################
proc stiffeners::layerdelete { table widget} {
    variable canlam
    set entry [$table curselection]
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
    stiffeners::drawlam $canlam
    focus $widget
}

##############################################################
#         Dump result intro tablelist laminate composition            #
##############################################################
proc stiffeners::layeradd { table entry } {
    variable numlayers  
    variable layerindex
    variable canlam
    variable layername
    variable matprop   
    variable lamprop
    variable  lamname 
    if { $layerindex == -1 } {
	$table insert end "[lrange $matprop($layername) 0  2] $numlayers"
	$table see end
	lappend lamprop($lamname)  [list $layername $numlayers]
	
    } else {   
	$table delete $layerindex
	$table insert $layerindex "[lrange $matprop($layername) 0 2] $numlayers"                
	$table see $layerindex
	set lamprop($lamname) [lreplace $lamprop($lamname) $layerindex $layerindex  [list $layername $numlayers]]
	set layerindex -1
	grid remove $stiffeners::layermodify
	grid remove $stiffeners::layercancel
	grid $stiffeners::layeradd
    }
       
    set layername ""
    set numlayers 1
    stiffeners::drawlam $canlam
    focus $entry    
}                


##############################################################
#       Edit a row into tablelist of laminate composition             #
##############################################################
proc stiffeners::layeredit { table } {
    variable numlayers  
    variable layerindex
    variable canlam
    variable layername
    variable matprop
    
    set layerindex [$table curselection]
    if { $layerindex != "" } {
	set entry [$table get $layerindex]
	set layername [lindex $entry 0]
	set numlayers [lindex $entry 3]
	grid $stiffeners::layermodify
	grid $stiffeners::layercancel
	grid remove $stiffeners::layeradd
	}
} 
##############################################################
#        Cancel edit process into tablelist laminate composition        #
##############################################################
proc stiffeners::layercancel { table entry } {
    variable numlayers
    variable layername   
    set numlayers 1
    set layername ""    
    $table see end
    grid remove $stiffeners::layermodify
    grid remove $stiffeners::layercancel
    grid $stiffeners::layeradd
    focus $entry
}

##############################################################
#          Draw visual description of laminate shell              #
##############################################################
proc stiffeners::drawlam { can } {
    variable lamlist       
    variable layersList 
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
    foreach mat $layersList {
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
	foreach mat $layersList {
	    $can create rectangle $xleg [expr [lindex $yi 0]+$ipos*$yleg] [expr $xleg+10] \
		    [expr [lindex $yi 0]+($ipos+1)*$yleg] -fill $matcolors([lindex $mat 0])
	    $can create text [expr $xleg+14] [expr [lindex $yi 0]+$ipos*$yleg] \
		    -text [lindex $mat 0] -justify right -anchor nw
	    set ipos [expr $ipos+1] 
	}
    }    
}
##############################################################
#       Add new lamiante shell to tablelist laminate         #
##############################################################

proc stiffeners::new { layertable lamtable elaminate } {

    variable numlayers  
    variable lamindex
    variable canlam
    variable layername
    variable matprop   
    variable lamprop
    variable  lamname 
    variable comprop
    variable lamlist
    variable cbtoplamin
    variable cbbottomlam
    variable cbheightlam
    variable laminatesList


    set num 0.0
    set den 0.0
    set weight 0.0
    if { ! [info exists comprop($lamname) ]  || $lamindex != -1} { 
	foreach mat $lamprop($lamname) {
	    set matname [lindex $mat 0]
	    set numlay [lindex $mat 1]
	    set esplay [lindex $matprop($matname) 2]
	    set younglay [lindex $matprop($matname) 1]
	    set weightlay [lindex $matprop($matname) 3] 
	    for { set i 0 } { $i < $numlay } { incr i } {
		set num [expr $num+$younglay*$esplay]       
		set den [expr $den+$esplay]
		set weight [expr $weight+$weightlay]
	    }
	}
	set comprop($lamname) [list $lamname [format %8.3g [expr $num/$den]] [format %.5g $den] [format %8g $weight]]
	if { $lamindex == -1 } {
	    $lamtable insert end $comprop($lamname)
	    $lamtable see end
	} else {   
	    $lamtable delete $lamindex
	    $lamtable insert $lamindex $comprop($lamname)                
	    $lamtable see $lamindex
	    set lamindex -1
	}
    }          
    set layername ""
    set numlayers 1
    set lamname ""
    $layertable delete 0 end
    stiffeners::drawlam $canlam
    focus $elaminate 
    set compnames ""
    set ipos1 0
    while { [lindex $laminatesList $ipos1] != "" } {
	set aux [lindex $laminatesList $ipos1]
	lappend compnames [lindex $aux 0]
	set ipos1 [ expr $ipos1+1 ]
    }
    $cbtoplamin configure -values $compnames
    $cbbottomlam configure -values $compnames
    $cbheightlam configure -values $compnames


}                 
##############################################################
#       Edit  lamiante shell to tablelist laminate         #
##############################################################
proc stiffeners::lamedit { layertable lamtable elaminate } {

    variable lamindex
    variable canlam
    variable layername
    variable lamprop
    variable  lamname 
    variable matprop

    set lamindex [$lamtable curselection]
    if { $lamindex != "" } {
	set entry [$lamtable get $lamindex]
	set lamname [lindex $entry 0]
	$layertable delete 0 end
	foreach mat $lamprop($lamname) {
	    $layertable insert end [list [lindex $mat 0] [lindex $matprop([lindex $mat 0]) 1] \
		[lindex $matprop([lindex $mat 0]) 2] [lindex $mat 1]]
	}
	stiffeners::drawlam $canlam
	focus $elaminate
    }
}

##############################################################
#           Delete a row intro tablelist of laminate  shells      #
##############################################################
proc stiffeners::lamdelete { table widget} {
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

##############################################################
#       Update of laminate shell data when laminate page is raised         #
##############################################################
proc stiffeners::raise { layertable lamtable elaminate } {

    variable lamname
    variable lamprop
    variable canlam 
    variable matprop
#     if { [info exists lamprop($lamname)] } {
#         if { $lamname != "" } {
#             set  aux $lamname
#             stiffeners::new $layertable $lamtable $elaminate
#             foreach mat $lamprop($aux) {
#                 $layertable insert end [list [lindex $mat 0] [lindex $matprop([lindex $mat 0]) 1] \
#                         [lindex $matprop([lindex $mat 0]) 2] [lindex $mat 1]]
#             }
#             set lamname $aux 
#             stiffeners::drawlam $canlam 
#             focus $elaminate
#         }
#     }
}



proc stiffeners::trap_sol { } {
#     variable topwidth
#     variable bottomwidth
#     variable height
    variable cansection
    
     $cansection delete all
     set x [ winfo width $cansection ]
     set y [ winfo height $cansection ]
    set x [expr $x/2]
    set y [expr $y/2]

#     set xmarge [expr $x*0.1]
#     set ymarge [expr $y*0.1]
#     set a1 [expr $xmarge+($x-2*$xmarge-140)/2]
#     set a2 [expr $y/2+100/2]
#     set b1 [expr $xmarge+($x-2*$xmarge-100)/2]
#     set b2 [expr $y/2-100/2]
#     set c1 [expr $b1+100]
#     set c2 [expr $y/2-100/2]
#     set d1 [expr $a1+140]
#     set d2 [expr $y/2+100/2]
#     set vertexs "$a1 $a2 $b1 $b2 $c1 $c2 $d1 $d2"
#     $cansection create polygon $vertexs -fill gray85 -outline black
#      $cansection create line [expr $xmarge] [expr $y/2+100/2] [expr $x-$xmarge] \
#         [expr $y/2+100/2] -width 4 
    set dir [file join $::lsdynaPriv(problemtypedir) images sectionstiffener.gif]
    set image [image create photo -file $dir]
    $cansection create image $x $y -image $image -anchor center
}

proc stiffeners::trap_sol_cal { } {
    variable cansection
    variable topwidth
    variable bottomwidth
    variable height
    variable basewidth
    variable area 
    variable izz
    variable iyy
    variable iyz
    variable j
    variable toplamin
    variable bottomlam
    variable heightlam
    variable comprop
    variable finalyoung
    variable finalweight
    if { $topwidth == 0.0 || $bottomwidth == 0.0 || $height == 0.0 || $basewidth == 0.0 } {
	stiffeners::trap_sol
    } else {

	$cansection delete all
	set x [ winfo width $cansection ]
	set y [ winfo height $cansection ]
	set xmarge [expr $x*0.1]
	set ymarge [expr $y*0.2]
	set xscale [expr ($x-2*$xmarge)/$basewidth]
	set yscale [expr ($y-2*$ymarge)/$height]
	if { $xscale <= $yscale } {
	    set topdraw [expr $xscale*$topwidth]
	    set bottomdraw [expr $xscale*$bottomwidth]
	    set ydraw [expr $xscale*$height]
	    set basedraw [expr $xscale*$basewidth]    
	} else {
	    set topdraw [expr $yscale*$topwidth]
	    set bottomdraw [expr $yscale*$bottomwidth]
	    set ydraw [expr $yscale*$height]
	    set basedraw [expr $xscale*$basewidth] 
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
	$cansection create text [expr $x/2+10] [expr $ymarge+10] -text Z
	$cansection create text [expr $x-$xmarge-10] [expr $y/2-10] -text Y
	$cansection create text [expr $x/2-3] [expr $y/2+10] -text G
    }
    catch { set etop [lindex $comprop($toplamin) 2] }
    catch { set ebase [lindex $comprop($bottomlam) 2] }
    catch { set eheight [lindex $comprop($heightlam) 2] }
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
    set ei [expr [lindex $comprop($toplamin) 1]*(pow($etop,3)*$topwidth/12.0+$etop*$topwidth*pow($height-$etop/2.0-$ccy,2))+\
	    [lindex $comprop($heightlam) 1]*(pow($height-$etop-$ebase,3)*$eheight/6.0+($height-$etop-$ebase)*2*$eheight*pow(($height-$etop+$ebase)/2.0-$ccy,2))+\
	    [lindex $comprop($bottomlam) 1]*(pow($ebase,3)*$basewidth/12.0+$ebase*$basewidth*pow($ccy-$ebase/2.0,2))]
    set finalyoung [expr $ei/$iyy]
    set finalweight [expr [lindex $comprop($toplamin) 3]+[lindex $comprop($bottomlam) 3]+[lindex $comprop($heightlam) 2]]
}
   
proc stiffeners::refresh { } {
    variable topwidth
    variable bottomwidth
    variable height
    variable basewidth
   

    if { $topwidth == "" || $bottomwidth == "" || $height == "" || $basewidth == "" } {
	stiffeners::trap_sol
    } else {
	stiffeners::trap_sol_cal
    }
} 

proc stiffeners::errorcntrl { values } {
    set message ""
     variable f
    if {[llength $values] != [lindex $values 0]  } {
	set message [= "Some entries are blank.\nPlease check for errors\n"] 
    }
    set values [string range $values 1 end]
    foreach elem $values {
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

proc stiffeners::getvalues_dict { dict } {

    variable matprop
    variable lamprop
    variable comprop
    variable layersList
    variable lamlist
    variable laminatesList
    variable topwidth 
    variable bottomwidth 
    variable height 
    variable toplamin
    variable bottomlam
    variable heightlam
    variable basewidth 
    variable shear
    variable lamname
    variable cblayer 
    variable units

     set v "topwidth toplamin bottomwidth bottomlam height heightlam basewidth shear"
#     foreach i $v { set $i 0.0 }
#     #comprop
#     foreach i [list matprop lamprop] {
#         array unset $i
#     }
#     set lamlist ""
#     #set layersList ""
#     set laminatesList ""
#     $cblayer configure -values ""

    set aux [dict get $dict sectionprop]
    if { $aux eq "" } { return }

    set units [dict get $dict Units]
    foreach $v $aux break
    
    array set matprop [dict get $dict matprop]
    array set lamprop [dict get $dict lamprop]
    array set comprop [dict get $dict comprop]
    set layersList [base64::decode [dict get $dict layersList]]
    set laminatesList [base64::decode [dict get $dict laminatesList]]

    set matnames ""
    set ipos1 0
    while { [lindex $layersList $ipos1] != "" } {
	set aux [lindex $layersList $ipos1]
	lappend matnames [lindex $aux 0]
	set ipos1 [ expr $ipos1+1 ]
    }
    $cblayer configure -values $matnames
}


proc stiffeners::getvalues { GDN STRUCT } {

    variable matprop
    variable lamprop
    variable comprop
    variable layersList
    variable lamlist
    variable laminatesList
    variable topwidth 
    variable bottomwidth 
    variable height 
    variable toplamin
    variable bottomlam
    variable heightlam
    variable basewidth 
    variable shear
    variable lamname
    variable cblayer 
    
    upvar \#0 $GDN GidData
    set aux $GidData($STRUCT,VALUE,2)
    set topwidth [lindex $aux 0]
    set toplamin [lindex $aux 1]
    set bottomwidth [lindex $aux 2]
    set bottomlam [lindex $aux 3]
    set height [lindex $aux 4]
    set heightlam [lindex $aux 5]
    set basewidth [lindex $aux 6]
    set shear [lindex $aux 7]
    
    array set matprop $GidData($STRUCT,VALUE,3)
    array set lamprop $GidData($STRUCT,VALUE,4)
    array set comprop $GidData($STRUCT,VALUE,5)
    set layersList [base64::decode $GidData($STRUCT,VALUE,6)]
    set laminatesList [base64::decode $GidData($STRUCT,VALUE,7)]

    set matnames ""
    set ipos1 0
    while { [lindex $layersList $ipos1] != "" } {
	set aux [lindex $layersList $ipos1]
	lappend matnames [lindex $aux 0]
	set ipos1 [ expr $ipos1+1 ]
    }
    $cblayer configure -values $matnames
}

    
proc stiffeners::unitsproc { } {

    variable units
    variable unit2
    variable unit1
    variable unit3
    variable massunit2  
    variable currentunit
    variable conv2 
    variable length
    variable dens

    variable ef         
    variable er        
    variable densityf         
    variable densityr         
    variable nuf         
    variable nur 
    variable topwidth 
    variable bottomwidth 
    variable height  
    variable basewidth
    variable remass
    variable shear

    variable mattable
    variable lamtable
    variable layertable
    variable comprop
    variable matprop
   
    variable area 
    variable izz
    variable iyy
    variable iyz
    variable j
    variable finalyoung
    variable finalweight

    switch $units {
	"N-m-kg" {
	    set unit2 "N/m\u00b2"
	    set unit3 "kg/m\u00b3"
	    set unit1 m
	    set massunit2 "kg/m\u00b2"
	}
	"N-cm-kg" {
	    set unit2 "N/cm\u00b2"
	    set unit3 "kg/cm\u00b3"
	    set unit1 cm
	    set massunit2 "kg/cm\u00b2"
	}
	"N-mm-kg" {
	    set unit2 "N/mm\u00b2"
	    set unit3 "kg/mm\u00b3"
	    set unit1 mm
	    set massunit2 "kg/mm\u00b2"
	}
	"Kp-cm-utm" {
	    set unit2 "Kp/cm\u00b2"
	    set unit3 "utm/cm\u00b3"
	    set unit1 cm
	    set massunit2 "utm/cm\u00b2"
	}
    }
      
    catch { set ef [format %.5g [expr $ef*$conv2($currentunit,$units)]] }
    catch { set er [format %.5g [expr $er*$conv2($currentunit,$units)]] }
    catch { set  shear [format %.5g [expr $shear*$conv2($currentunit,$units)]] }    
    catch { set  densityf [format %.5g [expr $densityf*$dens($currentunit,$units)]] } 
    catch { set  densityr [format %.5g [expr $densityr*$dens($currentunit,$units)]] }
    catch {set remass [format %.5g [expr $remass*$conv2($currentunit,$units)]] }
    catch {set topwidth [format %.5g [expr $topwidth*$length($currentunit,$units)]] }
    catch {set bottomwidth [format %.5g [expr $bottomwidth*$length($currentunit,$units)]] }   
    catch {set height [format %.5g [expr $height*$length($currentunit,$units)]] }
    catch {set basewidth [format %.5g [expr $basewidth*$length($currentunit,$units)]] }


    #Modifico Materials List
    set list_materials [$mattable get 0 end]
    set indice 0
    foreach imat $list_materials {       
	set titlel_aux [lindex $imat 0]
	set ef_aux [lindex $imat 1]
	set nuf_aux [lindex $imat 2]
	set densityf_aux [lindex $imat 3]
	set er_aux [lindex $imat 4]
	set nur_aux [lindex $imat 5]
	set densityr_aux [lindex $imat 6]
	set typel_aux [lindex $imat 7]
	set re100_aux [lindex $imat 8]
	set vac_aux [lindex $imat 9]
	set remass_aux [lindex $imat 10]
	$mattable delete $indice
	
	catch { set ef_aux [expr $ef_aux*$conv2($currentunit,$units)] }
	catch { set er_aux [expr $er_aux*$conv2($currentunit,$units)] }   
	catch { set densityf_aux [expr $densityf_aux*$dens($currentunit,$units)] } 
	catch { set  densityr_aux [expr $densityr_aux*$dens($currentunit,$units)] }
	catch { set remass_aux [expr $remass_aux*$conv2($currentunit,$units)] }
	$mattable insert $indice "[list $titlel_aux [format %.5g $ef_aux] \
		[format %4.3f $nuf_aux] [format %.5g $densityf_aux] [format %.5g $er_aux] \
		[format %4.3f $nur_aux] [format %.5g $densityr_aux] $typel_aux [format %4.1f $re100_aux] \
		[format %4.3f $vac_aux] [format %4.2f $remass_aux]]"
	set indice [expr $indice+1]

	set young_aux [lindex $matprop($titlel_aux) 1]
	set thick_aux [lindex $matprop($titlel_aux) 2]
	set weight_aux [lindex $matprop($titlel_aux) 3]
	catch { set young_aux [expr $young_aux*$conv2($currentunit,$units)] }
	catch { set thick_aux [expr $thick_aux*$length($currentunit,$units)] }
	catch { set weight_aux [expr $weight_aux*$dens($currentunit,$units)] }
	set matprop($titlel_aux) [list $titlel_aux [format %.5g $young_aux] [format %.5g $thick_aux]  $weight_aux]      
    }
    
    #Modifico Laminate Composition
    set list_lamcomp [$layertable get 0 end]
    set indice 0
    foreach imat $list_lamcomp {       
	set layer_name [lindex $imat 0]
	set layer_young [lindex $imat 1]
	set layer_thickness [lindex $imat 2]
	set layer_numlay [lindex $imat 3] 
       $layertable delete $indice
       catch { set layer_young [expr $layer_young*$conv2($currentunit,$units)] }
       catch { set layer_thickness [expr $layer_thickness*$length($currentunit,$units)] }   
       $layertable insert $indice "[list $layer_name [format %.5g $layer_young] \
		[format %.5g $layer_thickness] [format %4i $layer_numlay] ]"
       set indice [expr $indice+1]
    }

    #Modifico Laminate Properties
    set list_lamprop [$lamtable get 0 end]
    set indice 0
    foreach imat $list_lamprop {       
	set lam_name [lindex $imat 0]
	set lam_young [lindex $imat 1]
	set lam_thickness [lindex $imat 2]
	set lam_weight [lindex $comprop($lam_name) 3]
	$lamtable delete $indice
	catch { set lam_young [expr $lam_young*$conv2($currentunit,$units)] }
	catch { set lam_thickness [expr $lam_thickness*$length($currentunit,$units)] }
	catch { set lam_weight [expr $lam_weight*$dens($currentunit,$units)] }    
	$lamtable insert $indice "[list $lam_name [format %.5g $lam_young] \
		[format %.5g $lam_thickness] ]"
	set indice [expr $indice+1]
	set comprop($lam_name) [list $lam_name [format %.5g $lam_young] [format %.5g $lam_thickness] [format %.5g $lam_weight]]
    }
    
    if { $area != ""} {
	set finer [expr pow($length($currentunit,$units),4)]
	set farea [expr pow($length($currentunit,$units),2)]
	set iyy [format %.8g [expr $iyy*$finer]]
	set izz [format %.8g [expr $izz*$finer]]
	set iyz [format %.8g [expr $iyz*$finer]]
	set j [format %.8g [expr $j*$finer] ]
	set area [format %.8g [expr $area*$farea]]
	set finalyoung [expr $finalyoung*$conv2($currentunit,$units)]
	set finalweight [expr $finalweight*$dens($currentunit,$units)]
	set shear [expr $shear*$conv2($currentunit,$units)]
    }

    set currentunit $units
   
}      

namespace eval naval_stiffeners {

variable stiffener

}
proc naval_stiffeners::initbuttons { op args } {

variable stiffener    
    switch $op {
	"INIT" {
	    set PARENT [lindex $args 0]
	    upvar [lindex $args 1] ROW
	    set GDN [lindex $args 2]
	    set STRUCT [lindex $args 3]
	    set cmd "GidOpenMaterials Naval_Stiffeners"
	    set lstiffener [label $PARENT.lstiffener -text [= "Stiffener"] -justify left]
	    set bstiffener [Button $PARENT.bstiffener -text [= "Create/Edit"] -helptext \
		    [= "Open a window to create or to edit\na new naval stiffener"] \
		    -command $cmd]
	    set cbstiffener [ComboBox $PARENT.cbstiffener -textvariable naval_stiffeners::stiffener \
		    -editable false -values ""]
	    $cbstiffener configure -postcommand "naval_stiffeners::updatecbstiffener $cbstiffener"
	    grid $lstiffener -column 0 -row $ROW -sticky ne -pady 10
	    grid $cbstiffener -column 1 -row $ROW -sticky nw -pady 10
	    grid $bstiffener -column 1 -row [expr $ROW+1] -sticky nw

	    if { $stiffener == "" } {
		foreach elem [ .central.s info materials] {
		    if { [.central.s info materials $elem BOOK] == "Naval_Stiffeners" } {
		        set stiffener $elem
		        break
		    }
		}
	    }
	 
	}
	"SYNC" {
	    set GDN [lindex $args 0]
	    set STRUCT [lindex $args 1]
	    upvar \#0 $GDN GidData 
	    if { $stiffener != "" } {
	    DWLocalSetValue $GDN $STRUCT  "Stiffener" $stiffener
	    } else {
		WarnWin [= "Select a stiffener before assigning condition" ]
	    }
	}
	"CLOSE" {
	    set stiffener ""    
	}
    }
}
proc naval_stiffeners::updatecbstiffener { cb } {
    
    set values ""
    set aux [ .central.s info materials]
     foreach elem $aux {
	if { [.central.s info materials $elem BOOK] == "Naval_Stiffeners" } {
	    lappend values  $elem
	}
    }
    $cb configure -values $values
} 
	    

