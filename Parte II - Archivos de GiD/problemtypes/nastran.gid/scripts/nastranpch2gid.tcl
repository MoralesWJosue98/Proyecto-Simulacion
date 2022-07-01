
namespace eval PCH2GiD {
    variable fout
    variable QUAD4init
    variable TRIA3init
    variable BARinit
    variable ELBOWinit
    variable TUBEinit
    variable smoothing
    variable results
    variable results1
    variable results2
    variable results3
    variable text
    
}

#
# data_type can be:
#
#     scalar
#     vector
#     matrix
#     plaindeformationmatrix
#     mainmatrix
#     localaxes
#
# data_loc can be:
#
#     OnNodes
#     OnGaussPoints

proc PCH2GiD::GiDResultsHeader { name loadcase step data_type data_loc { components "" } \
    { gaussname "" } {units "" } } {
    
    set ret ""
    if { $units != "" } {
        set fname "$name ($units)"
    } else {
        set fname $name
    }
    append ret "Result \"$fname\" \"$loadcase\" $step $data_type "
    switch $data_loc {
        OnNodes { append ret "OnNodes\n" }
        OnGaussPoints { append ret "OnGaussPoints \"$gaussname\"\n" }
    }
    if { $components != "" } {
        append ret "ComponentNames "
        set needscomma 0
        foreach c [split $components \n] {
            if { $needscomma } { append ret "," }
            append ret "\"$c\""
            set needscomma 1
        }
        if { $data_type == "vector" } {
            append ret ",\"|$name|\""
        }
        append ret "\n"
    }
    append ret "Values\n"
    
    return $ret
}

proc PCH2GiD::EndGiDResultsHeader {} {
    
    return "End Values\n"
}

proc PCH2GiD::Translate { filein fileout smooth } {
    variable fin
    variable fout
    variable text
    variable NumLines
    variable currentstep 1
    variable currentresultstype ""
    variable currentid ""
    variable currentelementtype ""
    variable QUAD4init 0
    variable TRIA3init 0
    variable BARinit 0
    variable ELBOWinit 0
    variable TUBEinit 0
    variable percentage
    variable currentoutputtype ""
    variable factor
    variable smoothing 0
    
    set smoothing $smooth
    
    set factor [expr 3.14159265358979323846/180.]
    set fin [open $filein r]
    set fout [open $fileout w]
    
    puts $fout "GiD Post Results File 1.0b"
    
    set read 1
    set NumLine 0
    set size [file size $filein]
    set NumLines [expr 1+[file size $filein]/80]
    while { ![eof $fin] } {
        if { $read } {
            gets $fin aa
            incr NumLine
            set percentage [expr int($NumLine*100/$NumLines)]
            update
        }
        set read 1
        set aa [string range $aa 0 71]
        if { [string trim $aa] == "" } { continue }
        if { [string index $aa 0] == {$} } {
            if { [regexp {^[$]\s} $aa] } { continue }
            if { ![regexp {[$]([^=]+)\s*=\s*(.*)} $aa {} key value ] } {
                set key [string range $aa 1 end]
            }
            set key [string trim $key]
            switch $key {
                TITLE - SUBTITLE - LABEL {}
                "REAL OUTPUT" { set currentoutputtype "REAL OUTPUT" }
                "REAL-IMAGINARY OUTPUT" { set currentoutputtype "REAL-IMAGINARY OUTPUT" }
                "MAGNITUDE-PHASE OUTPUT" { set currentoutputtype "MAGNITUDE-PHASE OUTPUT" }
                "ELEMENT STRESSES" { set currentresultstype elmstress }
                "ELEMENT FORCES" { set currentresultstype elmforces }
                "SUBCASE ID" { set currentid [string trim $value] }
                "ELEMENT TYPE" { set currentelementtype [lindex $value 0] }
                "DISPLACEMENTS" { set currentresultstype displacements }
                "VELOCITY" { set currentresultstype velocity }
                "OLOADS" { set currentresultstype oloads }
                "SPCF" { set currentresultstype spcf }
                "FREQUENCY" { set currentstep [string trim $value]  }
                "EIGENVECTOR" { set currentresultstype displacements }
                "EIGENVALUE" { set currentstep [lindex $value 0] }
                default {
                    $text ins end "unknown command '$key' $value NumLine=$NumLine\n"
                    $text see end
                    update
                }
            }
        } else {
            if { $currentresultstype == "" } {
                $text ins end "unknown line '$aa' NumLine=$NumLine  \"$currentresultstype\" \n"
                $text see end
                update
                set read 1 
            }
            if { $currentelementtype == "" } {
                if { [info command ::PCH2GiD::Read_$currentresultstype] == "" } {
                    $text ins end "Result $currentresultstype is NOT SUPPORTED\n"
                    $text see end
                    update
                    foreach "NumLine aa" [eval PCH2GiD::Read_unknown $NumLine [list $aa]] break 
                    set read 1
                } else {
                    foreach "NumLine aa" [eval PCH2GiD::Read_$currentresultstype $NumLine [list $aa]] break
                    $text ins end "Reading result $currentresultstype-------- step = $currentstep  \n"
                    $text see end
                    update 
                    set read 0
                }
            } elseif { $currentresultstype == "elmstress" } {
                if { [info command ::PCH2GiD::Read_${currentresultstype}_$currentelementtype] == "" } {
                    $text ins end "Element $currentelementtype is NOT SUPPORTED\n"
                    $text see end
                    update
                    foreach "NumLine aa" [eval PCH2GiD::Read_unknown $NumLine [list $aa]] break 
                    set read 0
                } else {
                    if { $smoothing == 0 } {
                        foreach "NumLine aa" [eval PCH2GiD::Read_${currentresultstype}_$currentelementtype \
                                $NumLine [list $aa]] break
                        $text ins end "Reading result $currentresultstype $currentelementtype-------- step = $currentstep  \n"
                        $text see end
                        update 
                        set read 0
                    } else {
                        foreach "NumLine aa" [eval PCH2GiD::Readsmooth_${currentresultstype}_$currentelementtype \
                                $NumLine [list $aa]] break
                        $text ins end "Reading result $currentresultstype $currentelementtype-------- step = $currentstep  \n"
                        $text see end
                        update 
                        set read 0
                    }
                }
            } elseif { $currentresultstype == "elmforces" } {
                if { [info command ::PCH2GiD::Read_${currentresultstype}_$currentelementtype] == "" } {
                    $text ins end "Element $currentelementtype is NOT SUPPORTED\n"
                    $text see end
                    update
                    foreach "NumLine aa" [eval PCH2GiD::Read_unknown $NumLine [list $aa]] break 
                    set read 0
                } else {
                    if { $smoothing == 0 } {
                        foreach "NumLine aa" [eval PCH2GiD::Read_${currentresultstype}_$currentelementtype \
                                $NumLine [list $aa]] break
                        $text ins end "Reading result $currentresultstype $currentelementtype-------- step = $currentstep  \n"
                        $text see end
                        update 
                        set read 0
                    } else {
                        foreach "NumLine aa" [eval PCH2GiD::Readsmooth_${currentresultstype}_$currentelementtype \
                                $NumLine [list $aa]] break
                        $text ins end "Reading result $currentresultstype $currentelementtype-------- step = $currentstep  \n"
                        $text see end
                        update 
                        set read 0
                    }
                    
                }
            }
            #set read 0
            #set currentresultstype ""
        }
    }
    set percentage 100
    update
    $text ins end "Read $NumLine lines"
    close $fin
    close $fout
}

