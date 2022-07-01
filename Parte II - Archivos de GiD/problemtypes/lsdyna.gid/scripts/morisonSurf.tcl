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

namespace eval morisonSurf {
    
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
    variable waveHeight 0.0
    variable InitPeriod 0.0 
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
    variable draught 0.0

    # Longitudinal (OX) metacentric height, and trasversal (OY) metacentric height
    variable GMT 0.0
    variable GML 0.0

    # Radii of gyration
    variable RofGx 0.0
    variable RofGy 0.0
    variable RofGz 0.0  
    
    #Centre of gravity
    variable CofGx  0.0
    variable CofGy 0.0
    variable CofGz 0.0
   
    variable DsT 0.0
    
    
    # Output file
    variable file {C:\Temp\morison.res}
    
    # Constants
    variable pi 3.14159265358979323846264
    variable twopi 6.28318530717958647692528
       
    variable 3x3 0
    variable 4x4 1  

#     variable PerNum 1
    variable DirNum 0.0

    variable TotMass 0.0
    variable sumIx 0.0
    variable sumIy 0.0
    variable sumIz 0.0
    variable sumIflot 0.0
    variable VCTot 0.0
    variable KCiVCi 0.0

    variable Rs ""
    variable currDir 0.0
    variable windDir 0.0
    variable velWind 0.0

    variable h_1 1.0
    variable h_2 15
    variable t_1 1
    variable t_2 20

    variable ckBflag 0
#     variable ckwriteflag 

    variable tubDiam 0.0
    variable tubLength 0.0
 
    variable dX 0.0
    variable dY 0.0
    variable dZ 0.0
    variable tX 0.0
    variable tY 0.0
    variable tZ 0.0
    variable units
    variable doc
    variable f
       
}

proc morisonSurf::create_window {wp dict dict_units domNode} {
    variable w
    variable f
    variable waveHeight
    variable InitPeriod
    variable DirNum
    variable DsT
    variable draught
    variable GMT
    variable GML
    variable CofGx
    variable CofGy
    variable CofGz
    variable RofGx
    variable RofGy
    variable RofGz
    variable currDir
    variable windDir
    variable velWind
    variable tubDiam
    variable tubLength
    variable dX
    variable dY
    variable dZ
    variable tX
    variable tY
    variable tZ
    variable units    

    set datalist ""

    package require dialogwin
    destroy $wp.steelsections
    set w [dialogwin_snit $wp.steelsections -title [_ "Morison S-Loads"]]
    set f [$w giveframe]

    set units [morisonSurf::get_valueMorison units_mesh]  
    
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

#         accept
	lappend datalist $waveHeight $InitPeriod $DirNum $draught $DsT $GMT $GML \
	    $CofGx $CofGy $CofGz $RofGx $RofGy $RofGz $currDir $windDir $velWind $tubDiam $tubLength \
	    $dX $dY $dZ $tX $tY $tZ       
	set tclDataMorisonS [morisonSurf::WriteMorisonCustomLoad $datalist]
       
	dict set dict "WaveHeight" $waveHeight 
	dict set dict "InitialT" $InitPeriod
	dict set dict "WaveDir" $DirNum
	dict set dict "Displac" $DsT
	dict set dict "Draught" $draught
	dict set dict "LongMetRad" $GML
	dict set dict "TransMetRad" $GMT
	dict set dict "RadGyrX" $RofGx
	dict set dict "RadGyrY" $RofGy
	dict set dict "RadGyrZ" $RofGz
	dict set dict "WindVel" $velWind
	dict set dict "WindDir" $windDir
	dict set dict "CurrDir" $CurDir
	dict set dict "TubDiam" $tubDiam
	dict set dict "TubLength" $tubLength
	dict set dict "CofGx" $CofGx
	dict set dict "CofGy" $CofGy
	dict set dict "CofGz" $CofGz 
	dict set dict "LmovX" $dX 
	dict set dict "LmovY" $dY  
	dict set dict "LmovZ" $dZ        
	dict set dict "RotX" $tX 
	dict set dict "RotY" $tY  
	dict set dict "RotZ" $tZ      
	dict set dict "MorisonTclCodeS" $tclDataMorisonS
	destroy $w
	
	return [list $dict $dict_units]
    }
}

