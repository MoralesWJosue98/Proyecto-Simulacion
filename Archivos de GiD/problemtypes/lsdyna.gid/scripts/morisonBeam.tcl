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


#######################################################
#######################################################

namespace eval morison {
    
    package require math::statistics
    package require math::linearalgebra 
    
    namespace import \
	::math::linearalgebra::mkMatrix \
	::math::linearalgebra::mkVector \
	::math::linearalgebra::matmul \
	::math::linearalgebra::getelem \
	::math::linearalgebra::setelem \
	::math::linearalgebra::axpy \
	::math::linearalgebra::add \
	::math::linearalgebra::sub \
	::math::linearalgebra::solveGauss \
	::math::statistics::max  
    
    variable flagCalc 0
    variable path ""
    variable nrows 4
    # Characteristics of the wave (m, s, Kg)
    variable waveHeight 
    variable InitPeriod 
#     variable FinalPeriod 12.0
    
    # Physical data (m, s, Kg)
    variable density 1025.0
    variable visc 1.2e6
    variable gravity 9.8
    variable zo 0.0
    
    # Structure definition (m, s, Kg)
    # Tipo Xmax Xmin Xg D     
    #Cylinders
    variable NofRefElems 4
    variable structuredata

    #Cilindros bajos verticales
    variable typecyl_1 [list   \
	    CVref 0.0 0.0 8.0 0.0 0.0 0.0 0.0 0.0 4.0 4.0 0.017 i1 ]
    #Cilindros altos verticales
    variable typecyl_2 [list   \
	    CV 0.0 0.0 23.0 0.0 0.0 8.0 0.0 0.0 15.5 1.5 0.017 i2]
    #Cilindros bajos Horizontales,seg�n "x"
    variable typecyl_3 [list   \
	    CHxref 6.0 0.0 7.285 2.0 0.0 7.285 4.0 0.0 7.285 1.57 0.017 i3]
    #Cilindros bajos Horizontales,seg�n "y"
    variable typecyl_4 [list   \
	    CHyref 0.0 6.0 7.285 0.0 2.0 7.285 0.0 4.0 7.285 1.57 0.017 i4]
    for {set icol 0} {$icol <= 12} {incr icol} {
	set structuredata(1,$icol) [lindex $typecyl_1 $icol]  
	set structuredata(2,$icol) [lindex $typecyl_2 $icol]  
	set structuredata(3,$icol) [lindex $typecyl_3 $icol]  
	set structuredata(4,$icol) [lindex $typecyl_4 $icol]  
    }
    
	    

    #For the complete structure
    variable draught 

    # Longitudinal (OX) metacentric height, and trasversal (OY) metacentric height
    variable GMT 
    variable GML 

    # Radii of gyration
    variable RofGx 
    variable RofGy 
    variable RofGz 
    
    #Centre of gravity
    variable CofGx 
    variable CofGy 
    variable CofGz 
    
    variable DsT 
    
    
    # Output file
    variable file {C:\Temp\morison.res}
    
    # Constants
    variable pi 3.14159265358979323846264
    variable twopi 6.28318530717958647692528
       
    variable 3x3 0
    variable 4x4 1  

#     variable PerNum 1
    variable DirNum  

    variable TotMass 0.0
    variable sumIx 0.0
    variable sumIy 0.0
    variable sumIz 0.0
    variable sumIflot 0.0
    variable VCTot 0.0
    variable KCiVCi 0.0

    variable Rs ""
    variable currDir 
    variable windDir 
    variable velWind 

    variable h_1 1.0
    variable h_2 15
    variable t_1 1
    variable t_2 20

    variable tubDiam

    variable ckBflag 0
       
}

proc morison::create_window {wp dict dict_units domNode} {
    variable w

    package require dialogwin
    destroy $wp.steelsections
    set w [dialogwin_snit $wp.steelsections -title [_ "Morison B-Loads"]]
    set f [$w giveframe]
    
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
WriteMorisonCustomLoad
#         accept
	
	set tclDataMorisonB [morison::WriteMorisonCustomLoad]

	dict set dict "MorisonTclCodeB" $tclDataMorisonB
	destroy $w
	
	return [list $dict $dict_units]
    }
    
}

proc morison::addelem { mt i j val } {
    set val0 [getelem $mt $i $j]
    setelem mt $i $j [expr $val0+$val]
}

proc morison::vecmax { vt0 vt1 } {
    set len [llength $vt0]
    set ret [mkVector $len 0.0]
    for {set i 0} {$i < $len} {incr i} {
	set a0 [getelem $vt0 $i]
	set a1 [getelem $vt1 $i]
	if { $a0 > $a1 } {
	    setelem ret $i 0 $a0
	} else {
	    setelem ret $i 0 $a1
	} 
    }
    return $ret
}


proc morison::geomDefinition {  } {
    variable nrows
    variable structuredata
    variable NofRefElems

    variable typecyl_1
    variable typecyl_2
    variable typecyl_3
    variable typecyl_4
    
    variable RofGx 
    variable RofGy 
    variable RofGz 
    
    variable CofGx 
    variable CofGy 
    variable CofGz 

    variable TotMass 
    variable sumIx 
    variable sumIy 
    variable sumIz 
    variable sumIflot
    variable DsT
    variable VCTot
    variable KCiVCi
    variable GMT
    variable GML


############################################################
# Ubicaci�n cilindros verticales (el 0 es el de referencia)
#
#     ^ Y
#     '
#     '
#     12 - 13 - 14 - 15
#     '    '    '    '
#     8  - 9  - 10 - 11
#     '    '    '    '
#     4  - 5  - 6  - 7
#     '    '    '    '
#     0  - 1  - 2  - 3 ---> X
#############################################################
# Ubicaci�n cilindros horizontales (el 0 es el de referencia 
# seg�n "x", y el 12 es el de referencia seg�n "y")
#     ^ Y
#     '
#     '
#     o  9  o  10 o  11 o
#     20    21    22   23
#     o  6  o  7  o  8  o
#     16    17    18   19
#     o  3  o  4  o  5  o
#     12    13    14   15
#     o  0  o  1  o  2  o ---> X
############################################################### 


    
    for {set i 0} {$i <= 15} {incr i} {
	set DGroup [lindex $typecyl_1 10] 
	set ThickGroup [lindex $typecyl_1 11]
	
	if {$i >= 0 && $i <= 3} {
	    set XMGroup [expr [lindex $typecyl_1 1] + $i*8.0]
	    set YMGroup [lindex $typecyl_1 2]
	    set ZMGroup [lindex $typecyl_1 3]
	    
	    set XmGroup [expr [lindex $typecyl_1 4] + $i*8.0]
	    set YmGroup [lindex $typecyl_1 5]
	    set ZmGroup [lindex $typecyl_1 6]
	    
	    set XgGroup [expr [lindex $typecyl_1 7] + $i*8.0]
	    set YgGroup [lindex $typecyl_1 8]
	    set ZgGroup [lindex $typecyl_1 9]
	    
		        
	    if { $i == 0 } { 
		set typecyl_1Group [list   \
		        CVref $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup] 
	    } else {
		set typecyl_1Group [list   \
		        CV $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]
	    }
	    
	} elseif {$i > 3 && $i <= 7} {
	    set XMGroup [expr [lindex $typecyl_1 1] + ($i-4)*8.0]
	    set YMGroup [expr [lindex $typecyl_1 2] + 8.0]
	    set ZMGroup [lindex $typecyl_1 3]
	    
	    set XmGroup [expr [lindex $typecyl_1 4] + ($i-4)*8.0]
	    set YmGroup [expr [lindex $typecyl_1 5] + 8.0]
	    set ZmGroup [lindex $typecyl_1 6]
	    
	    set XgGroup [expr [lindex $typecyl_1 7] + ($i-4)*8.0]
	    set YgGroup [expr [lindex $typecyl_1 8] + 8.0]
	    set ZgGroup [lindex $typecyl_1 9]
	    
	    set typecyl_1Group [list   \
		    CV $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]
	    
	} elseif {$i > 7 && $i <= 11} {
	    set XMGroup [expr [lindex $typecyl_1 1] + ($i-8)*8.0]
	    set YMGroup [expr [lindex $typecyl_1 2] + 16.0]
	    set ZMGroup [lindex $typecyl_1 3]
	    
	    set XmGroup [expr [lindex $typecyl_1 4] + ($i-8)*8.0]
	    set YmGroup [expr [lindex $typecyl_1 5] + 16.0]
	    set ZmGroup [lindex $typecyl_1 6]
	    
	    set XgGroup [expr [lindex $typecyl_1 7] + ($i-8)*8.0]
	    set YgGroup [expr [lindex $typecyl_1 8] + 16.0]
	    set ZgGroup [lindex $typecyl_1 9]
	    
	    set typecyl_1Group [list   \
		    CV $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]
	    
	} elseif {$i > 11 && $i <= 15} {
	    set XMGroup [expr [lindex $typecyl_1 1] + ($i-12)*8.0]
	    set YMGroup [expr [lindex $typecyl_1 2] + 24.0]
	    set ZMGroup [lindex $typecyl_1 3]
	    
	    set XmGroup [expr [lindex $typecyl_1 4] + ($i-12)*8.0]
	    set YmGroup [expr [lindex $typecyl_1 5] + 24.0]
	    set ZmGroup [lindex $typecyl_1 6]
	    
	    set XgGroup [expr [lindex $typecyl_1 7] + ($i-12)*8.0]
	    set YgGroup [expr [lindex $typecyl_1 8] + 24.0]
	    set ZgGroup [lindex $typecyl_1 9]
	    
	    set typecyl_1Group [list   \
		    CV $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]
	}
	
	
	set NofRefElems [expr $i + 1]
	set NumRows [expr $i + 1] 
#         $datost configure -rows $NumRows
	
	for {set j 0} {$j <= 11} {incr j} {
	    set structuredata($NumRows,$j) [lindex $typecyl_1Group $j]
	    
	}
	set structuredata($NumRows,12) $NumRows

	## Radios de giro y desplazamiento para cada cilindro
	GyrDisp $typecyl_1Group $NumRows 
	#####################################
	
    }

    # Definici�n de la geometr�a de los 16 cilindros verticales altos
    
    for {set i 0} {$i <= 15} {incr i} {
	set DGroup [lindex $typecyl_2 10]
	set ThickGroup [lindex $typecyl_2 11]

	if {$i >= 0 && $i <= 3} {
	    set XMGroup [expr [lindex $typecyl_2 1] + $i*8.0]
	    set YMGroup [lindex $typecyl_2 2]
	    set ZMGroup [lindex $typecyl_2 3]
	    
	    set XmGroup [expr [lindex $typecyl_2 4] + $i*8.0]
	    set YmGroup [lindex $typecyl_2 5]
	    set ZmGroup [lindex $typecyl_2 6]
	    
	    set XgGroup [expr [lindex $typecyl_2 7] + $i*8.0]
	    set YgGroup [lindex $typecyl_2 8]
	    set ZgGroup [lindex $typecyl_2 9]
		                   
	    if { $i == 0} {
		set typecyl_2Group [list   \
		        CVref $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]
	    } else {
		set typecyl_2Group [list   \
		        CV $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]
	    }
	} elseif {$i > 3 && $i <= 7} {
	    set XMGroup [expr [lindex $typecyl_2 1] + ($i-4)*8.0]
	    set YMGroup [expr [lindex $typecyl_2 2] + 8.0]
	    set ZMGroup [lindex $typecyl_2 3]
	    
	    set XmGroup [expr [lindex $typecyl_2 4] + ($i-4)*8.0]
	    set YmGroup [expr [lindex $typecyl_2 5] + 8.0]
	    set ZmGroup [lindex $typecyl_2 6]
	    
	    set XgGroup [expr [lindex $typecyl_2 7] + ($i-4)*8.0]
	    set YgGroup [expr [lindex $typecyl_2 8] + 8.0]
	    set ZgGroup [lindex $typecyl_2 9]
	    
	    set typecyl_2Group [list   \
		    CV $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]

	} elseif {$i > 7 && $i <= 11} {
	    set XMGroup [expr [lindex $typecyl_2 1] + ($i-8)*8.0]
	    set YMGroup [expr [lindex $typecyl_2 2] + 16.0]
	    set ZMGroup [lindex $typecyl_2 3]
	    
	    set XmGroup [expr [lindex $typecyl_2 4] + ($i-8)*8.0]
	    set YmGroup [expr [lindex $typecyl_2 5] + 16.0]
	    set ZmGroup [lindex $typecyl_2 6]
	    
	    set XgGroup [expr [lindex $typecyl_2 7] + ($i-8)*8.0]
	    set YgGroup [expr [lindex $typecyl_2 8] + 16.0]
	    set ZgGroup [lindex $typecyl_2 9]
	   
	    set typecyl_2Group [list   \
		    CV $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]

	} elseif {$i > 11 && $i <= 15} {
	    set XMGroup [expr [lindex $typecyl_2 1] + ($i-12)*8.0]
	    set YMGroup [expr [lindex $typecyl_2 2] + 24.0]
	    set ZMGroup [lindex $typecyl_2 3]
	    
	    set XmGroup [expr [lindex $typecyl_2 4] + ($i-12)*8.0]
	    set YmGroup [expr [lindex $typecyl_2 5] + 24.0]
	    set ZmGroup [lindex $typecyl_2 6]
	    
	    set XgGroup [expr [lindex $typecyl_2 7] + ($i-12)*8.0]
	    set YgGroup [expr [lindex $typecyl_2 8] + 24.0]
	    set ZgGroup [lindex $typecyl_2 9]
	   
	    set typecyl_2Group [list   \
		    CV $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]
	}
	
	set NofRefElems [expr $NofRefElems + 1]
	set NumRows [expr $NofRefElems + 1] 
#         $datost configure -rows $NumRows
	set ni [expr $NumRows-1]

	for {set j 0} {$j <= 11} {incr j} {
	    set structuredata($ni,$j) [lindex $typecyl_2Group $j]
	    
	}
	set structuredata($ni,12) $ni

	GyrDisp $typecyl_2Group $ni 

    }

    # Definici�n de la geometr�a de los 24 cilindros horizontales bajos (seg�n "x" CHx, a partir del 0;
    #  y seg�n "y" CHy, a partir del 12)
    
    for {set i 0} {$i <= 23} {incr i} {
	set DGroup [lindex $typecyl_3 10]
	set ThickGroup [lindex $typecyl_3 11]
	if {$i >= 0 && $i <= 2} {
	    set XMGroup [expr [lindex $typecyl_3 1] + $i*8.0]
	    set YMGroup [lindex $typecyl_3 2]
	    set ZMGroup [lindex $typecyl_3 3]
	    
	    set XmGroup [expr [lindex $typecyl_3 4] + $i*8.0]
	    set YmGroup [lindex $typecyl_3 5]
	    set ZmGroup [lindex $typecyl_3 6]
	    
	    set XgGroup [expr [lindex $typecyl_3 7] + $i*8.0]
	    set YgGroup [lindex $typecyl_3 8]
	    set ZgGroup [lindex $typecyl_3 9]
	    
	    if {$i == 0} {
		set typecyl_3Group [list   \
		        CHxref $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]
	    } else {
		set typecyl_3Group [list   \
		        CHx $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]
	    }
	   

	} elseif {$i > 2 && $i <= 5} {
	    set XMGroup [expr [lindex $typecyl_3 1] + ($i-3)*8.0]
	    set YMGroup [expr [lindex $typecyl_3 2] + 8.0]
	    set ZMGroup [lindex $typecyl_3 3]
	    
	    set XmGroup [expr [lindex $typecyl_3 4] + ($i-3)*8.0]
	    set YmGroup [expr [lindex $typecyl_3 5] + 8.0]
	    set ZmGroup [lindex $typecyl_3 6]
	    
	    set XgGroup [expr [lindex $typecyl_3 7] + ($i-3)*8.0]
	    set YgGroup [expr [lindex $typecyl_3 8] + 8.0]
	    set ZgGroup [lindex $typecyl_3 9]
	    
	    set typecyl_3Group [list   \
		    CHx $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]

	} elseif {$i > 5 && $i <= 8} {
	    set XMGroup [expr [lindex $typecyl_3 1] + ($i-6)*8.0]
	    set YMGroup [expr [lindex $typecyl_3 2] + 16.0]
	    set ZMGroup [lindex $typecyl_3 3]
	    
	    set XmGroup [expr [lindex $typecyl_3 4] + ($i-6)*8.0]
	    set YmGroup [expr [lindex $typecyl_3 5] + 16.0]
	    set ZmGroup [lindex $typecyl_3 6]
	    
	    set XgGroup [expr [lindex $typecyl_3 7] + ($i-6)*8.0]
	    set YgGroup [expr [lindex $typecyl_3 8] + 16.0]
	    set ZgGroup [lindex $typecyl_3 9]
	   
	    set typecyl_3Group [list   \
		    CHx $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]

	} elseif {$i > 8 && $i <= 11} {
	    set XMGroup [expr [lindex $typecyl_3 1] + ($i-9)*8.0]
	    set YMGroup [expr [lindex $typecyl_3 2] + 24.0]
	    set ZMGroup [lindex $typecyl_3 3]
	    
	    set XmGroup [expr [lindex $typecyl_3 4] + ($i-9)*8.0]
	    set YmGroup [expr [lindex $typecyl_3 5] + 24.0]
	    set ZmGroup [lindex $typecyl_3 6]
	    
	    set XgGroup [expr [lindex $typecyl_3 7] + ($i-9)*8.0]
	    set YgGroup [expr [lindex $typecyl_3 8] + 24.0]
	    set ZgGroup [lindex $typecyl_3 9]
	   
	    set typecyl_3Group [list   \
		    CHx $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]
	
	} elseif {$i >= 12 && $i <= 15} {
	    set XMGroup [expr [lindex $typecyl_4 1] + ($i-12)*8.0]
	    set YMGroup [expr [lindex $typecyl_4 2] ]
	    set ZMGroup [lindex $typecyl_4 3]
	    
	    set XmGroup [expr [lindex $typecyl_4 4] + ($i-12)*8.0]
	    set YmGroup [expr [lindex $typecyl_4 5] ]
	    set ZmGroup [lindex $typecyl_4 6]
	    
	    set XgGroup [expr [lindex $typecyl_4 7] + ($i-12)*8.0]
	    set YgGroup [expr [lindex $typecyl_4 8] ]
	    set ZgGroup [lindex $typecyl_4 9]
	   
	    if {$i == 12 } {
		set typecyl_4Group [list   \
		        CHyref $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]
	    } else {
		set typecyl_4Group [list   \
		        CHy $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]
	    }
	
	} elseif {$i > 15 && $i <= 19} {
	    set XMGroup [expr [lindex $typecyl_4 1] + ($i-16)*8.0]
	    set YMGroup [expr [lindex $typecyl_4 2] + 8.0]
	    set ZMGroup [lindex $typecyl_4 3]
	    
	    set XmGroup [expr [lindex $typecyl_4 4] + ($i-16)*8.0]
	    set YmGroup [expr [lindex $typecyl_4 5] + 8.0]
	    set ZmGroup [lindex $typecyl_4 6]
	    
	    set XgGroup [expr [lindex $typecyl_4 7] + ($i-16)*8.0]
	    set YgGroup [expr [lindex $typecyl_4 8] + 8.0]
	    set ZgGroup [lindex $typecyl_4 9]
	   
	    set typecyl_4Group [list   \
		    CHy $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]
	
	} elseif {$i > 19 && $i <= 23} {
	    set XMGroup [expr [lindex $typecyl_4 1] + ($i-20)*8.0]
	    set YMGroup [expr [lindex $typecyl_4 2] + 16.0]
	    set ZMGroup [lindex $typecyl_4 3]
	    
	    set XmGroup [expr [lindex $typecyl_4 4] + ($i-20)*8.0]
	    set YmGroup [expr [lindex $typecyl_4 5] + 16.0]
	    set ZmGroup [lindex $typecyl_4 6]
	    
	    set XgGroup [expr [lindex $typecyl_4 7] + ($i-20)*8.0]
	    set YgGroup [expr [lindex $typecyl_4 8] + 16.0]
	    set ZgGroup [lindex $typecyl_4 9]
	   
	    set typecyl_4Group [list   \
		    CHy $XMGroup $YMGroup $ZMGroup $XmGroup $YmGroup $ZmGroup $XgGroup $YgGroup $ZgGroup $DGroup $ThickGroup]
	
	}
	
	set NofRefElems [expr $NofRefElems + 1]
	set NumRows [expr $NofRefElems + 1]
	set ni [expr $NumRows-1]
#         $datost configure -rows $NumRows
	
	if {$i >= 0 && $i <= 11} {
	    for {set j 0} {$j <= 11} {incr j} {
		set structuredata($ni,$j) [lindex $typecyl_3Group $j]
	    }
	    set structuredata($ni,12) $ni
	    GyrDisp $typecyl_3Group $ni 
	} elseif {$i >= 12 && $i <= 23} {
	    for {set j 0} {$j <= 11} {incr j} {
		set structuredata($ni,$j) [lindex $typecyl_4Group $j]
	    }
	    set structuredata($ni,12) $ni
	    GyrDisp $typecyl_4Group $ni 
	}
    }  
  
#     set RofGx [expr sqrt($sumIx/$TotMass)]
#     set RofGy [expr sqrt($sumIy/$TotMass)]
    set RofGz [expr sqrt($sumIz/$TotMass)]
    set DsTm3 [expr $DsT/1025.0]
    set CM [expr $sumIflot/$DsTm3]
    set KC [expr $KCiVCi/$VCTot]
    set KM [expr $CM + $KC]
    set GMT [expr $KM - $CofGz]
    set GML $GMT
 
}