proc PCH2GiD::Read_displacements { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable currentstep
    variable currentoutputtype
    variable  factor
    
    puts -nonewline $fout [PCH2GiD::GiDResultsHeader Displacements $currentid $currentstep vector \
            OnNodes "X\nY\nZ"]
    if { $currentoutputtype ==  "REAL OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %s %f %f %f" num {} x y z] != 5 } { break }
            puts $fout [format "%i %g %g %g" $num $x $y $z]
            gets $fin line
            incr NumLine
            #scan $line "%s %f %f %f" {} rx ry rz
            gets $fin line
            incr NumLine
        }
    }
    if { $currentoutputtype == "MAGNITUDE-PHASE OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %s %f %f %f" num {} x y z] != 5 } { break }
            gets $fin line
            incr NumLine
            #scan $line "%s %f %f %f" {} rx ry rz
            gets $fin line
            incr NumLine
            scan $line "%s %f %f %f" {} ox oy oz 
            set x [expr $x*cos($ox*$factor)]
            set y [expr $y*cos($oy*$factor)]
            set z [expr $z*cos($oz*$factor)]
            puts $fout [format "%i %g %g %g" $num $x $y $z]
            gets $fin line
            incr NumLine
            #scan $line "%s %f %f %f" {} orx ory orz
            gets $fin line
            incr NumLine
        }
    }
    if { $currentoutputtype == "REAL-IMAGINARY OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %s %f %f %f" num {} realx realy realz] != 5 } { break }
            puts $fout [format "%i %g %g %g" $num $realx $realy $realz]
            gets $fin line
            incr NumLine
            #scan $line "%s %f %f %f" {} rx ry rz
            gets $fin line
            incr NumLine
            #scan $line "%s %f %f %f" {} imgx imgy imgz
            gets $fin line
            incr NumLine
            #scan $line "%s %f %f %f" {} imgrx imgry imgrz  
            gets $fin line
            incr NumLine 
        }
    }
    puts -nonewline $fout [PCH2GiD::EndGiDResultsHeader]
    return [list $NumLine $line]
}

proc PCH2GiD::Read_velocity { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable currentstep
    variable currentoutputtype
    variable  factor
    
    puts -nonewline $fout [PCH2GiD::GiDResultsHeader velocity $currentid $currentstep vector \
            OnNodes "X\nY\nZ"]
    if { $currentoutputtype ==  "REAL OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %s %f %f %f" num {} x y z] != 5 } { break }
            puts $fout [format "%i %g %g %g" $num $x $y $z]
            gets $fin line
            incr NumLine
            #scan $line "%s %f %f %f" {} rx ry rz
            gets $fin line
            incr NumLine
        }
    }
    if { $currentoutputtype == "MAGNITUDE-PHASE OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %s %f %f %f" num {} x y z] != 5 } { break }
            gets $fin line
            incr NumLine
            #scan $line "%s %f %f %f" {} rx ry rz
            gets $fin line
            incr NumLine
            scan $line "%s %f %f %f" {} ox oy oz 
            set x [expr $x*cos($ox*$factor)]
            set y [expr $y*cos($oy*$factor)]
            set z [expr $z*cos($oz*$factor)]
            puts $fout [format "%i %g %g %g" $num $x $y $z]
            gets $fin line
            incr NumLine
            #scan $line "%s %f %f %f" {} orx ory orz
            gets $fin line
            incr NumLine
        }
    }
    if { $currentoutputtype == "REAL-IMAGINARY OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %s %f %f %f" num {} realx realy realz] != 5 } { break }
            puts $fout [format "%i %g %g %g" $num $realx $realy $realz]
            gets $fin line
            incr NumLine
            #scan $line "%s %f %f %f" {} rx ry rz
            gets $fin line
            incr NumLine
            #scan $line "%s %f %f %f" {} imgx imgy imgz
            gets $fin line
            incr NumLine
            #scan $line "%s %f %f %f" {} imgrx imgry imgrz  
            gets $fin line
            incr NumLine 
        }
    }
    puts -nonewline $fout [PCH2GiD::EndGiDResultsHeader]
    return [list $NumLine $line]
}

proc PCH2GiD::Read_oloads { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable currentstep
    variable  factor
    
    #PCH2GiD::GiDResultsHeader $fout Displacements $currentid $currentstep vector OnNodes "X\nY\nZ"
    while { ![eof $fin] } {
        if { [scan $line "%i %s %g %g %g" num {} x y z] != 5 } { break }
        #puts $fout [format "%i %g %g %g" $num $x $y $z]
        gets $fin line
        incr NumLine
        #scan $line "%s %g %g %g" {} rx ry rz
        gets $fin line
        incr NumLine
    }
    #PCH2GiD::EndGiDResultsHeader $fout
    return [list $NumLine $line]
}

proc PCH2GiD::Read_spcf { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable currentstep
    variable currentoutputtype
    variable  factor
    set var ""
    puts -nonewline $fout [PCH2GiD::GiDResultsHeader Reactions $currentid $currentstep vector OnNodes "X\nY\nZ"]
    append var [PCH2GiD::GiDResultsHeader "M reactions" $currentid $currentstep vector OnNodes "X\nY\nZ"]
    if { $currentoutputtype ==  "REAL OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %s %g %g %g" num {} x y z] != 5 } { break }
            puts $fout [format "%i %g %g %g" $num $x $y $z]
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} rx ry rz
            append var [format "%i %g %g %g\n" $num $rx $ry $rz]
            gets $fin line
            incr NumLine
        }
    }
    if { $currentoutputtype == "MAGNITUDE-PHASE OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %s %g %g %g" num {} x y z] != 5 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} rx ry rz
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} ox oy oz
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} orx ory orz
            set x [expr $x*cos($ox*$factor)]
            set y [expr $y*cos($oy*$factor)]
            set z [expr $z*cos($oz*$factor)]
            set rx [expr $rx*cos($orx*$factor)]
            set ry [expr $ry*cos($ory*$factor)]
            set rz [expr $rz*cos($orz*$factor)]
            puts $fout [format "%i %g %g %g" $num $x $y $z]
            append var [format "%i %g %g %g\n" $num $rx $ry $rz]
            gets $fin line
            incr NumLine
        }
    } 
    if { $currentoutputtype == "REAL-IMAGINARY OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %s %g %g %g" num {} realx realy realz] != 5 } { break }
            puts $fout [format "%i %g %g %g" $num $realx $realy $realz]
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} realrx realry realrz
            append var [format "%i %g %g %g\n" $num $realrx $realry $realrz]
            gets $fin line
            incr NumLine
            #scan $line "%s %g %g %g" {} imgx imgy imgz
            #puts $fout [format "%i %g %g %g" $num $imgx $imgy $imgz]
            gets $fin line
            incr NumLine
            #scan $line "%s %g %g %g" {} imgrx imgry imgrz
            #append var [format "%i %g %g %g\n" $num $imgrx $imgry $imgrz]
            gets $fin line
            incr NumLine
        }
    }
    
    puts -nonewline $fout [PCH2GiD::EndGiDResultsHeader]
    append var [PCH2GiD::EndGiDResultsHeader]
    puts -nonewline $fout $var
    return [list $NumLine $line]
}
# BAR elements

proc PCH2GiD::Readsmooth_elmstress_34 { NumLine line } {
    PCH2GiD::Read_elmstress_34 $NumLine $line
}

proc PCH2GiD::Read_elmstress_34 { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable BARinit
    variable currentstep
    if { ![info exists BARinit] || !$BARinit} {
        puts $fout "GaussPoints \"Bar1\" ElemType Linear"
        puts $fout "Number of Gauss Points: 2"
        puts $fout "Natural Coordinates: Internal"
        puts $fout "Nodes included"
        puts $fout "End gausspoints"
        set BARinit 1
    }
    
    set ic 1
    foreach i [list S1 S2 S3 S4 "Axial stress" Smax Smin] {
        set var($ic) [PCH2GiD::GiDResultsHeader $i $currentid $currentstep scalar \
                OnGaussPoints $i Bar1]
        incr ic
    }
    
    while { ![eof $fin] } {
        if { [scan $line "%i %g %g %g" num N(1) N(2) N(3)] != 4 } { break }
        gets $fin line
        incr NumLine
        scan $line "%s %g %g %g" {} N(4) N(5) N(6)
        gets $fin line
        incr NumLine
        scan $line "%s %g %g" {} N(7) N(8)
        gets $fin line
        incr NumLine
        scan $line "%s %g %g %g" {} N(9) N(10) N(11)
        gets $fin line
        incr NumLine
        scan $line "%s %g %g" {} N(13) N(14)
        gets $fin line
        incr NumLine
        set N(12) $N(5)
        
        for { set i 1 } { $i <= 7 } { incr i } {
            append var($i) [format "%i %g\n %g\n" $num $N($i) $N([expr $i+7])]
        }
        
    }
    for { set i 1 } { $i <= 7 } { incr i } {
        append var($i) [PCH2GiD::EndGiDResultsHeader]
        puts -nonewline $fout $var($i)
    }
    return [list $NumLine $line]
}

