namespace eval plate { } {
    
    variable thick
    variable matid
    variable matlist
    variable bend
    variable trans
    variable stress
    variable nomass
    variable window
    variable matidlist        
}

proc plate::initvars { } {
    variable thick
    variable matid
    variable bend
    variable trans
    variable stress
    variable nomass
    variable  matlist
    variable matidlist
    
    foreach name [list top bottom] {
        set stress($name) ""
    }
    set matlist ""
    set materials [GiD_Info materials]
    foreach mat $materials {
        if { [GiD_Info materials $mat BOOK]=="Material" } {
            set index [lsearch [GiD_Info materials $mat] Type]
            incr index
            set type [lindex [GiD_Info materials $mat] $index]
            if { $type =="isotropic" || $type == "anisotropic_shell" || $type == "orthotropic_shell" } {
                lappend matlist $mat
            }
        }
    }
    lappend matlist "Plate-Material"
    lappend matlist "None-Ignore"
    for {set i 1} { $i<=4} { incr i} {
        set thick($i) ""
    }
    set matid(1) [lindex $matlist 0]
    set matid(2) "Plate-Material"
    set matid(3) "Plate-Material"
    set matid(4) "None-Ignore"
    set trans ""
    set bend ""
    set nomass ""
    array unset matidlist
}

proc plate::comunicatewithGiD {op args } {
    variable window
    switch $op {
        "INIT" {
            set PARENT [lindex $args 0]
            set window $PARENT
            upvar [lindex $args 1] ROW
            set GDN [lindex $args 2]
            set STRUCT [lindex $args 3]
            set f [frame $PARENT.fplate]
            grid $f -row $ROW -column 0 -sticky nsew 
            grid columnconf $f 0 -weight 1
            grid columnconf $f 1 -weight 1
            grid rowconf $f 0 -weight 1
            grid rowconf $f 1 -weight 1
            grid rowconf $PARENT $ROW -weight 1
            grid columnconf $PARENT 0 -weight 1
            upvar \#0 $GDN GidData
            plate::initwindow $f 
            plate::initvars
            plate::getvalues $GDN $STRUCT
            return ""
        }
        "SYNC" {
            set GDN [lindex $args 0]
            set STRUCT [lindex $args 1]
            if { [ plate::errorcntrl $window] } {
                plate::dump $GDN $STRUCT
                return ""            
            } 
        }
    }
}

