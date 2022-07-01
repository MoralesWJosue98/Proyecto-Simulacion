## Ventana de cálculo de rigidizadores para planchas navales (matriz [D])-->RamSeries 
namespace eval stiff {
    variable stiffdir ""
    variable thickness 0.0
    variable pi 3.14159265358979323846
    variable section_data {
	R0lGODlhGAAYAKEAADMzMwAAAL6NkMzMzCH+Dk1hZGUgd2l0aCBHSU1QACH5
	BAEKAAMALAAAAAAYABgAAAJJnI+py+3fgJwy0KuA2Lx7AWTfyIXJRWKO1EnQ
	Wb6LJgSyCN5wrh+02Rv8goYhMbAB9mi8G6uknFFSFBzpExVeR9nLxOJ1EceP
	AgA7 
    }
    variable section [image create photo -data [set section_data]]
    variable clearance 0.0
    variable lbl6
    variable labelaux   
    variable stiffenervals
    variable stiffenerunits
    variable valsSI ""
    variable path
    variable flag
    variable Dm ""
    variable Df ""
    variable Dmf ""
    variable Dc ""
    variable spcweight 76900
    variable weightprom 0.0
    variable stiffmat
    variable wx
    variable aX
   
#####################################
#####################################

    variable dblclick
    variable tree
    variable imglabel
    variable text
    variable IsDataRead 0
    variable DataTypes "" ;# includes CustomSteelSections
    variable CustomSteelSections ""
    variable Data
    variable Units
    variable Description
    variable Id
    variable Images
    variable material
    variable path2
    variable w
    variable doc

#####################################
#####################################

  
}