proc PCH2GiD::Readsmooth_elmforces_34 { NumLine line } {
    PCH2GiD::Read_elmforces_34 $NumLine $line
}

proc PCH2GiD::Read_elmforces_34 { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable BARinit
    variable currentstep
    if { ![info exists BARinit] || !$BARinit} {
        puts $fout "GaussPoints \"Bar1\" ElemType Linear"
        puts $fout "Number of Gauss Points: 2"
        puts $fout "Natural Coordinates: Internal"
        puts $fout "Nodes included"
        puts $fout "End gausspoints"
        set BARinit 1
    }
    
    set ic 1
    foreach i [list "Mz'" "My'" "Axial force" Torque "Shear y'" "Shear z'" ] {
        set var($ic) [PCH2GiD::GiDResultsHeader $i $currentid $currentstep scalar \
                OnGaussPoints $i Bar1]
        incr ic
    }
    set ic [expr $ic-1]
    while { ![eof $fin] } {
        if { [scan $line "%i %g %g %g" num N(1) N(2) N(3)] != 4 } { break }
        gets $fin line
        incr NumLine
        scan $line "%s %g %g %g" {} N(4) N(5) N(6)
        gets $fin line
        incr NumLine
        scan $line "%s %g %g" {} N(7) N(8)
        gets $fin line
        incr NumLine
        append var(1) [format "%i %g\n %g\n" $num $N(1) $N(3)]
        append var(2) [format "%i %g\n %g\n" $num $N(2) $N(4)]
        append var(3) [format "%i %g\n %g\n" $num $N(7) $N(7)]
        append var(4) [format "%i %g\n %g\n" $num $N(8) $N(8)]
        append var(5) [format "%i %g\n %g\n" $num $N(5) $N(5)]
        append var(6) [format "%i %g\n %g\n" $num $N(6) $N(6)]
    }
    for { set i 1 } { $i <= $ic } { incr i } {
        append var($i) [PCH2GiD::EndGiDResultsHeader]
        puts -nonewline $fout $var($i)
    }
    return [list $NumLine $line]
}

# TUBE  elements
proc PCH2GiD::Readsmooth_elmforces_3 { NumLine line } {
    PCH2GiD::Read_elmforces_3 $NumLine $line
}

proc PCH2GiD::Read_elmforces_3 { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable TUBEinit
    variable currentstep
    if { ![info exists TUBEinit] || !$TUBEinit} {
        puts $fout "GaussPoints \"Tube1\" ElemType Linear"
        puts $fout "Number of Gauss Points: 1"
        puts $fout "Natural Coordinates: Internal"
        puts $fout "End gausspoints"
        set TUBEinit 1
    }
    
    set ic 1
    foreach i [list  "Axial force" Torque  ] {
        set var($ic) [PCH2GiD::GiDResultsHeader $i $currentid $currentstep scalar \
                OnGaussPoints $i Tube1]
        incr ic
    }
    set ic [expr $ic-1]
    while { ![eof $fin] } {
        if { [scan $line "%i %g %g " num N(1) N(2)] != 3 } { break }
        gets $fin line
        incr NumLine
        append var(1) [format "%i %g\n" $num $N(1)]
        append var(2) [format "%i %g\n" $num $N(2)]
    }
    for { set i 1 } { $i <= $ic } { incr i } {
        append var($i) [PCH2GiD::EndGiDResultsHeader]
        puts -nonewline $fout $var($i)
    }
    return [list $NumLine $line]
}

# ELBOW  elements
proc PCH2GiD::Readsmooth_elmstress_81 { NumLine line } {
    PCH2GiD::Read_elmstress_81 $NumLine $line
}

proc PCH2GiD::Read_elmstress_81 { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable ELBOWinit
    variable currentstep
    if { ![info exists ELBOWinit] || !$ELBOWinit} {
        puts $fout "GaussPoints \"Elbow\" ElemType Linear"
        puts $fout "Number of Gauss Points: 2"
        puts $fout "Natural Coordinates: Internal"
        puts $fout "Nodes included"
        puts $fout "End gausspoints"
        set ELBOWinit 1
    }
    
    set ic 1
    foreach i [list S1 S2 S3 S4 "Axial stress" Smax Smin] {
        set var($ic) [PCH2GiD::GiDResultsHeader $i $currentid $currentstep scalar \
                OnGaussPoints $i Elbow]
        incr ic
    }
    
    while { ![eof $fin] } {
        if { [scan $line "%i %g %g %g" num N(1) N(2) N(3)] != 4 } { break }
        gets $fin line
        incr NumLine
        scan $line "%s %g %g %g" {} N(4) N(5) N(6)
        gets $fin line
        incr NumLine
        scan $line "%s %g %g" {} N(7) N(8)
        gets $fin line
        incr NumLine
        scan $line "%s %g %g %g" {} N(9) N(10) N(11)
        gets $fin line
        incr NumLine
        scan $line "%s %g %g" {} N(13) N(14)
        gets $fin line
        incr NumLine
        set N(12) $N(5)
        
        for { set i 1 } { $i <= 7 } { incr i } {
            append var($i) [format "%i %g\n %g\n" $num $N($i) $N([expr $i+7])]
        }
        
    }
    for { set i 1 } { $i <= 7 } { incr i } {
        append var($i) [PCH2GiD::EndGiDResultsHeader]
        puts -nonewline $fout $var($i)
    }
    return [list $NumLine $line]
}