proc plate::initwindow { parent } {
    
    set tfprop [TitleFrame $parent.tfprop -text [= "Property Values"] -relief groove -bd 2]
    set fprop [$tfprop getframe]
    
    set lthick1 [Label $fprop.lthick1 -text [= "Thickness"] -helptext [= "Default membrane thickness"]]
    set ethick1 [entry $fprop.ethick1 -textvariable plate::thick(1)]
    set lnomass [Label $fprop.lnomass -text [= "Nonstructural Mass/area"] -helptext [= "Nonstructural mass per unit area"].]
    set enomass [entry $fprop.enomass -textvariable plate::nomass]
    set lmem [Label $fprop.lmem -text [= "Composition Material"] -helptext [= "Material identification for membrane behavior"].]
    set cbmem [ComboBox $fprop.cbmem -textvariable plate::matid(1) -editable 0 -postcommand "plate::creatematlist $fprop.cbmem 1"]
    
    
    set tfstress [TitleFrame $parent.tfstress -text [= "Stress Computation"] -relief groove -bd 2]
    set fstress [$tfstress getframe]
    
    set ltop [Label $fstress.ltop -text [= "Top Fiber"] \
            -helptext [= "Fiber distances for stress computation"].]
    set etop [entry $fstress.etop -textvariable plate::stress(top)]
    set lbottom [Label $fstress.lbottom -text [= "Bottom Fiber"] \
            -helptext [= "Fiber distances for stress computation"].]
    set ebottom [entry $fstress.ebottom -textvariable plate::stress(bottom)]
    
    set tfadv [TitleFrame $parent.tfadv -text [= "Advanced Options"] -relief groove -bd 2]
    set fadv [$tfadv getframe]
    
    set lbend [Label $fadv.lbend -text [= "Bending Stiffness"] \
            -helptext [concat "12I/T\u00b3" [= "Bending stiffness parameter"].]]
    set ebend [entry $fadv.ebend -textvariable plate::bend] 
    set ltrans [Label $fadv.ltrans -text [= "Transverse Shear"] \
            -helptext [= "Transverse shear thickness divided by the membrane thickness"].]
    set etrans [entry $fadv.etrans -textvariable plate::trans]
    
    set lbendmat [Label $fadv.lbendmat -text [= "Bending Mat."] \
            -helptext [= "Material identification for bending behavior"].]
    set cbbend [ComboBox $fadv.cbbend -textvariable plate::matid(2) \
            -editable 0 -postcommand "plate::creatematlist $fadv.cbbend 2"]
    
    set ltransmat [Label $fadv.ltransmat -text [= "Transverse Shear Mat."] \
            -helptext [= "Material identification for transverse shear behavior"].]
    set cbtransmat [ComboBox $fadv.cbtransmat -textvariable plate::matid(3) \
            -editable 0 -postcommand "plate::creatematlist $fadv.cbtransmat 3"]
    
    set lmemben [Label $fadv.lmemben -text [= "Mem-Bend Coupling"] \
            -helptext [= "Material identification for membrane-bending coupling"].]
    set cbmemben [ComboBox $fadv.cbmemben -textvariable plate::matid(4) \
            -editable 0 -postcommand "plate::creatematlist $fadv.cbmemben 4"]
    
    set fbutton [frame $fadv.fbutton ]
    set bmat [Button $fbutton.bmat -text [= "Create Material"] -command  "GidOpenMaterials Material" \
            -helptext [= "Create a new material"] -underline 0]
    
    grid $tfprop -column 0 -row 0 -sticky nsew
    grid columnconf  $fprop 1 -weight 1
    grid rowconf  $fprop 10 -weight 1
    
    grid $lthick1 -column 0 -row 0 -sticky e
    grid $ethick1 -column 1 -row 0 -sticky ew
    grid $lnomass -column 0 -row 1 -sticky e
    grid $enomass -column 1 -row 1 -sticky ew
    grid $lmem -column 0 -row 2 -sticky e
    grid $cbmem -column 1 -row 2 -sticky ew 
    
    grid $tfstress -column 0 -row 1 -sticky nsew
    grid columnconf  $fstress 1 -weight 1
    grid rowconf  $fstress 10 -weight 1
    
    grid $ltop -column 0 -row 0 -sticky e
    grid $etop -column 1 -row 0 -sticky ew
    grid $lbottom -column 0 -row 1 -sticky e
    grid $ebottom -column 1 -row 1 -sticky ew
    
    grid $tfadv -column 1 -row 0 -sticky nsew -rowspan 2
    grid columnconf  $fadv 1 -weight 1
    grid rowconf  $fadv 10 -weight 1
    
    grid $lbend -column 0 -row 0 -sticky e
    grid $ebend -column 1 -row 0 -sticky ew  
    grid $ltrans -column 0 -row 1 -sticky e
    grid $etrans -column 1 -row 1 -sticky ew  
    grid $lbendmat -column 0 -row 2 -sticky e -pady 2
    grid $cbbend -column 1 -row 2 -sticky ew -pady 2
    grid $ltransmat -column 0 -row 3 -sticky e -pady 2
    grid $cbtransmat -column 1 -row 3 -sticky ew -pady 2
    grid $lmemben -column 0 -row 4 -sticky e -pady 2
    grid $cbmemben -column 1 -row 4 -sticky ew -pady 2
    grid $fbutton -column 0 -row 5 -sticky nsew -columnspan 2 -pady 8
    grid $bmat -column 0 -row 0
    bind $fadv <Alt-KeyPress-c> "tkButtonInvoke $bmat"    
}