proc morison::GyrDisp { typecyl n} {
    variable pi
    variable twopi
    variable gravity
    variable visc
    variable density
    variable structuredata
    variable waveHeight
    variable period
    variable draught
    variable nrows
    variable NofRefElems
    variable draught
    variable CofGx 
    variable CofGy 
    variable CofGz 
    variable TotMass 
    variable sumIx 
    variable sumIy 
    variable sumIz
    variable sumIflot
    variable VCTot
    variable KCiVCi
    
    # Peso espec�fico acero (Kg/m^3)
    set spcWeight 7800.0
    # Espesor tubular
    set thick [lindex $typecyl 11]

    set Rint [expr [lindex $typecyl 10]*0.5 - $thick]
    set Rext [expr [lindex $typecyl 10]*0.5]    

    
    if {[lindex $typecyl 3] < $draught && ([lindex $typecyl 7]==[lindex $typecyl 1] && [lindex $typecyl 8]==[lindex $typecyl 2])} {
	# Cilindro vertical, totalmente sumergido
	set height [expr ([lindex $typecyl 3] - [lindex $typecyl 6]) ]
	
	# Desplazamiento
	set structuredata($n,13) [expr $pi*$Rext*$Rext*$height*$density]        

	# Volumen y masa del cilindro (de espesor 17 mm)
	set VolCyl [expr $pi*($Rext*$Rext - $Rint*$Rint)*$height]
	set massCyl [expr $VolCyl*$spcWeight]
	set TotMass [expr $TotMass + $massCyl]
	
	# Inercias y radios de giro (respecto del C.d.G.)
	set Ixg [expr $massCyl*(0.25*($Rext*$Rext + $Rint*$Rint) + $height*$height/12.0)]
	set delta [expr pow(([lindex $typecyl 8] - $CofGy),2) + pow(([lindex $typecyl 9] - $CofGz),2)]
	set IxG [expr $Ixg + $massCyl*$delta]
	set Rx [expr sqrt($IxG/$massCyl)]
	set structuredata($n,14) $Rx
	
	set Iyg $Ixg
	set delta [expr pow(([lindex $typecyl 7] - $CofGx),2) + pow(([lindex $typecyl 9] - $CofGz),2)]
	set IyG [expr $Iyg + $massCyl*$delta]
	set Ry [expr sqrt($IyG/$massCyl)]
	set structuredata($n,15) $Ry

	set Izg [expr $massCyl*0.5*($Rext*$Rext + $Rint*$Rint)]
	set delta [expr pow(([lindex $typecyl 8] - $CofGy),2) + pow(([lindex $typecyl 7] - $CofGx),2)]
	set IzG [expr $Izg + $massCyl*$delta]
	set Rz [expr sqrt($IzG/$massCyl)]
	set structuredata($n,16) $Rz

	# Volumen carena (VCi) y situci�n del centro de flot. de cada elemento (KCi)
	set VCi [expr $pi*$Rext*$Rext*$height]
	set KCi [lindex $typecyl 9]

	set sumIx [expr $sumIx + $IxG]
	set sumIy [expr $sumIy + $IyG]
	set sumIz [expr $sumIz + $IzG]

	set VCTot [expr $VCTot + $VCi]
	set KCiVCi [expr $KCiVCi + $KCi*$VCi]
	
    } elseif {[lindex $typecyl 3] < $draught && [lindex $typecyl 3]==[lindex $typecyl 9]} {
	# Cilindro horizontal, totalmente sumergido
	if {[lindex $typecyl 0] == "CHx" || [lindex $typecyl 0] == "CHxref"} {
	set length [expr [lindex $typecyl 1] - [lindex $typecyl 4]]
	} else {
	    set length [expr [lindex $typecyl 2] - [lindex $typecyl 5]]
	}
	set structuredata($n,13) [expr $pi*pow([lindex $typecyl 10],2)*0.25*$length*$density]

	# Volumen y masa del cilindro (de espesor 17 mm)
	set VolCyl [expr $pi*($Rext*$Rext - $Rint*$Rint)*$length]
	set massCyl [expr $VolCyl*$spcWeight]
	set TotMass [expr $TotMass + $massCyl]
		        
	# Inercias y radios de giro (respecto del C.d.G.)
	set Ixg [expr $massCyl*(0.25*($Rext*$Rext + $Rint*$Rint) + $length*$length/12.0)]
	set delta [expr pow(([lindex $typecyl 8] - $CofGy),2) + pow(([lindex $typecyl 9] - $CofGz),2)]
	set IxG [expr $Ixg + $massCyl*$delta]
	set Rx [expr sqrt($IxG/$massCyl)]
	set structuredata($n,14) $Rx
	
	set Iyg [expr $massCyl*0.5*($Rext*$Rext + $Rint*$Rint)]
	set delta [expr pow(([lindex $typecyl 9] - $CofGz),2) + pow(([lindex $typecyl 7] - $CofGx),2)]
	set IyG [expr $Iyg + $massCyl*$delta]
	set Ry [expr sqrt($IyG/$massCyl)]
	set structuredata($n,15) $Ry
	
	set Izg $Ixg
	set delta [expr pow(([lindex $typecyl 7] - $CofGx),2) + pow(([lindex $typecyl 8] - $CofGy),2)]
	set IzG [expr $Izg + $massCyl*$delta]
	set Rz [expr sqrt($IzG/$massCyl)]
	set structuredata($n,16) $Rz

	set VCi [expr $pi*$Rext*$Rext*$length]
	set KCi [lindex $typecyl 9]


	set sumIx [expr $sumIx + $IxG]
	set sumIy [expr $sumIy + $IyG]
	set sumIz [expr $sumIz + $IzG]

	set VCTot [expr $VCTot + $VCi]
	set KCiVCi [expr $KCiVCi + $KCi*$VCi]


    } elseif {[lindex $typecyl 3] >= $draught && ([lindex $typecyl 7]==[lindex $typecyl 1] && [lindex $typecyl 8]==[lindex $typecyl 2])} {
	# Cilindro vertical, parcialmente sumergido
	set height [expr ($draught - [lindex $typecyl 6])] 
	set structuredata($n,13) [expr $pi*pow([lindex $typecyl 10],2)*0.25*$height*$density]

	# Volumen y masa del cilindro (de espesor 17 mm)
	set heightI [expr ([lindex $typecyl 3] - [lindex $typecyl 6]) ]
	set VolCyl [expr $pi*($Rext*$Rext - $Rint*$Rint)*$heightI]
	set massCyl [expr $VolCyl*$spcWeight]
	set TotMass [expr $TotMass + $massCyl]
		        
	# Inercias y radios de giro (respecto del C.d.G.)
	set Ixg [expr $massCyl*(0.25*($Rext*$Rext + $Rint*$Rint) + $heightI*$heightI/12.0)]
	set delta [expr pow(([lindex $typecyl 8] - $CofGy),2) + pow(([lindex $typecyl 9] - $CofGz),2)]
	set IxG [expr $Ixg + $massCyl*$delta]
	set Rx [expr sqrt($IxG/$massCyl)]
	set structuredata($n,14) $Rx
	
	set Iyg $Ixg
	set delta [expr pow(([lindex $typecyl 7] - $CofGx),2) + pow(([lindex $typecyl 9] - $CofGz),2)]
	set IyG [expr $Iyg + $massCyl*$delta]
	set Ry [expr sqrt($IyG/$massCyl)]
	set structuredata($n,15) $Ry

	set Izg [expr $massCyl*0.5*($Rext*$Rext + $Rint*$Rint)]
	set delta [expr pow(([lindex $typecyl 8] - $CofGy),2) + pow(([lindex $typecyl 7] - $CofGx),2)]
	set IzG [expr $Izg + $massCyl*$delta]
	set Rz [expr sqrt($IzG/$massCyl)]
	set structuredata($n,16) $Rz

	# Inercia de la flotaci�n (c�rculo)
	set Iflot [expr $pi*pow($Rext,4)/4.0]
	set A [expr $pi*pow($Rext,2)]
	set delta [expr pow(([lindex $typecyl 7] - $CofGx),2)]
	set Iflot [expr $Iflot + $A*$delta]

	set VCi [expr $pi*$Rext*$Rext*$height]
	set KCi [expr [lindex $typecyl 6] + ($draught - [lindex $typecyl 6])/2.0]
	
	set sumIflot [expr $sumIflot + $Iflot]

	set sumIx [expr $sumIx + $IxG]
	set sumIy [expr $sumIy + $IyG]
	set sumIz [expr $sumIz + $IzG]

	set VCTot [expr $VCTot + $VCi]
	set KCiVCi [expr $KCiVCi + $KCi*$VCi]

    } elseif {[lindex $typecyl 3] >= $draught && [lindex $typecyl 3]==[lindex $typecyl 9]} {
	# Cilindro horizontal, parcialmente sumergido
	if {[lindex $typecyl 0] == "CHx" || [lindex $typecyl 0] == "CHxref"} {
	set length [expr [lindex $typecyl 1] - [lindex $typecyl 4]]
	} else {
	    set length [expr [lindex $typecyl 2] - [lindex $typecyl 5]]
	}        
	# (hay que calcular alg�n par�metro para integrar si no est� totalmente cubierto )
	set angle [expr asin(($draught - [lindex $typecyl 9] )*2.0/[lindex $typecyl 10])]
	set Atriang [expr ($draught - [lindex $typecyl 9])*[lindex $typecyl 10]*cos($angle)*0.5]
	set AsectCirc [expr pow([lindex $typecyl 10],2)*0.25*($angle + $pi*0.5)]

	set structuredata($n,13) [expr ($Atriang + $AsectCirc)*$length*$density]

	# Volumen y masa del cilindro (de espesor 17 mm)
	set VolCyl [expr $pi*($Rext*$Rext - $Rint*$Rint)*$length]
	set massCyl [expr $VolCyl*$spcWeight]
	set TotMass [expr $TotMass + $massCyl]
		        
	# Inercias y radios de giro (respecto del C.d.G.)
	set Ixg [expr $massCyl*(0.25*($Rext*$Rext + $Rint*$Rint) + $length*$length/12.0)]
	set delta [expr pow(([lindex $typecyl 8] - $CofGy),2) + pow(([lindex $typecyl 9] - $CofGz),2)]
	set IxG [expr $Ixg + $massCyl*$delta]
	set Rx [expr sqrt($IxG/$massCyl)]
	set structuredata($n,14) $Rx
	
	set Iyg [expr $massCyl*0.5*($Rext*$Rext + $Rint*$Rint)]
	set delta [expr pow(([lindex $typecyl 9] - $CofGz),2) + pow(([lindex $typecyl 7] - $CofGx),2)]
	set IyG [expr $Iyg + $massCyl*$delta]
	set Ry [expr sqrt($IyG/$massCyl)]
	set structuredata($n,15) $Ry
	
	set Izg $Ixg
	set delta [expr pow(([lindex $typecyl 7] - $CofGx),2) + pow(([lindex $typecyl 8] - $CofGy),2)]
	set IzG [expr $Izg + $massCyl*$delta]
	set Rz [expr sqrt($IzG/$massCyl)]
	set structuredata($n,16) $Rz

	set sumIx [expr $sumIx + $IxG]
	set sumIy [expr $sumIy + $IyG]
	set sumIz [expr $sumIz + $IzG]

    }

   
}