# TRIA3 elements
proc PCH2GiD::Read_elmstress_83 { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable TRIA3init
    variable currentstep
    variable currentoutputtype
    
    set var1 ""
    set var2 ""
    set var3 "" 
    
    if { $currentoutputtype == "REAL OUTPUT" } {
        if { ![ info exists TRIA3init ] || !$TRIA3init } {
            puts $fout "GaussPoints \"Tria1\" ElemType Triangle"
            puts $fout "Number of Gauss Points: 1"
            puts $fout "Natural Coordinates: Internal"
            puts $fout "End gausspoints"
            set TRIA3init 1
        }
        
        puts -nonewline $fout [ PCH2GiD::GiDResultsHeader "Shell stresses Down" $currentid $currentstep matrix \
                OnGaussPoints "Sx\nSy\nSxy" Tria1 ]
        append var1 [ PCH2GiD::GiDResultsHeader "Shell stresses Up" $currentid $currentstep matrix \
                OnGaussPoints "Sx\nSy\nSxy" Tria1 ]
        append var2 [ PCH2GiD::GiDResultsHeader "Von Mises Up Fiber" $currentid $currentstep scalar OnGaussPoints \
                "Von Mises Up" Tria1 ]
        append var3 [ PCH2GiD::GiDResultsHeader "Von Mises Down Fiber" $currentid $currentstep scalar OnGaussPoints \
                "Von Mises Down" Tria1 ]
        while { ![eof $fin] } {
            if { [ scan $line "%i %g %g %g" num FD1 Nx1 Ny1] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nxy1 A Ma
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mi VMD FD2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nx2 Ny2 Nxy2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} A Ma Mi
            gets $fin line
            incr NumLine
            scan $line "%s %g" {} VMU 
            
            puts $fout [ format "%i %g %g %g" $num $Nx1 $Ny1 $Nxy1 ]
            append var1 [ format "%i %g %g %g\n" $num $Nx2 $Ny2 $Nxy2 ]
            append var2 [ format "%i %g\n" $num $VMU ]
            append var3 [ format "%i %g\n" $num $VMD ]
            gets $fin line
            incr NumLine
        }
        puts -nonewline $fout [PCH2GiD::EndGiDResultsHeader]
        append var1 [PCH2GiD::EndGiDResultsHeader]
        append var2 [PCH2GiD::EndGiDResultsHeader]
        append var3 [PCH2GiD::EndGiDResultsHeader]
        puts -nonewline $fout $var1
        puts -nonewline $fout $var2
        puts -nonewline $fout $var3
        return [list $NumLine $line]
    }
    if { $currentoutputtype == "MAGNITUDE-PHASE OUTPUT" } {
        if { ![info exists TRIA34init] || !$TRIA3init} {
            puts $fout "GaussPoints \"Tria1\" ElemType Triangle "
            puts $fout "Number of Gauss Points: 1"
            puts $fout "Natural Coordinates: Internal"
            puts $fout "End gausspoints"
            set TRIA3init 1
        }
        set var1 ""
        puts -nonewline $fout [PCH2GiD::GiDResultsHeader "Shell stresses Down" $currentid $currentstep matrix \
                OnGaussPoints "Sx\nSy\nSxy" Tria1]
        append var1 [PCH2GiD::GiDResultsHeader "Shell stresses Up" $currentid $currentstep matrix \
                OnGaussPoints "Sx\nSy\nSxy" Tria1]
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num FD1 Nx1 Nox1] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Ny1 Noy1 Nxy1
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Noxy1 FD2 Nx2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nox2 Ny2 Noy2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g" {} Nxy2 Noxy2 
            set Nx1 [expr $Nx1*cos($Nox1*$factor)]
            set Ny1 [expr $Ny1*cos($Noy1*$factor)]
            set Nxy1 [expr $Nxy1*cos($Noxy1*$factor)]
            set Nx2 [expr $Nx2*cos($Nox2*$factor)]
            set Ny2 [expr $Ny2*cos($Noy2*$factor)]
            set Nxy2 [expr $Nxy2*cos($Noxy2*$factor)]
            puts $fout [format "%i %g %g %g" $num $Nx1 $Ny1 $Nxy1]
            append var1 [format "%i %g %g %g\n" $num $Nx2 $Ny2 $Nxy2]
            gets $fin line
            incr NumLine
        }
        puts -nonewline $fout [PCH2GiD::EndGiDResultsHeader]
        append var1 [PCH2GiD::EndGiDResultsHeader]
        puts -nonewline $fout $var1
        return [list $NumLine $line]
    }
    if { $currentoutputtype == "REAL-IMAGINARY OUTPUT" } {
        if { ![info exists TRIA3init] || !$TRIA3init} {
            puts $fout "GaussPoints \"Tria1\" ElemType Triangle "
            puts $fout "Number of Gauss Points: 1"
            puts $fout "Natural Coordinates: Internal"
            puts $fout "End gausspoints"
            set TRIA3init 1
        }
        set var1 ""
        puts -nonewline $fout [PCH2GiD::GiDResultsHeader "Shell stresses Down" $currentid $currentstep matrix \
                OnGaussPoints "Sx\nSy\nSxy" Tria1]
        append var1 [PCH2GiD::GiDResultsHeader "Shell stresses Up" $currentid $currentstep matrix \
                OnGaussPoints "Sx\nSy\nSxy" Tria1]
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num FD1 Nrx1 Nix1] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nry1 Niy1 Nrxy1
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nixy1 FD2 Nrx2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nix2 Nry2 Niy2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g" {} Nrxy2 Nixy2 
            puts $fout [format "%i %g %g %g" $num $Nrx1 $Nry1 $Nrxy1]
            append var1 [format "%i %g %g %g\n" $num $Nrx2 $Nry2 $Nrxy2]
            gets $fin line
            incr NumLine
        }
        puts -nonewline $fout [PCH2GiD::EndGiDResultsHeader]
        append var1 [PCH2GiD::EndGiDResultsHeader]
        puts -nonewline $fout $var1
        return [list $NumLine $line]
    }
    
}

proc PCH2GiD::Readsmooth_elmstress_83 { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable TRIA3init
    variable currentstep
    variable smoothing
    variable results
    variable results1
    variable results2
    variable results3
    variable currentoutputtype
    
    catch { unset results1 }
    catch { unset results2 }
    catch { unset results3 } 
    
    set results ""
    set results1 ""
    set results2 ""
    set results3 ""
    set var1 ""
    set var2 ""
    set var3 ""
    
    if { $currentoutputtype == "REAL OUTPUT" } {
        
        puts -nonewline $fout [PCH2GiD::GiDResultsHeader "Shell stresses Down" $currentid $currentstep matrix \
                OnNodes "Sx\nSy\nSxy"]
        append var1 [PCH2GiD::GiDResultsHeader "Shell stresses Up" $currentid $currentstep matrix \
                OnNodes "Sx\nSy\nSxy"]
        append var2 [PCH2GiD::GiDResultsHeader "Von Mises Up Fiber" $currentid $currentstep scalar OnNodes \
                "Von Mises Up"]
        append var3 [PCH2GiD::GiDResultsHeader "Von Mises Down Fiber" $currentid $currentstep scalar OnNodes \
                "Von Mises Down"]
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num FD1 Nx1 Ny1] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nxy1 A Ma
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mi VMD FD2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nx2 Ny2 Nxy2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} A Ma Mi
            gets $fin line
            incr NumLine
            scan $line "%s %g" {} VMU
            lappend results $Nx1 
            lappend results $Ny1 
            lappend results $Nxy1 
            lappend results1 $Nx2
            lappend results1 $Ny2 
            lappend results1 $Nxy2
            lappend results2 $VMD
            lappend results3 $VMU
            gets $fin line
            incr NumLine
        }
        PCH2GiD::Smooth 3 PCH2GiD::results Triangle
        puts -nonewline $fout $var1
        PCH2GiD::Smooth 3 PCH2GiD::results1 Triangle
        puts -nonewline $fout $var2
        PCH2GiD::Smooth 1 PCH2GiD::results2 Triangle
        puts -nonewline $fout $var3
        PCH2GiD::Smooth 1 PCH2GiD::results3 Triangle
        
        return [list $NumLine $line]
    }
    
    if { $currentoutputtype == "MAGNITUDE-PHASE OUTPUT" } {
        puts -nonewline $fout [PCH2GiD::GiDResultsHeader "Shell stresses Down" $currentid $currentstep matrix \
                OnNodes "Sx\nSy\nSxy"]
        append var1 [PCH2GiD::GiDResultsHeader "Shell stresses Up" $currentid $currentstep matrix \
                OnNodes "Sx\nSy\nSxy"]
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num FD1 Nx1 Nox1] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Ny1 Noy1 Nxy1
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Noxy1 FD2 Nx2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nox2 Ny2 Noy2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g" {} Nxy2 Noxy2 
            set Nx1 [expr $Nx1*cos($Nox1*$factor)]
            set Ny1 [expr $Ny1*cos($Noy1*$factor)]
            set Nxy1 [expr $Nxy1*cos($Noxy1*$factor)]
            set Nx2 [expr $Nx2*cos($Nox2*$factor)]
            set Ny2 [expr $Ny2*cos($Noy2*$factor)]
            set Nxy2 [expr $Nxy2*cos($Noxy2*$factor)]
            lappend results $Nx1 
            lappend results $Ny1 
            lappend results $Nxy1 
            lappend results1 $Nx2
            lappend results1 $Ny2 
            lappend results1 $Nxy2
            gets $fin line
            incr NumLine
        }
        PCH2GiD::Smooth 3 PCH2GiD::results Triangle
        puts -nonewline $fout $var1
        PCH2GiD::Smooth 3 PCH2GiD::results1 Triangle
        return [list $NumLine $line]
    }
    if { $currentoutputtype == "REAL-IMAGINARY OUTPUT" } {
        
        puts -nonewline $fout [PCH2GiD::GiDResultsHeader "Shell stresses Down" $currentid $currentstep matrix \
                OnNodes "Sx\nSy\nSxy"]
        append var1 [PCH2GiD::GiDResultsHeader "Shell stresses Up" $currentid $currentstep matrix \
                OnNodes "Sx\nSy\nSxy"]
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num FD1 Nrx1 Nix1] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nry1 Niy1 Nrxy1
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nixy1 FD2 Nrx2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nix2 Nry2 Niy2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g" {} Nrxy2 Nixy2 
            lappend results $Nrx1 
            lappend results $Nry1 
            lappend results $Nrxy1 
            lappend results1 $Nrx2
            lappend results1 $Nry2 
            lappend results1 $Nrxy2            
            gets $fin line
            incr NumLine
        }
        PCH2GiD::Smooth 3 PCH2GiD::results Triangle
        puts -nonewline $fout $var1
        PCH2GiD::Smooth 3 PCH2GiD::results1 Triangle
        return [list $NumLine $line]
    }
}