proc plate::creatematlist { combo id} {
    variable matid
    set matlist ""
    set materials [GiD_Info materials]
    foreach mat $materials {
        if { [GiD_Info materials $mat BOOK]=="Material" } {
            set index [lsearch [GiD_Info materials $mat] Type]
            incr index
            set type [lindex [GiD_Info materials $mat] $index]
            if { $type =="isotropic" || $type == "anisotropic_shell" || $type == "orthotropic_shell" } {
                lappend matlist $mat
            }
        }
    }
    lappend matlist "Plate-Material"
    lappend matlist "None-Ignore"
    if { $id == 1} {
        $combo configure -values [lrange $matlist 0 [expr [llength $matlist]-3]]
    } else {
        $combo configure -values $matlist
    }
}

proc plate::errorcntrl { window } {
    
    variable thick
    variable bend
    variable trans
    variable stress
    variable nomass
    
    set writemessage 0
    set message [= "Errors found:"]\n
    lappend varvalues $thick(1) $nomass $stress(top) $stress(bottom) $bend $trans
    foreach value $varvalues {
        if { ![string is double [string trim $value]] } {
            set addmsg 1
            append message [= "'%s' is not a valid input" $value]\n
            set writemessage 1
        }
    }
    if {$writemessage==1} {
        WarnWin $message $window
        return 0
    } else {
        return 1
    }
}

proc plate::void2blank { value } {
    if { $value == "void" } {
        return ""
    } else {
        return [string trim $value]
    }
}

proc plate::blank2void { value } {
    if { [string trim $value] == "" } {
        return void
    } else {
        return [string trim $value]
    }
}

proc plate::getvalues { GDN STRUCT } { 
    
    upvar \#0 $GDN GidData
    variable thick
    variable matid
    variable bend
    variable trans
    variable stress
    variable nomass
    variable matlist
    
    
    set thick(1) [plate::void2blank $GidData($STRUCT,VALUE,3)]
    set aux [base64::decode $GidData($STRUCT,VALUE,4)]
    for {set i 0} {$i<=3} {incr i} {
        set matid([expr $i+1]) [plate::void2blank [lindex $aux $i]]
    }
    if { $matid(1)=="" } {
        set matid(1) [lindex $matlist 0]
    }
    set bend [plate::void2blank $GidData($STRUCT,VALUE,5)]
    set trans [plate::void2blank $GidData($STRUCT,VALUE,6)]
    set nomass [plate::void2blank $GidData($STRUCT,VALUE,7)]
    set aux [base64::decode $GidData($STRUCT,VALUE,8)]
    set stress(top) [plate::void2blank [lindex $aux 0]]
    set stress(bottom) [plate::void2blank [lindex $aux end]]
}

proc plate::dump { GDN STRUCT} {
    
    variable thick
    variable matid
    variable bend
    variable trans
    variable stress
    variable nomass
    
    
    DWLocalSetValue $GDN $STRUCT "thick" [plate::blank2void $thick(1)]
    DWLocalSetValue $GDN $STRUCT "bend" [plate::blank2void $bend]
    DWLocalSetValue $GDN $STRUCT "trans" [plate::blank2void $trans]
    DWLocalSetValue $GDN $STRUCT "nomass" [plate::blank2void $nomass]
    
    lappend aux [plate::blank2void $stress(top)] [plate::blank2void $stress(bottom)]
    set aux [base64::encode  -wrapchar "" $aux]
    DWLocalSetValue $GDN $STRUCT "stress" $aux
    
    set aux ""
    for {set i 1} {$i<=4} {incr i} {
        lappend aux $matid($i)
    }
    set aux [base64::encode -wrapchar "" $aux]
    DWLocalSetValue $GDN $STRUCT "matid" $aux
    set aux [plate::nastran]
    DWLocalSetValue $GDN $STRUCT "nastran" $aux
}

proc plate::nastran { } {
    variable thick
    variable matid
    variable bend
    variable trans
    variable stress
    variable nomass
    
    set values ""
    lappend values $matid(1) $thick(1) $matid(2) $bend $matid(3) $trans $nomass $stress(top) $stress(bottom) $matid(4) 
    set values [base64::encode -wrapchar "" $values]
    return $values
    
}