proc morisonSurf::get_valueMorison { name } {    
    variable doc
   
    set file [file join $::lsdynaPriv(problemtypedir) "ramseries_default.spd"]
    set aux1 [tDOM::xmlReadFile $file]
    set doc [dom parse $aux1]
    
    set node [$doc selectNodes [format_xpath {//value[@n=%s]} $name]]
    return [get_domnode_attribute $node v]

}


proc morisonSurf::addelem { mt i j val } {
    set val0 [getelem $mt $i $j]
    setelem mt $i $j [expr $val0+$val]
}

proc morisonSurf::vecmax { vt0 vt1 } {
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

proc morisonSurf::MorisonCalc {} {
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
    variable tubDiam


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
	    
		        
	    ##################################################################################################            
	    set geomdat [GiD_Info conditions -interval 2 Morison_LoadsSurfs geometry]
	    ##################################################################################################
	    
	    set superIndex 0
	    set Fd ""
	    foreach i $geomdat {
		foreach "- num - " $i break
		
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
		
		set matProps [.central.s info conditions Section geometry $num]
		
		
		set typeSect [lindex $$matProps 4]
		if {[regexp {TUBE-} $typeSect]} {
		    set D [lindex [regexp -inline {TUBE-([ 0-9]*)} $typeSect] 1]
		}
		if {$ref==2} {
		    set D [expr $D*1.0e-3]  
		} 
		
		
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
		if {$zM <= $draught && ($xG==$xM && $yG==$yM)} {
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

proc morisonSurf::rangeHeight {e1H e2H e1T e2T ew1 ep1 ckBh} {
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

# proc morisonSurf::writeFile {ckBwrite} {
#     variable ckwriteflag
#     set selectBw [lindex [$ckBwrite state] 2] 
# 
#     if {$selectBw == "selected"} {
#         set ckwriteflag 1        
#     } else {
#         set ckwriteflag 0
#     } 
#     
# }

proc morisonSurf::Init { frame args } {
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
    variable tubLength

#     variable path 
    variable ckBflag
#     variable ckwriteflag 
    variable w
    
    variable dX
    variable dY
    variable dZ
    variable tX
    variable tY
    variable tZ


#     set path $::ProblemTypePriv(problemtypedir)

    set ckH 0
    set ckwrite 0

    package require fulltktable
    package require tile
      
    ttk::labelframe $frame.f2 -text "Wave Definition" 
 
    ttk::label $frame.f2.lDiam -text "Diameter of the tubular"
    set eDiam [ttk::entry $frame.f2.eDiam -textvar morisonSurf::tubDiam -state normal]
    ttk::label $frame.f2.luDiam -text "m"

    ttk::label $frame.f2.lL -text "Length of the tubular"
    set eL [ttk::entry $frame.f2.eL -textvar morisonSurf::tubLength -state normal]
    ttk::label $frame.f2.luL -text "m"

    ttk::label $frame.f2.lT1 -text "T1"
    ttk::label $frame.f2.lT2 -text "T2"
    set e1T [ttk::entry $frame.f2.e1T -textvar morisonSurf::t_1 -state disabled]
    set e2T [ttk::entry $frame.f2.e2T -textvar morisonSurf::t_2 -state disabled]
    ttk::label $frame.f2.luT -text "s"

    ttk::label $frame.f2.lH1 -text "H1"
    ttk::label $frame.f2.lH2 -text "H2"
    set e1H [ttk::entry $frame.f2.e1H -textvar morisonSurf::h_1 -state disabled]
    set e2H [ttk::entry $frame.f2.e2H -textvar morisonSurf::h_2 -state disabled]
    ttk::label $frame.f2.luH -text "m"

    ttk::label $frame.f2.lw1 -text "Height" 
    set ew1 [ttk::entry $frame.f2.ew1 -textvar morisonSurf::waveHeight -state normal]
    ttk::label $frame.f2.lwu1 -text "m"
    
    ttk::label $frame.f2.lp1 -text "Period"
    set ep1 [ttk::entry $frame.f2.ep1 -textvar morisonSurf::InitPeriod -state normal]
    ttk::label $frame.f2.lpu1 -text "s"

    ttk::label $frame.f2.lbH -text "Study period and height range"
    set ckBH [ttk::checkbutton $frame.f2.ckBh -offvalue 0 -onvalue 1]
    $frame.f2.ckBh configure -variable $ckH
    $frame.f2.ckBh configure -command [list morisonSurf::rangeHeight $e1H $e2H \
	$e1T $e2T $ew1 $ep1 $ckBH]

#     ttk::label $frame.f2.lbwrite -text "Write forces file"
#     set ckBWrite [ttk::checkbutton $frame.f2.ckBwrite -offvalue 0 -onvalue 1]
#     $frame.f2.ckBwrite configure -variable $ckwrite
#     $frame.f2.ckBwrite configure -command [list morisonSurf::writeFile $ckBWrite]
# 
#     if {[$frame.f2.ckBh state] == "selected"} {
#         set ckBflag 1
#         $frame.f2.e1T configure -state normal
#         $frame.f2.e2T configure -state normal
#         $frame.f2.ep1 configure -state disabled
#         
#         $frame.f2.e1H configure -state normal
#         $frame.f2.e2H configure -state normal
#         $frame.f2.ew1 configure -state disabled
#     } else {
#         set ckBflag 0
#     }
# 
#     if {[$frame.f2.ckBwrite state] == "selected"} {
#         set ckwriteflag 1
#     } else {
#         set ckwriteflag 0
#     }
    
    Label $frame.f2.ldn1 -text "Direction" -helptext "Wave direction \nto study, between 0 and pi"
    ttk::entry $frame.f2.edn1 -textvar morisonSurf::DirNum 
    ttk::label $frame.f2.ldnu1 -text "rad"

    Label $frame.f2.lcd1 -text "Current Direction" -helptext "Current direction \nto study, between 0 and pi"
    ttk::entry $frame.f2.ecd1 -textvar morisonSurf::currDir
    ttk::label $frame.f2.lcdu1 -text "rad"

    Label $frame.f2.lwv1 -text "Wind Velocity" -helptext "Wind velocity"
    ttk::entry $frame.f2.ewv1 -textvar morisonSurf::velWind
    ttk::label $frame.f2.lwvu1 -text "m/s"
    
    Label $frame.f2.lwd1 -text "Wind Direction" -helptext "Wind direction \nto study, between 0 and pi"
    ttk::entry $frame.f2.ewd1 -textvar morisonSurf::windDir
    ttk::label $frame.f2.lwdu1 -text "rad"

    ttk::label $frame.f2.lbD -text "Lin.Movements(Dx,Dy,Dz)"
    ttk::entry $frame.f2.eDx -textvar morisonSurf::dX
    ttk::entry $frame.f2.eDy -textvar morisonSurf::dY
    ttk::entry $frame.f2.eDz -textvar morisonSurf::dZ
    ttk::label $frame.f2.uD -text "m"

    ttk::label $frame.f2.lbT -text "Rotations(Tx,Ty,Tz)"
    ttk::entry $frame.f2.eTx -textvar morisonSurf::tX
    ttk::entry $frame.f2.eTy -textvar morisonSurf::tY
    ttk::entry $frame.f2.eTz -textvar morisonSurf::tZ
    ttk::label $frame.f2.uT -text "rad"

#     grid $frame.f2.lbH -row 0 -column 0 -sticky nsew -padx 2 -pady 1
#     grid $frame.f2.ckBh -row 0 -column 1 -sticky nsew -padx 2 -pady 1
#     grid $frame.f2.lH1 -row 1 -column 0 -sticky nsw -padx 2 -pady 1
#     grid $frame.f2.e1H -row 1 -column 1 -sticky nsw -padx 2 -pady 1
#     grid $frame.f2.lH2 -row 1 -column 2 -sticky nsw -padx 2 -pady 1
#     grid $frame.f2.e2H -row 1 -column 3 -sticky nsw -padx 2 -pady 1
#     grid $frame.f2.luH -row 1 -column 4 -sticky nsw -padx 2 -pady 1
   

# #     grid $frame.f2.lb_T -row 3 -column 0 -sticky nsew -padx 2 -pady 1
# #     grid $frame.f2.ckBt -row 3 -column 1 -sticky nsew -padx 2 -pady 1
#     grid $frame.f2.lT1 -row 2 -column 0 -sticky nsw -padx 2 -pady 1
#     grid $frame.f2.e1T -row 2 -column 1 -sticky nsw -padx 2 -pady 1
#     grid $frame.f2.lT2 -row 2 -column 2 -sticky nsw -padx 2 -pady 1
#     grid $frame.f2.e2T -row 2 -column 3 -sticky nsw -padx 2 -pady 1
#     grid $frame.f2.luT -row 2 -column 4 -sticky nsw -padx 2 -pady 1
    
    grid $frame.f2.lbD -row 0 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.eDx -row 0 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.eDy -row 0 -column 2 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.eDz -row 0 -column 3 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.uD -row 0 -column 4 -sticky nsew -padx 2 -pady 1
    
    grid $frame.f2.lbT -row 1 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.eTx -row 1 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.eTy -row 1 -column 2 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.eTz -row 1 -column 3 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.uT -row 1 -column 4 -sticky nsew -padx 2 -pady 1

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

    grid $frame.f2.lL -row 10 -column 0 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.eL -row 10 -column 1 -sticky nsew -padx 2 -pady 1
    grid $frame.f2.luL -row 10 -column 2 -sticky nsew -padx 2 -pady 1     
    
#     grid $frame.f2.lbwrite -row 10 -column 0 -sticky nsew -padx 2 -pady 1
#     grid $frame.f2.ckBwrite -row 10 -column 1 -sticky nsew -padx 2 -pady 1
    
    ttk::labelframe $frame.f3 -text "More Data"

    ttk::label $frame.f3.ld1 -text "Draught"
    ttk::entry $frame.f3.ed1 -textvar morisonSurf::draught
    ttk::label $frame.f3.lud1 -text "m"
    
    ttk::label $frame.f3.ld2 -text "Displacement"
    ttk::entry $frame.f3.ed2 -textvar morisonSurf::DsT
    ttk::label $frame.f3.lud2 -text "kg"

    ttk::label $frame.f3.ld3 -text "Centre of Gravity (Xg,Yg,Zg)"
    ttk::entry $frame.f3.ed3 -textvar morisonSurf::CofGx
    ttk::entry $frame.f3.ed4 -textvar morisonSurf::CofGy
    ttk::entry $frame.f3.ed5 -textvar morisonSurf::CofGz
    ttk::label $frame.f3.lud3 -text "m"

    ttk::label $frame.f3.ld4 -text "Radius of Gyration (Rx,Ry,Rz)"
    ttk::entry $frame.f3.ed6 -textvar morisonSurf::RofGx 
    ttk::entry $frame.f3.ed7 -textvar morisonSurf::RofGy 
    ttk::entry $frame.f3.ed8 -textvar morisonSurf::RofGz  
    ttk::label $frame.f3.lud4 -text "m"

    ttk::label $frame.f3.ld5 -text "Long. Metacentric Radius"
    ttk::entry $frame.f3.ed9 -textvar morisonSurf::GML 
    ttk::label $frame.f3.lud5 -text "m"

    ttk::label $frame.f3.ld8 -text "Transv. Metacentric Radius"
    ttk::entry $frame.f3.ed10 -textvar morisonSurf::GMT 
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


#     ttk::frame $frame.buts
#     ttk::button $frame.buts.b -text Calculate -width 10 -command [list morisonSurf::CalcEvents] -und 0
    
#     bind Entry <Return> "tkButtonInvoke $frame.buts.b"
#     bind $frame <Escape> "tkButtonInvoke $frame.buts.b2"
#     bind $frame <Alt-c> "tkButtonInvoke $frame.buts.b"
#     bind $frame <Alt-x> "tkButtonInvoke $frame.buts.b2"

#     grid $frame.buts.b -row 1 -column 1 -padx 2 -pady 3

    grid $frame.f2 -row 0 -column 1 -sticky nsew -padx 2 -pady 2
    grid $frame.f3 -row 1 -column 1 -sticky nsew -padx 2 -pady 2
#     grid $frame.buts -row 2 -column 1 -sticky nsew
    grid columnconf $frame 1 -weight 1
    grid rowconf $frame 0 -weight 1
     


}

proc morisonSurf::CalcEvents {} {
    
    morisonSurf::MorisonCalc
       
}

proc morisonSurf::progressbarStop { arg } {
    destroy $arg
    return
}

proc morisonSurf::WriteMorisonCustomLoad {datalist} {
    variable units
    variable doc

    set affectedNodes ""
    array unset bas_custom_morisonforce

    set doc $gid_groups_conds::doc
    set root [$doc documentElement]
#     
#     set _ ""
#     set matnum [expr {[llength [GiD_Info materials]]+1}]
	   
    if { $units == "mm" } {
	set ref 0
    } elseif { $units == "cm" } {
	set ref 1
    } elseif { $units == "m" } {
	set ref 2
    }
    
    set xp {container[@n='loadcases']/blockdata[@n='loadcase']/container[@n='Shells']/condition[@n='morison_load_shell']/group}

    foreach gNode [$root selectNodes $xp] {
	set formats ""
	set elmList ""
	
	dict set formats [$gNode @n] "%d"
	set elmList [GiD_WriteCalculationFile elements -return $formats]
	set elmList [split $elmList \n]
	set elmListaux ""
	foreach num $elmList { 
	    if {$num != ""} {
		lappend elmListaux $num
	    }
	}
	set elmList $elmListaux
       
    }     

#     set data [.central.s info conditions -interval 2 Morison_LoadsSurfs mesh]
#     if { ![llength $data] } { return "" }
    
    set loadedNodes [.central.s info conditions -interval 2 Punctual_Load mesh]
    
    set PCoordX ""
    set PCoordY ""
    set PCoordZ ""
    set FnX ""
    set FnY ""
    set FnZ ""
    
    if { $loadedNodes != ""} {
	foreach j $loadedNodes {
	    foreach "- num - Units Fx Fy Fz" $j break
	    set PointCoords [GiD_Info Coordinates $num mesh] 
	    set PointCoords [lindex $PointCoords 0]
	    lappend PCoordX [lindex $PointCoords 0]
	    lappend PCoordY [lindex $PointCoords 1]
	    lappend PCoordZ [lindex $PointCoords 2]
	    lappend FnX $Fx
	    lappend FnY $Fy
	    lappend FnZ $Fz            
	}
    }
       

    set NelemCount18 0
    set NelemCount45 0
    set NelemCount165 0

    foreach i $data {
	foreach "- num - localaxes units WaveH IniPer Dn Draught Displac GMt GMl \
	    CGx CGy CGz RGx RGy RGz CurD WinD vWind TubD TubL StrMovDx StrMovDy StrMovDz \
	    StrMovTx StrMovTy StrMovTz" $i break 

	if {$num == 1} {
	    set Rs ""
	    lappend Rs $StrMovDx $StrMovDy $StrMovDz \
		$StrMovTx $StrMovTy $StrMovTz
	}
	
	set matProps [.central.s info conditions Steel_Shell mesh $num]
	set units [lindex $$matProps 4]
       
	if {$TubD == 1.8} {
	    incr NelemCount18 
	} elseif {$TubD == 4.5} { 
	    incr NelemCount45 
	} else {
	    incr NelemCount165 
	}


    }
	
    append _ "custom_data\n"
    foreach i $data {
	foreach "- num - localaxes units WaveH IniPer Dn Draught Displac GMt GMl \
	    CGx CGy CGz RGx RGy RGz CurD WinD vWind TubD TubL StrMovDx StrMovDy StrMovDz \
	    StrMovTx StrMovTy StrMovTz" $i break 
	       
	set elem [GiD_Info Mesh Elements Triangle $num]
	
	set key [list $localaxes $units $WaveH $IniPer $Dn $Draught $Displac $GMt $GMl \
		$CGx $CGy $CGz $RGx $RGy $RGz $CurD $WinD $vWind $TubD $TubL]
	      
	if { ![info exists bas_custom_morisonforce($key)] } {
	    set tcl_code {
		
		foreach "xmin xmax" [list 1e20 -1e20] break              
		foreach "zmin zmax" [list 1e20 -1e20] break
		foreach "ymin ymax" [list 1e20 -1e20] break
		for { set i 1 } { $i <= 3 } { incr i } {
		    if { coords($i,3) < $zmin } { set zmin [coords $i 3] }              
		    if { coords($i,3) > $zmax } { set zmax [coords $i 3] }
		    
		    if { coords($i,1) < $xmin } { set xmin [coords $i 1] }
		    if { coords($i,1) > $xmax } { set xmax [coords $i 1] }
		    
		    if { coords($i,2) < $ymin } { set ymin [coords $i 2] }
		    if { coords($i,2) > $ymax } { set ymax [coords $i 2] }
		    
		    if {$i == 1} {
		        lappend E1 coords(1,1) coords(1,2) coords(1,3)
		    } elseif {$i == 2} {
		        lappend E2 coords(2,1) coords(2,2) coords(2,3)
		    } elseif {$i == 3} {
		        lappend E3 coords(3,1) coords(3,2) coords(3,3)
		    }
		}
		
		lappend v_a [expr [lindex $E2 0] - [lindex $E1 0]] [expr [lindex $E2 1] - [lindex $E1 1]] [expr [lindex $E2 2] - [lindex $E1 2]]
		lappend v_b2 [expr [lindex $E3 0] - [lindex $E2 0]] [expr [lindex $E3 1] - [lindex $E2 1]] [expr [lindex $E3 2] - [lindex $E2 2]]
		lappend v_b [expr [lindex $E3 0] - [lindex $E1 0]] [expr [lindex $E3 1] - [lindex $E1 1]] [expr [lindex $E3 2] - [lindex $E1 2]]

		lappend v_c [expr ([lindex $v_b 2]*[lindex $v_a 1] - [lindex $v_b 1]*[lindex $v_a 2])] \
		[expr ([lindex $v_b 0]*[lindex $v_a 2] - [lindex $v_b 2]*[lindex $v_a 0])] \
		[expr ([lindex $v_b 1]*[lindex $v_a 0] - [lindex $v_b 0]*[lindex $v_a 1])]
		
		set v_aModule [expr sqrt([lindex $v_a 0]*[lindex $v_a 0] + \
		[lindex $v_a 1]*[lindex $v_a 1] + [lindex $v_a 2]*[lindex $v_a 2])]
		set v_bModule [expr sqrt([lindex $v_b 0]*[lindex $v_b 0] + \
		        [lindex $v_b 1]*[lindex $v_b 1] + [lindex $v_b 2]*[lindex $v_b 2])]
		set v_cModule [expr sqrt([lindex $v_c 0]*[lindex $v_c 0] + \
		        [lindex $v_c 1]*[lindex $v_c 1] + [lindex $v_c 2]*[lindex $v_c 2])]
		               
		                
		set prodVect [expr $v_cModule/($v_aModule*$v_bModule)]
		if {$prodVect >= 0} {
		    set Atol [expr $prodVect - 1.0]
		    if {(abs($Atol) <= 1.0e-3)} {
		        set prodVect 1.0
		    }
		} else {
		    set Btol [expr $prodVect + 1.0]
		    if {(abs($Btol) <= 1.0e-3)} {
		        set prodVect -1.0
		    }
		}
		
		set v_aAv_b [expr asin($prodVect)]
		set cosA [expr cos($v_aAv_b)]
		set sinA [expr sin($v_aAv_b)]
		set aElm [expr $v_bModule*$cosA]
		set hElm [expr $v_bModule*$sinA]
		
		set nu [expr -$Dn]
		set elemArea [expr 0.5*$v_cModule]
		set xEg [expr ([lindex $E1 0] + [lindex $E2 0] + [lindex $E3 0])/3.0]
		set yEg [expr ([lindex $E1 1] + [lindex $E2 1] + [lindex $E3 1])/3.0]
		set zEg [expr ([lindex $E1 2] + [lindex $E2 2] + [lindex $E3 2])/3.0]
		set xEgNu [expr $xEg*cos($nu) + $yEg*sin($nu)]
		set yEgNu [expr $yEg*cos($nu) - $xEg*sin($nu)]
		set elmIgX [expr 1/36.0*$v_bModule*$hElm*$hElm*$hElm]
		set elmIgY [expr 1/36.0*$v_bModule*$hElm*($v_bModule*$v_bModule - $aElm*$v_bModule + $aElm*$aElm)]
		set elmIgZ [expr $elmIgX + $elmIgY]
		
		
		lappend elemNormal [expr [lindex $v_c 0]/$v_cModule] [expr [lindex $v_c 1]/$v_cModule] [expr [lindex $v_c 2]/$v_cModule]
		set n1 [lindex $elemNormal 0]
		set n2 [lindex $elemNormal 1]
		set n3 [lindex $elemNormal 2]
		                                                
		set nodenum1 [conec 1]
		set nodenum2 [conec 2]
		set nodenum3 [conec 3]
		
		set forceslist ""
		set forcesdraglist ""
		set pi 3.14159265358979323846264
		set twopi 6.28318530717958647692528   
		set density 1025.0
		set visc 1.2e6
		set gravity 9.8
		set densityA 1.22
		                
		set AWP 0.0
		set Ampl [expr 1.0*$WaveH]
		
		set period $IniPer
		set frec [expr $twopi/$period]
		set Kd [expr $frec*$frec/$gravity]
		
		set matProps [giveprops]
		if {[lindex $matProps 0] == "Shell" } {
		    set spfWeight [lindex $matProps 1]
		    set thick [lindex $matProps 7]
		} else {
		    set thick [lindex $matProps 4]
		    set spfWeight 76900
		}
		
		set D $TubD
		
		if {$D != 0.0} {    
		    if {$D == 1.8} {
		       set NelemCount $NelemCount18 
		    } elseif {$D == 4.5} {
		       set NelemCount $NelemCount45 
		    } else {
		        set NelemCount [expr $NelemCount165*($Draught - 8.0)/15.0] 
		    }

		    if {(abs($n1) < abs($n2)) && (abs($n1) < abs($n3))} {
		        set ux [expr cos($nu)]
		        set uy [expr -sin($nu)]
		        set uz 0.0  
		        set zMor [expr (abs([lindex $v_a 0]) + abs([lindex $v_b 0]) + abs([lindex $v_b2 0]))/3.0]
		    } elseif {(abs($n2) < abs($n1)) && (abs($n2) < abs($n3))} {
		        set ux [expr sin($nu)]
		        set uy [expr cos($nu)]
		        set uz 0.0
		        set zMor [expr (abs([lindex $v_a 1]) + abs([lindex $v_b 1]) + abs([lindex $v_b2 1]))/3.0]
		        
		    } elseif {(abs($n3) < abs($n1)) && (abs($n3) < abs($n2))} {
		        set ux 0.0
		        set uy 0.0
		        set uz 1.0
		        set zMor [expr (abs([lindex $v_a 2]) + abs([lindex $v_b 2]) + abs([lindex $v_b2 2]))/3.0]
		    }
		    set fazztorV 1.0
		    set V1 [expr cos($nu)]
		    set V2 [expr sin($nu)]            
		    set cosAlpha [expr $n1*$V1 + $n2*$V2]
		    if {$cosAlpha <= 0.2} {
		        set fazztorV 0.0
		    }    
		    
		    if {$zEg <= $Draught} {
		        set Zcalc [expr -($Draught - $zEg)] 
		        set fazztor 1.0  
		    } else {
		        set Zcalc 0.0
		        set fazztor 0.0
		    }
		    
		    set UdMax [expr $Ampl*$frec]
		    
		    set Reyn [expr $UdMax*$D/$visc]
		    if {$Reyn <= 1.0e-5} {
		        set Cd 1.2
		        set Cm 2.0
		    } else {
		        set Cd 0.7
		        set Cm 1.5
		    }
		    
		    
		    set coef1Fd [expr $fazztor*$Cm*$density*$frec*$frec*$Ampl*$D*$D*$pi*0.25*exp($Kd*$Zcalc)*$TubL]
		    set coef1Fd [expr $coef1Fd/($NelemCount*$elemArea)]
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
		    
		    set F4a [lindex $forceslist 3]
		    set F5a [lindex $forceslist 4]
		    set F4 [expr ($F4a*cos($nu) + $F5a*sin($nu))*$elemArea/3.0]
		    set F5 [expr $F5a*cos($nu) - $F4a*sin($nu)*$elemArea/3.0]
		    set F6 [expr [lindex $forceslist 5]*$elemArea/3.0]
		    
		    addload pressure \
		        [list $F1 $F2 $F3]  
		                        
		    
		    set vX [expr $Ampl*$frec*exp($Kd*$Zcalc)*sin($Kd*$xEg)]
		    set vZ [expr $Ampl*$frec*exp($Kd*$Zcalc)*cos($Kd*$xEg)]
		    set modLxVxL [expr pow($vX*($uz*$uz + $uy*$uy) - $vZ*$ux*$uz,2) + pow(-$vX*$ux*$uy - $vZ*$uz*$uy,2) \
		            + pow($vZ*($uy*$uy + $ux*$ux) - $vX*$ux*$uz,2)]
		    set modLxVxL [expr pow($modLxVxL,0.5)]
		    set coefDrag [expr $modLxVxL*$fazztor*$density*0.5*$Cd*$frec*$Ampl*$D*exp($Kd*$Zcalc)*$TubL]
		    set coefDrag [expr $coefDrag*$fazztorV/(0.5*$NelemCount*$elemArea)]                
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
		    set F1Drag [expr ($F1Draga*cos($nu) + $F2Draga*sin($nu))]
		    set F2Drag [expr ($F2Draga*cos($nu) - $F1Draga*sin($nu))]
		    set F3Drag [expr [lindex $forcesdraglist 2]]
		    
		    set F4Draga [lindex $forcesdraglist 3]
		    set F5Draga [lindex $forcesdraglist 4]
		    set F4Drag [expr ($F4Draga*cos($nu) + $F5Draga*sin($nu))*$elemArea/3.0]
		    set F5Drag [expr $F5Draga*cos($nu) - $F4Draga*sin($nu)*$elemArea/3.0]
		    set F6Drag [expr [lindex $forcesdraglist 5]*$elemArea/3.0]
		    
		    addload pressure \
		        [list $F1Drag $F2Drag $F3Drag]  
		                        
		}
		
		set elmMass [expr $spfWeight*$elemArea*$thick/$gravity]
		set dx [expr ($xEgNu - $CGx)]
		set dy [expr ($yEgNu - $CGy)]
		set dz [expr ($zEg - $Draught)]             
		
		set Fi1 [expr -$elmMass*([lindex $Rs 0] + ([lindex $Rs 4]*$dz - [lindex $Rs 5]*$dy))*$frec*$frec/$elemArea]
		set Fi2 [expr -$elmMass*([lindex $Rs 1] + ([lindex $Rs 5]*$dx - [lindex $Rs 3]*$dz))*$frec*$frec/$elemArea]
		set Fi3 [expr -$elmMass*([lindex $Rs 2] + ([lindex $Rs 3]*$dy - [lindex $Rs 4]*$dx))*$frec*$frec/$elemArea]

		set elmDens [expr $spfWeight*$thick/$gravity]
		set delta [expr sqrt($dx*$dx + $dy*$dy + $dz*$dz)]
		set elmIx [expr $elmDens*$elmIgX + $elmMass*$delta*$delta ]
		set elmIy [expr $elmDens*$elmIgY + $elmMass*$delta*$delta ]
		set elmIz [expr $elmDens*$elmIgZ + $elmMass*$delta*$delta ]
		
		set Fi4 [expr -$elmIx*[lindex $Rs 3]*$frec*$frec/3.0]
		set Fi5 [expr -$elmIy*[lindex $Rs 4]*$frec*$frec/3.0]
		set Fi6 [expr -$elmIz*[lindex $Rs 5]*$frec*$frec/3.0]
		
		addload pressure \
		    [list $Fi1 $Fi2 $Fi3]  
		
		
		if { $loadedNodes != ""} {
		    if {![info exists FxI_Punct]} {
		        for {set j 0} {$j < [llength $loadedNodes]} {incr j} {
		            set P_X [lindex $PCoordX $j]
		            set P_Y [lindex $PCoordY $j]
		            set P_Z [lindex $PCoordZ $j]
		            
		            set distX [expr abs($P_X - $CGx)]
		            set distY [expr abs($P_Y - $CGy)]
		            set distZ [expr abs($P_Z - $Draught)]
		            
		            set dist [expr sqrt(pow($distX,2) + pow($distY,2) + pow($distZ,2))]
		            
		            set mass [expr -[lindex $FnZ $j]/$gravity]
		            set IPunctMass [expr $mass*$dist*$dist]
		            
		            set FxI_Punct [expr $mass*[lindex $Rs 0]*$frec*$frec]
		            set FyI_Punct [expr $mass*[lindex $Rs 1]*$frec*$frec]
		            set FzI_Punct [expr $mass*[lindex $Rs 2]*$frec*$frec]
		            set MxI_Punct [expr $IPunctMass*$distX*[lindex $Rs 3]*$frec*$frec]
		            set MyI_Punct [expr $IPunctMass*$distY*[lindex $Rs 4]*$frec*$frec]
		            set MzI_Punct [expr $IPunctMass*$distZ*[lindex $Rs 5]*$frec*$frec]
		            
		            set nodesAux [lindex $loadedNodes $j]
		            set nodesAux [lindex $nodesAux 1]
		            
		            add_to_load_vector $nodesAux\
		                [list $FxI_Punct $FyI_Punct $FzI_Punct \
		                    0.0 0.0 0.0]
		            
		        }
		    }
		}
		
		set Vcurr1 [expr cos($CurD)]
		set Vcurr2 [expr sin($CurD)]
		set cosBeta [expr $n1*$Vcurr1 + $n2*$Vcurr2]
		set fazztorC 1.0
		if {abs($cosBeta) <= 0.2} {
		    set fazztorC 0.0
		} 
		if { $zEg <= $Draught} {
		    set kZ [expr 0.01/$Draught*$zEg]
		    set FcurrX [expr $fazztorC*0.5*pow($kZ*$vWind,2)*$density*cos($CurD)]
		    set FcurrY [expr $fazztorC*0.5*pow($kZ*$vWind,2)*$density*sin($CurD)]
		    set McurrX [expr $FcurrX*$elemArea*($zEg-$CGz)/3.0]
		    set McurrY [expr $FcurrY*$elemArea*($zEg-$CGz)/3.0]
		    set McurrZ [expr ($FcurrX*($yEg-$CGy) + $FcurrY*($xEg-$CGx))*$elemArea/3.0]
		    
		    addload pressure \
		        [list $FcurrX $FcurrY 0.0]  
		    
		}
		
		set Vw1 [expr cos($WinD)]
		set Vw2 [expr sin($WinD)]
		set cosGamma [expr $n1*$Vw1 + $n2*$Vw2]
		set fazztorW 1.0
		if {abs($cosGamma) <= 0.2} {
		    set fazztorW 0.0
		}
		if { $zEg > $Draught} {
		    set FwindX [expr $fazztorW*0.5*pow($vWind,2)*$densityA*0.7*cos($WinD)*$cosGamma]
		    set FwindY [expr $fazztorW*0.5*pow($vWind,2)*$densityA*0.7*sin($WinD)*$cosGamma]
		    set MwindX [expr $FwindX*$elemArea*($zEg-$CGz)/3.0]
		    set MwindY [expr $FwindY*$elemArea*($zEg-$CGz)/3.0]
		    set MwindZ [expr ($FwindX*($yEg-$CGy) + $FwindY*($xEg-$CGx))*$elemArea/3.0]
		    
		    addload pressure \
		    [list $FwindX $FwindY 0.0] 
		    
		}
		
	    }            
	    #final del tcl_code

#             add_to_load_vector $nodenum1 \
#                 [list 0.0 0.0 0.0 $F4Drag $F5Drag $F6Drag]
#             add_to_load_vector $nodenum2 \
#                 [list 0.0 0.0 0.0 $F4Drag $F5Drag $F6Drag]
#             add_to_load_vector $nodenum3 \
#                 [list 0.0 0.0 0.0 $F4Drag $F5Drag $F6Drag]

#             add_to_load_vector $nodenum1 \
#                 [list 0.0 0.0 0.0 $MwindX $MwindY $MwindZ]
#             add_to_load_vector $nodenum2 \
#                 [list 0.0 0.0 0.0 $MwindX $MwindY $MwindZ]
#             add_to_load_vector $nodenum3 \
#                 [list 0.0 0.0 0.0 $MwindX $MwindY $MwindZ] 

#             add_to_load_vector $nodenum1 \
#                 [list 0.0 0.0 0.0 $McurrX $McurrY $McurrZ]
#             add_to_load_vector $nodenum2 \
#                 [list 0.0 0.0 0.0 $McurrX $McurrY $McurrZ]
#             add_to_load_vector $nodenum3 \
#                 [list 0.0 0.0 0.0 $McurrX $McurrY $McurrZ]

#             add_to_load_vector $nodenum1 \
#                 [list 0.0 0.0 0.0 $F4 $F5 $F6]
#             add_to_load_vector $nodenum2 \
#                 [list 0.0 0.0 0.0 $F4 $F5 $F6]
#             add_to_load_vector $nodenum3 \
#                 [list 0.0 0.0 0.0 $F4 $F5 $F6]

#             add_to_load_vector $nodenum1 \
#                 [list 0.0 0.0 0.0 $Fi4 $Fi5 $Fi6]
#             add_to_load_vector $nodenum2 \
#                 [list 0.0 0.0 0.0 $Fi4 $Fi5 $Fi6]
#             add_to_load_vector $nodenum3 \
#                 [list 0.0 0.0 0.0 $Fi4 $Fi5 $Fi6]
	 
#             set n1 [elem_normal 1]
#             set n2 [elem_normal 2]
#             set n3 [elem_normal 3]   
	    
	    
	    set maplist ""           
	    foreach i [list localaxes units WaveH IniPer Dn Draught Displac GMt GMl \
		    CGx CGy CGz RGx RGy RGz ref loadedNodes \
		    PCoordX PCoordY PCoordZ FnX FnY FnZ CurD WinD vWind \
		    TubD TubL Rs NelemCount18 NelemCount165 NelemCount45] {
		lappend maplist \$$i [list [set $i]]
	    }
	    set tcl_code [string map $maplist $tcl_code]
	    
	    set tcl_code [string trim $tcl_code]
	    if { $tcl_code eq "" } { set tcl_code " " }
	}
    }
       
    set WriteF 1
    if {$WriteF } {
	###################### C�digo de prueba
	############################# para probar en debug    
	set TestEmpTot 0.0
	set EmpTot 0.0
	set AWP 0.0
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
	
	set count -1
	
	set ResMorisonX 0.0
	set ResDragX 0.0
	set ResWindX 0.0
	set ResCurrentX 0.0
	set ResInertiaX 0.0
	
	set ResMorisonY 0.0
	set ResDragY 0.0
	set ResWindY 0.0
	set ResCurrentY 0.0
	set ResInertiaY 0.0

	set ResMorisonZ 0.0
	set ResDragZ 0.0
	set ResWindZ 0.0
	set ResCurrentZ 0.0
	set ResInertiaZ 0.0

	foreach i $data {
	    foreach "- num - localaxes units WaveH IniPer Dn Draught Displac GMt GMl \
		CGx CGy CGz RGx RGy RGz CurD WinD vWind TubD TubL StrMovDx StrMovDy StrMovDz \
		StrMovTx StrMovTy StrMovTz" $i break 
		       
	    incr count
	    set ux ""
	    set uy ""
	    set uz ""
	    set E1 ""
	    set E2 ""
	    set E3 ""
	    set v_a ""
	    set v_b ""
	    set v_c ""
	    set elemNormal ""
	    set fazztorV 1.0        
	    
	    if {$num == 1} {
		set Rs ""
		lappend Rs $StrMovDx $StrMovDy $StrMovDz \
		    $StrMovTx $StrMovTy $StrMovTz
	    }
	    
	    set matProps [.central.s info conditions Steel_Shell mesh $num]
	    set units [lindex $$matProps 4]
	    set thick [lindex $$matProps 5]
	    set spfWeight 76900
	    
	    if {$units == ""} {
		set matProps [.central.s info conditions Shell mesh $num]
		set units [lindex $$matProps 4]
		set thick [lindex $$matProps 5]
		set spfWeight [lindex [split [lindex $$matProps 12] \}] 0]
	    }
	    
	    set D $TubD  
	    
	    set forceslist ""
	    set forcesdraglist ""
	    set pi 3.14159265358979323846264
	    set twopi 6.28318530717958647692528   
	    set density 1025.0
	    set visc 1.2e6
	    set gravity 9.8
	    set densityA 1.22
	  
	    
	    set Ampl [expr 1.0*$WaveH]
	    set nu [expr -$Dn]
	    set period $IniPer
	    set frec [expr $twopi/$period]
	    set Kd [expr $frec*$frec/$gravity]
	    
	    set elem [GiD_Info Mesh Elements Triangle $num]
	    
	    foreach "xmin xmax" [list 1e20 -1e20] break              
	    foreach "zmin zmax" [list 1e20 -1e20] break
	    
	    for { set j 1 } { $j <= 3 } { incr j } {
		set coords [GiD_Info Coordinates [lindex $elem $j] mesh] 
		
		if { [lindex $coords 0 2] < $zmin } { set zmin [lindex $coords 0 2] } 
		if { [lindex $coords 0 2] > $zmax } { set zmax [lindex $coords 0 2] }
		
		if { [lindex $coords 0 0] < $xmin } { set xmin [lindex $coords 0 0] }
		if { [lindex $coords 0 0] > $xmax } { set xmax [lindex $coords 0 0] }
		
		if {$j == 1} {
		    lappend E1 [lindex $coords 0 0] [lindex $coords 0 1] [lindex $coords 0 2]
		} elseif {$j == 2} {
		    lappend E2 [lindex $coords 0 0] [lindex $coords 0 1] [lindex $coords 0 2]
		} elseif {$j == 3} {
		    lappend E3 [lindex $coords 0 0] [lindex $coords 0 1] [lindex $coords 0 2]
		}
	    }
	    
	    set elemProps [GiD_Info ListMassProperties Elements $num]
	    
	    lappend v_a [expr [lindex $E2 0] - [lindex $E1 0]] [expr [lindex $E2 1] - [lindex $E1 1]] [expr [lindex $E2 2] - [lindex $E1 2]]
	    lappend v_b [expr [lindex $E3 0] - [lindex $E1 0]] [expr [lindex $E3 1] - [lindex $E1 1]] [expr [lindex $E3 2] - [lindex $E1 2]]
	    lappend v_b2 [expr [lindex $E3 0] - [lindex $E2 0]] [expr [lindex $E3 1] - [lindex $E2 1]] [expr [lindex $E3 2] - [lindex $E2 2]]

	    lappend v_c [expr ([lindex $v_b 2]*[lindex $v_a 1] - [lindex $v_b 1]*[lindex $v_a 2])] \
		[expr ([lindex $v_b 0]*[lindex $v_a 2] - [lindex $v_b 2]*[lindex $v_a 0])] \
		[expr ([lindex $v_b 1]*[lindex $v_a 0] - [lindex $v_b 0]*[lindex $v_a 1])]
	   
	    
	    set v_aModule [expr sqrt([lindex $v_a 0]*[lindex $v_a 0] + \
		    [lindex $v_a 1]*[lindex $v_a 1] + [lindex $v_a 2]*[lindex $v_a 2])]
	    set v_bModule [expr sqrt([lindex $v_b 0]*[lindex $v_b 0] + \
		    [lindex $v_b 1]*[lindex $v_b 1] + [lindex $v_b 2]*[lindex $v_b 2])]
	    set v_b2Module [expr sqrt([lindex $v_b2 0]*[lindex $v_b2 0] + \
		    [lindex $v_b2 1]*[lindex $v_b2 1] + [lindex $v_b2 2]*[lindex $v_b2 2])]
	    
	    set v_cModule [expr sqrt([lindex $v_c 0]*[lindex $v_c 0] + \
		    [lindex $v_c 1]*[lindex $v_c 1] + [lindex $v_c 2]*[lindex $v_c 2])]

	    set prodVect [expr $v_cModule/($v_aModule*$v_bModule)]
	    if {$prodVect >= 0} {
		set Atol [expr $prodVect - 1.0]
		if {(abs($Atol) <= 1.0e-4)} {
		    set prodVect 1.0
		}
	    } else {
		set Btol [expr $prodVect + 1.0]
		if {(abs($Btol) <= 1.0e-4)} {
		    set prodVect -1.0
		}
	    }
		        
	    set v_aAv_b [expr asin($prodVect)]
	    set cosA [expr cos($v_aAv_b)]
	    set sinA [expr sin($v_aAv_b)]
	    set aElm [expr $v_bModule*$cosA]
	    set hElm [expr $v_bModule*$sinA]
	    
	    set elemArea [expr 0.5*$v_cModule]
	    set xEg [expr ([lindex $E1 0] + [lindex $E2 0] + [lindex $E3 0])/3.0]
	    set yEg [expr ([lindex $E1 1] + [lindex $E2 1] + [lindex $E3 1])/3.0]
	    set zEg [expr ([lindex $E1 2] + [lindex $E2 2] + [lindex $E3 2])/3.0]
	    set xEgNu [expr $xEg*cos($nu) + $yEg*sin($nu)]
	    set yEgNu [expr $yEg*cos($nu) - $xEg*sin($nu)]
	    set elmIgX [expr 1/36.0*$v_bModule*$hElm*$hElm*$hElm]
	    set elmIgY [expr 1/36.0*$v_bModule*$hElm*($v_bModule*$v_bModule - $aElm*$v_bModule + $aElm*$aElm)]
	    set elmIgZ [expr $elmIgX + $elmIgY]
	    
	    lappend elemNormal [expr [lindex $v_c 0]/$v_cModule] [expr [lindex $v_c 1]/$v_cModule] [expr [lindex $v_c 2]/$v_cModule]
	    set n1 [lindex $elemNormal 0]
	    set n2 [lindex $elemNormal 1]
	    set n3 [lindex $elemNormal 2]
	   
	    if {$D != 0.0} { 
		
		if {$D == 1.8} {
		    set NelemCount $NelemCount18 
		} elseif {$D == 4.5} {
		    set NelemCount $NelemCount45 
		} else {
#                     el ((calado - 8.0)/15) es la proporci�n de n�mero de elementos mojados
		    set NelemCount [expr $NelemCount165*($Draught - 8.0)/15.0] 
		}
		
		if {(abs($n1) < abs($n2)) && (abs($n1) < abs($n3))} {
		    # cilindros horizontales OX (se gira el �ngulo correspondiente a la ola incidente $nu)
		    set ux [expr cos($nu)]
		    set uy [expr -sin($nu)]
		    set uz 0.0  
		    set zMor [expr (abs([lindex $v_a 0]) + abs([lindex $v_b 0]) + abs([lindex $v_b2 0]))/3.0]
		} elseif {(abs($n2) < abs($n1)) && (abs($n2) < abs($n3))} {
		    # cilindros horizontales OY (se gira el �ngulo correspondiente a la ola incidente $nu)
		    set ux [expr sin($nu)]
		    set uy [expr cos($nu)]
		    set uz 0.0
		    set zMor [expr (abs([lindex $v_a 1]) + abs([lindex $v_b 1]) + abs([lindex $v_b2 1]))/3.0]
		} elseif {(abs($n3) < abs($n1)) && (abs($n3) < abs($n2))} {
		    # cilindros verticales
		    set ux 0.0
		    set uy 0.0
		    set uz 1.0
		    set zMor [expr (abs([lindex $v_a 0]) + abs([lindex $v_b 0]) + abs([lindex $v_b2 0]))/3.0]
		}
		
		#         Hay que comprobar que solo se afectan los elementos de la mitad enfrentada a la ola incidente           
		set V1 [expr cos($nu)]
		set V2 [expr sin($nu)]            
		set cosAlpha [expr $n1*$V1 + $n2*$V2]
		if {$cosAlpha <= 0.2} {
		    set fazztorV 0.0
		}    
		
		if {$zEg <= $Draught} {
		    set Zcalc [expr -($Draught - $zEg)] 
		    set fazztor 1.0  
		} else {
		    set Zcalc 0.0
		    set fazztor 0.0
		}
		
		set UdMax [expr $Ampl*$frec]
		
		set Reyn [expr $UdMax*$D/$visc]
		if {$Reyn <= 1.0e-5} {
		    set Cd 1.2
		    set Cm 2.0
		} else {
		    set Cd 0.7
		    set Cm 1.5
		}
		
		# Fuerzas de Morison (m�sicas) (Newtons)
		set coef1Fd [expr $fazztor*$Cm*$density*$frec*$frec*$Ampl*$D*$D*$pi*0.25*exp($Kd*$Zcalc)*$TubL/($NelemCount)]
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
		
		
#                 set F4a [lindex $forceslist 3]
#                 set F5a [lindex $forceslist 4]
#                 set F4 [expr ($F4a*cos($nu) + $F5a*sin($nu))*$elemArea]
#                 set F5 [expr ($F5a*cos($nu) - $F4a*sin($nu))*$elemArea]
#                 set F6 [expr [lindex $forceslist 5]*$elemArea]
		
		# Fuerzas de "drag" (Newtons)
		set vX [expr $Ampl*$frec*exp($Kd*$Zcalc)*sin($Kd*$xEg)]
		set vZ [expr $Ampl*$frec*exp($Kd*$Zcalc)*cos($Kd*$xEg)]
		set modLxVxL [expr pow($vX*($uz*$uz + $uy*$uy) - $vZ*$ux*$uz,2) + pow(-$vX*$ux*$uy - $vZ*$uz*$uy,2) \
		        + pow($vZ*($uy*$uy + $ux*$ux) - $vX*$ux*$uz,2)]
		set modLxVxL [expr pow($modLxVxL,0.5)]
#                 set coefDrag [expr $modLxVxL*$fazztor*$fazztorV*$density*0.5*$Cd*$frec*$Ampl*$D*exp($Kd*$Zcalc)]
		set coefDrag [expr $fazztorV*$modLxVxL*$fazztor*$density*0.5*$Cd*$frec*$Ampl*$D*exp($Kd*$Zcalc)*$TubL/(0.5*$NelemCount)]
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
		
#                 set F4Draga [lindex $forcesdraglist 3]
#                 set F5Draga [lindex $forcesdraglist 4]
#                 set F4Drag [expr ($F4Draga*cos($nu) + $F5Draga*sin($nu))*$elemArea]
#                 set F5Drag [expr ($F5Draga*cos($nu) - $F4Draga*sin($nu))*$elemArea]
#                 set F6Drag [expr [lindex $forcesdraglist 5]*$elemArea]
		
	    } 

	    ######################################################
	    
	    # Fuerzas de inercia sobre la estructura 
#             set elmMass [expr $spfWeight*$elemArea*$thick/$gravity]
	    #presi�n
	    set elmMass [expr $spfWeight*$thick/$gravity] 
	    set dx [expr ($xEgNu - $CGx)]
	    set dy [expr ($yEgNu - $CGy)]
	    set dz [expr ($zEg - $Draught)]             
	    
	    set Fi1 [expr -$elmMass*([lindex $Rs 0] + ([lindex $Rs 4]*$dz - [lindex $Rs 5]*$dy))*$frec*$frec]
	    set Fi2 [expr -$elmMass*([lindex $Rs 1] + ([lindex $Rs 5]*$dx - [lindex $Rs 3]*$dz))*$frec*$frec]
	    set Fi3 [expr -$elmMass*([lindex $Rs 2] + ([lindex $Rs 3]*$dy - [lindex $Rs 4]*$dx))*$frec*$frec]
		                    
#             set elmDens [expr $spfWeight*$thick/$gravity]
#             set delta [expr sqrt($dx*$dx + $dy*$dy + $dz*$dz)]
#             set elmIx [expr $elmDens*$elmIgX + $elmMass*$delta*$delta*$elemArea ]
#             set elmIy [expr $elmDens*$elmIgY + $elmMass*$delta*$delta*$elemArea ]
#             set elmIz [expr $elmDens*$elmIgZ + $elmMass*$delta*$delta*$elemArea ]
#             
#             set Fi4 [expr -$elmIx*[lindex $Rs 3]*$frec*$frec]
#             set Fi5 [expr -$elmIy*[lindex $Rs 4]*$frec*$frec]
#             set Fi6 [expr -$elmIz*[lindex $Rs 5]*$frec*$frec]
	    
	    
	    # Fuerzas corrientes marinas
	    # Vector de la direcci�n de la corriente
	    set Vcurr1 [expr cos($CurD)]
	    set Vcurr2 [expr sin($CurD)]
	    # �ngulo con la normal al elemento con la direcci�n de la corriente
	    set cosBeta [expr $n1*$Vcurr1 + $n2*$Vcurr2]
	    set fazztorC 1.0
	    if {$cosBeta <= 0.2} {
		set fazztorC 0.0
	    } 
	    if { $zEg <= $Draught } {
		set kZ [expr 0.01/$Draught*$zEg]
		set Fcurr1 [expr $fazztorC*pow($kZ*$vWind,2)*$density*0.5*cos($CurD)]
		set Fcurr2 [expr $fazztorC*pow($kZ*$vWind,2)*$density*0.5*sin($CurD)]
	    } else {
		set Fcurr1 0.0
		set Fcurr2 0.0
	    }
	    
	    # Fuerzas viento
	    # Vector de la direcci�n de la corriente
	    set Vw1 [expr cos($WinD)]
	    set Vw2 [expr sin($WinD)]
	    # �ngulo con la normal al elemento con la direcci�n de la corriente
	    set cosGamma [expr $n1*$Vw1 + $n2*$Vw2]
	    set fazztorW 1.0
	    if {$cosGamma <= 0.2} {
		set fazztorW 0.0
	    }
	    if { $zEg > $Draught } {
		set Fwind1 [expr $fazztorW*0.5*pow($vWind,2)*$densityA*0.7*cos($WinD)*$cosGamma]
		set Fwind2 [expr $fazztorW*0.5*pow($vWind,2)*$densityA*0.7*sin($WinD)*$cosGamma]
	    } else {
		set Fwind1 0.0
		set Fwind2 0.0
	    }
	    
	    if {$D != 0.0} {
		lappend FxMor $F1
		lappend FyMor $F2
		lappend FzMor $F3
		
		lappend FxDr $F1Drag
		lappend FyDr $F2Drag
		lappend FzDr $F3Drag
		
		set ResMorisonX [expr $ResMorisonX + $F1]
		set ResDragX [expr $ResDragX + $F1Drag]
		
		set ResMorisonY [expr $ResMorisonY + $F2]
		set ResDragY [expr $ResDragY + $F2Drag]
		
		set ResMorisonZ [expr $ResMorisonZ + $F3]
		set ResDragZ [expr $ResDragZ + $F3Drag]
		
		
	    } else {
		lappend FxMor 0.0
		lappend FyMor 0.0
		lappend FzMor 0.0
	       
		lappend FxDr 0.0
		lappend FyDr 0.0
		lappend FzDr 0.0
	    }
	    
	    lappend FxIn [format %.5g $Fi1]
	    lappend FyIn [format %.5g $Fi2]
	    lappend FzIn [format %.5g $Fi3]
	    lappend MxIn 0.0
	    lappend MyIn 0.0
	    lappend MzIn 0.0
	    
	    lappend FxCurrent $Fcurr1
	    lappend FyCurrent $Fcurr2
	    
	    lappend FxWind $Fwind1
	    lappend FyWind $Fwind2
	    
	    
	    set ResWindX [expr $ResWindX + $Fwind1]
	    set ResCurrentX [expr $ResCurrentX + $Fcurr1]
	    set ResInertiaX [expr $ResInertiaX + [format %.5g $Fi1]]
		        
	    set ResWindY [expr $ResWindY + $Fwind2]
	    set ResCurrentY [expr $ResCurrentY + $Fcurr2]
	    set ResInertiaY [expr $ResInertiaY + [format %.5g $Fi2]]
		        
	    set ResInertiaZ [expr $ResInertiaZ + [format %.5g $Fi3]]
		        
	}
	
	if { ![winfo exists .resforces] } { 
	    toplevel .resforces 
	    wm title .resforces "Forces"
	    wm iconname .resforces "Forces Output"
	    pack [text .resforces.t -width 70 -height 20]
	}
	
	.resforces.t ins end "\nFxMor = $ResMorisonX \n"
	.resforces.t ins end "FyMor = $ResMorisonY \n"
	.resforces.t ins end "FzMor = $ResMorisonZ \n"
	.resforces.t ins end "\nFxDrag = $ResDragX \n"
	.resforces.t ins end "FyDrag = $ResDragY \n"
	.resforces.t ins end "FzDrag = $ResDragZ \n"
	.resforces.t ins end "\nFxI = $ResInertiaX \n"
	.resforces.t ins end "FyI = $ResInertiaY \n"
	.resforces.t ins end "FzI = $ResInertiaZ \n"
	.resforces.t ins end "\nFxW = $ResWindX \n"
	.resforces.t ins end "FyW = $ResWindY \n"
	.resforces.t ins end "\nFxC = $ResCurrentX \n"
	.resforces.t ins end "FyC = $ResCurrentY \n"
	
	.resforces.t ins end "Finished OK\n"
	.resforces.t see end ; update


	# Fuerzas de inercia sobre las cargas puntuales
	set FpX ""
	set FpY ""
	set FpZ ""
	set MpX ""
	set MpY ""
	set MpZ ""
	set NumList ""
	
	if {$loadedNodes != ""} {
	    foreach j $loadedNodes {
		foreach "- num - Units Fx Fy Fz" $j break
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
		
		set FxI_Punct [expr $mass*[lindex $Rs 0]*$frec*$frec]
		set FyI_Punct [expr $mass*[lindex $Rs 1]*$frec*$frec]
		set FzI_Punct [expr $mass*[lindex $Rs 2]*$frec*$frec]
		set MxI_Punct [expr $IPunctMass*$distX*[lindex $Rs 3]*$frec*$frec]
		set MyI_Punct [expr $IPunctMass*$distY*[lindex $Rs 4]*$frec*$frec]
		set MzI_Punct [expr $IPunctMass*$distZ*[lindex $Rs 5]*$frec*$frec]
		
		lappend FpX $FxI_Punct
		lappend FpY $FyI_Punct
		lappend FpZ $FzI_Punct
#                 lappend MpX $MxI_Punct
#                 lappend MpY $MyI_Punct
#                 lappend MpZ $MzI_Punct
		
		lappend NumList $num
	    }
	}
	
		
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
	puts $res_file "GaussPoints \"G_P\" Elemtype Triangle"
	puts $res_file "Number Of Gauss Points: 1"
	#     puts $res_file "Nodes not included"
	puts $res_file "Natural Coordinates: Internal"
	puts $res_file "End Gausspoints"
	
	#     puts $res_file "Result \"PunctMassF\" \"App_Forces\" 1 Vector OnNodes "
	#     puts $res_file "ComponentNames \"FpX\" \"FpY\" \"FpZ\" \"|Fp|\""
	#     puts $res_file "Values"  
	#     for {set j 0} {$j <= [llength $NumList]} {incr j} {
	    #         puts $res_file "[lindex $NumList $j] [lindex $FpX $j] [lindex $FpY $j] [lindex $FpZ $j]"
	    #     }
	#     puts $res_file "End Values"
	# 
	#     puts $res_file "Result \"PunctMassM\" \"App_Forces\" 1 Vector OnNodes "
	#     puts $res_file "ComponentNames \"MpX\" \"MpY\" \"MpZ\" \"|Mp|\""
	#     puts $res_file "Values"  
	#     for {set j 0} {$j <= [llength $NumList]} {incr j} {
	    #         puts $res_file "[lindex $NumList $j] [lindex $MpX $j] [lindex $MpY $j] [lindex $MpZ $j]"
	    #     }
	#     puts $res_file "End Values"
	
	#     puts $res_file "Result \"Empuje\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
	#     puts $res_file "ComponentNames \"\" \"\" \"Emp\" \"|E|\""
	#     puts $res_file "Values"  
	#     set index 0
	#     foreach i $data {
	    #         foreach "- num - " $i break 
	    # #         if {[lindex $empOut $num] == ""} {
		# #             break
		# #         }
	    # #         puts $res_file "$num 0.0 0.0 [lindex $empOut [expr $num-1]]"
	    #         puts $res_file "$num 0.0 0.0 [lindex $empOut $index]"
	    #         incr index    
	    #     }
	#     puts $res_file "End Values" 
	
	       
	puts $res_file "Result \"F_Inertia_Str\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
	puts $res_file "ComponentNames \"FxI\" \"FyI\" \"FzI\" \"|FI|\""
	puts $res_file "Values"
	set index 0 
	foreach i $data {
	    foreach "- num - " $i break 
	    #         puts $res_file "$num [lindex $FxIn [expr $num-1]] [lindex $FyIn [expr $num-1]] [lindex $FzIn [expr $num-1]]"
	    puts $res_file "$num [lindex $FxIn $index] [lindex $FyIn $index] [lindex $FzIn $index]"
	    incr index
#             set morisonSurf::progressbar $num
#             set morisonSurf::progressbarT "Out-> F. Inertia"
	}
	puts $res_file "End Values" 
#         set num 0
	
	puts $res_file "Result \"M_Inertia_Str\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
	puts $res_file "ComponentNames \"MxI\" \"MyI\" \"MzI\" \"|MI|\""
	puts $res_file "Values"
	set index 0 
	foreach i $data {
	    foreach "- num - " $i break
	    #         puts $res_file "$num [lindex $MxIn [expr $num-1]] [lindex $MyIn [expr $num-1]] [lindex $MzIn [expr $num-1]]"
	    puts $res_file "$num [lindex $MxIn $index] [lindex $MyIn $index] [lindex $MzIn $index]"
	    incr index
#             set morisonSurf::progressbar $num
#             set morisonSurf::progressbarT "Out-> M. Inertia"
	}
	puts $res_file "End Values" 
#         set num 0

       
	    puts $res_file "Result \"F_Morison\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
	    puts $res_file "ComponentNames \"FxM\" \"FyM\" \"FzM\" \"|FM|\""
	    puts $res_file "Values"   
	    set index 0
	    foreach i $data {
		foreach "- num - " $i break 
		#         puts $res_file "$num [lindex $FxMor [expr $num-1]] [lindex $FyMor [expr $num-1]] [lindex $FzMor [expr $num-1]]"
		puts $res_file "$num [lindex $FxMor $index] [lindex $FyMor $index] [lindex $FzMor $index]"
		incr index
#                 set morisonSurf::progressbar $num
#                 set morisonSurf::progressbarT "Out-> F. Morison"
	    }
	    puts $res_file "End Values" 
#             set num 0

#             puts $res_file "Result \"M_Morison\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
#             puts $res_file "ComponentNames \"MxM\" \"MyM\" \"MzM\" \"|MM|\""
#             puts $res_file "Values"
#             set index 0 
#             foreach i $data {
#                 foreach "- num - " $i break 
#                 #         puts $res_file "$num [lindex $MxMor [expr $num-1]] [lindex $MyMor [expr $num-1]] [lindex $MzMor [expr $num-1]]"
#                 puts $res_file "$num [lindex $MxMor $index] [lindex $MyMor $index] [lindex $MzMor $index]"
#                 incr index
#                 set morisonSurf::progressbar $num
#                 set morisonSurf::progressbarT "Out-> M. Morison"
#             }
#             puts $res_file "End Values" 
#             set num 0
	    
	    puts $res_file "Result \"F_Drag\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
	    puts $res_file "ComponentNames \"FxD\" \"FyD\" \"FzD\" \"|FD|\""
	    puts $res_file "Values"  
	    set index 0 
	    foreach i $data {
		foreach "- num - " $i break 
		#         puts $res_file "$num [lindex $FxDr [expr $num-1]] [lindex $FyDr [expr $num-1]] [lindex $FzDr [expr $num-1]]"
		puts $res_file "$num [lindex $FxDr $index] [lindex $FyDr $index] [lindex $FzDr $index]"
		incr index
#                 set morisonSurf::progressbar $num
#                 set morisonSurf::progressbarT "Out-> F.Drag"
	    }
#             set num 0
	    puts $res_file "End Values" 
	    
#             puts $res_file "Result \"M_Drag\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
#             puts $res_file "ComponentNames \"MxD\" \"MyD\" \"MzD\" \"|MD|\""
#             puts $res_file "Values"  
#             set index 0 
#             foreach i $data {
#                 foreach "- num - " $i break 
#                 #         puts $res_file "$num [lindex $MxDr [expr $num-1]] [lindex $MyDr [expr $num-1]] [lindex $MzDr [expr $num-1]]"
#                 puts $res_file "$num [lindex $MxDr $index] [lindex $MyDr $index] [lindex $MzDr $index]"
#                 incr index
#                 set morisonSurf::progressbar $num
#                 set morisonSurf::progressbarT "Out-> M.Drag"
#             }
#             puts $res_file "End Values" 
#             set num 0
	
#         set num 0
	
	puts $res_file "Result \"F_Current\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
	puts $res_file "ComponentNames \"FxCurr\" \"FyCurr\" \"-\" \"|FCURR|\""
	puts $res_file "Values"   
	set index 0
	foreach i $data {
	    foreach "- num - " $i break 
	    #         puts $res_file "$num [lindex $FxMor [expr $num-1]] [lindex $FyMor [expr $num-1]] [lindex $FzMor [expr $num-1]]"
	    puts $res_file "$num [lindex $FxCurrent $index] [lindex $FyCurrent $index] 0.0"
	    incr index
#             set morisonSurf::progressbar $num
#             set morisonSurf::progressbarT "Out-> F.Curr"
	}
#         set num 0
	puts $res_file "End Values" 
	
	puts $res_file "Result \"F_Wind\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
	puts $res_file "ComponentNames \"FxWind\" \"FyWind\" \"-\" \"|FWIND|\""
	puts $res_file "Values"   
	set index 0
	foreach i $data {
	    foreach "- num - " $i break 
	    #         puts $res_file "$num [lindex $FxMor [expr $num-1]] [lindex $FyMor [expr $num-1]] [lindex $FzMor [expr $num-1]]"
	    puts $res_file "$num [lindex $FxWind $index] [lindex $FyWind $index] 0.0"
	    incr index
#             set morisonSurf::progressbar $num
#             set morisonSurf::progressbarT "Out-> F.Wind"
	}
	puts $res_file "End Values" 
#         set num 0 
	
#         puts $res_file "Result \"M_Wind\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
#         puts $res_file "ComponentNames \"MxWind\" \"MyWind\" \"MzWind\" \"|MWIND|\""
#         puts $res_file "Values"   
#         set index 0
#         foreach i $data {
#             foreach "- num - " $i break 
#             #         puts $res_file "$num [lindex $FxMor [expr $num-1]] [lindex $FyMor [expr $num-1]] [lindex $FzMor [expr $num-1]]"
#             puts $res_file "$num [lindex $MxWind $index] [lindex $MyWind $index] [lindex $MzWind $index]"
#             incr index
#             set morisonSurf::progressbar $num
#             set morisonSurf::progressbarT "Out-> M.Wind"
#         }
#         puts $res_file "End Values" 
#         set num 0 
#         
#         puts $res_file "Result \"M_Curr\" \"App_Forces\" 1 Vector OnGaussPoints \"G_P\""
#         puts $res_file "ComponentNames \"MxCurr\" \"MyCurr\" \"MzCurr\" \"|MCURR|\""
#         puts $res_file "Values"   
#         set index 0
#         foreach i $data {
#             foreach "- num - " $i break 
#             #         puts $res_file "$num [lindex $FxMor [expr $num-1]] [lindex $FyMor [expr $num-1]] [lindex $FzMor [expr $num-1]]"
#             puts $res_file "$num [lindex $MxCurrent $index] [lindex $MyCurrent $index] [lindex $MzCurrent $index]"
#             incr index
#             set morisonSurf::progressbar $num
#             set morisonSurf::progressbarT "Out-> M.Curr"
#         }
#         puts $res_file "End Values" 
#         set num 0
	
	close $res_file
	#############################        
	
    }

    return $tcl_code

}

proc morisonSurf::WriteInBasFile { interval_num } {
    variable bas_custom_morisonforce
    
    if { $interval_num != 1 } { return }
    set data [.central.s info conditions -interval 2 Morison_LoadsSurfs mesh]
    if { ![llength $data] } { return "" }
	
    set _ ""
    append _ "static_load\ncustom_data_elems\n"

# obtenci�n del n� de intervalos/casos de carga
#     set intvNum [lindex [GiD_Info intvdata num] 1]
#     for {set intv 2} {$intv <= $intvNum} {incr intv} {
#         set intvName [lindex [GiD_Info intvdata -interval $intv] 2]
#         set data [GiD_Info conditions -interval $intv Morison_Loads mesh]
#     }

    if { ![llength $data] } { return "" }
    foreach i $data {
	foreach "- num - localaxes units WaveH IniPer Dn Draught Displac GMt GMl \
	    CGx CGy CGz RGx RGy RGz CurD WinD vWind TubD TubL StrMovDx StrMovDy StrMovDz \
	    StrMovTx StrMovTy StrMovTz" $i break
	set key [list $localaxes $units $WaveH $IniPer $Dn $Draught $Displac $GMt $GMl \
		$CGx $CGy $CGz $RGx $RGy $RGz $CurD $WinD $vWind $TubD $TubL]
	#         append _ "$num [lindex $bas_custom_morisonforce($key) 0] name=$intvName\n"
	append _ "$num [lindex $bas_custom_morisonforce($key) 0]\n"
    }
    append _ "end custom_data_elems\nend static_load\n"
    return $_
    
   
}


proc morisonSurf::ComunicateWithGiD { op args } {
    global ProblemTypePriv
    
    
    switch $op {
	"INIT" {
	    set PARENT [lindex $args 0]
	    
	    upvar [lindex $args 1] ROW
	    set GDN [lindex $args 2]
	    set STRUCT [lindex $args 3]
	    
	    set f [frame $PARENT.f]
	    set morisonSurf::path $ProblemTypePriv(problemtypedir)
	    
	    morisonSurf::Init $f $args
	    
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
	    set tL [DWLocalGetValue $GDN $STRUCT TubL]
	    set StMdX [DWLocalGetValue $GDN $STRUCT StrMovDx]
	    set StMdY [DWLocalGetValue $GDN $STRUCT StrMovDy]
	    set StMdZ [DWLocalGetValue $GDN $STRUCT StrMovDz]
	    set StMtX [DWLocalGetValue $GDN $STRUCT StrMovTx]
	    set StMtY [DWLocalGetValue $GDN $STRUCT StrMovTy]
	    set StMtZ [DWLocalGetValue $GDN $STRUCT StrMovTz]
#             set WrF [DWLocalGetValue $GDN $STRUCT WriteFlag]

#             if { $WrF ne "" } {
#                 set morisonSurf::ckwriteflag $WrF
#             }
	    if { $StMdX ne "" } {
		set morisonSurf::dX $StMdX
	    }
	    if { $StMdY ne "" } {
		set morisonSurf::dY $StMdY
	    }
	    if { $StMdZ ne "" } {
		set morisonSurf::dZ $StMdZ
	    }
	    if { $StMtX ne "" } {
		set morisonSurf::tX $StMtX
	    }
	    if { $StMtY ne "" } {
		set morisonSurf::tY $StMtY
	    }
	    if { $StMtZ ne "" } {
		set morisonSurf::tZ $StMtZ
	    }
	    if { $tD ne "" } {
		set morisonSurf::tubDiam $tD
	    }
	    if { $tL ne "" } {
		set morisonSurf::tubLength $tL
	    }
	    if { $vW ne "" } {
		set morisonSurf::velWind $vW
	    }
	    if { $cuD ne "" } {
		set morisonSurf::currDir $cuD
	    }
	    if { $wiD ne "" } {
		set morisonSurf::windDir $wiD
	    }
	    if { $wh ne "" } {
		set morisonSurf::waveHeight $wh
	    }
	    if { $inT ne "" } {
		set morisonSurf::InitPeriod $inT
	    }
	    if { $dn ne "" } {
		set morisonSurf::DirNum $dn
	    }            
	    if { $drt ne "" } {
		set morisonSurf::draught $drt
	    }
	    if { $dst ne "" } {
		set morisonSurf::DsT $dst
	    }
	    if { $gmt ne "" } {
		set morisonSurf::GMT $gmt
	    }
	    if { $gml ne "" } {
		set morisonSurf::GML $gml
	    }
	    if { $cgx ne "" } {
		set morisonSurf::CofGx $cgx
	    }
	    if { $cgy ne "" } {
		set morisonSurf::CofGy $cgy
	    }
	    if { $cgz ne "" } {
		set morisonSurf::CofGz $cgz
	    }
	    if { $rgx ne "" } {
		set morisonSurf::RofGx $rgx
	    }
	    if { $rgy ne "" } {
		set morisonSurf::RofGy $rgy
	    }
	    if { $rgz ne "" } {
		set morisonSurf::RofGz $rgz
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
		rgx rgy rgz cuD wiD vW tD tL StMdX StMdY StMdZ \
		StMtX StMtY StMtZ" [GiveSelectedValues] break
	       
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
	    DWLocalSetValue $GDN $STRUCT TubL $tL
	    DWLocalSetValue $GDN $STRUCT StrMovDx $StMdX
	    DWLocalSetValue $GDN $STRUCT StrMovDy $StMdY
	    DWLocalSetValue $GDN $STRUCT StrMovDz $StMdZ
	    DWLocalSetValue $GDN $STRUCT StrMovTx $StMtX
	    DWLocalSetValue $GDN $STRUCT StrMovTy $StMtY
	    DWLocalSetValue $GDN $STRUCT StrMovTz $StMtZ
#             DWLocalSetValue $GDN $STRUCT WriteFlag $WrF
		 
	    return ""
	}

    }
}

proc morisonSurf::ClosingWarn {} {
    variable flagCalc

    if {$flagCalc == 0} {
	WarnWin [= "Please, press Calculate before closing the window"]
    } else {
	return ""
    }
 }
	    
proc morisonSurf::GiveSelectedValues {} {
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
    variable dX
    variable dY
    variable dZ
    variable tX
    variable tY
    variable tZ
#     variable ckwriteflag
    variable tubLength


    ErrCntrl

    return [list $waveHeight $InitPeriod $DirNum $draught $DsT $GMT $GML \
	    $CofGx $CofGy $CofGz $RofGx $RofGy $RofGz $currDir $windDir $velWind $tubDiam $tubLength \
	    $dX $dY $dZ $tX $tY $tZ]

}  

proc morisonSurf::ErrCntrl {} {
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
    variable tubLength
    variable dX
    variable dY
    variable dZ
    variable tX
    variable tY
    variable tZ


    set refcontrol [GiD_AccessValue get gendata Mesh_units#CB#(m,cm,mm)]

    return
}

proc morisonSurf::ChangeIntervals {intv} {

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