proc PCH2GiD::Read_elmforces_83 { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable TRIA3init
    variable currentstep
    variable currentoutputtype
    variable  factor
    
    set var1 ""
    set var2 ""
    
    if { ![info exists TRIA3init] || !$TRIA3init} {
        puts $fout "GaussPoints \"Tria1\" ElemType Triangle "
        puts $fout "Number of Gauss Points: 1"
        puts $fout "Natural Coordinates: Internal"
        puts $fout "End gausspoints"
        set TRIA3init 1
    }
    
    puts -nonewline $fout [PCH2GiD::GiDResultsHeader "Shell menbrane Forces" $currentid $currentstep matrix \
            OnGaussPoints "Fx\nFy\nFxy" Tria1]
    append var1 [PCH2GiD::GiDResultsHeader "Shell bending Moments" $currentid $currentstep matrix \
            OnGaussPoints "Mx\nMy\nMxy" Tria1]
    append var2 [PCH2GiD::GiDResultsHeader "Shell transverse Shear" $currentid $currentstep vector OnGaussPoints \
            "Vx\nVy\n" Tria1]
    
    if { $currentoutputtype == "REAL OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num Fx Fy Fxy] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mx My Mxy
            gets $fin line
            incr NumLine
            scan $line "%s %g %g" {} Vx Vy
            
            puts $fout [format "%i %g %g %g" $num $Fx $Fy $Fxy]
            append var1 [format "%i %g %g %g\n" $num $Mx $My $Mxy]
            append var2 [format "%i %g % g\n" $num $Vx $Vy]
            
            gets $fin line
            incr NumLine
        }
    }
    if { $currentoutputtype == "MAGNITUDE-PHASE OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num Fx Fy Fxy] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mx My Mxy
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Vx Vy Fox
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Foy Foxy Mox
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Moy Moxy Vox
            gets $fin line
            incr NumLine
            scan $line "%s %g" {} Voy
            set Fx [expr $Fx*cos($Fox*$factor)]
            set Fy [expr $Fy*cos($Foy*$factor)]
            set Fxy [expr $Fxy*cos($Foxy*$factor)]
            set Vx [expr $Vx*cos($Vox*$factor)]
            set Vy [expr $Vy*cos($Voy*$factor)]
            set Mx [expr $Mx*cos($Mox*$factor)]
            set My [expr $My*cos($Moy*$factor)]
            set Mxy [expr $Mxy*cos($Moxy*$factor)]
            puts $fout [format "%i %g %g %g" $num $Fx $Fy $Fxy]
            append var1 [format "%i %g %g %g\n" $num $Mx $My $Mxy]
            append var2 [format "%i %g % g\n" $num $Vx $Vy]
            
            gets $fin line
            incr NumLine
        }
    }
    if { $currentoutputtype == "REAL-IMAGINARY OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num Frx Fry Frxy] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mrx Mry Mrxy
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Vrx Vry Fix
            gets $fin line
            incr NumLine
            #scan $line "%s %g %g %g" {} Fiy Fixy Mix
            gets $fin line
            incr NumLine
            #scan $line "%s %g %g %g" {} Miy Mixy Vix
            gets $fin line
            incr NumLine
            #scan $line "%s %g" {} Viy
            puts $fout [format "%i %g %g %g" $num $Frx $Fry $Frxy]
            append var1 [format "%i %g %g %g\n" $num $Mrx $Mry $Mrxy]
            append var2 [format "%i %g % g\n" $num $Vrx $Vry]
            
            gets $fin line
            incr NumLine
        }
    }
    puts -nonewline $fout [PCH2GiD::EndGiDResultsHeader]
    append var1 [PCH2GiD::EndGiDResultsHeader]
    append var2 [PCH2GiD::EndGiDResultsHeader]
    puts -nonewline $fout $var1
    puts -nonewline $fout $var2
    return [list $NumLine $line]    
}

proc PCH2GiD::Readsmooth_elmforces_83 { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable TRIA3init
    variable currentstep
    variable smoothing
    variable results
    variable results1
    variable results2
    variable results3
    variable currentoutputtype
    
    catch { unset results1 }
    catch { unset results2 }
    catch { unset results3 } 
    
    set results ""
    set results1 ""
    set results2 ""
    set results3 ""
    set var1 ""
    set var2 ""
    set var3 ""
    puts -nonewline $fout [PCH2GiD::GiDResultsHeader "Shell menbrane Forces" $currentid $currentstep matrix \
            OnNodes "Fx\nFy\nFxy"]
    append var1 [PCH2GiD::GiDResultsHeader "Shell bending Moments" $currentid $currentstep matrix \
            OnNodes "Mx\nMy\nMxy"]
    append var2 [PCH2GiD::GiDResultsHeader "Shell transverse Shear" $currentid $currentstep vector OnNodes \
            "Vx\nVy\n"]
    if { $currentoutputtype == "REAL OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num Fx Fy Fxy] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mx My Mxy
            gets $fin line
            incr NumLine
            scan $line "%s %g %g" {} Vx Vy
            lappend results $Fx 
            lappend results $Fy 
            lappend results $Fxy 
            lappend results1 $Mx
            lappend results1 $My 
            lappend results1 $Mxy
            lappend results2 $Vx
            lappend results2 $Vy
            
            gets $fin line
            incr NumLine
        }
    }
    if { $currentoutputtype == "MAGNITUDE-PHASE OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num Fx Fy Fxy] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mx My Mxy
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Vx Vy Fox
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Foy Foxy Mox
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Moy Moxy Vox
            gets $fin line
            incr NumLine
            scan $line "%s %g" {} Voy
            set Fx [expr $Fx*cos($Fox*$factor)]
            set Fy [expr $Fy*cos($Foy*$factor)]
            set Fxy [expr $Fxy*cos($Foxy*$factor)]
            set Vx [expr $Vx*cos($Vox*$factor)]
            set Vy [expr $Vy*cos($Voy*$factor)]
            set Mx [expr $Mx*cos($Mox*$factor)]
            set My [expr $My*cos($Moy*$factor)]
            set Mxy [expr $Mxy*cos($Moxy*$factor)]
            lappend results $Fx 
            lappend results $Fy 
            lappend results $Fxy 
            lappend results1 $Mx
            lappend results1 $My 
            lappend results1 $Mxy
            lappend results2 $Vx
            lappend results2 $Vy
            
            gets $fin line
            incr NumLine
        }
    }
    if { $currentoutputtype == "REAL-IMAGINARY OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num Frx Fry Frxy] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mrx Mry Mrxy
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Vrx Vry Fix
            gets $fin line
            incr NumLine
            #scan $line "%s %g %g %g" {} Fiy Fixy Mix
            gets $fin line
            incr NumLine
            #scan $line "%s %g %g %g" {} Miy Mixy Vix
            gets $fin line
            incr NumLine
            #scan $line "%s %g" {} Viy
            lappend results $Frx 
            lappend results $Fry 
            lappend results $Frxy 
            lappend results1 $Mrx
            lappend results1 $Mry 
            lappend results1 $Mrxy
            lappend results2 $Vrx
            lappend results2 $Vry
            
            gets $fin line
            incr NumLine
        }
    }
    PCH2GiD::Smooth 3 PCH2GiD::results Triangle
    puts -nonewline $fout $var1
    PCH2GiD::Smooth 3 PCH2GiD::results1 Triangle
    puts -nonewline $fout $var2
    PCH2GiD::Smooth 2 PCH2GiD::results2 Triangle
    return [list $NumLine $line]
}