proc plate::writecard {format card layout type values} {
    
    if {$format=="Small" } {
        set card [string trim $card]
        set card_length [string length $card]
        set tofill [expr 8-$card_length ]
        for {set i 1} {$i<=$tofill} {incr i} {
            append card " "
        }
        set output $card
        set card [string trim $card]
        set statment_num 1
        set line_num 1
        foreach statment $layout {
            if {$statment==1} {
                append output  [nasmat_orthotropicshell::outputformat [lindex $values 0]  s [lindex $type 0]]
                set values [lrange $values 1 end]
                set type [lrange $type 1 end]
            } else {
                append output "        "
                set type [lrange $type 1 end]
            }
            if { $statment_num==8 && $values != ""} {
                append output "+\n+       "
                incr line_num
                set statment_num 0
            }
            incr statment_num
        }
    } else {
        set card [string trim $card]
        append card *
        set card_length [string length $card]
        set tofill [expr 8-$card_length ]
        for {set i 1} {$i<=$tofill} {incr i} {
            append card " "
        }
        set output $card
        set card [string trim $card]
        set statment_num 1         
        set line_num 1
        foreach statment $layout {
            if {$statment==1} {
                append output  [nasmat_orthotropicshell::outputformat [lindex $values 0]  l [lindex $type 0]]
                set values [lrange $values 1 end] 
                set type [lrange $type 1 end]
            } else {
                append output "                "
            }
            if { $statment_num==4 && $values != ""} {
                append output "*\n*       "
                incr line_num
                set statment_num 0
            }
            incr statment_num
        }
    }
    return "$output"
}

proc plate::outputformat { value formattype numbertype} { 
    
    if { $formattype == "s" } {
        set freal %#8.5g
        set fint %8i
        set blank "        "
    } else {
        set freal %#16.6g
        set fint %16i
        set blank "                "
    }
    switch $numbertype {
        "i" {
            if { [string is integer -strict [string trim $value]] } {
                set output [format $fint $value ]
            } else {
                set output "$blank"
            }
        }
        "r" {
            if { [string is double -strict [string trim $value]] } {
                set output [GiD_FormatReal $freal $value forcewidthnastran]
            } else {
                set output "$blank"
            }
        } 
        "c" {
            if { $formattype == "s" } {
                set output [format %8s $value]
            } else {
                set output [format %16s $value]
            }
        }
    }
    return $output
}

##############################################################################
#   Nastran.bas : Write in the bas the materials use in the plate     #
##############################################################################
proc plate::writemats { matnames } {
    
    variable matidlist
    set output ""
    set matnames [base64::decode $matnames]
    foreach name $matnames {
        if { ![info exists matidlist($name)] && $name != "None-Ignore" && $name != "Plate-Material" } { 
            set matid [expr $BasWriter::currentmatid+1]
            set BasWriter::currentmatid $matid
            BasWriter::getmatnum $matid
            append output [BasWriter::matnastran [DWSpace2Under $name]]
            set matidlist($name) $matid
        }
    }
    return $output
}   

proc plate::writenastran {matid input} {
    
    variable matidlist
    
    
    set input [base64::decode $input]
    set gendata [ lrange [ GiD_Info gendata ] 1 end ]
    foreach { name value } $gendata {
        if { [regexp Format_File* $name] } {
            set format $value
            break
        }
    }
    set layout [list \
            1 1 1 1 1 1 1 1 \
            1 1 1]
    set type [list \
            i i r i r i r r \
            r r i]
    
    set values $matid 
    append values " $input"
    
    set indexs [lsearch -all $values "Plate-Material"]
    foreach index $indexs {
        set values [lreplace $values $index $index $matidlist([lindex $values 1])]
    }
    foreach name [array names matidlist] {
        set indexs [lsearch -all $values $name]
        foreach index $indexs {
            set values [lreplace $values $index $index $matidlist($name)]
        }
    }
    set indexs [lsearch -all $values "None-Ignore"]
    foreach index $indexs {
        set values [lreplace $values $index $index ""]
    }
    set result [plate::writecard $format PSHELL $layout $type $values]
    return $result
}