proc stiff::get_valueWave { name } {   
    variable doc  
    set file [file join $::lsdynaPriv(problemtypedir) "ramseries_default.spd"]
    set aux1 [tDOM::xmlReadFile $file]
    set doc [dom parse $aux1]
    
    set node [$doc selectNodes [format_xpath {//value[@n=%s]} $name]]
    return [get_domnode_attribute $node v]

}

proc stiff::get_valueStiff { name } {       
    set file [file join $::lsdynaPriv(problemtypedir) "ramseries_default.spd"]
    set aux1 [tDOM::xmlReadFile $file]
    set doc [dom parse $aux1]
    
    set node [$doc selectNodes [format_xpath {//value[@n=%s]} $name]]
    return [get_domnode_attribute $node v]

}


proc stiff::create_window { wp dict dict_units} {
    variable flag
    variable w

    set datalist ""

    package require dialogwin
    destroy $wp.steelsections
    set w [dialogwin_snit $wp.steelsections -title [_ "Stiffened Shells"]]
    set f [$w giveframe]
    
#     set units [stiff::get_valueStiff units_mesh]  
       
    Init $f
    
    grid columnconfigure $f 0 -weight 1
    grid rowconfigure $f 0 -weight 1
    
   
    bind $w <Return> [list $w invokeok]
    set action [$w createwindow]
    while 1 {
	if { $action <= 0 } {
	    destroy $w
	    return ""
	}
	set dict ""
     
	if {$stiff::valsSI == ""} {
	    WarnWin [= "Please check inserted data. Remember to choose an stiffener"] 
	    set flag 0
	    destroy $w
	    return ""
	}
	
	foreach "Dm Df Dmf Dc wx aX" [calculateDok ] break
	
	if {$flag == 0} {
	    return ""
	}

	if {$stiff::stiffmat == "A37"} {
	    set maxStress 2.352e8
	} elseif {$stiff::stiffmat == "A42"} {
	    set maxStress 2.548e8
	} else {
	    set maxStress 3.528e8
	}

	dict set dict "StiffThickness" $stiff::thickness
	dict set dict "StiffClearance" $stiff::clearance
	dict set dict "StiffMat" $stiff::stiffmat
	dict set dict "StiffName" $stiff::stiffname
	dict set dict "StiffDirection" $stiff::stiffdir
#         dict set dict "StiffWeight" $stiff::weightprom
	dict set dict "StiffWeight" $stiff::spcweight
	dict set dict "Specific_weight" $stiff::spcweight
    
	dict set dict "StiffDm" $Dm
	dict set dict "StiffDf" $Df
	dict set dict "StiffDmf" $Dmf
	dict set dict "StiffDc" $Dc
	dict set dict "StiffWx" $wx
	dict set dict "StiffAx" $aX
	dict set dict "StiffAy" $aX
	dict set dict "StiffAt" $aX
	dict set dict "StiffAtx" $aX
	dict set dict "StiffAty" $aX
	dict set dict "StiffWt" $wx
	dict set dict "StiffWy" $wx
	dict set dict "StiffMaxstress" $maxStress
	
	destroy $w
	
	return [list $dict $dict_units]
    }
}


proc stiff::Init { frame args } {
    variable thickness 0.0 
    variable clearance 0.0
    variable stiffdir ""
    variable lbl6
    variable labelaux   
    variable path
    variable spcweight 
    variable valsSI ""
    variable stiffmat ""
    variable stiffname ""
    
    if { [info exists ::lsdynaPriv(problemtypedir)] } {
	set path $::lsdynaPriv(problemtypedir)
    } else {
	set path $::ProblemTypePriv(problemtypedir)
    }    

    set f1 [labelframe $frame.f1 -text [= "Stiffened shell data"] -borderwidth 2 -relief groove]
    set lbl1 [label $f1.lbl1 -text [= "Thickness"] -relief flat]
    set e1 [Entry $f1.e1 -relief sunken -width 3 -textvariable stiff::thickness -helptext [= "Shell/plate thickness (m)"]]
    set lblu1 [label $f1.lblu1 -text "(m)" -relief flat]

    set lbl2 [label $f1.lbl2 -text [= "Clearance"] -relief flat]
    set e2 [Entry $f1.e2 -relief sunken -width 3 -textvariable stiff::clearance -helptext [= "Distance between stiffeners"]]
    set lblu2 [label $f1.lblu2 -text "(m)" -relief flat]
    
    set lbl3 [label $f1.lbl3 -text [= "Stiffener direction"] -relief flat]
    
    set listdirection [list "x" "y"]
    set cbdirection [ComboBox $f1.cbdirection -values $listdirection \
	    -textvariable stiff::stiffdir \
	    -editable no ]
    $cbdirection configure -modifycmd "stiff::stiffdirection $e2"
    
    set lbl4 [label $f1.lbl4 -text [= "Type of Stiffener"] -relief flat]
#     set lbl6 [label $f1.lbl6 -relief sunken -textvariable "stiff::stiffname"]
#     set fselect [frame $frame.fselect -borderwidth 2 -relief groove]
#     set chooseb [Button $f1.chooseb -text [= "Choose"] -relief raised \
#             -helptext [= "Displays available stiffeners. More: right click"]]
#     $chooseb configure -command "stiff::chooseSection $frame $chooseb $f1" 
    set viewDmatrix [Button $f1.viewDmatrix -text [= "View D_Matrix"] -relief link \
	    -command "stiff::viewDmatrix" -helptext [= "Shows calculated D matrix"]]

    set fsec [labelframe $frame.fsec -text [= "Stiffener Sections"] -borderwidth 2 -relief groove]
    

	
#     GidHelpRecursive $chooseb [= "Select one steel section here following"] \
#         [= " the EA-95 regulations. Note that the section will be oriented with its"] \
#         [= " y axe pointing to the beam local y' axe"]
    GidHelpRecursive $cbdirection [= " The X and Y stiffeners directions will be coincident"] \
		    [= " with the local axes X and Y directions defined by user"]
    
    grid $f1 -row 0 -column 0 -sticky news -pady 3 -padx 2
    grid $fsec -row 1 -column 0 -sticky news -pady 3 -padx 2
    
    grid columnconfigure $frame 0 -weight 1
    grid rowconfigure $frame 0 -weight 0
    grid rowconfigure $frame 1 -weight 1 

    grid columnconfigure $f1 0 -weight 0
    grid columnconfigure $f1 1 -weight 1
    grid columnconfigure $f1 2 -weight 0
    grid columnconfigure $f1 3 -weight 1
    grid rowconfigure $f1 0 -weight 0
    grid rowconfigure $f1 1 -weight 0
    grid rowconfigure $f1 2 -weight 0
    grid rowconfigure $f1 2 -weight 0
	
    grid $lbl1 -row 0 -column 0 
    grid $e1 -row 0 -column 1
    grid $lblu1 -row 0 -column 2 
    grid $lbl2 $e2 $lblu2
    grid $lbl3 $cbdirection
#     grid $viewDmatrix -row 3 -column 1
    grid configure $e1 $e2 $cbdirection -sticky ew
    grid configure $e1 -sticky news
#     grid configure $viewDmatrix -sticky ns
    
    set signal 1
    stiff::Create $fsec

    
#################bindings###########################
#     bind $chooseb <Return> {stiff::chooseSection }
    bind $viewDmatrix <Return> {stiff::viewDmatrix}
####################################################
    
}

proc stiff::stiffdirection { e2 } {
    variable stiffdir

   set sd $stiffdir
   

if { $sd == "x" } {
	$e2 configure -state normal  -relief sunken
	return
    } elseif {$sd == "y"} {
	$e2 configure -state normal  -relief sunken
	return
    }
}



proc stiff::refresh { } {
    variable stiffdirection
    switch $stiffdirection {
	"x" { stiff::x_cal }
	"y" { stiff::y_cal }
	default { }    
    }
}

proc stiff::choosestiffCancel { } {
    variable valsSI
    variable stiffname
    variable stiffmat
    
    set stiffmat ""
    set stiffname ""
    set valsSI ""
    
} 

proc stiff::choosestifflabel { node infostiffval infostiffunits stiffcomments material } {
    variable valsSI
    variable stiffname
    variable labelaux
    variable stiffmat
    
    
    set stiffmat $material
    set stiffname $node
    set valsSI $infostiffval
    for {set i 1} {$i <= [llength $stiffcomments]} {incr i 1} {
	lappend valsSI [lindex $stiffcomments $i]
    }
    return
}


proc stiff::calculateDok { } {
    variable clearance
    variable stiffdir
    variable thickness
    variable stiffenervals
    variable stiffenerunits
    variable valsSI
    variable flag
    variable Dm
    variable Df
    variable Dmf
    variable Dc
    variable spcweight
    variable weightprom
    variable wx
    variable aX    

    set wx 0.0
    set aX 0.0
    set flag 1
    
    set doc $gid_groups_conds::doc
    set root [$doc documentElement]
    
    stiff::errcntrl 

    if {$flag == 0} {
	return
    } else {
	for {set i 1} {$i <= [llength $valsSI]} {incr i 1} {
	    if { [lindex $valsSI $i] == "e" } {
# espesor refuerzo
		set e [lindex $valsSI [expr $i+1]]
		break
	    } 
	}
	for {set i 1} {$i <= [llength $valsSI]} {incr i 1} {
	    if {[lindex $valsSI $i] == "h"} {
#altura del refuerzo
		set H [lindex $valsSI [expr $i+1]]
		break
	    }
	}
	    
	#distancia entre refuerzos
	set c $clearance
	#espesor de la plancha
	set h $thickness
	#coef. de Poisson
	set nu 0.3
	# mód. de Young (N/m^2)
	set E 2.1e+011
	# mód. de elasticidad transversal (N/m^2).
#         set G [expr $E/(2*(1+$nu))]
	set G 8.1e+010
	
	#Habrá que ajustar, ya que se deberá referir todo al eje neutro del conjunto:
	#Se calcula el eje neutro del conjunto, y se refiere su inercia a su eje neutro.
	
	#área del refuerzo
	set Ar [lindex $valsSI 1]
	#inercia propia del refuerzo
	set Ir [lindex $valsSI 2]
	#c.d.g del refuerzo
	set Ygr [lindex $valsSI 10]
	#área del trozo de plancha (sección)
	set Ap [expr $c*$h]
   
	#altura del refuerzo
	set hRef [lindex $valsSI 15]

#         set Ape [expr $h]
	set Ape [expr $h*$c]
	#inercia propia del trozo de plancha
	set Ipe [expr $Ape*$h*$h/12]
	#inercia propia de la plancha entera
	set Ip [expr $Ap*$h*$h/12]
	#c.d.g de la plancha
	set Ygp [expr $h/2]
#         #número de refuerzos
#         set nref [expr $a/$c-1] 

	#distancia entre la base del conjunto y el EN real
	set delta [expr ($Ape*$h/2+$Ar*$Ygr)/($Ar+$Ape)]
	#Finalmente, el momento de inercia del conjunto plancha entera + refuerzos,respecto al eje neutro, será
	set Ien [expr $Ape*$h*$h/4+$Ar*$Ygr*$Ygr+$Ir+$Ipe-($Ar+$Ape)*$delta*$delta]

	#El momento de inercia del refuerzo respecto a la sección media de la plancha, será(T.Steiner):
	set I [expr $Ir+$Ar*pow($Ygr+$h/2,2)]
	
#         Inercia de la sección en T, formada por el refuerzo y el trozo de plancha de ancho $c (respecto a su eje neutro) (IprT)
	set delta2 [expr ($Ape*$h/2+$Ar*($Ygr+$h))/($Ar+$Ape)]
	set IprT [expr $Ape*$h*$h/4+$Ar*($Ygr+$h)*($Ygr+$h)+$Ir+$Ipe-($Ar+$Ape)*$delta*$delta]
#         Inercia del refuerzo respecto al eje neutro del sistema
	set IrEN [expr $Ir+$Ar*pow($delta2,2)]
		
	

	set teq [expr pow(12*$IprT/$c, 1/3.0)]
	set t1 $h

	set dist1 [expr ($hRef + $h) - $delta2]
	set dist2 [expr $delta2]
	
	if {abs($dist1) >= abs($dist2)} {
	    set wx [expr $IprT/$dist1]            
	} else {
	    set wx [expr $IprT/$dist2]            
	}
	
#         set wx [expr $wx/(1.0*$c)]

	set aX [expr ($Ar+$h*$c)]
#         set teqPeso [expr ($Ar+$h*$c)/($c*1.0)]
	set teqPeso [expr $aX/($c*1.0)]
	
# hay que dar el peso específico por el espesor de la plancha equivalente
	set weightprom [expr $spcweight*$teqPeso]
	 
	set CoefAlpha [expr $h/$H]
	set alpha3 [expr $CoefAlpha*$CoefAlpha*$CoefAlpha]
		  
	       
#         set D1 [expr $nu*$t1*$t1*$t1*$E/((1-$nu*$nu)*12.0)]

	if {$stiffdir=="x"} {
	    set Dx [expr $E*$IrEN/$c + $E*pow($h,3)/(12*(1-$nu*$nu))]
	    set Dy [expr $E*pow($teq,3)/(12*(1-$nu*$nu))] 

#             set Dx [expr $E*$IrEN/$c + $E*pow($h,3)/(12*(1-$nu*$nu))]
#             set Dy [expr $E*pow($h,3)/(12*(1-$nu*$nu))] 
# OK
#             set Dx [expr $E*$IprT/(4.0*$c) + $teq*$teq*$teq*$E/((1-$nu*$nu)*12.0)]
#             set Dy [expr $teq*$teq*$teq*$E/((1-$nu*$nu)*12.0)]


	} else {
	    set Dy [expr $E*$IrEN/$c + $E*pow($h,3)/(12*(1-$nu*$nu))]
	    set Dx [expr $E*pow($teq,3)/(12.0*(1-$nu*$nu))]

#             set Dy [expr $E*$IrEN/$c + $E*pow($h,3)/(12*(1-$nu*$nu))]
#             set Dx [expr $E*pow($h,3)/(12.0*(1-$nu*$nu))]

# OK
#             set Dy [expr $E*$IprT/(4.0*$c) + $teq*$teq*$teq*$E/((1-$nu*$nu)*12.0)]
#             set Dx [expr $teq*$teq*$teq*$E/((1-$nu*$nu)*12.0)]
	}
   



	#módulo de torsión de los refuerzos
	set Jcoefkk [expr ($H+53.0*$e)*$e*$e*$e]
	set Jcoef [expr ($H+$e)*$e*$e*$e]
	#rigidez a torsión de un refuerzo
	set Ccoef [expr $G*$Jcoef]
#         set Dxyp [expr $G*$h*$h*$h/12.0]
#         set Dxy [expr $Dxyp + $Ccoef/(2.0*$c)]
	set Dxy [expr $G*$teq*$teq*$teq/12.0]
	
	
	# matriz Df
	set fact [expr 1/(1-$nu*$nu)]
	set DF11 [expr $fact*$E]
	set DF12 [expr $fact*$nu*$E]
	set DF33 [expr $G]
	
	#coeficiente "alpha"-->5/6 .Como aproximación
	set alpha 0.83333333
		
	
#         #^Dm    
	set Dm11 [expr $teq*$DF11]
#         set Dm11kk [expr $t1*$DF11 - 2.0*$E*$Ar*$Ygr/$t1]
	set Dm22 [expr $teq*$DF11]
	set Dm12 [expr $teq*$DF12]
	set Dm13 0.0 
	set Dm21 $Dm12 
	set Dm31 0.0 
	set Dm23 0.0 
	set Dm32 0.0
	set Dm33 [expr $teq*$DF33]
#         set Dm33 [expr $t1*$E/(2.0*(1+$nu))]

#         #^Dmf
	set Dmf11 [expr $teq*$teq*$DF11/4.0] 
	set Dmf22 [expr $teq*$teq*$DF11/4.0] 
	set Dmf12 [expr $teq*$teq*$DF12/4.0]
	set Dmf13 0.0 
	set Dmf21 $Dmf12
	set Dmf31 0.0 
	set Dmf23 0.0 
	set Dmf32 0.0
	set Dmf33 [expr $teq*$teq*$DF33/4.0]

	#^Df
	set Df11 $Dx 
	set Df22 $Dy 
	set Df12 [expr $teq*$teq*$teq*$DF12/12.0]
	set Df13 0.0 
	set Df21 $Df12 
	set Df31 0.0 
	set Df23 0.0 
	set Df32 0.0
	set Df33 $Dxy
	set Df33 [expr $teq*$teq*$teq*$DF33/12.0]
 
	#^Dc
	set Dc11 [expr $teq*$alpha*$G]
	set Dc22 $Dc11
	set Dc12 0.0
	set Dc21 0.0
	
	
	set Dm [list $Dm11 $Dm12 $Dm13 \
		$Dm21 $Dm22 $Dm23 \
		$Dm31 $Dm32 $Dm33]
	set Df [list $Df11 $Df12 $Df13 \
		$Df21 $Df22 $Df23 \
		$Df31 $Df32 $Df33]
	set Dmf [list $Dmf11 $Dmf12 $Dmf13 \
		$Dmf21 $Dmf22 $Dmf23 \
		$Dmf31 $Dmf32 $Dmf33]
	set Dc [list $Dc11 $Dc12 \
		$Dc21 $Dc22 ]    
	
	   
	return [list $Dm $Df $Dmf $Dc $wx $aX]    
	
    }
}

proc stiff::viewDmatrix {} {

    variable Dm ""
    variable Df ""
    variable Dmf ""
    variable Dc ""
    variable stiffenervals
    variable valsSI
    variable wx ""
    
#     if { [info exists stiffenervals] } {
#         stiff::units [llength $stiffenervals]
#     } else {
#         WarnWin [= "Constitutive D_Matrix not calculated yet"] 
#         return 
#     }
    
    if { $valsSI == "0.0" } {
	WarnWin [= "Constitutive D_Matrix not calculated yet"] 
	return 
    }

    set flag 1
#     stiff::errcntrl
    stiff::calculateDok
    
    if {$Dm == "" || $Df == "" || $Dmf == "" || $Dc == ""} {
	WarnWin [= "Constitutive D_Matrix not calculated yet"] 
	    return 
    }   

    set w4 .matrix
    catch {destroy $w4}
    toplevel $w4
    wm title $w4 [= "Constitutive Matrix"]
    set w4f [frame $w4.ventana -borderwidth 2 -relief groove]
    
    
    set mb11 [label $w4f.mb11 -text Dm11 -relief flat]
    set mbd11 [label $w4f.mbd11 -text [lindex $Dm 0] -relief sunken]    
    set mb12 [label $w4f.mb12 -text Dm12 -relief flat]
    set mbd12 [label $w4f.mbd12 -text [lindex $Dm 1] -relief sunken]
    set mb13 [label $w4f.mb13 -text Dm13 -relief flat]
    set mbd13 [label $w4f.mbd13 -text [lindex $Dm 2] -relief sunken]
    set mb21 [label $w4f.mb21 -text Dm21 -relief flat]
    set mbd21 [label $w4f.mbd21 -text [lindex $Dm 3] -relief sunken]
    set mb22 [label $w4f.mb22 -text Dm22 -relief flat]
    set mbd22 [label $w4f.mbd22 -text [lindex $Dm 4] -relief sunken]
    set mb23 [label $w4f.mb23 -text Dm23 -relief flat]
    set mbd23 [label $w4f.mbd23 -text [lindex $Dm 5] -relief sunken]
    set mb31 [label $w4f.mb31 -text Dm31 -relief flat]
    set mbd31 [label $w4f.mbd31 -text [lindex $Dm 6] -relief sunken]
    set mb32 [label $w4f.mb32 -text Dm32 -relief flat]
    set mbd32 [label $w4f.mbd32 -text [lindex $Dm 7] -relief sunken]
    set mb33 [label $w4f.mb33 -text Dm33 -relief flat]
    set mbd33 [label $w4f.mbd33 -text [lindex $Dm 8] -relief sunken]
    
    
    set fb11 [label $w4f.fb11 -text Df11 -relief flat]
    set fbd11 [label $w4f.fbd11 -text [lindex $Df 0] -relief sunken]    
    set fb12 [label $w4f.fb12 -text Df12 -relief flat]
    set fbd12 [label $w4f.fbd12 -text [lindex $Df 1] -relief sunken]
    set fb13 [label $w4f.fb13 -text Df13 -relief flat]
    set fbd13 [label $w4f.fbd13 -text [lindex $Df 2] -relief sunken]
    set fb21 [label $w4f.fb21 -text Df21 -relief flat]
    set fbd21 [label $w4f.fbd21 -text [lindex $Df 3] -relief sunken]
    set fb22 [label $w4f.fb22 -text Df22 -relief flat]
    set fbd22 [label $w4f.fbd22 -text [lindex $Df 4] -relief sunken]
    set fb23 [label $w4f.fb23 -text Df23 -relief flat]
    set fbd23 [label $w4f.fbd23 -text [lindex $Df 5] -relief sunken]
    set fb31 [label $w4f.fb31 -text Df31 -relief flat]
    set fbd31 [label $w4f.fbd31 -text [lindex $Df 6] -relief sunken]
    set fb32 [label $w4f.fb32 -text Df32 -relief flat]
    set fbd32 [label $w4f.fbd32 -text [lindex $Df 7] -relief sunken]
    set fb33 [label $w4f.fb33 -text Df33 -relief flat]
    set fbd33 [label $w4f.fbd33 -text [lindex $Df 8] -relief sunken]
    
    set mfb11 [label $w4f.mfb11 -text Dmf11 -relief flat]
    set mfbd11 [label $w4f.mfbd11 -text [lindex $Dmf 0] -relief sunken]    
    set mfb12 [label $w4f.mfb12 -text Dmf12 -relief flat]
    set mfbd12 [label $w4f.mfbd12 -text [lindex $Dmf 1] -relief sunken]
    set mfb13 [label $w4f.mfb13 -text Dmf13 -relief flat]
    set mfbd13 [label $w4f.mfbd13 -text [lindex $Dmf 2] -relief sunken]
    set mfb21 [label $w4f.mfb21 -text Dmf21 -relief flat]
    set mfbd21 [label $w4f.mfbd21 -text [lindex $Dmf 3] -relief sunken]
    set mfb22 [label $w4f.mfb22 -text Dmf22 -relief flat]
    set mfbd22 [label $w4f.mfbd22 -text [lindex $Dmf 4] -relief sunken]
    set mfb23 [label $w4f.mfb23 -text Dmf23 -relief flat]
    set mfbd23 [label $w4f.mfbd23 -text [lindex $Dmf 5] -relief sunken]
    set mfb31 [label $w4f.mfb31 -text Dmf31 -relief flat]
    set mfbd31 [label $w4f.mfbd31 -text [lindex $Dmf 6] -relief sunken]
    set mfb32 [label $w4f.mfb32 -text Dmf32 -relief flat]
    set mfbd32 [label $w4f.mfbd32 -text [lindex $Dmf 7] -relief sunken]
    set mfb33 [label $w4f.mfb33 -text Dmf33 -relief flat]
    set mfbd33 [label $w4f.mfbd33 -text [lindex $Dmf 8] -relief sunken]
    
    set cb11 [label $w4f.cb11 -text Dc11 -relief flat]
    set cbd11 [label $w4f.cbd11 -text [lindex $Dc 0] -relief sunken]    
    set cb12 [label $w4f.cb12 -text Dc12 -relief flat]
    set cbd12 [label $w4f.cbd12 -text [lindex $Dc 1] -relief sunken]
    set cb21 [label $w4f.cb21 -text Dc21 -relief flat]
    set cbd21 [label $w4f.cbd21 -text [lindex $Dc 2] -relief sunken]
    set cb22 [label $w4f.cb22 -text Dc22 -relief flat]
    set cbd22 [label $w4f.cbd22 -text [lindex $Dc 3] -relief sunken]
    
    grid columnconf $w4 0 -weight 1
    #    grid rowconf $w4 0 -weight 1
    
    grid $w4f -row 0 -column 0 -sticky ew
    #grid columnconf $w4f 0 -weight 1
    #grid rowconf $w4f 0 -weight 1
    grid $mb11 -row 0 -column 0
    grid $mbd11 -row 0 -column 1
    grid $mb12 -row 0 -column 2
    grid $mbd12 -row 0 -column 3
    grid $mb13 -row 0 -column 4
    grid $mbd13 -row 0 -column 5
    grid $mb21 -row 1 -column 0
    grid $mbd21 -row 1 -column 1
    grid $mb22 -row 1 -column 2
    grid $mbd22 -row 1 -column 3
    grid $mb23 -row 1 -column 4
    grid $mbd23 -row 1 -column 5
    grid $mb31 -row 2 -column 0
    grid $mbd31 -row 2 -column 1
    grid $mb32 -row 2 -column 2
    grid $mbd32 -row 2 -column 3
    grid $mb33 -row 2 -column 4
    grid $mbd33 -row 2 -column 5
    grid configure $mbd11 $mbd12 $mbd13 \
	$mbd21 $mbd22 $mbd23 \
	$mbd31 $mbd32 $mbd33 -sticky news
    
    grid $fb11 -row 3 -column 0
    grid $fbd11 -row 3 -column 1
    grid $fb12 -row 3 -column 2
    grid $fbd12 -row 3 -column 3
    grid $fb13 -row 3 -column 4
    grid $fbd13 -row 3 -column 5
    grid $fb21 -row 4 -column 0
    grid $fbd21 -row 4 -column 1
    grid $fb22 -row 4 -column 2
    grid $fbd22 -row 4 -column 3
    grid $fb23 -row 4 -column 4
    grid $fbd23 -row 4 -column 5
    grid $fb31 -row 5 -column 0
    grid $fbd31 -row 5 -column 1
    grid $fb32 -row 5 -column 2
    grid $fbd32 -row 5 -column 3
    grid $fb33 -row 5 -column 4
    grid $fbd33 -row 5 -column 5
    grid configure $fbd11 $fbd12 $fbd13 \
	$fbd21 $fbd22 $fbd23 \
	$fbd31 $fbd32 $fbd33 -sticky news
    
    grid $mfb11 -row 6 -column 0
    grid $mfbd11 -row 6 -column 1
    grid $mfb12 -row 6 -column 2
    grid $mfbd12 -row 6 -column 3
    grid $mfb13 -row 6 -column 4
    grid $mfbd13 -row 6 -column 5
    grid $mfb21 -row 7 -column 0
    grid $mfbd21 -row 7 -column 1
    grid $mfb22 -row 7 -column 2
    grid $mfbd22 -row 7 -column 3
    grid $mfb23 -row 7 -column 4
    grid $mfbd23 -row 7 -column 5
    grid $mfb31 -row 8 -column 0
    grid $mfbd31 -row 8 -column 1
    grid $mfb32 -row 8 -column 2
    grid $mfbd32 -row 8 -column 3
    grid $mfb33 -row 8 -column 4
    grid $mfbd33 -row 8 -column 5
    grid configure $mfbd11 $mfbd12 $mfbd13 \
	$mfbd21 $mfbd22 $mfbd23 \
	$mfbd31 $mfbd32 $mfbd33 -sticky news
    
    grid $cb11 -row 9 -column 0
    grid $cbd11 -row 9 -column 1
    grid $cb12 -row 9 -column 2
    grid $cbd12 -row 9 -column 3
    grid $cb21 -row 10 -column 0
    grid $cbd21 -row 10 -column 1
    grid $cb22 -row 10 -column 2
    grid $cbd22 -row 10 -column 3
    grid configure $cbd11 $cbd12 \
	$cbd21 $cbd22 -sticky news
    
    return
}
proc stiff::errcntrl {} {
#     variable stiffdir
#     variable thickness 
#     variable clearance
    variable flag
#     variable spcweight
  
    foreach "var description max min" [list $stiff::thickness "Thickness" 0.1 0.0 \
	    $stiff::clearance "Clearance" 5 0.0 \
	    $stiff::spcweight "Spec. Weight" 100000 0.0] {
	if {![string is double $var] } {
	    WarnWin [= "Please check inserted data"] 
	    set flag 0
	    destroy $stiff::w
	    return ""
	}
	if {$max != ""} {
	    if {$var <= $min || $var >= $max} {
		WarnWin [= "Please check inserted data"] 
		set flag 0
		destroy $stiff::w
		return "" 
	    }
	} 
    }   
    return 
}

proc stiff::ComunicateWithGiD { op args } {   
    variable stiffenervals
    variable clearance
    variable thickness
    variable stiffdir
    variable stiffname
    variable valsSI
    variable weightprom
    variable spcweight
    variable stiffmat

    
    switch $op {
	"INIT" {
	    set PARENT [lindex $args 0]
	    upvar [lindex $args 1] ROW
	    set GDN [lindex $args 2]
	    set STRUCT [lindex $args 3]
	    
	    set f [frame $PARENT.f]
	    set stiff::path $::lsdynaPriv(problemtypedir)

	
	    stiff::Init $f $args
	    
	    set thick [DWLocalGetValue $GDN $STRUCT StiffThickness]
	    set clear [DWLocalGetValue $GDN $STRUCT StiffClearance]           
	    set stiffdir [string trim [DWLocalGetValue $GDN $STRUCT StiffDirection]]
	    set stiffname [string trim [DWLocalGetValue $GDN $STRUCT StiffName]]
	    set stiffmat [string trim [DWLocalGetValue $GDN $STRUCT StiffMat]]            
	    set valsSI [lrange [DWLocalGetValue $GDN $STRUCT StiffProperties] 2 end]
	    set weightprom [string trim [DWLocalGetValue $GDN $STRUCT StiffWeight]]
	    set spcweight [string trim [DWLocalGetValue $GDN $STRUCT Specific_weight]]
	    
	    unset -nocomplain stiffenervals

	    if { $clear ne " " } {
		set clearance $clear
	    }
	    if { $thick ne " " } {
		set thickness $thick
	    }
	  
	    grid $f -row $ROW -column 0 -sticky nsew -columnspan 2 -pady 3 -padx 2
	    grid rowconf $PARENT $ROW -weight 1
	    grid columnconf $PARENT 1 -weight 1
	    
	    return ""
	}
	"SYNC" {
	    set GDN [lindex $args 0]
	    set STRUCT [lindex $args 1]

	    set flag 1
	    errcntrl

	    DWLocalSetValue $GDN $STRUCT StiffThickness $thickness
	    DWLocalSetValue $GDN $STRUCT StiffClearance $clearance
	    DWLocalSetValue $GDN $STRUCT StiffDirection $stiffdir
	    DWLocalSetValue $GDN $STRUCT StiffName $stiffname
	    DWLocalSetValue $GDN $STRUCT StiffMat $stiffmat
	    set props "#N# [llength $valsSI] $valsSI"
	    DWLocalSetValue $GDN $STRUCT StiffProperties $props
	    DWLocalSetValue $GDN $STRUCT StiffWeight $weightprom
	    DWLocalSetValue $GDN $STRUCT Specific_weight $spcweight
	    return ""
	}
    }
    
}


# proc stiff::WriteDMatrix { datalist } {
#     variable clearance
#     variable stiffdir
#     variable thickness
#     variable spcweight
#     variable weightprom
#     variable valsSI
#     variable flag
#     variable bas_materials
#     variable stiffmat
# 
#     array unset bas_materials
#     set _ ""
#     set matnum [expr {[llength [GiD_Info materials]]+1}]
# 
#     set data [GiD_Info conditions Stiffened_shell mesh]
#     if { ![llength $data] } { return "" }
# 
#     append _ "materials\n"
    
#     set valsSI [lrange $props 2 end]
    
#     if {$stiffmat == "A37"} {
#         set maxStress 2.352e8
#     } elseif {$stiffmat == "A42"} {
#         set maxStress 2.548e8
#     } else {
#         set maxStress 3.528e8
#     }
#     
#     foreach "Dm Df Dmf Dc wx aX" [calculateDok $datalist] break
#     
#     set aY $aX
#     set aT $aX
#     set aTx $aX
#     set aTy $aX
#     set wy $wx 
#     set wt $wx

    
    
#         append _ "$matnum Units=N-m-kg "
#         append _ "Dm=$Dm Df=$Df Dmf=$Dmf Dc=$Dc Weight=$weightprom Maximum_stress=$maxStress \
#         Wx=$wx Wy=$wy Wt=$wt Ax=$aX Ay=$aY At=$aT Atx=$aTx Aty=$aTy\n"
#         
# }

# proc stiff::WriteQuadsInBasFile {} {
#     return [WriteTrianglesQuadsInBasFile Quadrilateral]
# }
# 
# proc stiff::WriteTrianglesInBasFile {} {
#     return [WriteTrianglesQuadsInBasFile Triangle]
# }
# 
# proc stiff::WriteTrianglesQuadsInBasFile { elemtype } {
#     variable bas_materials
# 
#     set _ ""
#     foreach i [GiD_Info conditions -localaxes Stiffened_shell mesh] {
#         foreach "- num - localaxes units thickness clearance stiffdir name stiffmat props weightprom spcweight" $i break
#         set ret [GiD_Info Mesh Elements $elemtype $num]
#         if { ![llength $ret] } { continue }
#         set key [list $thickness $clearance $stiffdir $name $stiffmat $weightprom $spcweight]
#         append _ [lreplace $ret end end $bas_materials($key)]
#  
# #        if { $localaxes != "-Default-" } {
# #             append _ " "
# #             append _ [eval format [list {Euler1=%.15g Euler2=%.15g Euler3=%.15g}]\
# #                     $localaxes]
# #         }
# 
#         if { [llength $localaxes] == 3 } {
# #             append _ " "
# #             append _ "StiffenedShell"
#             append _ " "
#             append _ [eval format [list {StiffEuler1=%.15g StiffEuler2=%.15g StiffEuler3=%.15g}]\
#                     $localaxes]
#         }
# 
#         append _ "\n"
#     }
# 
#     return $_
# }

##############################
##############################
##############################

proc stiff::Create { frame } {
    variable tree
    variable imglabel
    variable text
    variable zposition
    variable to_h_button

    set pw    [PanedWindow $frame.pw -side top]

    set pane  [$pw add -weight 1]
    set title [TitleFrame $pane.lf -text [= "steel sections"]]
    set sw    [ScrolledWindow [$title getframe].sw \
		  -relief sunken -borderwidth 2]
    set tree  [Tree $sw.tree \
	    -relief flat -borderwidth 0 -width 15 -highlightthickness 0\
	    -redraw 0 -dropenabled 1 -dragenabled 1 \
	    -dragevent 3 \
	    -droptypes { \
	    TREE_NODE    {copy {} move {} link {}} \
	    LISTBOX_ITEM {copy {} move {} link {}} \
	} \
	-opencmd   "stiff::ModTree 1" \
	-closecmd  "stiff::ModTree 0"]
    $sw setwidget $tree

    if {[string equal "unix" $::tcl_platform(platform)]} {
	bind [winfo toplevel $sw.tree] <4> "$sw.tree yview scroll -5 units"
	bind [winfo toplevel $sw.tree] <5> "$sw.tree yview scroll  5 units"
    }

    set title2 [TitleFrame $pane.lf2 -text [= "material"]]
    tk_optionMenu [$title2 getframe].om stiff::material A37 A42 A52
    set stiff::material A42
    
    pack $sw    -side top  -expand yes -fill both
    pack [$title2 getframe].om -side top  -expand yes -fill x
    pack $title2 -fill x
    pack $title -fill both -expand yes
    
    set pane [$pw add -weight 2]
    set lf   [labelframe $pane.lf -text [= "visual description"]]
    set imglabel [Label $lf.l -bd 2 -relief raised]
    set hlp [= "Position of the center (related to the natural center)"]
    Label $lf.l2 -text [= "Z axe position:"] -helptext $hlp
    spinbox $lf.sp1 -from 0 -to 1e4 -increment .5 -textvariable \
	stiff::zposition -width 4
    Label $lf.l3 -text cm -helptext $hlp
    Button $lf.b1 -text [= "Reset"] -helptext \
	[= "Sets 'Z axe position' equal to 0"] -command \
	[list set stiff::zposition 0.0] -width 6 -bd 1 -relief link
    set to_h_button [Button $lf.b2 -text "h/2"  -width 6 -bd 1  -relief link \
	    -helptext [= "Sets 'Z axe position' equal to h/2"] -state disabled]

    set zposition 0.0

    set cmd "[list stiff::UpdateZposition $tree] ;#"
    trace add variable stiff::zposition write $cmd
    bind $lf.sp1 <Destroy> [list trace remove variable \
	    stiff::zposition write $cmd]

    set lf2 [TitleFrame $pane.lf2 -text [= "properties"]]
    set sw    [ScrolledWindow [$lf2 getframe].sw]
    set text [text $sw.t -height 3 -width 10 -highlightthickness 0 -state disabled -wrap none]
    set textfam [font actual [$text cget -font] -family]
    set textsize [font actual [$text cget -font] -size]
    set stextsize [expr {$textsize-2}]
    
    if { [font actual [list $textfam $stextsize]] eq \
	[font actual [list $textfam $textsize]] } {
	set smallfont [list Helvetica $stextsize]
    } else {
	set smallfont [list $textfam $stextsize]
    }
    
    $text tag conf superindex -offset [expr [font metrics [$text cget -font] \
		-linespace]/3] -font $smallfont
    $text tag conf bold -font [list $textfam $textsize bold]
    
    $sw setwidget $text
    pack $sw -fill both -expand yes
    bind $text <1> "focus %W"

    pack $lf -fill x -expand 0
    pack $lf2 -fill both -expand yes
    grid $imglabel - - - - -sticky n
    grid $lf.l2 $lf.sp1 $lf.l3 $lf.b1 $to_h_button -sticky nw -padx 2 -pady 3
    #pack $text -fill both -expand 1
    grid columnconf $lf 4 -weight 1

    pack $pw -fill both -expand yes

    $tree bindText  <ButtonPress-1>        "stiff::Select 1"
    $tree bindText  <Double-ButtonPress-1> "stiff::Select 2"
    $tree bindImage  <ButtonPress-1>        "stiff::Select 1"
    $tree bindImage  <Double-ButtonPress-1> "stiff::Select 2"
    # dirty trick
#     foreach i [bind $tree.c] {
#         bind $tree.c $i "+ [list after idle [list stiff::Select 0 {}]]"
#     }
#      set bbox [ButtonBox $frame.bb -spacing 3 -padx 12 -pady 0 -homogeneous 1]
#      $bbox add -text [= Apply] -underline 0
#      $bbox add -text [= Close] -command "exit" -underline 0
#      $bbox setfocus 0
#      pack $bbox -pady 3

#      bind [winfo toplevel $frame] <Alt-a> "$bbox invoke 0"
#      bind [winfo toplevel $frame] <Alt-c> "$bbox invoke 1"

   stiff::Init2
}


proc stiff::Init2 { args } {
    variable DataTypes
    variable CustomSteelSections
    variable Data
    variable Units
    variable Description
    #variable Id
    variable Images
    variable tree
    variable path2
    variable IsDataRead

    if { [info exists ::lsdynaPriv(problemtypedir)] } {
	set path2 $::lsdynaPriv(problemtypedir)
    } else {
	set path2 $::ProblemTypePriv(problemtypedir)
    }

    if { !$IsDataRead } {
	catch { unset Description Id Units Data }
	set DataTypes ""
	set CustomSteelSections ""
	ReadData [file join $path2 scripts steelsections.csv]
	ReadData [file join $path2 scripts steelsections-custom.csv] iscustom
    }
    if { ![info exists tree] || ![winfo exists $tree] } { return }

    foreach i $DataTypes {
	$tree insert end root $i -text $i -open 0 \
		-image [Bitmap::get folder] -drawcross allways -data $i
    }
    Select 1 [lindex $DataTypes 0]
    $tree configure -redraw 1
}


proc stiff::ReadData { file { iscustom no } } {
    variable DataTypes
    variable CustomSteelSections
    variable Description
    variable Data
    variable Units
    variable Comments
    variable IsDataRead

    set descs [list name A Iy Iz Iyz J Wy Wz Aty Atz Yg Zg Comments]
    set units [list - m2 m4 m4 m4 m4 m3 m3 m2 m2 m m]

    set f [open $file r]
    while { ![eof $f] } {
	gets $f aa
	set list [split $aa ";\t"]
	if { [llength $list] != [llength $descs] } { continue }
	if { [string equal -nocase [lindex $list 0] [lindex $descs 0]] } { continue }
	set rname [lindex $list 0]
	set name [split $rname -]
	set sname [lindex $name 0]
	set Description($sname) $descs
	if { [lsearch -exact $DataTypes $sname] == -1 } {
	    lappend DataTypes $sname
	}
	if { $iscustom eq "iscustom" && [lsearch -exact $CustomSteelSections $rname] == -1 } {
	    lappend CustomSteelSections $rname
	}
	set Data($name) $list
	set Units($sname) $units
    }
    set CustomSteelSections [lsort $CustomSteelSections]
    set IsDataRead 1
}


proc stiff::Select { num node } {
    variable dblclick
    variable Images
    variable tree
    variable imglabel
    variable text
    variable Data
    variable Description
    variable Units
    variable zposition
    variable to_h_button
    variable material

    set zposition 0.0

    if { $num == 0 } {
	#if { ![winfo exists $node] } { return }
	set node [$tree selection get]
	if { [llength $node] != 1 } { return }
    } elseif { ![$tree exists $node] } {
	TryToCreateNode $node
    }
    set dblclick 1
    if { $num == 1 || $num == 0 } {
       if { $num == 1 && [lsearch [$tree selection get] $node] != -1 } {
	    unset dblclick
	   # it can be used to let the user modify on value in the tree
	   #after 500 "SteelSections::Edit $node"
	   return
	}
	$tree selection set $node
	$tree see $node
	set parent [$tree parent $node]
	while { $parent != "root" } {
	    if { [$tree itemcget $parent -open] == 0 } {
		$tree itemconfigure $parent -open 1
	    }
	    set parent [$tree parent $parent]
	}
	#update
	set name [split $node -]
	set type [lindex $name 0]

	CreateImages $type

	$imglabel configure -image $Images($type) \
		-width [image width $Images($type)]
	$text conf -state normal
	$text del 1.0 end

	if { [info exists Data($name)] } {
	    set infostiffval [list jarenau]
	    set infostiffunits [list jarenau]
	    set stiffcomments [list jarenau]
	    set icount 0
	    foreach i $Description($type) {
		if { [regexp {^(char|int|name)} $i] } { continue }
		set pos [lsearch $Description($type) $i]
		if { $i eq "Comments" } {
		    $text insert end "\n"
		    InsertPropertyInText $text [= "Z axe position"] 0.0 cm
		    $text insert end "\n\n"
		    foreach j [split [lindex $Data($name) $pos]] {
		        if { [regexp {=} $j] } {
		            foreach "name val" [split $j =] {
		                if { [regexp {(.*)(m\d?)} $val {} val unit] } {
		                    lappend stiffcomments $name
		                    lappend stiffcomments $val
		                    set ipos [lsearch [list m m2 m3 m4] $unit]
		                    if { $ipos != -1 } {
		                        set unit [lindex [list cm cm2 cm3 cm4] $ipos]
		                        set val [format "%.4g" [ConvertValuesFromSI $val $unit]]
		                    }
		                } else { set unit - }
		                InsertPropertyInText $text $name $val $unit
		                if { $name eq "h" } {
		                    set h_value $val
		                }
		            }
		            incr icount
		        } else {
		            $text insert end "$j "
		        }
		        if { $icount == 3 } { 
		            $text ins end "\n"
		            set icount 0
		        }
		    }
		} else {
		    set val [lindex $Data($name) $pos]
		    if { $val eq "" || $val eq "-" } { continue }
		    set unit  [lindex $Units($type) $pos]
		    set ipos [lsearch [list m m2 m3 m4] $unit]
		    if { $ipos != -1 } {
		        set unit [lindex [list cm cm2 cm3 cm4] $ipos]
		        if { $val ne "" } {
		            set val [format "%.4g" [ConvertValuesFromSI $val $unit]]
		        }
		    }
		    lappend infostiffval [lindex $Data($name) $pos]
		    lappend infostiffunits [lindex $Units($type) $pos]
		    InsertPropertyInText $text $i $val $unit
		    if { $i eq "Zg" } { set Zg_value $val }
		}
		incr icount
		if { $icount == 3 } { 
		    $text ins end "\n"
		    set icount 0
		}
	    }
	    stiff::choosestifflabel $node $infostiffval $infostiffunits $stiffcomments $material
	}

	

	$text conf -state disabled

	if { ![info exists h_value] } {
	    $to_h_button configure -state disabled
	} else {
	    if { [info exists Zg_value] } {
		if { $h_value-$Zg_value > $Zg_value } {
		    set val [expr {$h_value-$Zg_value}]
		} else { set val $Zg_value }
		set txt Zg
	    } else {
		set txt h/2
		set val [expr {.5*$h_value}]
	    }
	    set val [format "%.4g" $val]
	    $to_h_button configure -state normal -text $txt -command \
		[list set stiff::zposition $val]
	}
    } else {
	if { [$tree itemcget $node -open] == 0 } {
	    $tree itemconfigure $node -open 1
	    set idx 1
	} else {
	    $tree itemconfigure $node -open 0
	    set idx 0
	}
	ModTree $idx $node
    }
}

proc stiff::CreateImages { datatype } {
    variable Images
    variable path

    if { [info exists Images($datatype)] } { return }

    set imgname profile_$datatype.gif
    if { [string match profile_HE* $imgname] } {
	set imgname profile_HE.gif
    }
    if { [string match profile_NavalT $imgname] } {
	set imgname profile_NAVALT.gif
    }
    if { [catch {
	set Images($datatype) [image create photo -file [file join $path images steelsections $imgname]]
    }] } {
	if { ![info exists Images(profile_blank.gif)] } {
	    set Images(blank) [image create photo -file [file join $path images steelsections \
		                                             profile_blank.gif]]
	}
	set Images($datatype) $Images(blank)
    }
    set imgname icon_$datatype.gif

    if { [string match icon_*F.gif $imgname] } {
	regexp {icon_(.*)F} $imgname {} img
	set imgname icon_$img.gif
    }
    if { $imgname == "icon_U.gif" } {
	set imgname icon_UPN.gif
    }
     if { [string match icon_HE* $imgname] } {
	set imgname icon_H.gif
    }
    if { [string match icon_IP* $imgname] } {
	set imgname icon_IP.gif
    }
    if { [string match icon_L* $imgname] } {
	set imgname icon_L.gif
    }
    if { [catch {
	set Images(icon,$datatype) [image create photo -file [file join $path images steelsections $imgname]]
    }] } {
	if { ![info exists Images(icon_blank.gif)] } {
	    set Images(icon,blank) [image create photo -file [file join $path images steelsections \
		                                                  icon_blank.gif]]
	}
	set Images(icon,$datatype) $Images(icon,blank)
    }
}


proc stiff::UpdateZposition { tree } {
    variable zposition
    variable text

    if { ![winfo exists $tree] } { return }
    set node [$tree selection get]
    if { [llength $node] != 1 } { return }
    set name [split $node -]
    set type [lindex $name 0]

    foreach i [list A Iy Wy] {
	set $i ""
	foreach "$i -" [_getvalue $name $i] break
	if { [set $i] eq "" } { return }
    }
    set zg [expr {1.0*$Iy/$Wy}]
    set Iy [expr {$Iy+$zposition*$zposition*$A}]
    set Wy [expr {$Iy/($zg+abs($zposition))}]
    set "Z axe position" $zposition

    $text conf -state normal
    foreach i [list "Z axe position" Iy Wy] {
	set i1 ""
	foreach "i1 i2" [$text tag nextrange name=$i 1.0] break
	if { $i1 eq "" } { continue }
	$text delete $i1 $i2
	$text insert $i1 [format %.4g [set $i]] [list name=$i]
    }
    $text conf -state disabled
}

proc stiff::ModTree { idx node } {
    variable tree
    variable Data
    variable Images

    if { $idx && [$tree itemcget $node -drawcross] == "allways" } {
	set data [$tree itemcget $node -data]
	CreateImages $data
	foreach j [lsort -command SortIndices [array names Data "$data *"]] {
	    $tree insert end $data [join $j -] -text [lrange $j 1 end] -open 0 \
		-image $Images(icon,$data)
	}
	$tree itemconfigure $node -drawcross auto
    }
    if { [llength [$tree nodes $node]] } {
	if { $idx } {
	    $tree itemconfigure $node -image [Bitmap::get openfold]
	} else {
	    $tree itemconfigure $node -image [Bitmap::get folder]
	}
    }
}

proc stiff::_getvalue { name property } {
    variable Description
    variable Data
    variable Units

    set type [lindex $name 0]
    set pos [lsearch $Description($type) $property]
    if { $pos == -1 } { return ""}
    if { ![info exists Data($name)] } { return }
    set val [lindex $Data($name) $pos]
    set unit  [lindex $Units($type) $pos]
    set ipos [lsearch [list m m2 m3 m4] $unit]
    if { $ipos != -1 } {
	set unit [lindex [list cm cm2 cm3 cm4] $ipos]
	set val [format "%.4g" [ConvertValuesFromSI $val $unit]]
    }
    return [list $val $unit]
}

proc stiff::SortIndices { idx1 idx2 } {

    if { [lindex $idx1 1] < [lindex $idx2 1] } { return -1 }
    if { [lindex $idx1 1] > [lindex $idx2 1] } { return 1 }
    if { [lindex $idx1 2] < [lindex $idx2 2] } { return -1 }
    if { [lindex $idx1 2] > [lindex $idx2 2] } { return 1 }
    return 0
}

proc stiff::ConvertValuesFromSI { val unit } {

    if { $val == 0.0 || $val == 1} {
	return 1.0
    } else {
	switch $unit {
	    cm { return [expr $val*1e2] }
	    mm { return [expr $val*1e3] }
	    cm2 { return [expr $val*1e4] }
	    cm3 { return [expr $val*1e6] }
	    cm4 { return [expr $val*1e8] }
	    kp/m { return [expr $val/9.8] }
	    default {
		error "Unknown unit '$unit' "
		#tk_messageBox -message "Unknown unit '$unit' "
		exit
	    }
	}
    }
}

proc stiff::InsertPropertyInText { text name val units } {

    if { $val == "-" } { return }
    $text ins end $name bold
    $text ins end "="
    $text ins end "$val" [list name=$name]
    if { $units ne "-" } {
	for { set j 0 } { $j < [string length $units] } { incr j } {
	    set char [string index $units $j]
	    if { [string is digit $char] } {
		$text ins end $char superindex
	    } else {
		$text ins end $char
	    }
	}
    }
    $text ins end " "
}