# QUAD4 elements
proc PCH2GiD::Read_elmstress_64 { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable QUAD4init
    variable currentstep
    variable currentoutputtype
    variable  factor
    set var1 ""
    set var2 ""
    set var3 ""
    if { $currentoutputtype == "REAL OUTPUT" } {
        if { ![info exists QUAD4init] || !$QUAD4init} {
            puts $fout "GaussPoints \"Quad1\" ElemType Quadrilateral "
            puts $fout "Number of Gauss Points: 1"
            puts $fout "Natural Coordinates: Internal"
            puts $fout "End gausspoints"
            set QUAD4init 1
        }
        
        puts -nonewline $fout [PCH2GiD::GiDResultsHeader "Shell stresses Down" $currentid $currentstep matrix \
                OnGaussPoints "Sx\nSy\nSxy" Quad1]
        append var1 [PCH2GiD::GiDResultsHeader "Shell stresses Up" $currentid $currentstep matrix \
                OnGaussPoints "Sx\nSy\nSxy" Quad1]
        append var2 [PCH2GiD::GiDResultsHeader "Von Mises Up Fiber" $currentid $currentstep scalar OnGaussPoints \
                "Von Mises Up" Quad1]
        append var3 [PCH2GiD::GiDResultsHeader "Von Mises Down Fiber" $currentid $currentstep scalar OnGaussPoints \
                "Von Mises Down" Quad1]
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num FD1 Nx1 Ny1] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nxy1 A Ma
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mi VMD FD2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nx2 Ny2 Nxy2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} A Ma Mi
            gets $fin line
            incr NumLine
            scan $line "%s %g" {} VMU
            
            puts $fout [format "%i %g %g %g" $num $Nx1 $Ny1 $Nxy1]
            append var1 [format "%i %g %g %g\n" $num $Nx2 $Ny2 $Nxy2]
            append var2 [format "%i %g\n" $num $VMU]
            append var3 [format "%i %g\n" $num $VMD]
            gets $fin line
            incr NumLine
        }
        puts -nonewline $fout [PCH2GiD::EndGiDResultsHeader]
        append var1 [PCH2GiD::EndGiDResultsHeader]
        append var2 [PCH2GiD::EndGiDResultsHeader]
        append var3 [PCH2GiD::EndGiDResultsHeader]
        puts -nonewline $fout $var1
        puts -nonewline $fout $var2
        puts -nonewline $fout $var3
        return [list $NumLine $line]
    }
    
    if { $currentoutputtype == "MAGNITUDE-PHASE OUTPUT" } {
        if { ![info exists QUAD4init] || !$QUAD4init} {
            puts $fout "GaussPoints \"Quad1\" ElemType Quadrilateral "
            puts $fout "Number of Gauss Points: 1"
            puts $fout "Natural Coordinates: Internal"
            puts $fout "End gausspoints"
            set QUAD4init 1
        }
        set var1 ""
        puts -nonewline $fout [PCH2GiD::GiDResultsHeader "Shell stresses Down" $currentid $currentstep matrix \
                OnGaussPoints "Sx\nSy\nSxy" Quad1]
        append var1 [PCH2GiD::GiDResultsHeader "Shell stresses Up" $currentid $currentstep matrix \
                OnGaussPoints "Sx\nSy\nSxy" Quad1]
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num FD1 Nx1 Nox1] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Ny1 Noy1 Nxy1
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Noxy1 FD2 Nx2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nox2 Ny2 Noy2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g" {} Nxy2 Noxy2 
            set Nx1 [expr $Nx1*cos($Nox1*$factor)]
            set Ny1 [expr $Ny1*cos($Noy1*$factor)]
            set Nxy1 [expr $Nxy1*cos($Noxy1*$factor)]
            set Nx2 [expr $Nx2*cos($Nox2*$factor)]
            set Ny2 [expr $Ny2*cos($Noy2*$factor)]
            set Nxy2 [expr $Nxy2*cos($Noxy2*$factor)]
            puts $fout [format "%i %g %g %g" $num $Nx1 $Ny1 $Nxy1]
            append var1 [format "%i %g %g %g\n" $num $Nx2 $Ny2 $Nxy2]
            gets $fin line
            incr NumLine
        }
        puts -nonewline $fout [PCH2GiD::EndGiDResultsHeader]
        append var1 [PCH2GiD::EndGiDResultsHeader]
        puts -nonewline $fout $var1
        return [list $NumLine $line]
    }
    if { $currentoutputtype == "REAL-IMAGINARY OUTPUT" } {
        if { ![info exists QUAD4init] || !$QUAD4init} {
            puts $fout "GaussPoints \"Quad1\" ElemType Quadrilateral "
            puts $fout "Number of Gauss Points: 1"
            puts $fout "Natural Coordinates: Internal"
            puts $fout "End gausspoints"
            set QUAD4init 1
        }
        set var1 ""
        puts -nonewline $fout [PCH2GiD::GiDResultsHeader "Shell stresses Down" $currentid $currentstep matrix \
                OnGaussPoints "Sx\nSy\nSxy" Quad1]
        append var1 [PCH2GiD::GiDResultsHeader "Shell stresses Up" $currentid $currentstep matrix \
                OnGaussPoints "Sx\nSy\nSxy" Quad1]
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num FD1 Nrx1 Nix1] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nry1 Niy1 Nrxy1
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nixy1 FD2 Nrx2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nix2 Nry2 Niy2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g" {} Nrxy2 Nixy2 
            puts $fout [format "%i %g %g %g" $num $Nrx1 $Nry1 $Nrxy1]
            append var1 [format "%i %g %g %g\n" $num $Nrx2 $Nry2 $Nrxy2]
            gets $fin line
            incr NumLine
        }
        puts -nonewline $fout [PCH2GiD::EndGiDResultsHeader]
        append var1 [PCH2GiD::EndGiDResultsHeader]
        puts -nonewline $fout $var1
        return [list $NumLine $line]
    }
}