proc morison::MorisonCalc {} {
    variable pi
    variable twopi
    variable gravity
    variable visc
    variable density
    variable structuredata
    variable waveHeight
    variable InitPeriod
    variable draught
    variable nrows
    variable NofRefElems
    variable DsT 
    variable GMT
    variable GML
    variable CofGx
    variable CofGy
    variable CofGz
    variable RofGx
    variable RofGy
    variable RofGz 
    variable draught
    variable file
    variable 3x3
    variable 4x4
    variable TotMass 
    variable sumIx 
    variable sumIy 
    variable sumIz 
    variable sumIflot 
    variable VCTot 
    variable KCiVCi 
    variable GMT
    variable GML
    variable DirNum
    variable flagCalc

    set TotMass 0.0
    set sumIx 0.0
    set sumIy 0.0
    set sumIz 0.0
    set sumIflot 0.0
    set VCTot 0.0
    set KCiVCi 0.0
    set flagCalc 1

    # Resultado (movimientos)
    variable Rs 
    
    variable h_1 
    variable h_2 
    variable t_1 
    variable t_2 

    variable ckBflag 
#     variable tubDiam


    GiD_Process escape escape escape escape geometry

    set refunits [GiD_AccessValue get gendata Mesh_units#CB#(m,cm,mm)]
    if { $refunits == "mm" } {
	set ref 0
    } elseif { $refunits == "cm" } {
	set ref 1
    } elseif { $refunits == "m" } {
	set ref 2
    }
    
    set Fd ""
    set Ft ""
    
# Excel file to write
    if {$ckBflag == 1} {
	set projectPath [GiD_Info Project ModelName]
	set initial [file rootname [file tail $projectPath]].xls
	set ext ".xls"
	if { $::tcl_platform(platform) == "windows" } {
	    set tofile [tk_getSaveFile -defaultextension $ext \
		    -initialfile $initial -initialdir $projectPath \
		    -title "Write Trasfer Functions"]
	} else {
	    set tofile [Browser-ramR file save]
	}
	if { [file ext $tofile] != ".xls"} {
	    WarnWin "Unknown extension for file '$tofile'"
	    return 0
	}
	
	set file2 $tofile
	set res_file [open $file2 "w+"]
    }
#################################


    #Waterplane area
    set AWP 0.0

    #Output window
    if { ![winfo exists .morison] } { 
	toplevel .morison 
	wm title .morison "Morison Output"
	wm iconname .morison "Morison Output"
	pack [text .morison.t -width 70 -height 20]
    }
    
    set out [open $file "w+"]
    
    puts $out "T Nu Dx Dy Dx Rx Ry Rz" 
    
    set nu $DirNum
    
    set RotM [mkMatrix 3 3 0.0]

    setelem RotM 0 0 [expr cos($nu)]
    setelem RotM 0 1 [expr sin($nu)]
    setelem RotM 1 0 [expr -sin($nu)]
    setelem RotM 1 1 [expr cos($nu)]
    setelem RotM 2 2 [expr 1.0]
       
    if {$ckBflag == 0} {
	set Ampl [expr $waveHeight]
	set period $InitPeriod
	set hsList $Ampl
	set tsList $period
    }    
    if {$ckBflag == 1} {
	set hsList $h_1
	set tsList $t_1
	set nT 100.0
	set nH 1.0
	set deltaT [expr ($t_2 - $t_1)/$nT]
	set deltaH [expr ($h_2 - $h_1)/$nH]

	for {set i 0} {$i < $nT} {incr i} {
	    lappend tsList [expr [lindex $tsList $i] + $deltaT]
	}
	for {set i 0} {$i < $nH} {incr i} {
	    lappend hsList [expr [lindex $hsList $i] + $deltaH]
	}
    }

    foreach Ampl $hsList {
	if {$ckBflag == 1} {
	    puts $res_file "\n H (m) \[Ampl/2\] \t $Ampl"
	    if {$Ampl == [lindex $hsList 0]} {
		puts $res_file "\t\t T (s) \t w/sqrt(Lpp/g) \t L (m) \t dX (m) \t dY (m) \t dZ (m) \t ThX \t ThY \t ThZ \t dX/A \t dY/A \t dZ/A \t ThXadim \t ThYadim \t ThZadim"
	    } else {
		puts $res_file "\t\t T (s) \t w/sqrt(Lpp/g) \t dX (m) \t dY (m) \t dZ (m) \t ThX \t ThY \t ThZ \t dX/A \t dY/A \t dZ/A \t ThXadim \t ThYadim \t ThZadim"
	    }
	}
	foreach period $tsList {
	    set frec [expr $twopi/$period]
	    # Deep waters model is supposed --> w^2=g�k ; Lw=g*T/(2�pi)~1.56�T^2
	    set Kd [expr $frec*$frec/$gravity]
	    set waveLength [expr 1.56*$period*$period]
		        
#             if {$ckBflag == 1} {
#                 puts $res_file "\t\t $period"
#             }

	    .morison.t ins end "-- Evaluate for Period = $period s, Angle = $nu rad, Height= $Ampl m--\n -- Wave Length= $waveLength m -- \n"
	    .morison.t see end ; update
	    .morison.t ins end "Phase 1: Evaluate local forces\n"
	    .morison.t see end ; update
  
	    set intvNum [lindex [GiD_Info intvdata num] 1]
	    for {set intv 2} {$intv <= $intvNum} {incr intv} {
		set intvName [lindex [GiD_Info intvdata -interval $intv] 2]
		set geomdat [GiD_Info conditions -interval $intv Morison_Loads geometry]
		if {$geomdat != ""} {
		    break
		}
	    }          
		        
	    ##################################################################################################            
#             set geomdat [GiD_Info conditions -interval 2 Morison_Loads geometry]
	    ##################################################################################################
	    
	    set superIndex 0
	    set Fd ""
	    foreach i $geomdat {
		foreach "- num - localaxes units WaveH IniPer Dn Draught Displac GMt GMl \
		    CGx CGy CGz RGx RGy RGz CurD WinD vWind TubD" $i break
		
		# "Reset" de variables
		set eKzS ""
		set eKzI ""
		set exp1 ""
		set intM1 ""
		set intM2 ""
		set intM3 ""
		set intM4 ""
		set intM5 ""
		set integral_1 ""
		set integral_2 ""
		set coef1 ""
		set coef2 ""
		set coef3 ""
		set coef4 ""
		set coef5 ""
		##########################
		
		set D $TubD
		
		if {$D != 0.0} {
		    
		    set linfo [.central.s info list_entities lines $num]
		    set points [lindex [regexp -linestop -inline {Points: ([ 0-9]*)} $linfo] 1] 
		    
		    set pntini [lindex $points 0]
		    set pntfin [lindex $points 1]
		    
		    set inipoint [lindex [.central.s info Coordinates $pntini] 0]
		    
		    # Giro
		    set iniP [mkMatrix 3 1 0.0]
		    setelem iniP 0 0 [expr double([lindex $inipoint 0])]
		    setelem iniP 1 0 [expr double([lindex $inipoint 1])]
		    setelem iniP 2 0 [expr double([lindex $inipoint 2])]
		    set iniP [matmul $RotM $iniP]
		    set xM [getelem $iniP 0 0]
		    set yM [getelem $iniP 1 0]
		    set zM [getelem $iniP 2 0]
		    
		    
		    set finpoint [lindex [.central.s info Coordinates $pntfin] 0]
		    
		    set finP [mkMatrix 3 1 0.0]
		    setelem finP 0 0 [expr double([lindex $finpoint 0])]
		    setelem finP 1 0 [expr double([lindex $finpoint 1])]
		    setelem finP 2 0 [expr double([lindex $finpoint 2])]
		    set finP [matmul $RotM $finP]
		    set xm [getelem $finP 0 0]
		    set ym [getelem $finP 1 0]
		    set zm [getelem $finP 2 0]                
		    
		    
		    if {$xM < $xm} {
		        set xma $xM
		        set xMa $xm
		        
		        set xm $xma
		        set xM $xMa
		    }
		    if {$yM < $ym} {
		        set yma $yM
		        set yMa $ym
		        
		        set ym $yma
		        set yM $yMa
		    }
		    if {$zM < $zm} {
		        set zma $zM
		        set zMa $zm
		        
		        set zm $zma
		        set zM $zMa
		    }
		    
		    set xG [expr $xm + ($xM-$xm)*0.5]
		    set yG [expr $ym + ($yM-$ym)*0.5]
		    set zG [expr $zm + ($zM-$zm)*0.5]
		    
#                     set matProps [.central.s info conditions Section geometry $num]
		    
		    
		    #                 set typeSect [lindex $$matProps 4]
		    #                 if {[regexp {TUBE-} $typeSect]} {
		        #                     set D [lindex [regexp -inline {TUBE-([ 0-9]*)} $typeSect] 1]
		        #                 }
		    #                 if {$ref==2} {
		        #                     set D [expr $D*1.0e-3]  
		        #                 } 
		    
		    
		    # Orientaci�n del tubular u_=(ux,uy,uz)=(cosG*cosT,cosG*sinT,sinG) 
		    set Lcyl [expr sqrt(pow(($xM-$xm),2) + pow(($yM-$ym),2) + pow(($zM-$zm),2))]
		    #         set ux [expr ($xM - $xm)/$Lcyl]
		    #         set uy [expr ($yM - $ym)/$Lcyl]
		    if {$xm >= 0.0} {
		        set ux [expr ($xM - $xm)/$Lcyl]
		    } else {
		        set ux [expr -($xM - $xm)/$Lcyl]
		    }
		    if {$ym >= 0.0} {
		        set uy [expr ($yM - $ym)/$Lcyl]
		    } else {
		        set uy [expr -($yM - $ym)/$Lcyl]
		    }       
		    set uz [expr ($zM - $zm)/$Lcyl]
		    
		    
		    # Checking if the cylinder is completely covered by the wave
		    if {$zM <= $draught && ([expr abs($xG-$xM)<=1.0e-5] && [expr abs($yG-$yM)<=1.0e-5])} {
		        # Cilindro vertical, totalmente sumergido
		        # L�mites de integraci�n
		        set Zsup [expr -($draught - $zM)]
		        set Zinf [expr -($draught - $zm)]
		        
		    } elseif {[expr $zG + $D*0.5] <= $draught && $zG==$zM} {
		        # Cilindro horizontal, totalmente sumergido
		        set height $D 
		        set Zsup [expr -($draught - ($zG + $D*0.5))] 
		        set Zinf [expr -($draught - ($zG - $D*0.5))] 
		        set sAng 1.0
		        set cAng 0.0           
		    } elseif {($zM > $draught && $zm < $draught) && ($xG==$xM && $yG==$yM)} {
		        # Cilindro vertical, parcialmente sumergido
		        set Zsup 0.0
		        set Zinf [expr -($draught - $zm)]
		        set AWP [expr $AWP+0.25*$pi*$D*$D]
		    } elseif {([expr $zG + $D*0.5] > $draught && [expr $zG - $D*0.5] < $draught) && $zG==$zM} {
		        # Cilindro horizontal, parcialmente sumergido
		        set height [expr ($draught - $zG) + $D*0.5] 
		        set zMaxCyl $draught
		        # (hay que calcular alg�n par�metro para integrar si no est� totalmente cubierto )
		        set angle [expr asin(($draught - $zG )*2.0/$D)]
		        set sAng [expr sin($angle)]
		        set cAng [expr cos($angle)]
		        set Zsup 0.0
		        set Zinf [expr -($draught - $zG - $D*0.5)]
		        # Area de flotaci�n
		        set AWP [expr $AWP + $D*0.5*$cAng*$Lh] 
		    }
		    
		    #                 
		    #Max. speed (z=0; para la ola, se toma la referencia en la superficie del agua, siendo las Z negativas hacia abajo)
		    set UdMax [expr $Ampl*$frec]
		    
		    #Reynolds number for each cilynder
		    set Reyn [expr $UdMax*$D/$visc]
		    #Cd y Cm coefs., dependents of Reynolds number
		    if {$Reyn <= 1.0e-5} {
		        set Cd 1.2
		        set Cm 2.0
		    } else {
		        set Cd 0.7
		        set Cm 1.5
		    }
		    
		    # Las FdiC corresponden a la parte que multiplica a cos(wt) (fuerzas + momentos -> 6), y las FdiS a sen(wt) (fuerzas + momentos -> 6)
		    
		    if { $zM <= $draught || ($zM > $draught && $zm < $draught) || [expr $zG + $D*0.5] <= $draught || ([expr $zG + $D*0.5] > $draught && [expr $zG - $D*0.5] < $draught)} {
		        set eKzS [expr exp($Kd*$Zsup)]
		        set eKzI [expr exp($Kd*$Zinf)]
		        
		        if {abs($uz) <= 1.0e-5} {
		            set exp1 [expr exp($Kd*($Zsup - $Zinf)*0.5)]
		            # Cilindro horizontal
		            if {abs($uy) <= 1.0e-5} {
		                # Eje longitudinal paralelo al eje OX
		                
		                # Integrales para las fuerzas
		                set integral_1 [expr (sin($xM*$Kd) - sin($xm*$Kd))*$exp1/$Kd]
		                set integral_2 [expr -(cos($xM*$Kd) - cos($xm*$Kd))*$exp1/$Kd]
		                
		                # Integrales para los momentos
		                set intM1 [expr $integral_1*($zG - $CofGz)]
		                set intM2 [expr $integral_2*($zG - $CofGz)] 
		                set intM3 [expr $integral_1*($yG - $CofGy)]
		                set intM4 [expr $integral_2*($yG - $CofGy)]
		                set intM5 [expr $exp1*(sin($Kd*$xM)*($xM-$CofGx) - sin($Kd*$xm)*($xm-$CofGx) + (cos($Kd*$xM)- cos($Kd*$xm))/$Kd)/$Kd]
		                set intM6 [expr $exp1*(cos($Kd*$xm)*($xm-$CofGx) - cos($Kd*$xM)*($xM-$CofGx) + (sin($Kd*$xM)- sin($Kd*$xm))/$Kd)/$Kd]
		            } elseif { abs($ux) <= 1.0e-5} {
		                # Eje longitudinal paralelo con eje OY
		                # Integrales para las fuerzas
		                set integral_1 [expr $Lcyl*cos($Kd*$xG)*exp($Kd*($Zsup - $Zinf)*0.5)]
		                set integral_2 [expr $Lcyl*sin($Kd*$xG)*exp($Kd*($Zsup - $Zinf)*0.5)]
		                
		                # Integrales para los momentos
		                set intM1 [expr $exp1*cos($Kd*$xG)*($zG - $CofGz)*$Lcyl]
		                set intM2 [expr $exp1*sin($Kd*$xG)*($zG - $CofGz)*$Lcyl] 
		                set intM3 [expr $exp1*cos($Kd*$xG)*(($yM*$yM - $ym*$ym)*0.5 - ($yM - $ym)*$CofGy)]
		                set intM4 [expr $exp1*sin($Kd*$xG)*(($yM*$yM - $ym*$ym)*0.5 - ($yM - $ym)*$CofGy)]
		                set intM5 [expr $exp1*cos($Kd*$xG)*($xG - $CofGx)*$Lcyl]
		                set intM6 [expr $exp1*sin($Kd*$xG)*($xG - $CofGx)*$Lcyl]
		            } else {
		                # Integrales para las fuerzas
		                set integral_1 [expr (sin($xM*$Kd) - sin($xm*$Kd))*$exp1/($Kd*$ux)]
		                set integral_2 [expr -(cos($xM*$Kd) - cos($xm*$Kd))*$exp1/($Kd*$ux)]
		                # Integrales para los momentos
		                set intM1 [expr $integral_1*($zG - $CofGz)]
		                set intM2 [expr $integral_2*($zG - $CofGz)] 
		                set intM3 [expr $exp1*(($xM*$uy/$ux-$CofGy)*sin($Kd*$xM) - ($xm*$uy/$ux-$CofGy)*sin($Kd*$xm) + $uy/$ux*(cos($Kd*$xM) - cos($Kd*$xm)))/($ux*$Kd)]
		                set intM4 [expr $exp1*(($xm*$uy/$ux-$CofGy)*cos($Kd*$xm) - ($xM*$uy/$ux-$CofGy)*cos($Kd*$xM) + $uy/$ux*(sin($Kd*$xM) - sin($Kd*$xm)))/($ux*$Kd)]
		                set intM5 [expr $exp1*(sin($Kd*$xM)*($xM-$CofGx) - sin($Kd*$xm)*($xm-$CofGx) + (cos($Kd*$xM)- cos($Kd*$xm))/$Kd)/$Kd]
		                set intM6 [expr $exp1*(cos($Kd*$xm)*($xm-$CofGx) - cos($Kd*$xM)*($xM-$CofGx) + (sin($Kd*$xM)- sin($Kd*$xm))/$Kd)/$Kd]
		            }                     
		        } elseif {($uz ==1.0 || $uz == -1.0) && (abs($ux) <= 1.0e-5 && abs($uy) <= 1.0e-5)} {
		            # Cilindros verticales
		            # Integrales para las fuerzas
		            set integral_1 [expr cos($Kd*$xG)*($eKzS - $eKzI)/($Kd)]
		            set integral_2 [expr sin($Kd*$xG)*($eKzS - $eKzI)/($Kd)] 
		            
		            # Integrales para los momentos
		            set intM1 [expr cos($Kd*$xG)*($eKzS*($Zsup-$CofGz-1/$Kd) - $eKzI*($Zinf-$CofGz-1/$Kd))/$Kd]
		            set intM2 [expr sin($Kd*$xG)*($eKzS*($Zsup-$CofGz-1/$Kd) - $eKzI*($Zinf-$CofGz-1/$Kd))/$Kd] 
		            set intM3 [expr cos($Kd*$xG)*($yG-$CofGy)*($eKzS - $eKzI)/$Kd]
		            set intM4 [expr sin($Kd*$xG)*($yG-$CofGy)*($eKzS - $eKzI)/$Kd]
		            set intM5 [expr cos($Kd*$xG)*($xG-$CofGx)*($eKzS - $eKzI)/$Kd]
		            set intM6 [expr sin($Kd*$xG)*($xG-$CofGx)*($eKzS - $eKzI)/$Kd]
		        } else {
		            # Resto de cilindros
		            set coef1 [expr $Kd*$ux/$uz]
		            set coef2 [expr 1/($uz*($Kd*$Kd + $coef1*$coef1))]
		            set coef3 [expr $Kd*$uz*$coef2]
		            set coef4 [expr $uy/$uz]
		            set coef5 [expr $ux/$uz]
		            
		            set cKzS [expr cos($Zsup*$coef1)]
		            set cKzI [expr cos($Zinf*$coef1)]
		            
		            set sKzS [expr sin($Zsup*$coef1)]
		            set sKzI [expr sin($Zsup*$coef1)]
		            
		            set E1 [expr $eKzS*($Kd*$cKzS + $coef1*$sKzS)]
		            set E2 [expr $eKzI*($Kd*$cKzI + $coef1*$sKzI)]
		            set E3 [expr $eKzS*($Kd*$sKzS - $coef1*$cKzS)]
		            set E4 [expr $eKzI*($Kd*$sKzI - $coef1*$cKzI)]
		            
		            set Z1 [expr ($Zsup - $CofGz) - $coef3]
		            set Z2 [expr ($Zinf - $CofGz) - $coef3]
		            set Y1 [expr ($coef4*$Zsup - $CofGy) - $coef3]
		            set Y2 [expr ($coef4*$Zinf - $CofGy) - $coef3]
		            set X1 [expr ($coef5*$Zsup - $CofGx) - $coef3]
		            set X2 [expr ($coef5*$Zinf - $CofGx) - $coef3]
		            
		            # Integrales para las fuerzas
		            set integral_2 [expr ($E3 - $E4)*$coef2]
		            set integral_1 [expr ($E1 - $E2)*$coef2]
		            
		            # Integrales para los momentos
		            set intM1 [expr ($E1*$Z1 - $E2*$Z2 - $coef3*($E3 - $E4))*$coef2]
		            set intM2 [expr ($E3*$Z1 - $E4*$Z2 - $coef3*($E2 - $E1))*$coef2] 
		            set intM3 [expr ($E1*$Y1 - $E2*$Y2 - $coef3*($E3 - $E4))*$coef2]
		            set intM4 [expr ($E3*$Y1 - $E4*$Y2 - $coef3*($E2 - $E1))*$coef2]
		            set intM5 [expr ($E1*$X1 - $E2*$X2 - $coef3*($E3 - $E4))*$coef2]
		            set intM6 [expr ($E3*$X1 - $E4*$X2 - $coef3*($E2 - $E1))*$coef2]
		        }      
		        
		        
		        # Cilindro gen�rico
		        set qd 0.0
		        set coef1Fd [expr $Cm*$density*$frec*$frec*$Ampl*$D*$D*$pi*0.25]
		        #                     set coef1Fd [expr $Cm*$density*$frec*$frec*$Ampl*$D*$Lcyl]
		        #Components corresponding to forces (Fdx, Fdy, Fdz)
		        set Fd1C [expr $coef1Fd*(($uz*$uz + $uy*$uy)*$integral_1 + $uz*$ux*$integral_2)]
		        set Fd1S [expr $coef1Fd*(-($uz*$uz + $uy*$uy)*$integral_2 + $uz*$ux*$integral_1)]
		        
		        set Fd2C [expr $coef1Fd*(-$ux*$uy*$integral_1 + $uz*$uy*$integral_2)]
		        set Fd2S [expr $coef1Fd*($ux*$uy*$integral_2 + $uz*$uy*$integral_1)]
		        
		        set Fd3C [expr $coef1Fd*(-($ux*$ux + $uy*$uy)*$integral_2 - $uz*$ux*$integral_1)]
		        set Fd3S [expr $coef1Fd*(-($ux*$ux + $uy*$uy)*$integral_1 + $uz*$ux*$integral_2)]
		        
		        #Components corresponding to moments (Mx, My, Mz)
		        #             set Fd4C [expr $coef1Fd*($ux*$uy*$intM1 - $uz*$uy*$intM2 - $ux*$uz*$intM3 - ($ux*$ux + $uy*$uy)*$intM4)]
		        #             set Fd4S [expr $coef1Fd*(-$ux*$uy*$intM2 - $uz*$uy*$intM1 + $ux*$uz*$intM4 - ($ux*$ux + $uy*$uy)*$intM3)]        
		        #             
		        #             set Fd5C [expr $coef1Fd*(($uy*$uy + $uz*$uz)*$intM1 + $uz*$ux*$intM2 + $ux*$uz*$intM5 + ($ux*$ux + $uy*$uy)*$intM6)]
		        #             set Fd5S [expr $coef1Fd*($ux*$uz*$intM1 - ($uz*$uz + $uy*$uy)*$intM2 - $ux*$uz*$intM6 + ($ux*$ux + $uy*$uy)*$intM5)]
		        #             
		        #             set Fd6C [expr $coef1Fd*(-($uy*$uy + $uz*$uz)*$intM3 - $uz*$ux*$intM4 - $ux*$uy*$intM5 + $uz*$uy*$intM6)]
		        #             set Fd6S [expr $coef1Fd*(-$ux*$uz*$intM3 + ($uy*$uy + $ux*$ux)*$intM4 + $uy*$uz*$intM5 + $ux*$uy*$intM6)]  
		        
		        set Fd4C [expr $coef1Fd*(-$ux*$uy*$intM1 + $uz*$uy*$intM2 - $ux*$uz*$intM3 - ($ux*$ux + $uy*$uy)*$intM4)]
		        set Fd4S [expr $coef1Fd*($ux*$uy*$intM2 + $uz*$uy*$intM1 + $ux*$uz*$intM4 - ($ux*$ux + $uy*$uy)*$intM3)]        
		        
		        set Fd5C [expr $coef1Fd*(($uy*$uy + $uz*$uz)*$intM1 + $uz*$ux*$intM2 - $ux*$uz*$intM5 - ($ux*$ux + $uy*$uy)*$intM6)]
		        set Fd5S [expr $coef1Fd*($ux*$uz*$intM1 - ($uz*$uz + $uy*$uy)*$intM2 + $ux*$uz*$intM6 - ($ux*$ux + $uy*$uy)*$intM5)]
		        
		        set Fd6C [expr $coef1Fd*(($uy*$uy + $uz*$uz)*$intM3 + $uz*$ux*$intM4 - $ux*$uy*$intM5 + $uz*$uy*$intM6)]
		        set Fd6S [expr $coef1Fd*($ux*$uz*$intM3 - ($uy*$uy + $ux*$ux)*$intM4 + $uy*$uz*$intM5 + $ux*$uy*$intM6)]                          
		        
		        lappend Fd $Fd1C $Fd2C $Fd3C $Fd4C $Fd5C $Fd6C $Fd1S $Fd2S $Fd3S $Fd4S $Fd5S $Fd6S  
		        incr superIndex
		    }
		}
	    } 
	    
	

	    .morison.t ins end "Phase 1: OK\n"
	    .morison.t ins end "Phase 2: Calculate Mass, Added Mass and Damping matrixes\n"
	    .morison.t see end ; update
		
	    # Data initialization (first 6 indexes correspond to sin terms, rest to cos terms)
	    set M [mkMatrix 12 12 0.0]
	    foreach i {0 6} {
		setelem M [expr 0+$i] [expr 0+$i] $DsT
		setelem M [expr 0+$i] [expr 4+$i] [expr $DsT*($CofGz-$draught)]
		setelem M [expr 1+$i] [expr 1+$i] $DsT
		setelem M [expr 1+$i] [expr 3+$i] [expr -$DsT*($CofGz-$draught)]
		setelem M [expr 2+$i] [expr 2+$i] $DsT
		setelem M [expr 3+$i] [expr 3+$i] [expr $DsT*pow($RofGx,2)]
		setelem M [expr 3+$i] [expr 1+$i] [expr -$DsT*($CofGz-$draught)]
		setelem M [expr 4+$i] [expr 4+$i] [expr $DsT*pow($RofGy,2)]
		setelem M [expr 4+$i] [expr 0+$i] [expr $DsT*($CofGz-$draught)]
		setelem M [expr 5+$i] [expr 5+$i] [expr $DsT*pow($RofGz,2)]
	    }
	    
	    set A [mkMatrix 12 12 0.0]
	    set B [mkMatrix 12 12 0.0]
		        
	    .morison.t ins end "Phase 2: OK\n"
	    .morison.t ins end "Phase 3: Evaluate global forces\n"
	    .morison.t see end ; update
	    
	    # Restoring forces
	    # se asume simetr�a en xz y por ello C24=C42=0.0)
	    set C [mkMatrix 12 12 0.0]
	    setelem C 2 2 [expr $density*$gravity*$AWP]
	    setelem C 2 4 0.0
	    setelem C 3 3 [expr $DsT*$gravity*$GMT]
	    setelem C 4 4 [expr $DsT*$gravity*$GML]
	    setelem C 4 2 0.0
	    
	    # Evaluate total force
	    set Ft [mkVector 12 0.0]
	    
	    for {set i 0} {$i < [expr $superIndex]} {incr i} {
		for {set j 0} {$j < 12} {incr j} {
		    set Ftij [lindex $Fd [expr $i*12+$j]]
		    setelem Ft $j [expr [getelem $Ft $j 0]+$Ftij]
		}
	    }
	    
	    # Rotaci�n de las fuerzas (Para referirlas al sist. de ref. de la estructura)
	    set R [mkMatrix 12 12 0.0]
	    #     if {$DirNum == [expr $pi*0.5]} {
		#         setelem R 0 0 [expr 0.0]
		#         setelem R 0 1 [expr 1.0]
		#         setelem R 1 0 [expr -1.0]
		#         setelem R 1 1 [expr 0.0]
		#         setelem R 2 2 [expr 1.0]
		#         setelem R 3 3 [expr 0.0]
		#         setelem R 3 4 [expr 1.0]
		#         setelem R 4 3 [expr -1.0]
		#         setelem R 4 4 [expr 0.0]
		#         setelem R 5 5 [expr 1.0]
		#         setelem R 6 6 [expr 0.0]
		#         setelem R 6 7 [expr 1.0]
		#         setelem R 7 6 [expr -1.0]
		#         setelem R 7 7 [expr 0.0]
		#         setelem R 8 8 [expr 1.0]
		#         setelem R 9 9 [expr 0.0]
		#         setelem R 9 10 [expr 1.0]
		#         setelem R 10 9 [expr -1.0]
		#         setelem R 10 10 [expr 0.0]
		#         setelem R 11 11 [expr 1.0]
		#     } else 
	    
	    setelem R 0 0 [expr cos($nu)]
	    setelem R 0 1 [expr sin($nu)]
	    setelem R 1 0 [expr -sin($nu)]
	    setelem R 1 1 [expr cos($nu)]
	    setelem R 2 2 [expr 1.0]
	    setelem R 3 3 [expr cos($nu)]
	    setelem R 3 4 [expr sin($nu)]
	    setelem R 4 3 [expr -sin($nu)]
	    setelem R 4 4 [expr cos($nu)]
	    setelem R 5 5 [expr 1.0]
	    setelem R 6 6 [expr cos($nu)]
	    setelem R 6 7 [expr sin($nu)]
	    setelem R 7 6 [expr -sin($nu)]
	    setelem R 7 7 [expr cos($nu)]
	    setelem R 8 8 [expr 1.0]
	    setelem R 9 9 [expr cos($nu)]
	    setelem R 9 10 [expr sin($nu)]
	    setelem R 10 9 [expr -sin($nu)]
	    setelem R 10 10 [expr cos($nu)]
	    setelem R 11 11 [expr 1.0]
	    #     
	    set Ft [matmul $R $Ft]

	    # Damping / Added mass evaluation 
	    # se asume que las matrices A, B son diagonales
	    #     for {set i 0} {$i < [expr $NumRows-1]} {incr i} {
		#         for {set j 0} {$j < 6} {incr j} {
		    #             set F [mkVector 2 0.0]
		    #             setelem F 0 [lindex $Fd [expr $i*12+$j]]
		    #             setelem F 1 [lindex $Fd [expr $i*12+$j+6]]
		    #             set K [mkMatrix 2 2 0.0]
		    #             setelem K 0 0 [expr -$frec*$frec]
		    #             setelem K 0 1 [expr $frec]
		    #             setelem K 1 0 [expr -$frec*$frec]
		    #             setelem K 1 1 [expr -$frec]
		    #             set ab [solveGauss $K $F]
		    #             setelem A $j $j [expr [getelem $A $j $j]+[getelem $ab 0]]
		    #             setelem B $j $j [expr [getelem $B $j $j]+[getelem $ab 1]]
		    #         }
		#     }
	    #     for {set j 0} {$j < 6} {incr j} {
		#         setelem A [expr $j+6] [expr $j+6] [getelem $A $j $j]
		#         setelem B [expr $j+6] [expr $j+6] [expr -[getelem $B $j $j]]
		#     }
	    
	    # .morison.t ins end "M = $M\nA = $A\n B = $B\n"
	    
	    
	    .morison.t ins end "Phase 3: OK\n"
	    .morison.t ins end "Phase 4: Evaluate movement\n"
	    .morison.t see end ; update
	    
	    # Movements evaluation
	    set MA [add $M $A]
	    set w2MA_C [axpy [expr $frec*$frec] $MA $C]
	    set w2MA_wB_C [axpy $frec $B $w2MA_C]
	    set Mu [solveGauss $w2MA_wB_C $Ft]
	    
	    #set Rs [mkVector 6 0.0]
	    set Rs [mkMatrix 6 1 0.0]
	    for {set i 0} {$i < 6} {incr i} {
		set Acos [getelem $Mu $i]
		set Asin [getelem $Mu [expr $i+6]]
		if {$Acos == 0.0 && $Asin == 0.0} {
		    set value1 0.0
		    set value2 0.0
		} else {
		    set cosa [expr (sqrt($Acos*$Acos/double($Asin*$Asin+$Acos*$Acos)))]
		    set alpha1 [expr acos($cosa)]
		    set alpha2 [expr acos(-$cosa)]
		    set value1 [expr abs($Acos*cos($alpha1)+$Asin*sin($alpha1))]
		    set value2 [expr abs($Acos*cos($alpha2)+$Asin*sin($alpha2))]
		}
		if { $value1 >= $value2 } {
		    setelem Rs $i 0 $value1
		} else {
		    setelem Rs $i 0 $value2
		}
	    }    
	    
	    if {$ckBflag == 1} {
		set dX [getelem $Rs 0 0]
		set dY [getelem $Rs 1 0]
		set dZ [getelem $Rs 2 0]
		if {$dX != 0.0} {
		    set dXH [expr $dX/($Ampl*2)]
		} else {
		    set dXH ""
		}
		if {$dY != 0.0} {
		    set dYH [expr $dY/($Ampl*2)]
		} else {
		    set dYH ""
		}
		if {$dZ != 0.0} {
		    set dZH [expr $dZ/($Ampl*2)]
		} else {
		    set dZH ""
		}
		
		set ThX [getelem $Rs 3 0]
		set ThY [getelem $Rs 4 0]
		set ThZ [getelem $Rs 5 0]
		
		set Lpp 35.0
		set adimThX [expr $ThX*$Lpp/(2*$pi*2*$Ampl)]
		set adimThY [expr $ThY*$Lpp/(2*$pi*2*$Ampl)]
		set adimThZ [expr $ThZ*$Lpp/(2*$pi*2*$Ampl)]
		
		set adimFrec [expr $frec/sqrt($Lpp/$gravity)]

		if {$Ampl == [lindex $hsList 0]} {
		    puts $res_file "\t\t $period \t $adimFrec \t $waveLength \t $dX \t $dY \t $dZ \t $ThX \t $ThY \t $ThZ \t $dXH \t $dYH \t $dZH \t $adimThX \t $adimThY \t $adimThZ"
		} else {
		    puts $res_file "\t\t $period \t $adimFrec \t $dX \t $dY \t $dZ \t $ThX \t $ThY \t $ThZ \t $dXH \t $dYH \t $dZH \t $adimThX \t $adimThY \t $adimThZ"
		}
	    }
	    .morison.t ins end "Movements = $Rs\n"
	    .morison.t ins end "Phase 4: OK\n"
	    .morison.t see end ; update
	    
	    puts $out "\n\n$Ampl $period $nu \n$Rs \n\n$Ft"
	    
	}
    }
    .morison.t ins end "Finished OK\n"
    .morison.t see end ; update
    
    if {$ckBflag == 1} {
	close $res_file
    }
    close $out  

    
}

proc morison::rangeHeight {e1H e2H e1T e2T ew1 ep1 ckBh} {
    variable ckBflag
    set selectB [lindex [$ckBh state] 2] 
    
    if {$selectB == "selected"} {
	$e1T configure -state normal
	$e2T configure -state normal
	$ep1 configure -state disabled
	
	$e1H configure -state normal
	$e2H configure -state normal
	$ew1 configure -state disabled

	set ckBflag 1        
    } else {
	$e1T configure -state disabled
	$e2T configure -state disabled
	$ep1 configure -state normal
       
	$e1H configure -state disabled
	$e2H configure -state disabled
	$ew1 configure -state normal

	set ckBflag 0
    } 
    
}
proc morison::Init { frame args } {
    variable waveHeight
    variable InitPeriod
    variable density 
    variable structuredata
    variable draught
    variable NofRefElems
    variable nrows
    variable DsT
    variable CofGx
    variable CofGy
    variable CofGz
    variable RofGx
    variable RofGy
    variable RofGz
    variable 4x4
    variable 3x3
    variable GMT 
    variable GML 
    variable DirNum
    variable windDir
    variable currdir
    variable velWind 45.24
    variable h_1
    variable h_2
    variable t_1
    variable t_2
    variable tubDiam

#     variable path 
    variable ckBflag
    variable w

#     set path $::ProblemTypePriv(problemtypedir)

    set ckH 0

    package require fulltktable
    package require tile
      
    ttk::labelframe $frame.f2 -text "Wave Definition" 

    ttk::label $frame.f2.lDiam -text "Diameter of the tubular"
    set eDiam [ttk::entry $frame.f2.eDiam -textvar morison::tubDiam -state normal]
    ttk::label $frame.f2.luDiam -text "m"
 
    ttk::label $frame.f2.lT1 -text "T1"
    ttk::label $frame.f2.lT2 -text "T2"
    set e1T [ttk::entry $frame.f2.e1T -textvar morison::t_1 -state disabled]
    set e2T [ttk::entry $frame.f2.e2T -textvar morison::t_2 -state disabled]
    ttk::label $frame.f2.luT -text "s"

    ttk::label $frame.f2.lH1 -text "H1"
    ttk::label $frame.f2.lH2 -text "H2"
    set e1H [ttk::entry $frame.f2.e1H -textvar morison::h_1 -state disabled]
    set e2H [ttk::entry $frame.f2.e2H -textvar morison::h_2 -state disabled]
    ttk::label $frame.f2.luH -text "m"

    ttk::label $frame.f2.lw1 -text "Height" 
    set ew1 [ttk::entry $frame.f2.ew1 -textvar morison::waveHeight -state normal]
    ttk::label $frame.f2.lwu1 -text "m"
    
    ttk::label $frame.f2.lp1 -text "Period"
    set ep1 [ttk::entry $frame.f2.ep1 -textvar morison::InitPeriod -state normal]
    ttk::label $frame.f2.lpu1 -text "s"

    ttk::label $frame.f2.lbH -text "Study period and height range"
    set ckBH [ttk::checkbutton $frame.f2.ckBh -offvalue 0 -onvalue 1]
    $frame.f2.ckBh configure -variable $ckH
    $frame.f2.ckBh configure -command [list morison::rangeHeight $e1H $e2H \
	$e1T $e2T $ew1 $ep1 $ckBH]

    if {[$frame.f2.ckBh state] == "selected"} {
	set ckBflag 1
	$frame.f2.e1T configure -state normal
	$frame.f2.e2T configure -state normal
	$frame.f2.ep1 configure -state disabled
	
	$frame.f2.e1H configure -state normal
	$frame.f2.e2H configure -state normal
	$frame.f2.ew1 configure -state disabled
    } else {
	set ckBflag 0
    }
    
    Label $frame.f2.ldn1 -text "Direction" -helptext "Wave direction \nto study, between 0 and pi"
    ttk::entry $frame.f2.edn1 -textvar morison::DirNum 
    ttk::label $frame.f2.ldnu1 -text "rad"

    Label $frame.f2.lcd1 -text "Current Direction" -helptext "Current direction \nto study, between 0 and pi"
    ttk::entry $frame.f2.ecd1 -textvar morison::currDir
    ttk::label $frame.f2.lcdu1 -text "rad"

    Label $frame.f2.lwv1 -text "Wind Velocity" -helptext "Wind velocity"
    ttk::entry $frame.f2.ewv1 -textvar morison::velWind
    ttk::label $frame.f2.lwvu1 -text "m/s"
    
    Label $frame.f2.lwd1 -text "Wind Direction" -helptext "Wind direction \nto study, between 0 and pi"
    ttk::entry $frame.f2.ewd1 -textvar morison::windDir
    ttk::label $frame.f2.lwdu1 -text "rad"

    grid $frame.f2.lbH -row 0 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.ckBh -row 0 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.lH1 -row 1 -column 0 -sticky nsw -padx 2 -pady 1
    grid $frame.f2.e1H -row 1 -column 1 -sticky nsw -padx 2 -pady 1
    grid $frame.f2.lH2 -row 1 -column 2 -sticky nsw -padx 2 -pady 1
    grid $frame.f2.e2H -row 1 -column 3 -sticky nsw -padx 2 -pady 1
    grid $frame.f2.luH -row 1 -column 4 -sticky nsw -padx 2 -pady 1
   

#     grid $frame.f2.lb_T -row 3 -column 0 -sticky nsew -padx 2 -pady 1
#     grid $frame.f2.ckBt -row 3 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.lT1 -row 2 -column 0 -sticky nsw -padx 2 -pady 1
    grid $frame.f2.e1T -row 2 -column 1 -sticky nsw -padx 2 -pady 1
    grid $frame.f2.lT2 -row 2 -column 2 -sticky nsw -padx 2 -pady 1
    grid $frame.f2.e2T -row 2 -column 3 -sticky nsw -padx 2 -pady 1
    grid $frame.f2.luT -row 2 -column 4 -sticky nsw -padx 2 -pady 1

    grid $frame.f2.lw1 -row 3 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.ew1 -row 3 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.lwu1 -row 3 -column 2 -sticky nsw -padx 2 -pady 1

    grid $frame.f2.lp1 -row 4 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.ep1 -row 4 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.lpu1 -row 4 -column 2 -sticky nsw -padx 2 -pady 1
   
    grid $frame.f2.ldn1 -row 5 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.edn1 -row 5 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.ldnu1 -row 5 -column 2 -sticky nsew -padx 2 -pady 1   

    grid $frame.f2.lcd1 -row 6 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.ecd1 -row 6 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.lcdu1 -row 6 -column 2 -sticky nsew -padx 2 -pady 1   

    grid $frame.f2.lwv1 -row 7 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.ewv1 -row 7 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.lwvu1 -row 7 -column 2 -sticky nsew -padx 2 -pady 1   

    
    grid $frame.f2.lwd1 -row 8 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.ewd1 -row 8 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.lwdu1 -row 8 -column 2 -sticky nsew -padx 2 -pady 1   

    grid $frame.f2.lDiam -row 9 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.eDiam -row 9 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.luDiam -row 9 -column 2 -sticky nsew -padx 2 -pady 1   

    ttk::labelframe $frame.f3 -text "More Data"

    ttk::label $frame.f3.ld1 -text "Draught"
    ttk::entry $frame.f3.ed1 -textvar morison::draught
    ttk::label $frame.f3.lud1 -text "m"
    
    ttk::label $frame.f3.ld2 -text "Displacement"
    ttk::entry $frame.f3.ed2 -textvar morison::DsT
    ttk::label $frame.f3.lud2 -text "kg"

    ttk::label $frame.f3.ld3 -text "Centre of Gravity (Xg,Yg,Zg)"
    ttk::entry $frame.f3.ed3 -textvar morison::CofGx
    ttk::entry $frame.f3.ed4 -textvar morison::CofGy
    ttk::entry $frame.f3.ed5 -textvar morison::CofGz
    ttk::label $frame.f3.lud3 -text "m"

    ttk::label $frame.f3.ld4 -text "Radius of Gyration (Rx,Ry,Rz)"
    ttk::entry $frame.f3.ed6 -textvar morison::RofGx 
    ttk::entry $frame.f3.ed7 -textvar morison::RofGy 
    ttk::entry $frame.f3.ed8 -textvar morison::RofGz  
    ttk::label $frame.f3.lud4 -text "m"

    ttk::label $frame.f3.ld5 -text "Long. Metacentric Radius"
    ttk::entry $frame.f3.ed9 -textvar morison::GML 
    ttk::label $frame.f3.lud5 -text "m"

    ttk::label $frame.f3.ld8 -text "Transv. Metacentric Radius"
    ttk::entry $frame.f3.ed10 -textvar morison::GMT 
    ttk::label $frame.f3.lud8 -text "m"
   
    grid $frame.f3.ld1 -row 0 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f3.ed1 -row 0 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f3.lud1 -row 0 -column 2 -sticky nsw -padx 2 -pady 1

    grid $frame.f3.ld2 -row 1 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f3.ed2 -row 1 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f3.lud2 -row 1 -column 2 -sticky nsw -padx 2 -pady 1

    grid $frame.f3.ld3 -row 5 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f3.ed3 -row 5 -column 1 -sticky e -padx 2 -pady 1
    grid $frame.f3.ed4 -row 5 -column 2 -sticky w -padx 2 -pady 1
    grid $frame.f3.ed5 -row 5 -column 3 -sticky e -padx 2 -pady 1
    grid $frame.f3.lud3 -row 5 -column 4 -sticky nsw -padx 2 -pady 1

    grid $frame.f3.ld4 -row 4 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f3.ed6 -row 4 -column 1 -sticky e -padx 2 -pady 1
    grid $frame.f3.ed7 -row 4 -column 2 -sticky w -padx 2 -pady 1
    grid $frame.f3.ed8 -row 4 -column 3 -sticky e -padx 2 -pady 1
    grid $frame.f3.lud4 -row 4 -column 4 -sticky nsw -padx 2 -pady 1

    grid $frame.f3.ld5 -row 2 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f3.ed9 -row 2 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f3.lud5 -row 2 -column 2 -sticky nsw -padx 2 -pady 1

    grid $frame.f3.ld8 -row 3 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f3.ed10 -row 3 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f3.lud8 -row 3 -column 2 -sticky nsw -padx 2 -pady 1


    ttk::frame $frame.buts
    ttk::button $frame.buts.b -text Calculate -width 10 -command [list morison::CalcEvents] -und 0
    
#     bind Entry <Return> "tkButtonInvoke $frame.buts.b"
#     bind $frame <Escape> "tkButtonInvoke $frame.buts.b2"
#     bind $frame <Alt-c> "tkButtonInvoke $frame.buts.b"
#     bind $frame <Alt-x> "tkButtonInvoke $frame.buts.b2"

    grid $frame.buts.b -row 1 -column 1 -padx 2 -pady 3

    grid $frame.f2 -row 0 -column 1 -sticky nsew -padx 2 -pady 2
    grid $frame.f3 -row 1 -column 1 -sticky nsew -padx 2 -pady 2
    grid $frame.buts -row 2 -column 1 -sticky nsew
    grid columnconf $frame 1 -weight 1
    grid rowconf $frame 0 -weight 1
     


}

proc morison::CalcEvents {} {
    
    MorisonCalc
       
}



proc morison::WriteMorisonCustomLoad { } {
#     variable bas_custom_morisonforce
    variable Rs
    variable units
    
#     if {$Rs == ""} {
#         WarnWin [= "Movements not previously obtained.\nCalculating...\nPress OK to continue"]
#         MorisonCalc
#     }

    set intvNum [lindex [GiD_Info intvdata num] 1]
    for {set intv 2} {$intv <= $intvNum} {incr intv} {
	set intvName [lindex [GiD_Info intvdata -interval $intv] 2]
	set data [GiD_Info conditions -interval $intv Morison_Loads mesh]
	if {$data != ""} {
	    break
	}
    }

    set affectedNodes ""
    array unset bas_custom_morisonforce
    
    set _ ""
    set matnum [expr {[llength [GiD_Info materials]]+1}]
    
    set refunits [GiD_AccessValue get gendata Mesh_units#CB#(m,cm,mm)]
    if { $refunits == "mm" } {
	set ref 0
    } elseif { $refunits == "cm" } {
	set ref 1
    } elseif { $refunits == "m" } {
	set ref 2
    }
    
    
#     set data [.central.s info conditions -interval $intvNum Morison_Loads mesh]
    if { ![llength $data] } { return "" }

    MorisonCalc
    
    set loadcasesList ""
    for {set intv 2} {$intv <= $intvNum} {incr intv} {
	set intvName [lindex [GiD_Info intvdata -interval $intv] 2]
	lappend loadcasesList $intvName
	lappend loadedNodes [.central.s info conditions -interval $intv Punctual_Load mesh]
    }

    set PCoordX ""
    set PCoordY ""
    set PCoordZ ""
#     set FnX ""
#     set FnY ""
    set FnZ ""
    
    set countinggg 0
    if { $loadedNodes != ""} {
	foreach j $loadedNodes {
	    if {$j != ""} {
		foreach jj $j {
		    foreach "- num - Units Fx Fy Fz" $jj break
		    set PointCoords [GiD_Info Coordinates $num mesh] 
		    set PointCoords [lindex $PointCoords 0]
		    lappend PCoordX [lindex $PointCoords 0]
		    lappend PCoordY [lindex $PointCoords 1]
		    lappend PCoordZ [lindex $PointCoords 2]
#                     lappend FnX $Fx
#                     lappend FnY $Fy
		    lappend FnZ $Fz
		    incr countinggg
		}            
	    }
	}
    }
    
    foreach i $data {
	foreach "- num - " $i break 
	
	set matProps [.central.s info conditions Section mesh $num]
	set typeSect [lindex $$matProps 4]
	set units [lindex $$matProps 5]

    }
    
    append _ "custom_data\n"
    foreach i $data {
	foreach "- num - localaxes units WaveH IniPer Dn Draught Displac GMt GMl \
	    CGx CGy CGz RGx RGy RGz CurD WinD vWind TubD" $i break 
	       
	set elem [GiD_Info Mesh Elements Linear $num]
	
	set key [list $localaxes $units $WaveH $IniPer $Dn $Draught $Displac $GMt $GMl \
		$CGx $CGy $CGz $RGx $RGy $RGz $CurD $WinD $vWind $TubD]
	
	
	if { ![info exists bas_custom_morisonforce($key)] } {
	    set tcl_code {
		                                
		set nodenum1 [conec 1]
		set nodenum2 [conec 2]
		
		set forceslist ""
		set forcesdraglist ""
		set pi 3.14159265358979323846264
		set twopi 6.28318530717958647692528   
		set density 1025.0
		set visc 1.2e6
		set gravity 9.8
		set densityA 1.22
		set spfWeight 76900
		
		set AWP 0.0
		set Ampl [expr 1.0*$WaveH]
		
		set nu $Dn
		
		set period $IniPer
		set frec [expr $twopi/$period]
		set Kd [expr $frec*$frec/$gravity]
		
		set matProps [giveprops]
		
		set thick [lindex $matProps 16]
		if {[lindex [split $thick -] 0] == "TUBE"} {
		    set thick [lindex [split $thick -] 2]
		} else {
		    set thick [lindex [split $thick -] 1]
		}
		set thick [expr $thick*1.0e-3]
		                
		set elmIx [lindex $matProps 6]
		set elmIy [lindex $matProps 7]
		set elmIz [lindex $matProps 9]
		
		set elmAW [lindex $matProps 10]

		set D $TubD
		
		set xE1a [coords 1 1]
		set yE1a [coords 1 2]
		set zE1 [coords 1 3]
		set xE1 [expr $xE1a*cos($nu) + $yE1a*sin($nu)]
		set yE1 [expr $yE1a*cos($nu) - $xE1a*sin($nu)]

		set xE2a [coords 2 1]
		set yE2a [coords 2 2]
		set zE2 [coords 2 3]
		set xE2 [expr $xE2a*cos($nu) + $yE2a*sin($nu)]
		set yE2 [expr $yE2a*cos($nu) - $xE2a*sin($nu)]
		              
		if {$xE1 < $xE2} {
		    set xma $xE1
		    set xMa $xE2
		    
		    set xE2 $xma
		    set xE1 $xMa
		}
		if {$yE1 < $yE2} {
		    set yma $yE1
		    set yMa $yE2
		    
		    set yE2 $yma
		    set yE1 $yMa
		}
		if {$zE1 < $zE2} {
		    set zma $zE1
		    set zMa $zE2
		    
		    set zE2 $zma
		    set zE1 $zMa
		}
		
		set xEg [expr $xE2 + ($xE1-$xE2)*0.5]
		set yEg [expr $yE2 + ($yE1-$yE2)*0.5]
		set xEga [expr $xE2a + ($xE1a-$xE2a)*0.5]
		set yEga [expr $yE2a + ($yE1a-$yE2a)*0.5]
		set zEg [expr $zE2 + ($zE1-$zE2)*0.5]       
		
		set Lcyl [expr sqrt(pow(($xE1-$xE2),2) + pow(($yE1-$yE2),2) + pow(($zE1-$zE2),2))]
		set elmLong $Lcyl
		
		if {$D != 0.0} {   
		    if {$xE2 >= 0.0} {
		        set ux [expr ($xE1 - $xE2)/$Lcyl]
		    } else {
		        set ux [expr -($xE1 - $xE2)/$Lcyl]
		    }
		    if {$yE2 >= 0.0} {
		        set uy [expr ($yE1 - $yE2)/$Lcyl]
		    } else {
		        set uy [expr -($yE1 - $yE2)/$Lcyl]
		    }                
		    
		    set uz [expr ($zE1 - $zE2)/$Lcyl]
		    
		    if {$zEg <= $Draught} {
		        set Zcalc [expr -($Draught - $zEg)] 
		        set fazztor 1.0  
		        if {$zEg==$zE1} {
		            set height $D 
		            set sAng 1.0
		            set cAng 0.0                 
		        }
		    } else {
		        set Zcalc 0.0
		        set fazztor 0.0
		        if {$zEg==$zE1} {
		            set height [expr ($Draught - $zEg) + $D*0.5] 
		            set zMaxCyl $Draught
		        }
		    }
		    
		    if {($zE1 >= $Draught && $zE2 < $Draught) || ($zE1 > $Draught && $zE2 <= $Draught)} {
		        set AWP [expr $AWP+0.25*$pi*$D*$D]
		    }
		    
		    if {$D==1.8} {
		        set empFict [expr 20*$pi*$D*$D*(10 + 7.5)]
		        set empReal [expr 16*$pi*$D*$D*5.5 + 16*$pi*$D*$D*5.25 + \
		                2*$pi*$D*$D*5.5 + 2*$pi*$D*$D*6.5 + 4*$pi*$D*$D*8.0]
		        set tubFac [expr $empReal/$empFict]
		    } elseif {$D==1.8} {
		        set empFict [expr 20*$pi*$D*$D*(10 + 7.5)]
		        set empReal [expr 16*$pi*$D*$D*5.5 + 16*$pi*$D*$D*5.25 + \
		                2*$pi*$D*$D*5.5 + 2*$pi*$D*$D*6.5 + 4*$pi*$D*$D*8.0]
		        set tubFac [expr $empReal/$empFict]
		    } else {
		        set tubFac 1.0
		    }
		    
		    set elmA [expr $pi*$D*$D*0.25]
		    if { $zE1 <= $Draught && $zE2 < $Draught } {
		        set Emp [expr $tubFac*$density*$gravity*$elmA ]
		    } elseif {$zE1 > $Draught && $zE2 < $Draught} {
		        set dif [expr $Draught - $zE2]
		        set delta [expr $dif/$elmLong]
		        set Emp [expr $tubFac*$density*$gravity*$elmA*$delta ]
		    } else {
		        set Emp 0.0
		    }
		    
		    
		    set Rext [expr $D*0.5]
		    set Rint [expr $Rext - $thick]
		    
		                        
		    set UdMax [expr $Ampl*$frec]
		    
		    set Reyn [expr $UdMax*$D/$visc]
		    if {$Reyn <= 1.0e-5} {
		        set Cd 1.2
		        set Cm 2.0
		    } else {
		        set Cd 0.7
		        set Cm 1.5
		    }
		    
		    
		    set coef1Fd [expr $fazztor*$Cm*$density*$frec*$frec*$Ampl*$D*$D*$pi*0.25*exp($Kd*$Zcalc)]
		    set Fdi ""
		    
		    lappend Fdi [expr $coef1Fd*(($uz*$uz + $uy*$uy)*cos($Kd*$xEg) + $uz*$ux*sin($Kd*$xEg))]
		    lappend Fdi [expr $coef1Fd*(-($uz*$uz + $uy*$uy)*sin($Kd*$xEg) + $uz*$ux*cos($Kd*$xEg))]
		    
		    lappend Fdi [expr $coef1Fd*(-$ux*$uy*cos($Kd*$xEg) + $uz*$uy*sin($Kd*$xEg))]
		    lappend Fdi [expr $coef1Fd*($ux*$uy*sin($Kd*$xEg) + $uz*$uy*cos($Kd*$xEg))]
		    
		    lappend Fdi [expr $coef1Fd*(-($ux*$ux + $uy*$uy)*sin($Kd*$xEg) - $uz*$ux*cos($Kd*$xEg))]
		    lappend Fdi [expr $coef1Fd*(-($ux*$ux + $uy*$uy)*cos($Kd*$xEg) + $uz*$ux*sin($Kd*$xEg))]
		    
		    set Fd1C [lindex $Fdi 0]
		    set Fd1S [lindex $Fdi 1]
		    set Fd2C [lindex $Fdi 2]
		    set Fd2S [lindex $Fdi 3]
		    set Fd3C [lindex $Fdi 4]
		    set Fd3S [lindex $Fdi 5]
		    
		    for {set iF 0} {$iF <= 4} {set iF [expr $iF+2]} {
		        set FdC [lindex $Fdi $iF]
		        set FdS [lindex $Fdi [expr ($iF+1)]]
		        if { [expr abs($FdC)] <= 1.0e-4 && [expr abs($FdS)] <= 1.0e-4} {
		            set F1 0.0
		            set F2 0.0
		        } else {
		            set arg [expr $FdC/sqrt($FdC*$FdC + $FdS*$FdS)]
		            if {abs($arg) > 1.0 } {
		                break
		            }
		            set wtPos [expr acos($arg)] 
		            set wtNeg [expr acos(-$arg)] 
		            
		            set F1 [expr $FdC*cos($wtNeg) + $FdS*sin($wtNeg)]
		            set F2 [expr $FdC*cos($wtPos) + $FdS*sin($wtPos)]
		        }
		        lappend forceslist $F2
		    }
		    
		    
		    lappend forceslist [expr [lindex $forceslist 1]*($zEg-$CGz) + [lindex $forceslist 2]*($yEg-$CGy)]
		    lappend forceslist [expr [lindex $forceslist 0]*($zEg-$CGz) + [lindex $forceslist 2]*($xEg-$CGx)]
		    lappend forceslist [expr [lindex $forceslist 0]*($yEg-$CGy) + [lindex $forceslist 1]*($xEg-$CGx)]
		    
		    set F1a [lindex $forceslist 0]
		    set F2a [lindex $forceslist 1]               
		    set F1 [expr ($F1a*cos($nu) + $F2a*sin($nu))]
		    set F2 [expr ($F2a*cos($nu) - $F1a*sin($nu))]
		    set F3 [lindex $forceslist 2]
		    
		    set F1 [expr $F1*$elmLong*0.5]
		    set F2 [expr $F2*$elmLong*0.5]
		    set F3 [expr $F3*$elmLong*0.5]
		    
		    add_to_load_vector $nodenum1 \
		        [list $F1 $F2 $F3 0.0 0.0 0.0]
		    add_to_load_vector $nodenum2 \
		        [list $F1 $F2 $F3 0.0 0.0 0.0]
		    
		    set vX [expr $Ampl*$frec*exp($Kd*$Zcalc)*sin($Kd*$xEg)]
		    set vZ [expr $Ampl*$frec*exp($Kd*$Zcalc)*cos($Kd*$xEg)]
		    set modLxVxL [expr pow($vX*($uz*$uz + $uy*$uy) - $vZ*$ux*$uz,2) + pow(-$vX*$ux*$uy - $vZ*$uz*$uy,2) \
		            + pow($vZ*($uy*$uy + $ux*$ux) - $vX*$ux*$uz,2)]
		    set modLxVxL [expr pow($modLxVxL,0.5)]
		    set coefDrag [expr $modLxVxL*$fazztor*$density*0.5*$Cd*$frec*$Ampl*$D*exp($Kd*$Zcalc)]                
		    set FDrag ""

		    lappend FDrag [expr $coefDrag*(($uy*$uy + $uz*$uz)*sin($Kd*$xEg) - $ux*$uz*cos($Kd*$xEg))]
		    lappend FDrag [expr $coefDrag*(($uy*$uy + $uz*$uz)*cos($Kd*$xEg) + $ux*$uz*sin($Kd*$xEg))]
		    
		    lappend FDrag [expr $coefDrag*(-$ux*$uy*sin($Kd*$xEg) - $uy*$uz*cos($Kd*$xEg))]
		    lappend FDrag [expr $coefDrag*(-$ux*$uy*cos($Kd*$xEg) + $uy*$uz*sin($Kd*$xEg))]
		    
		    lappend FDrag [expr $coefDrag*(($uy*$uy + $ux*$ux)*cos($Kd*$xEg) - $ux*$uz*sin($Kd*$xEg))]
		    lappend FDrag [expr $coefDrag*(-($uy*$uy + $ux*$ux)*sin($Kd*$xEg) - $ux*$uz*cos($Kd*$xEg))]
		    
		    set FDrag1C [lindex $FDrag 0]
		    set FDrag1S [lindex $FDrag 1]
		    set FDrag2C [lindex $FDrag 2]
		    set FDrag2S [lindex $FDrag 3]
		    set FDrag3C [lindex $FDrag 4]
		    set FDrag3S [lindex $FDrag 5]
		    
		    for {set iF 0} {$iF <= 4} {set iF [expr $iF+2]} {
		        set FdC [lindex $FDrag $iF]
		        set FdS [lindex $FDrag [expr ($iF+1)]]
		        if { [expr abs($FdC)] <= 1.0e-4 && [expr abs($FdS)] <= 1.0e-4} {
		            set F1aux 0.0
		            set F2aux 0.0
		        } else {
		            set arg [expr $FdC/sqrt($FdC*$FdC + $FdS*$FdS)]
		            if {abs($arg) > 1.0 } {
		                break
		            }
		            set wtPos [expr acos($arg)] 
		            set wtNeg [expr acos(-$arg)] 
		            
		            set F1aux [expr $FdC*cos($wtNeg) + $FdS*sin($wtNeg)]
		            set F2aux [expr $FdC*cos($wtPos) + $FdS*sin($wtPos)]
		        }
		        lappend forcesdraglist $F2aux
		    }
		    
		    
		    lappend forcesdraglist [expr [lindex $forcesdraglist 1]*($zEg-$CGz) + [lindex $forcesdraglist 2]*($yEg-$CGy)]
		    lappend forcesdraglist [expr [lindex $forcesdraglist 0]*($zEg-$CGz) + [lindex $forcesdraglist 2]*($xEg-$CGx)]
		    lappend forcesdraglist [expr [lindex $forcesdraglist 0]*($yEg-$CGy) + [lindex $forcesdraglist 1]*($xEg-$CGx)]
		    
		    set F1Draga [lindex $forcesdraglist 0]
		    set F2Draga [lindex $forcesdraglist 1]                
		    set F1Drag [expr 0.5*$elmLong*($F1Draga*cos($nu) + $F2Draga*sin($nu))]
		    set F2Drag [expr 0.5*$elmLong*($F2Draga*cos($nu) - $F1Draga*sin($nu))]
		    set F3Drag [expr 0.5*$elmLong*[lindex $forcesdraglist 2]]
		                        
		    add_to_load_vector $nodenum1 \
		        [list $F1Drag $F2Drag $F3Drag 0.0 0.0 0.0]
		    add_to_load_vector $nodenum2 \
		        [list $F1Drag $F2Drag $F3Drag 0.0 0.0 0.0]

		    addload pressure \
		        [list 0.0 0.0 $Emp]
		    
		    if { $zE1 <= $Draught && $zE2 < $Draught } {
		        set kZ [expr 0.01/$Draught*$zEg]
		        set FcurrX [expr 0.5*pow($kZ*$vWind,2)*$density*0.5*$elmLong*$D*cos($CurD)]
		        set FcurrY [expr 0.5*pow($kZ*$vWind,2)*$density*0.5*$elmLong*$D*sin($CurD)]
		        
		        add_to_load_vector $nodenum1 \
		            [list $FcurrX $FcurrY 0.0 0.0 0.0 0.0]
		        add_to_load_vector $nodenum2 \
		            [list $FcurrX $FcurrY 0.0 0.0 0.0 0.0]
		    }
		    
		}
		

		set elmMass [expr $spfWeight*$elmAW/$gravity]
		set elmDens [expr $spfWeight*$thick/$gravity]
		
		set Fi1 [expr -$elmMass*[lindex $Rs 0]*$frec*$frec]
		set Fi2 [expr -$elmMass*[lindex $Rs 1]*$frec*$frec]
		set Fi3 [expr -$elmMass*[lindex $Rs 2]*$frec*$frec]
	       
		set Fi1 [expr $elmLong*$Fi1*0.5]
		set Fi2 [expr $elmLong*$Fi2*0.5]
		set Fi3 [expr $elmLong*$Fi3*0.5]

		set dx [expr abs($xEga - $CGx)]
		set dy [expr abs($yEga - $CGy)]
		set dz [expr abs($zEg - $Draught)] 
		
		set delta [expr sqrt($dx*$dx + $dy*$dy + $dz*$dz)]
		set elmIx [expr $elmDens*$elmIx + $elmMass*$elmLong*$delta*$delta ]
		set elmIy [expr $elmDens*$elmIy + $elmMass*$elmLong*$delta*$delta ]
		set elmIz [expr $elmDens*$elmIz + $elmMass*$elmLong*$delta*$delta ]

		set Fi4 [expr -0.5*$elmIx*[lindex $Rs 3]*$frec*$frec*$dx]
		set Fi5 [expr -0.5*$elmIy*[lindex $Rs 4]*$frec*$frec*$dy]
		set Fi6 [expr -0.5*$elmIz*[lindex $Rs 5]*$frec*$frec*$dz]
		                
		add_to_load_vector $nodenum1 \
		    [list $Fi1 $Fi2 $Fi3 $Fi4 $Fi5 $Fi6]
		add_to_load_vector $nodenum2 \
		    [list $Fi1 $Fi2 $Fi3 $Fi4 $Fi5 $Fi6]

		
		set count 0
		if { $loadedNodes != ""} {
		    if {![info exists FxI_Punct]} {
		        foreach i $loadedNodes {
		            if {$i != ""} {
		                for {set j $count} {$j < [expr [llength $i] + $count]} {incr j} {
		                    set P_X [lindex $PCoordX $j]
		                    set P_Y [lindex $PCoordY $j]
		                    set P_Z [lindex $PCoordZ $j]
		                    
		                    set distX [expr abs($P_X - $CGx)]
		                    set distY [expr abs($P_Y - $CGy)]
		                    set distZ [expr abs($P_Z - $Draught)]
		                    
		                    set dist [expr sqrt(pow($distX,2) + pow($distY,2) + pow($distZ,2))]
		                    set mass [expr -[lindex $FnZ $j]/$gravity]
		                    set IPunctMass [expr $mass*$dist*$dist]
		                    
		                    set FxI_Punct [expr -$mass*[lindex $Rs 0]*$frec*$frec]
		                    set FyI_Punct [expr -$mass*[lindex $Rs 1]*$frec*$frec]
		                    set FzI_Punct [expr -$mass*[lindex $Rs 2]*$frec*$frec]
		                    
		                    set nodesAux [lindex $i [expr $j - $count]]
		                    set nodesAux [lindex $nodesAux 1]
		                    
		                    add_to_load_vector $nodesAux\
		                        [list $FxI_Punct $FyI_Punct $FzI_Punct \
		                            0.0 0.0 0.0]
		                }
		                set count [expr $j]
		            }
		        }
		    }
		}
	       
		
		if { $zE1 > $Draught && $zE2 >= $Draught } {
		    if {$D != 0.0} {
		        set FwindX [expr pow($vWind,2)*$densityA*0.7*$elmLong*$D*cos($WinD)]
		        set FwindY [expr pow($vWind,2)*$densityA*0.7*$elmLong*$D*sin($WinD)]
		    } else {
		        set B [expr $elmAW/$thick]
		        set FwindX [expr pow($vWind,2)*$densityA*0.7*$elmLong*$B*cos($WinD)]
		        set FwindY [expr pow($vWind,2)*$densityA*0.7*$elmLong*$B*sin($WinD)]
		    }
		    add_to_load_vector $nodenum1 \
		        [list $FwindX $FwindY 0.0 0.0 0.0 0.0]
		    add_to_load_vector $nodenum2 \
		        [list $FwindX $FwindY 0.0 0.0 0.0 0.0]
		} 
		                                                       
	    }            
    #final del tcl_code
	       
	    set maplist ""           
	    foreach i [list localaxes units WaveH IniPer Dn Draught Displac GMt GMl \
		    CGx CGy CGz RGx RGy RGz ref Rs loadedNodes \
		    PCoordX PCoordY PCoordZ FnZ CurD WinD vWind TubD] {
		lappend maplist \$$i [list [set $i]]
	    }
	    set tcl_code [string map $maplist $tcl_code]
	    
	    set tcl_code [string trim $tcl_code]
	    if { $tcl_code eq "" } { set tcl_code " " }
	    set tcl_code_enc [string map [list %0D ""] [::ncgi::encode $tcl_code]]
	    set bas_custom_morisonforce($key) [list $matnum $tcl_code_enc]
	    incr matnum             
	}
    }
    
    foreach key [array names bas_custom_morisonforce] {
	foreach "matnum tcl_code_enc" $bas_custom_morisonforce($key) break
	append _ "$matnum Units=N-m-kg tcl=$tcl_code_enc name=custom$matnum\n"
#         incr matnum
    }
    append _ "end custom_data\n"
    
    

###################### C�digo de prueba
############################# para probar en debug    
    set TestEmpTot 0.0
    set EmpTot 0.0
    set AWP 0.0
    set empOut ""
    set FxMor ""
    set FyMor ""
    set FzMor ""
    
    set FxIn ""
    set FyIn ""
    set FzIn ""
    set MxIn ""
    set MyIn ""
    set MzIn ""
    
    set FxDr "" 
    set FyDr ""
    set FzDr ""

    set FxCurrent ""
    set FyCurrent ""

    set FxWind ""
    set FyWind ""
    
    
    foreach i $data {
	foreach "- num - localaxes units WaveH IniPer Dn Draught Displac GMt GMl \
	    CGx CGy CGz RGx RGy RGz CurD WinD vWind TubD" $i break 
      
	set D $TubD  
	
	set forceslist ""
	set forcesdraglist ""
	
	set pi 3.14159265358979323846264
	set twopi 6.28318530717958647692528   
	set density 1025.0
	set visc 1.2e6
	set gravity 9.8
	set densityA 1.22
	set spfWeight 76900
	
	set Ampl [expr 1.0*$WaveH]
	set nu $Dn
	set period $IniPer
	set frec [expr $twopi/$period]
	set Kd [expr $frec*$frec/$gravity]

	set matProps [.central.s info conditions Section mesh $num]
	
	set elmIx [lindex $$matProps 7]
	set elmIy [lindex $$matProps 8]
	set elmIz [lindex $$matProps 9]
	
	set typeSect [lindex $$matProps 4]
	if {[lindex [split $typeSect -] 0] == "TUBE"} {
	    set thick [lindex [split $typeSect -] 2]
	} else {
	    set thick [lindex [split $typeSect -] 1]       
	}
	
	#         if {[regexp {TUBE-} $typeSect]} {
	    # #             set D [lindex [regexp -inline {TUBE-([ 0-9]*)} $typeSect] 1]
	    #             set thick [lindex [regexp -inline {TUBE-([ 0-9]*)-([ 0-9]*)} $typeSect] 2]
	    #         } 
	if {$ref==2} {
	    #             set D [expr $D*1.0e-3]  
	    set thick [expr $thick*1.0e-3]  
	}
     
       
	set elem [GiD_Info Mesh Elements Linear $num]
	
	set coords1 [GiD_Info Coordinates [lindex $elem 1] mesh] 
	set coords2 [GiD_Info Coordinates [lindex $elem 2] mesh] 
	
	set xE1a [lindex $coords1 0 0]
	set yE1a [lindex $coords1 0 1]
	set zE1 [lindex $coords1 0 2]
	set xE1 [expr $xE1a*cos($nu) + $yE1a*sin($nu)]
	set yE1 [expr $yE1a*cos($nu) - $xE1a*sin($nu)]
	
	set xE2a [lindex $coords2 0 0]
	set yE2a [lindex $coords2 0 1]
	set zE2 [lindex $coords2 0 2]
	set xE2 [expr $xE2a*cos($nu) + $yE2a*sin($nu)]
	set yE2 [expr $yE2a*cos($nu) - $xE2a*sin($nu)]
		               
	if {$xE1 < $xE2} {
	    set xma $xE1
	    set xMa $xE2
	    
	    set xE2 $xma
	    set xE1 $xMa
	}
	if {$yE1 < $yE2} {
	    set yma $yE1
	    set yMa $yE2
	    
	    set yE2 $yma
	    set yE1 $yMa
	}
	if {$zE1 < $zE2} {
	    set zma $zE1
	    set zMa $zE2
	    
	    set zE2 $zma
	    set zE1 $zMa
	}
	
	set xEg [expr $xE2 + ($xE1-$xE2)*0.5]
	set yEg [expr $yE2 + ($yE1-$yE2)*0.5]
	set xEga [expr $xE2a + ($xE1a-$xE2a)*0.5]
	set yEga [expr $yE2a + ($yE1a-$yE2a)*0.5]
	set zEg [expr $zE2 + ($zE1-$zE2)*0.5]       
	
	# Orientaci�n del tubular u_=(ux,uy,uz)=(cosG*cosT,cosG*sinT,sinG) 
	set Lcyl [expr sqrt(pow(($xE1-$xE2),2) + pow(($yE1-$yE2),2) + pow(($zE1-$zE2),2))]  
	set elmLong $Lcyl   
	# Al estar el origen en el centro, hay que tener cuidado con
	# el vector director del tubular
	
	if {$D != 0.0} {
	    if {$xE2 >= 0.0} {
		set ux [expr ($xE1 - $xE2)/$Lcyl]
	    } else {
		set ux [expr -($xE1 - $xE2)/$Lcyl]
	    }
	    if {$yE2 >= 0.0} {
		set uy [expr ($yE1 - $yE2)/$Lcyl]
	    } else {
		set uy [expr -($yE1 - $yE2)/$Lcyl]
	    }
	    #         set ux [expr ($xE1 - $xE2)/$Lcyl] 
	    #         set uy [expr ($yE1 - $yE2)/$Lcyl]       
	    set uz [expr ($zE1 - $zE2)/$Lcyl]
	    #          
	    #         lappend uxs $num $ux
	    #         lappend uys $num $uy
	    
		        
	    if {$zEg <= $Draught} {
		set Zcalc [expr -($Draught - $zEg)] 
		set fazztor 1.0  
		if {$zEg==$zE1} {
		    set height $D 
		    set sAng 1.0
		    set cAng 0.0                 
		}
	    } else {
		set Zcalc 0.0
		set fazztor 0.0
		if {$zEg==$zE1} {
		    set height [expr ($Draught - $zEg) + $D*0.5] 
		    set zMaxCyl $Draught
		}
	    }
	    
	    # para calcular el �rea de flotaci�n
	    if {($zE1 >= $Draught && $zE2 < $Draught) || ($zE1 > $Draught && $zE2 <= $Draught)} {
		set AWP [expr $AWP+0.25*$pi*$D*$D]
	    }
	    
	    # Factor de "escala" para corregir el empuje, ya que hay que tener en cuenta que se coge una longitud mayor de la real
	    # para los tubos horizontales bajos, y hay mucho m�s empuje
	    if {$D==1.8} {
		set empFict [expr 20*$pi*$D*$D*(10 + 7.5)]
		set empReal [expr 16*$pi*$D*$D*5.5 + 16*$pi*$D*$D*5.25 + \
		        2*$pi*$D*$D*5.5 + 2*$pi*$D*$D*6.5 + 4*$pi*$D*$D*8.0]
		#             set tubFac 0.57185
		set tubFac [expr $empReal/$empFict]
	    } elseif {$D==1.8} {
		set empFict [expr 20*$pi*$D*$D*(10 + 7.5)]
		set empReal [expr 16*$pi*$D*$D*5.5 + 16*$pi*$D*$D*5.25 + \
		        2*$pi*$D*$D*5.5 + 2*$pi*$D*$D*6.5 + 4*$pi*$D*$D*8.0]
		#             set tubFac 0.57185
		set tubFac [expr $empReal/$empFict]
	    } else {
		set tubFac 1.0
	    }
	    # Empuje de cada elemento (N/m)
	    set elmA [expr $pi*$D*$D*0.25]
	    if { $zE1 <= $Draught && $zE2 < $Draught } {
		#tubulares totalmente cubiertos
		set Emp [expr $tubFac*$density*$gravity*$elmA ]
	    } elseif {$zE1 > $Draught && $zE2 < $Draught} {
		#tubulares cubiertos parcialmente
		set dif [expr $Draught - $zE2]
		set delta [expr $dif/$elmLong]
		set Emp [expr $tubFac*$density*$gravity*$elmA*$delta ]
	    } else {
		set Emp 0.0
	    }
	    # Peso por unidad de longitud de cada elemento (kg/m)
	    set Rext [expr $D*0.5]
	    set Rint [expr $Rext - $thick]
	    #         set elmAW [expr $pi*($Rext*$Rext - $Rint*$Rint)]
	    
	    set UdMax [expr $Ampl*$frec]
	    
	    set Reyn [expr $UdMax*$D/$visc]
	    if {$Reyn <= 1.0e-5} {
		set Cd 1.2
		set Cm 2.0
	    } else {
		set Cd 0.7
		set Cm 1.5
	    }
	    
	    # Fuerzas de Morison (inercia)
	    set coef1Fd [expr $fazztor*$Cm*$density*$frec*$frec*$Ampl*$D*$D*$pi*0.25*exp($Kd*$Zcalc)]
	    #         set coef1Fd [expr $fazztor*$Cm*$density*$frec*$frec*$Ampl*$D*$elmLong*exp($Kd*$Zcalc)]
	    set Fdi ""
	    
	    lappend Fdi [expr $coef1Fd*(($uz*$uz + $uy*$uy)*cos($Kd*$xEg) + $uz*$ux*sin($Kd*$xEg))]
	    lappend Fdi [expr $coef1Fd*(-($uz*$uz + $uy*$uy)*sin($Kd*$xEg) + $uz*$ux*cos($Kd*$xEg))]
	    
	    lappend Fdi [expr $coef1Fd*(-$ux*$uy*cos($Kd*$xEg) + $uz*$uy*sin($Kd*$xEg))]
	    lappend Fdi [expr $coef1Fd*($ux*$uy*sin($Kd*$xEg) + $uz*$uy*cos($Kd*$xEg))]
	    
	    lappend Fdi [expr $coef1Fd*(-($ux*$ux + $uy*$uy)*sin($Kd*$xEg) - $uz*$ux*cos($Kd*$xEg))]
	    lappend Fdi [expr $coef1Fd*(-($ux*$ux + $uy*$uy)*cos($Kd*$xEg) + $uz*$ux*sin($Kd*$xEg))]
	    
	    set Fd1C [lindex $Fdi 0]
	    set Fd1S [lindex $Fdi 1]
	    set Fd2C [lindex $Fdi 2]
	    set Fd2S [lindex $Fdi 3]
	    set Fd3C [lindex $Fdi 4]
	    set Fd3S [lindex $Fdi 5]
	    
	    for {set iF 0} {$iF <= 4} {set iF [expr $iF+2]} {
		set FdC [lindex $Fdi $iF]
		set FdS [lindex $Fdi [expr ($iF+1)]]
		if { [expr abs($FdC)] <= 1.0e-4 && [expr abs($FdS)] <= 1.0e-4} {
		    set F1 0.0
		    set F2 0.0
		} else {
		    set arg [expr $FdC/sqrt($FdC*$FdC + $FdS*$FdS)]
		    if {abs($arg) > 1.0 } {
		        break
		    }
		    set wtPos [expr acos($arg)] 
		    set wtNeg [expr acos(-$arg)] 
		    
		    set F1 [expr $FdC*cos($wtNeg) + $FdS*sin($wtNeg)]
		    set F2 [expr $FdC*cos($wtPos) + $FdS*sin($wtPos)]
		}
		lappend forceslist $F2
	    }
	    
	    
	    lappend forceslist [expr [lindex $forceslist 1]*($zEg-$CGz) + [lindex $forceslist 2]*($yEg-$CGy)]
	    lappend forceslist [expr [lindex $forceslist 0]*($zEg-$CGz) + [lindex $forceslist 2]*($xEg-$CGx)]
	    lappend forceslist [expr [lindex $forceslist 0]*($yEg-$CGy) + [lindex $forceslist 1]*($xEg-$CGx)]
	    
	    set F1a [lindex $forceslist 0]
	    set F2a [lindex $forceslist 1]                
	    set F1 [expr $F1a*cos($nu) + $F2a*sin($nu)]
	    set F2 [expr $F2a*cos($nu) - $F1a*sin($nu)]
	    set F3 [lindex $forceslist 2]
	    
	    
	    #         set F4a [lindex $forceslist 3]
	    #         set F5a [lindex $forceslist 4]
	    #         set F4 [expr ($F4a*cos($nu) + $F5a*sin($nu))]
	    #         set F5 [expr $F5a*cos($nu) - $F4a*sin($nu)]
	    #         set F6 [lindex $forceslist 5]
	    
	    ###########################under construction
	    # Fuerzas de "drag"
	    set vX [expr $Ampl*$frec*exp($Kd*$Zcalc)*sin($Kd*$xEg)]
	    set vZ [expr $Ampl*$frec*exp($Kd*$Zcalc)*cos($Kd*$xEg)]
	    set modLxVxL [expr pow($vX*($uz*$uz + $uy*$uy) - $vZ*$ux*$uz,2) + pow(-$vX*$ux*$uy - $vZ*$uz*$uy,2) \
		    + pow($vZ*($uy*$uy + $ux*$ux) - $vX*$ux*$uz,2)]
	    set modLxVxL [expr pow($modLxVxL,0.5)]
	    set coefDrag [expr $modLxVxL*$fazztor*$density*0.5*$Cd*$frec*$Ampl*$D*exp($Kd*$Zcalc)]
	    set FDrag ""
	    
	    lappend FDrag [expr $coefDrag*(($uy*$uy + $uz*$uz)*sin($Kd*$xEg) - $ux*$uz*cos($Kd*$xEg))]
	    lappend FDrag [expr $coefDrag*(($uy*$uy + $uz*$uz)*cos($Kd*$xEg) + $ux*$uz*sin($Kd*$xEg))]
	    
	    lappend FDrag [expr $coefDrag*(-$ux*$uy*sin($Kd*$xEg) - $uy*$uz*cos($Kd*$xEg))]
	    lappend FDrag [expr $coefDrag*(-$ux*$uy*cos($Kd*$xEg) + $uy*$uz*sin($Kd*$xEg))]
	    
	    lappend FDrag [expr $coefDrag*(($uy*$uy + $ux*$ux)*cos($Kd*$xEg) - $ux*$uz*sin($Kd*$xEg))]
	    lappend FDrag [expr $coefDrag*(-($uy*$uy + $ux*$ux)*sin($Kd*$xEg) - $ux*$uz*cos($Kd*$xEg))]
	    
	    
	    set FDrag1C [lindex $FDrag 0]
	    set FDrag1S [lindex $FDrag 1]
	    set FDrag2C [lindex $FDrag 2]
	    set FDrag2S [lindex $FDrag 3]
	    set FDrag3C [lindex $FDrag 4]
	    set FDrag3S [lindex $FDrag 5]
	    
	    for {set iF 0} {$iF <= 4} {set iF [expr $iF+2]} {
		set FdC [lindex $FDrag $iF]
		set FdS [lindex $FDrag [expr ($iF+1)]]
		if { [expr abs($FdC)] <= 1.0e-4 && [expr abs($FdS)] <= 1.0e-4} {
		    set F1aux 0.0
		    set F2aux 0.0
		} else {
		    set arg [expr $FdC/sqrt($FdC*$FdC + $FdS*$FdS)]
		    if {abs($arg) > 1.0 } {
		        break
		    }
		    set wtPos [expr acos($arg)] 
		    set wtNeg [expr acos(-$arg)] 
		    
		    set F1aux [expr $FdC*cos($wtNeg) + $FdS*sin($wtNeg)]
		    set F2aux [expr $FdC*cos($wtPos) + $FdS*sin($wtPos)]
		}
		lappend forcesdraglist $F2aux
	    }
	    
	    
	    lappend forcesdraglist [expr [lindex $forcesdraglist 1]*($zEg-$CGz) + [lindex $forcesdraglist 2]*($yEg-$CGy)]
	    lappend forcesdraglist [expr [lindex $forcesdraglist 0]*($zEg-$CGz) + [lindex $forcesdraglist 2]*($xEg-$CGx)]
	    lappend forcesdraglist [expr [lindex $forcesdraglist 0]*($yEg-$CGy) + [lindex $forcesdraglist 1]*($xEg-$CGx)]
	    
	    set F1Draga [lindex $forcesdraglist 0]
	    set F2Draga [lindex $forcesdraglist 1]                
	    set F1Drag [expr $F1Draga*cos($nu) + $F2Draga*sin($nu)]
	    set F2Drag [expr $F2Draga*cos($nu) - $F1Draga*sin($nu)]
	    set F3Drag [lindex $forcesdraglist 2]
	    
	    # Fuerzas corrientes marinas
	    if { $zE1 <= $Draught && $zE2 < $Draught } {
		set kZ [expr 0.01/$Draught*$zEg]
		set Fcurr1 [expr pow($kZ*$vWind,2)*$density*0.5*$elmLong*$D*cos($CurD)]
		set Fcurr2 [expr pow($kZ*$vWind,2)*$density*0.5*$elmLong*$D*sin($CurD)]
	    } else {
		set Fcurr1 0.0
		set Fcurr2 0.0
	    }
	    
		        
	    # C�lculo del empuje total
	    set EmpTot [expr $EmpTot + $Emp]
	    set TestEmpTot [expr $TestEmpTot + $Emp*$elmLong]
	    
	}

######################################################
	
	set elmAW [lindex $$matProps 6]
	# Fuerzas viento
	if { $zE1 > $Draught && $zE2 >= $Draught } {
	    if {$D != 0.0} {
		set Fwind1 [expr pow($vWind,2)*$densityA*0.7*$elmLong*$D*cos($WinD)]
		set Fwind2 [expr pow($vWind,2)*$densityA*0.7*$elmLong*$D*sin($WinD)]
	    } else {
		set B [expr $elmAW/$thick]
		set Fwind1 [expr pow($vWind,2)*$densityA*0.7*$elmLong*$B*cos($WinD)]
		set Fwind2 [expr pow($vWind,2)*$densityA*0.7*$elmLong*$B*sin($WinD)]
	    }
	} else {
	    set Fwind1 0.0
	    set Fwind2 0.0
	}
	
	set elmMass [expr $spfWeight*$elmAW/$gravity]
	set elmDens [expr $spfWeight*$elmLong/$gravity]
	
	# Fuerzas de inercia sobre la estructura 
	set Fi1 [expr -$elmMass*[lindex $Rs 0]*$frec*$frec]
	set Fi2 [expr -$elmMass*[lindex $Rs 1]*$frec*$frec]
	set Fi3 [expr -$elmMass*[lindex $Rs 2]*$frec*$frec]
	
	set dx [expr ($xEga - $CGx)]
	set dy [expr ($yEga - $CGy)]
	set dz [expr ($zEg - $Draught)] 

	set delta [expr sqrt($dx*$dx + $dy*$dy + $dz*$dz)]
	set elmIx [expr $elmDens*$elmIx + $elmMass*$elmLong*$delta*$delta ]
	set elmIy [expr $elmDens*$elmIy + $elmMass*$elmLong*$delta*$delta ]
	set elmIz [expr $elmDens*$elmIz + $elmMass*$elmLong*$delta*$delta ]

	set Fi4 [expr -$elmIx*[lindex $Rs 3]*$frec*$frec*$dx]
	set Fi5 [expr -$elmIy*[lindex $Rs 4]*$frec*$frec*$dy]
	set Fi6 [expr -$elmIz*[lindex $Rs 5]*$frec*$frec*$dz]
      
      
  
	if {$D != 0.0} {
	    lappend empOut [expr $Emp*$elmLong]
	    lappend FxMor $F1
	    lappend FyMor $F2
	    lappend FzMor $F3
	   
	    lappend FxDr $F1Drag
	    lappend FyDr $F2Drag
	    lappend FzDr $F3Drag

	    lappend FxCurrent $Fcurr1
	    lappend FyCurrent $Fcurr2
		        
	} else {
	    lappend empOut 0.0
	    lappend FxMor 0.0
	    lappend FyMor 0.0
	    lappend FzMor 0.0
	    
	    lappend FxDr 0.0
	    lappend FyDr 0.0
	    lappend FzDr 0.0
	    
	    lappend FxCurrent 0.0
	    lappend FyCurrent 0.0
	}

	lappend FxWind $Fwind1
	lappend FyWind $Fwind2
	
	lappend FxIn [format %.5g $Fi1]
	lappend FyIn [format %.5g $Fi2]
	lappend FzIn [format %.5g $Fi3]
	lappend MxIn $Fi4
	lappend MyIn $Fi5
	lappend MzIn $Fi6
	
    }

    # Fuerzas de inercia sobre las cargas puntuales
    set FpX ""
    set FpY ""
    set FpZ ""
    set NumList ""
    
    if {$loadedNodes != ""} {
	foreach j $loadedNodes {
	    if {$j != ""} {
		foreach jj $j {
		    foreach "- num - Units Fx Fy Fz" $jj break
		    #         if { $loadedNodes != ""} 
		    set PointCoords [GiD_Info Coordinates $num mesh] 
		    set PointCoords [lindex $PointCoords 0]
		    set PCoordX [lindex $PointCoords 0]
		    set PCoordY [lindex $PointCoords 1]
		    set PCoordZ [lindex $PointCoords 2]
		    
		    set distX [expr ($PCoordX - $CGx)]
		    set distY [expr ($PCoordY - $CGy)]
		    set distZ [expr ($PCoordZ - $Draught)]
		    
		    set dist [expr sqrt(pow($distX,2) + pow($distY,2) + pow($distZ,2))]
		    
		    set mass [expr -$Fz/$gravity]
		    set IPunctMass [expr $mass*$dist*$dist]
		    
		    set FxI_Punct [expr -$mass*[lindex $Rs 0]*$frec*$frec]
		    set FyI_Punct [expr -$mass*[lindex $Rs 1]*$frec*$frec]
		    set FzI_Punct [expr -$mass*[lindex $Rs 2]*$frec*$frec]
		    
		    lappend FpX $FxI_Punct
		    lappend FpY $FyI_Punct
		    lappend FpZ $FzI_Punct
		    
		    lappend NumList $num
		}
	    }
	} 
    }
    
    #############################
#     set PARENT [lindex $args 0]
#     set frameres [frame $PARENT.f]
    set projectPath [GiD_Info Project ModelName]
    set initial [file rootname [file tail $projectPath]].flavia.res
    set ext ".flavia.res"
    if { $::tcl_platform(platform) == "windows" } {
	set tofile [tk_getSaveFile -defaultextension $ext -initialfile $initial -initialdir $projectPath -title "Save Results"]
    } else {
	set tofile [Browser-ramR file save]
    }
    if { [file ext $tofile] != ".res"} {
	WarnWin "Unknown extension for file '$tofile'"
	return
    }

    set file2 $tofile
    set res_file [open $file2 "w+"]
    puts $res_file "GiD Post Results File 1.0"
    puts $res_file "GaussPoints \"G_P\" Elemtype Linear"
    puts $res_file "Number Of Gauss Points: 1"
    puts $res_file "Nodes not included"
    puts $res_file "Natural Coordinates: Internal"
    puts $res_file "End Gausspoints"

    puts $res_file "Result \"PunctMassF\" \"App_Forces\" 1 Vector OnNodes "
    puts $res_file "ComponentNames \"FpX\" \"FpY\" \"FpZ\" \"|Fp|\""
    puts $res_file "Values"  
    for {set j 0} {$j <= [llength $NumList]} {incr j} {
	puts $res_file "[lindex $NumList $j] [lindex $FpX $j] [lindex $FpY $j] [lindex $FpZ $j]"
    }
    puts $res_file "End Values"

    puts $res_file "Result \"Empuje\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
    puts $res_file "ComponentNames \"\" \"\" \"Emp\" \"|E|\""
    puts $res_file "Values"  
    set index 0
    foreach i $data {
	foreach "- num - " $i break 
	puts $res_file "$num 0.0 0.0 [lindex $empOut $index]"
	incr index    
    }
    puts $res_file "End Values" 
    
    puts $res_file "Result \"F_Morison\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
    puts $res_file "ComponentNames \"FxM\" \"FyM\" \"FzM\" \"|FM|\""
    puts $res_file "Values"   
    set index 0
    foreach i $data {
	foreach "- num - " $i break 
	puts $res_file "$num [lindex $FxMor $index] [lindex $FyMor $index] [lindex $FzMor $index]"
	incr index
    }
    puts $res_file "End Values" 
    
    puts $res_file "Result \"F_Inertia_Str\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
    puts $res_file "ComponentNames \"FxI\" \"FyI\" \"FzI\" \"|FI|\""
    puts $res_file "Values"
    set index 0 
    foreach i $data {
	foreach "- num - " $i break 
	puts $res_file "$num [lindex $FxIn $index] [lindex $FyIn $index] [lindex $FzIn $index]"
	incr index
    }
    puts $res_file "End Values" 
    
    puts $res_file "Result \"M_Inertia_Str\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
    puts $res_file "ComponentNames \"MxI\" \"MyI\" \"MzI\" \"|MI|\""
    puts $res_file "Values"
    set index 0 
    foreach i $data {
	foreach "- num - " $i break
	puts $res_file "$num [lindex $MxIn $index] [lindex $MyIn $index] [lindex $MzIn $index]"
	incr index
    }
    puts $res_file "End Values" 

    puts $res_file "Result \"F_Drag\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
    puts $res_file "ComponentNames \"FxD\" \"FyD\" \"FzD\" \"|FD|\""
    puts $res_file "Values"  
    set index 0 
    foreach i $data {
	foreach "- num - " $i break 
	puts $res_file "$num [lindex $FxDr $index] [lindex $FyDr $index] [lindex $FzDr $index]"
	incr index
	    }
	
    puts $res_file "End Values" 

    puts $res_file "Result \"F_Current\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
    puts $res_file "ComponentNames \"FxCurr\" \"FyCurr\" \"-\" \"|FCURR|\""
    puts $res_file "Values"   
    set index 0
    foreach i $data {
	foreach "- num - " $i break 
	puts $res_file "$num [lindex $FxCurrent $index] [lindex $FyCurrent $index] 0.0"
	incr index
    }
    puts $res_file "End Values" 

    puts $res_file "Result \"F_Wind\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
    puts $res_file "ComponentNames \"FxWind\" \"FyWind\" \"-\" \"|FWIND|\""
    puts $res_file "Values"   
    set index 0
    foreach i $data {
	foreach "- num - " $i break 
	puts $res_file "$num [lindex $FxWind $index] [lindex $FyWind $index] 0.0"
	incr index
    }
    puts $res_file "End Values" 

   
    close $res_file
    #############################        

    set kk $TestEmpTot
    WarnWin [= "Empuje total: $kk"]

    return $_


}

proc morison::WriteInBasFile { interval_num } {
    variable bas_custom_morisonforce
    
    if { $interval_num != 1 } { return }
#     set data [GiD_Info conditions -interval 2 Morison_Loads mesh]
#     if { ![llength $data] } { return "" }
	
    set _ ""
    append _ "static_load\ncustom_data_elems\n"
    # obtenci�n del n� de intervalos/casos de carga
    set intvNum [lindex [GiD_Info intvdata num] 1]
    for {set intv 2} {$intv <= $intvNum} {incr intv} {
	set intvName [lindex [GiD_Info intvdata -interval $intv] 2]
	set data [GiD_Info conditions -interval $intv Morison_Loads mesh]
	if {$data != ""} {
	    break
	}
    }

    if { ![llength $data] } { return "" }
    foreach i $data {
	foreach "- num - localaxes units WaveH IniPer Dn Draught Displac GMt GMl \
	    CGx CGy CGz RGx RGy RGz CurD WinD vWind TubD" $i break
	set key [list $localaxes $units $WaveH $IniPer $Dn $Draught $Displac $GMt $GMl \
		$CGx $CGy $CGz $RGx $RGy $RGz $CurD $WinD $vWind $TubD]
	append _ "$num [lindex $bas_custom_morisonforce($key) 0] name=$intvName\n"
#         append _ "$num [lindex $bas_custom_morisonforce($key) 0]\n"
    }
    append _ "end custom_data_elems\nend static_load\n"
    return $_
    
   
}


proc morison::ComunicateWithGiD { op args } {
    global ProblemTypePriv
    
    
    switch $op {
	"INIT" {
	    set PARENT [lindex $args 0]
	    upvar [lindex $args 1] ROW
	    set GDN [lindex $args 2]
	    set STRUCT [lindex $args 3]
	    
	    set f [frame $PARENT.f]
	    set morison::path $ProblemTypePriv(problemtypedir)
	    
	    morison::Init $f $args
	    
#             set sdat [DWLocalGetValue $GDN $STRUCT StrData]
	    set wh [DWLocalGetValue $GDN $STRUCT WaveH]
	    set inT [DWLocalGetValue $GDN $STRUCT IniPer]
	    set dn [DWLocalGetValue $GDN $STRUCT Dn]
	    set drt [DWLocalGetValue $GDN $STRUCT Draught]
	    set dst [DWLocalGetValue $GDN $STRUCT Displac]
	    set gmt [DWLocalGetValue $GDN $STRUCT GMt]            
	    set gml [DWLocalGetValue $GDN $STRUCT GMl]
	    set cgx [DWLocalGetValue $GDN $STRUCT CGx]
	    set cgz [DWLocalGetValue $GDN $STRUCT CGz]
	    set cgy [DWLocalGetValue $GDN $STRUCT CGy]
	    set rgx [DWLocalGetValue $GDN $STRUCT RGx]
	    set rgz [DWLocalGetValue $GDN $STRUCT RGz]
	    set rgy [DWLocalGetValue $GDN $STRUCT RGy]
	    set cuD [DWLocalGetValue $GDN $STRUCT CurD]
	    set wiD [DWLocalGetValue $GDN $STRUCT WinD]
	    set vW [DWLocalGetValue $GDN $STRUCT vWind]
	    set tD [DWLocalGetValue $GDN $STRUCT TubD]

	    if { $tD ne "" } {
		set morison::tubDiam $tD
	    }            
	    if { $vW ne "" } {
		set morison::velWind $vW
	    }
	    if { $cuD ne "" } {
		set morison::currDir $cuD
	    }
	    if { $wiD ne "" } {
		set morison::windDir $wiD
	    }
	    if { $wh ne "" } {
		set morison::waveHeight $wh
	    }
	    if { $inT ne "" } {
		set morison::InitPeriod $inT
	    }
	    if { $dn ne "" } {
		set morison::DirNum $dn
	    }            
	    if { $drt ne "" } {
		set morison::draught $drt
	    }
	    if { $dst ne "" } {
		set morison::DsT $dst
	    }
	    if { $gmt ne "" } {
		set morison::GMT $gmt
	    }
	    if { $gml ne "" } {
		set morison::GML $gml
	    }
	    if { $cgx ne "" } {
		set morison::CofGx $cgx
	    }
	    if { $cgy ne "" } {
		set morison::CofGy $cgy
	    }
	    if { $cgz ne "" } {
		set morison::CofGz $cgz
	    }
	    if { $rgx ne "" } {
		set morison::RofGx $rgx
	    }
	    if { $rgy ne "" } {
		set morison::RofGy $rgy
	    }
	    if { $rgz ne "" } {
		set morison::RofGz $rgz
	    }
		      
	    
	    grid $f -row $ROW -column 0 -sticky nsew -columnspan 2 -pady 3 -padx 2
	    grid rowconf $PARENT $ROW -weight 1
	    grid columnconf $PARENT 1 -weight 1
	    return ""
	}
	"SYNC" {
	    set GDN [lindex $args 0]
	    set STRUCT [lindex $args 1]
	    
	    foreach "wh inT dn drt dst gmt gml cgx cgy cgz \
		rgx rgy rgz cuD wiD vW tD" [GiveSelectedValues] break
	       
	    DWLocalSetValue $GDN $STRUCT WaveH $wh
	    DWLocalSetValue $GDN $STRUCT IniPer $inT
	    DWLocalSetValue $GDN $STRUCT Dn $dn      
	    DWLocalSetValue $GDN $STRUCT Draught $drt
	    DWLocalSetValue $GDN $STRUCT Displac $dst
	    DWLocalSetValue $GDN $STRUCT GMt $gmt
	    DWLocalSetValue $GDN $STRUCT GMl $gml
	    DWLocalSetValue $GDN $STRUCT CGx $cgx
	    DWLocalSetValue $GDN $STRUCT CGy $cgy
	    DWLocalSetValue $GDN $STRUCT CGz $cgz
	    DWLocalSetValue $GDN $STRUCT RGx $rgx
	    DWLocalSetValue $GDN $STRUCT RGy $rgy
	    DWLocalSetValue $GDN $STRUCT RGz $rgz
	    DWLocalSetValue $GDN $STRUCT CurD $cuD
	    DWLocalSetValue $GDN $STRUCT WinD $wiD
	    DWLocalSetValue $GDN $STRUCT vWind $vW
	    DWLocalSetValue $GDN $STRUCT TubD $tD
		 
	    return ""
	}

    }
}

proc morison::ClosingWarn {} {
    variable flagCalc

    if {$flagCalc == 0} {
	WarnWin [= "Please, press Calculate before closing the window"]
    } else {
	return ""
    }
 }
	    
proc morison::GiveSelectedValues {} {
    variable waveHeight
    variable InitPeriod
#     variable FinalPeriod
    variable draught
    variable DsT 
    variable GMT
    variable GML
    variable CofGx
    variable CofGy
    variable CofGz
    variable RofGx
    variable RofGy
    variable RofGz 
    variable draught
#     variable PerNum
    variable DirNum
    variable currDir 
    variable windDir 
    variable velWind
    variable tubDiam



    ErrCntrl

    return [list $waveHeight $InitPeriod $DirNum $draught $DsT $GMT $GML \
	    $CofGx $CofGy $CofGz $RofGx $RofGy $RofGz $currDir $windDir $velWind $tubDiam]

}  

proc morison::ErrCntrl {} {
    variable waveHeight
    variable InitPeriod
#     variable FinalPeriod
    variable draught
    variable DsT 
    variable GMT
    variable GML
    variable CofGx
    variable CofGy
    variable CofGz
    variable RofGx
    variable RofGy
    variable RofGz 
    variable draught
    variable structuredata
#     variable PerNum 
    variable DirNum 
    variable currDir 
    variable windDir
    variable velWind 
    variable tubDiam
    


    set refcontrol [GiD_AccessValue get gendata Mesh_units#CB#(m,cm,mm)]

    return
}

proc morison::ChangeIntervals {intv} {

    delayedop -cancel changefunc "ChangeIntervals"

    set DisableGraphics [.central.s disable graphics]
    set DisableWarnLine [.central.s disable warnline]
    
    .central.s disable graphics 1
    .central.s disable warnline 1

    .central.s wordcomeraseall
    
    .central.s process escape escape escape escape data intervals changeinterval \
	    $intv escape
    
    if { !$DisableGraphics } { .central.s disable graphics 0 }
    if { !$DisableWarnLine } { .central.s disable warnline 0 }
}