proc PCH2GiD::Readsmooth_elmstress_64 { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable fout
    variable QUAD4init
    variable currentstep
    variable smoothing
    variable results
    variable results1
    variable results2
    variable results3
    variable currentoutputtype
    
    catch { unset results1 }
    catch { unset results2 }
    catch { unset results3 } 
    
    set results ""
    set results1 ""
    set results2 ""
    set results3 ""
    set var1 ""
    set var2 ""
    set var3 ""
    if { $currentoutputtype == "REAL OUTPUT" } {
        puts -nonewline $fout [PCH2GiD::GiDResultsHeader "Shell stresses Down" $currentid $currentstep matrix \
                OnNodes "Sx\nSy\nSxy"]
        append var1 [PCH2GiD::GiDResultsHeader "Shell stresses Up" $currentid $currentstep matrix \
                OnNodes "Sx\nSy\nSxy"]
        append var2 [PCH2GiD::GiDResultsHeader "Von Mises Up Fiber" $currentid $currentstep scalar OnNodes \
                "Von Mises Up"]
        append var3 [PCH2GiD::GiDResultsHeader "Von Mises Down Fiber" $currentid $currentstep scalar OnNodes \
                "Von Mises Down"]
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num FD1 Nx1 Ny1] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nxy1 A Ma
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mi VMD FD2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nx2 Ny2 Nxy2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} A Ma Mi
            gets $fin line
            incr NumLine
            scan $line "%s %g" {} VMU
            lappend results $Nx1 
            lappend results $Ny1 
            lappend results $Nxy1 
            lappend results1 $Nx2
            lappend results1 $Ny2 
            lappend results1 $Nxy2
            lappend results2 $VMD
            lappend results3 $VMU
            gets $fin line
            incr NumLine
        }
        PCH2GiD::Smooth 3 PCH2GiD::results Quadrilateral
        puts -nonewline $fout $var1
        PCH2GiD::Smooth 3 PCH2GiD::results1 Quadrilateral
        puts -nonewline $fout $var2
        PCH2GiD::Smooth 1 PCH2GiD::results2 Quadrilateral
        puts -nonewline $fout $var3
        PCH2GiD::Smooth 1 PCH2GiD::results3 Quadrilateral
        
        return [list $NumLine $line]
    }
    
    if { $currentoutputtype == "MAGNITUDE-PHASE OUTPUT" } {
        puts -nonewline $fout [PCH2GiD::GiDResultsHeader "Shell stresses Down" $currentid $currentstep matrix \
                OnNodes "Sx\nSy\nSxy"]
        append var1 [PCH2GiD::GiDResultsHeader "Shell stresses Up" $currentid $currentstep matrix \
                OnNodes "Sx\nSy\nSxy"]
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num FD1 Nx1 Nox1] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Ny1 Noy1 Nxy1
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Noxy1 FD2 Nx2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nox2 Ny2 Noy2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g" {} Nxy2 Noxy2 
            set Nx1 [expr $Nx1*cos($Nox1*$factor)]
            set Ny1 [expr $Ny1*cos($Noy1*$factor)]
            set Nxy1 [expr $Nxy1*cos($Noxy1*$factor)]
            set Nx2 [expr $Nx2*cos($Nox2*$factor)]
            set Ny2 [expr $Ny2*cos($Noy2*$factor)]
            set Nxy2 [expr $Nxy2*cos($Noxy2*$factor)]
            lappend results $Nx1 
            lappend results $Ny1 
            lappend results $Nxy1 
            lappend results1 $Nx2
            lappend results1 $Ny2 
            lappend results1 $Nxy2
            gets $fin line
            incr NumLine
        }
        PCH2GiD::Smooth 3 PCH2GiD::results Quadrilateral
        puts -nonewline $fout $var1
        PCH2GiD::Smooth 3 PCH2GiD::results1 Quadrilateral
        return [list $NumLine $line]
    }
    if { $currentoutputtype == "REAL-IMAGINARY OUTPUT" } {
        
        puts -nonewline $fout [PCH2GiD::GiDResultsHeader "Shell stresses Down" $currentid $currentstep matrix \
                OnNodes "Sx\nSy\nSxy"]
        append var1 [PCH2GiD::GiDResultsHeader "Shell stresses Up" $currentid $currentstep matrix \
                OnNodes "Sx\nSy\nSxy"]
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num FD1 Nrx1 Nix1] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nry1 Niy1 Nrxy1
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nixy1 FD2 Nrx2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Nix2 Nry2 Niy2
            gets $fin line
            incr NumLine
            scan $line "%s %g %g" {} Nrxy2 Nixy2 
            lappend results $Nrx1 
            lappend results $Nry1 
            lappend results $Nrxy1 
            lappend results1 $Nrx2
            lappend results1 $Nry2 
            lappend results1 $Nrxy2            
            gets $fin line
            incr NumLine
        }
        PCH2GiD::Smooth 3 PCH2GiD::results Quadrilateral
        puts -nonewline $fout $var1
        PCH2GiD::Smooth 3 PCH2GiD::results1 Quadrilateral
        return [list $NumLine $line]
    }
}

proc PCH2GiD::Read_elmforces_64 { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable QUAD4init
    variable currentstep
    variable currentoutputtype
    variable  factor
    
    set var1 ""
    set var2 ""
    
    if { ![info exists QUAD4init] || !$QUAD4init} {
        puts $fout "GaussPoints \"Quad1\" ElemType Quadrilateral "
        puts $fout "Number of Gauss Points: 1"
        puts $fout "Natural Coordinates: Internal"
        puts $fout "End gausspoints"
        set QUAD4init 1
    }
    
    
    puts -nonewline $fout [PCH2GiD::GiDResultsHeader "Shell menbrane Forces" $currentid $currentstep matrix \
            OnGaussPoints "Fx\nFy\nFxy" Quad1]
    append var1 [PCH2GiD::GiDResultsHeader "Shell bending Moments" $currentid $currentstep matrix \
            OnGaussPoints "Mx\nMy\nMxy" Quad1]
    append var2 [PCH2GiD::GiDResultsHeader "Shell transverse Shear" $currentid $currentstep vector OnGaussPoints \
            "Vx\nVy\n" Quad1]
    
    if { $currentoutputtype == "REAL OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num Fx Fy Fxy] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mx My Mxy
            gets $fin line
            incr NumLine
            scan $line "%s %g %g" {} Vx Vy
            
            puts $fout [format "%i %g %g %g" $num $Fx $Fy $Fxy]
            append var1 [format "%i %g %g %g\n" $num $Mx $My $Mxy]
            append var2 [format "%i %g % g\n" $num $Vx $Vy]
            
            gets $fin line
            incr NumLine
        }
    }
    if { $currentoutputtype == "MAGNITUDE-PHASE OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num Fx Fy Fxy] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mx My Mxy
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Vx Vy Fox
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Foy Foxy Mox
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Moy Moxy Vox
            gets $fin line
            incr NumLine
            scan $line "%s %g" {} Voy
            set Fx [expr $Fx*cos($Fox*$factor)]
            set Fy [expr $Fy*cos($Foy*$factor)]
            set Fxy [expr $Fxy*cos($Foxy*$factor)]
            set Vx [expr $Vx*cos($Vox*$factor)]
            set Vy [expr $Vy*cos($Voy*$factor)]
            set Mx [expr $Mx*cos($Mox*$factor)]
            set My [expr $My*cos($Moy*$factor)]
            set Mxy [expr $Mxy*cos($Moxy*$factor)]
            puts $fout [format "%i %g %g %g" $num $Fx $Fy $Fxy]
            append var1 [format "%i %g %g %g\n" $num $Mx $My $Mxy]
            append var2 [format "%i %g % g\n" $num $Vx $Vy]
            
            gets $fin line
            incr NumLine
        }
    }
    if { $currentoutputtype == "REAL-IMAGINARY OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num Frx Fry Frxy] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mrx Mry Mrxy
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Vrx Vry Fix
            gets $fin line
            incr NumLine
            #scan $line "%s %g %g %g" {} Fiy Fixy Mix
            gets $fin line
            incr NumLine
            #scan $line "%s %g %g %g" {} Miy Mixy Vix
            gets $fin line
            incr NumLine
            #scan $line "%s %g" {} Viy
            puts $fout [format "%i %g %g %g" $num $Frx $Fry $Frxy]
            append var1 [format "%i %g %g %g\n" $num $Mrx $Mry $Mrxy]
            append var2 [format "%i %g % g\n" $num $Vrx $Vry]
            
            gets $fin line
            incr NumLine
        }
    }
    puts -nonewline $fout [PCH2GiD::EndGiDResultsHeader]
    append var1 [PCH2GiD::EndGiDResultsHeader]
    append var2 [PCH2GiD::EndGiDResultsHeader]
    puts -nonewline $fout $var1
    puts -nonewline $fout $var2
    return [list $NumLine $line]    
}

proc PCH2GiD::Readsmooth_elmforces_64 { NumLine line } {
    variable currentid
    variable fin
    variable fout
    variable QUAD4init
    variable currentstep
    variable smoothing
    variable results
    variable results1
    variable results2
    variable results3
    variable currentoutputtype
    
    catch { unset results1 }
    catch { unset results2 }
    catch { unset results3 } 
    
    set results ""
    set results1 ""
    set results2 ""
    set results3 ""
    set var1 ""
    set var2 ""
    set var3 ""
    puts -nonewline $fout [PCH2GiD::GiDResultsHeader "Shell menbrane Forces" $currentid $currentstep matrix \
            OnNodes "Fx\nFy\nFxy"]
    append var1 [PCH2GiD::GiDResultsHeader "Shell bending Moments" $currentid $currentstep matrix \
            OnNodes "Mx\nMy\nMxy"]
    append var2 [PCH2GiD::GiDResultsHeader "Shell transverse Shear" $currentid $currentstep vector OnNodes \
            "Vx\nVy\n"]
    if { $currentoutputtype == "REAL OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num Fx Fy Fxy] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mx My Mxy
            gets $fin line
            incr NumLine
            scan $line "%s %g %g" {} Vx Vy
            lappend results $Fx 
            lappend results $Fy 
            lappend results $Fxy 
            lappend results1 $Mx
            lappend results1 $My 
            lappend results1 $Mxy
            lappend results2 $Vx
            lappend results2 $Vy
            
            gets $fin line
            incr NumLine
        }
    }
    if { $currentoutputtype == "MAGNITUDE-PHASE OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num Fx Fy Fxy] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mx My Mxy
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Vx Vy Fox
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Foy Foxy Mox
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Moy Moxy Vox
            gets $fin line
            incr NumLine
            scan $line "%s %g" {} Voy
            set Fx [expr $Fx*cos($Fox*$factor)]
            set Fy [expr $Fy*cos($Foy*$factor)]
            set Fxy [expr $Fxy*cos($Foxy*$factor)]
            set Vx [expr $Vx*cos($Vox*$factor)]
            set Vy [expr $Vy*cos($Voy*$factor)]
            set Mx [expr $Mx*cos($Mox*$factor)]
            set My [expr $My*cos($Moy*$factor)]
            set Mxy [expr $Mxy*cos($Moxy*$factor)]
            lappend results $Fx 
            lappend results $Fy 
            lappend results $Fxy 
            lappend results1 $Mx
            lappend results1 $My 
            lappend results1 $Mxy
            lappend results2 $Vx
            lappend results2 $Vy
            
            gets $fin line
            incr NumLine
        }
    }
    if { $currentoutputtype == "REAL-IMAGINARY OUTPUT" } {
        while { ![eof $fin] } {
            if { [scan $line "%i %g %g %g" num Frx Fry Frxy] != 4 } { break }
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Mrx Mry Mrxy
            gets $fin line
            incr NumLine
            scan $line "%s %g %g %g" {} Vrx Vry Fix
            gets $fin line
            incr NumLine
            #scan $line "%s %g %g %g" {} Fiy Fixy Mix
            gets $fin line
            incr NumLine
            #scan $line "%s %g %g %g" {} Miy Mixy Vix
            gets $fin line
            incr NumLine
            #scan $line "%s %g" {} Viy
            lappend results $Frx 
            lappend results $Fry 
            lappend results $Frxy 
            lappend results1 $Mrx
            lappend results1 $Mry 
            lappend results1 $Mrxy
            lappend results2 $Vrx
            lappend results2 $Vry
            
            gets $fin line
            incr NumLine
        }
    }
    PCH2GiD::Smooth 3 PCH2GiD::results Quadrilateral
    puts -nonewline $fout $var1
    PCH2GiD::Smooth 3 PCH2GiD::results1 Quadrilateral
    puts -nonewline $fout $var2
    PCH2GiD::Smooth 2 PCH2GiD::results2 Quadrilateral
    return [list $NumLine $line]
}

proc PCH2GiD::Read_unknown { NumLine line } {
    variable fin
    
    while { ![eof $fin] } {
        if { [string index $line 0] == $ } { break }
        gets $fin line
        incr NumLine
    }
    return [list $NumLine $line]
}

proc PCH2GiD::Smooth { numres arrayname elemtype} {
    
    variable text 
    variable fout 
    upvar #0 $arrayname results
    
    set NumEntities  [GiD_Info Mesh MaxNumElements]
    if { [catch { set info [GiD_Info list_entities Elements 1:$NumEntities]}] } {
        tk_dialogRAM .gid.tmpwin error \
            "Mesh has to be generated before import" \
            error 0 OK
        return
    }
    set elements ""
    foreach i [split $info \n] {
        if { $i != "" } {
            lappend elements [lindex $i 1]
            foreach j [lindex $i 2] {
                lappend elements $j
            }       
        }
    }
    set  finalelems ""
    foreach i $elements {
        if { $i != "" } {
            lappend finalelems $i
        }
    }
    set icounter 0
    if { $elemtype == "Triangle" } {
        foreach "elemsnum  n(1) n(2) n(3)" $finalelems {
            for { set i 1 } { $i <= 3 } { incr i } {
                if { ![info exists nodescounter($n($i))] } {
                    set nodescounter($n($i)) 1
                    set nodesvalue($n($i))  [lrange $results $icounter [expr $icounter+$numres-1]]
                } else {
                    incr nodescounter($n($i)) 1
                    set aux $nodesvalue($n($i))
                    set nodesvalue($n($i)) ""
                    for { set j 0 } { $j < $numres } { incr j } {
                        lappend nodesvalue($n($i)) [expr [lindex $aux $j]+[lindex $results [expr $icounter+$j]]]
                    }
                }
            }
            incr icounter $numres
        }
    }
    if { $elemtype == "Quadrilateral" } {
        foreach "elemsnum  n(1) n(2) n(3) n(4)" $finalelems {
            for { set i 1 } { $i <= 4 } { incr i } {
                if { ![info exists nodescounter($n($i))] } {
                    set nodescounter($n($i)) 1
                    set nodesvalue($n($i))  [lrange $results $icounter [expr $icounter+$numres-1]]
                } else {
                    incr nodescounter($n($i)) 1
                    set aux $nodesvalue($n($i))
                    set nodesvalue($n($i)) ""
                    for { set j 0 } { $j < $numres } { incr j } {
                        lappend nodesvalue($n($i)) [expr [lindex $aux $j]+[lindex $results [expr $icounter+$j]]]
                    }
                }
            }
            incr icounter $numres
        }
    }
    foreach i [lsort -integer [array names nodesvalue]] {
        set aux ""
        for { set j 0 } { $j < $numres } { incr j } {
            lappend aux [expr [ lindex $nodesvalue($i) $j ]/double($nodescounter($i))]
            
        }
        set nodesvalue($i) $aux
        puts  -nonewline $fout [format "%i "  $i]
        for { set j 0 } { $j < $numres } { incr j } {
            puts -nonewline $fout [format "%g " [lindex $nodesvalue($i) $j]]
        }
        puts $fout ""
    }
    puts $fout [PCH2GiD::EndGiDResultsHeader]    
}

proc PCH2GiD::TranslateW { filein fileout smooth } {
    variable percentage
    variable text
    
    package require progressbar
    
    
    catch { destroy .translatenastran }
    set w [toplevel .translatenastran]
    wm title $w PCH2GiD
    
    
    set sw [ScrolledWindow $w.lf -relief sunken -borderwidth 0]
    set text [text $w.t -width 50 -height 4]
    $sw setwidget $text
    
    set pb [::progressbar::progressbar $w.pb -variable PCH2GiD::percentage -width 300 \
            -background [ $w cget -background]]
    
    button $w.b -text Close -width 10 -command "destroy $w"
    
    grid $sw -sticky ewns
    grid $pb
    grid $w.b
    
    grid columnconf $w 0 -weight 1
    grid rowconf $w 0 -weight 1
    
    PCH2GiD::Translate $filein $fileout $smooth
}

#  package require BWidget
#  source C:/compasser/progressbar.tcl
#  PCH2GiD::TranslateW {\\Compass1\c\Temp\prova\prova.pch} \
    #   {\\Compass1\c\Temp\prova.gid\prova.flavia.res}
