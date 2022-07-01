proc VerifyProperty {} {
    
    .central.s waitstate 1
    update
    set elemsunassinged ""
    set elemtypes [lrange [GiD_Info Mesh] 1 end] 
    set error 0
    if { $elemtypes == "" } {
        WarnWin [= "It is necessary to create the mesh before verifying properties of the model"]
        set error 1 
        .central.s waitstate 0
        return 
    }
    set IsQuadratic [lindex [GiD_Info Project] 5]
    
    foreach elemtype $elemtypes {
        switch $elemtype {
            Linear {
                set propertyla [list BAR BEAM]
                set propertynola [list TUBE VISCOUS_DAMPER SPRING DOF_SPRING ROD]
                set elemsunassigned ""
                if { !$IsQuadratic } {
                    foreach "num n1 n2 prop" [GiD_Info Mesh Elements Linear] {
                        if { $prop != 0 } {
                            set propname [lindex [GiD_Info materials] [expr $prop-1]]
                            lappend propelems($propname) $num
                        } else {
                            lappend elemsunassigned $num
                        } 
                    }
                    if { $elemsunassigned != "" } { 
                        WarnWinText [= "The following linear elements do not have assigned any properties:\n%s" \
                                $elemsunassigned]
                        set error 1                   
                    }
                    foreach propname [array names propelems] {
                        set propelems($propname) [lsort -integer $propelems($propname)]
                        foreach "n val" [lrange [GiD_Info materials $propname]  1 end] {
                            if { [string match PROPERTY* $n] } { 
                                if { [lsearch -exact $propertyla $val] != -1} {
                                    set needla($propname) 1
                                    break
                                } elseif { [lsearch -exact $propertynola $val] !=-1 } {
                                    set needla($propname) 0
                                    break
                                } else {
                                    WarnWinText [= "Some linear elements have $propname property assigned.\n\
                                            This property is not allowed for this kind of elements"]
                                    set error 1 
                                    break                               
                                }
                            }
                        }
                    }
                    set localaxesprop ""
                    foreach propname [array names propelems] {
                        if { $needla($propname) } {
                            set localaxesprop [concat $localaxesprop $propelems($propname)]
                        }
                    }
                    set localaxesprop [lsort -integer $localaxesprop]
                    
                    set elemscond ""
                    foreach elems [GiD_Info conditions Line-Local-Axes mesh] {
                        lappend elemscond [lindex $elems 1]
                    } 
                    set elemscond [lsort -integer $elemscond]
                    set index 0
                    set indexprevious 0
                    set aux [lindex $localaxesprop 0]
                    set elemsnola ""
                    
                    foreach  elem  $elemscond {
                        while { $elem >= $aux && $aux != ""} {
                            if { $elem == $aux } {
                                set elemsnola [concat $elemsnola [lrange $localaxesprop $indexprevious [expr $index-1]]]
                                incr index
                                set indexprevious $index
                                set aux [lindex $localaxesprop $index]
                                break
                            }
                            incr index
                            set aux [lindex $localaxesprop $index]                        
                        }                                                                     
                    }
                    if { $index !=0 } { 
                        catch { set elemsnola [concat $elemsnola [lrange $localaxesprop $index end]] }
                    }
                    if { $elemsnola != ""} {
                        WarnWinText [= "The following linear elements have assigned Bar or Beam property\n\
                                but do not have defined local axes:\n$elemsnola\n\
                                To solve this error use: Data -> Properties -> Local Axes"]
                        set error 1 
                    }
                    
                } else {
                    WarnWinText [= "Quadratic Linear elements are not supported"]
                    set error 1 
                }
            }
            Triangle {
                set property [list SHEAR_PANEL MEMBRANE BENDING_ONLY PLATE PLANE_STRAIN LAMINATE]
                set propaccept ""
                foreach propname [GiD_Info materials] { 
                    foreach "n val" [lrange [GiD_Info materials $propname]  1 end] {
                        if { [string match PROPERTY* $n] } { 
                            if { [lsearch -exact $property $val] != -1} {
                                lappend propaccept $propname
                                break
                            }
                        }
                    } 
                }              
                set elemsunassigned ""
                if { !$IsQuadratic } {
                    foreach "num n1 n2 n3 prop" [GiD_Info Mesh Elements Triangle] {
                        if { $prop != 0 } {
                            set propname [lindex [GiD_Info materials] [expr $prop-1]]
                            if { [lsearch -exact $propaccept $propname] == -1 } {
                                WarnWinText [= "Triangle Element ID: %s has %s property assigned.\n\
                                        This property is not allowed for this kind of elements" $num $propname]
                                set error 1 
                            }
                        } else {
                            lappend elemsunassigned $num
                        } 
                    }
                    if { $elemsunassigned != "" } { 
                        WarnWinText [= "The following Triangle elements do not have assigned any properties:\n%s" \
                                $elemsunassigned]
                        set error 1                   
                    }
                } else {
                    WarnWinText [= "Quadratic Triangle elements are not supported"]
                    set error 1 
                }
            }
            Quadrilateral {
                set property [list SHEAR_PANEL MEMBRANE BENDING_ONLY PLATE PLANE_STRAIN LAMINATE]
                set propaccept ""
                foreach propname [GiD_Info materials] { 
                    foreach "n val" [lrange [GiD_Info materials $propname]  1 end] {
                        if { [string match PROPERTY* $n] } { 
                            if { [lsearch -exact $property $val] != -1} {
                                lappend propaccept $propname
                                break
                            }
                        }
                    } 
                }              
                set elemsunassigned ""
                if { !$IsQuadratic } {
                    foreach "num n1 n2 n3 n4 prop" [GiD_Info Mesh Elements Quadrilateral] {
                        if { $prop != 0 } {
                            set propname [lindex [GiD_Info materials] [expr $prop-1]]
                            if { [lsearch -exact $propaccept $propname] == -1 } {
                                WarnWinText [= "Quadrilateral Element ID: %s has %s property assigned.\n\
                                        This property is not allowed for this kind of elements" $num $propname]
                                set error 1 
                            }
                        } else {
                            lappend elemsunassigned $num
                        } 
                    }
                    if { $elemsunassigned != "" } { 
                        WarnWinText [= "The following Quadrilateral elements do not have assigned any properties:\n%s"
                            $elemsunassigned] 
                        set error 1                    
                    }
                } else {
                    WarnWinText [= "Quadratic Quadrilateral elements are not supported"]
                    set error 1 
                }
            }
            Tetrahedra {
                set property TETRAHEDRON
                set propaccept ""
                foreach propname [GiD_Info materials] { 
                    foreach "n val" [lrange [GiD_Info materials $propname]  1 end] {
                        if { [string match PROPERTY* $n] } { 
                            if { [lsearch -exact $property $val] != -1} {
                                lappend propaccept $propname
                                break
                            }
                        }
                    } 
                }              
                set elemsunassigned ""
                if { !$IsQuadratic } {
                    foreach "num n1 n2 n3 n4 prop" [GiD_Info Mesh Elements Tetrahedra] {
                        if { $prop != 0 } {
                            set propname [lindex [GiD_Info materials] [expr $prop-1]]
                            if { [lsearch -exact $propaccept $propname] == -1 } {
                                WarnWinText [= "Tetrahedra Element ID: %s has %s property assigned.\n\
                                        This property is not allowed for this kind of elements" $num $propname]
                                set error 1 
                            }
                        } else {
                            lappend elemsunassigned $num
                        } 
                    }
                    if { $elemsunassigned != "" } { 
                        WarnWinText [= "The following Tetrahedra elements do not have assigned any properties:\n%s" \
                                $elemsunassigned]
                        set error 1                   
                    }
                } else {
                    WarnWinText [= "Quadratic Tetrahedra elements are not supported"]
                }
            }
            Hexahedra {
                set property HEXAHEDRON
                set propaccept ""
                foreach propname [GiD_Info materials] { 
                    foreach "n val" [lrange [GiD_Info materials $propname]  1 end] {
                        if { [string match PROPERTY* $n] } { 
                            if { [lsearch -exact $property $val] != -1} {
                                lappend propaccept $propname
                                break
                            }
                        }
                    } 
                }              
                set elemsunassigned ""
                if { !$IsQuadratic } {
                    foreach "num n1 n2 n3 n4 n5 n6 n7 n8 prop" [GiD_Info Mesh Elements Hexahedra] {
                        if { $prop != 0 } {
                            set propname [lindex [GiD_Info materials] [expr $prop-1]]
                            if { [lsearch -exact $propaccept $propname] == -1 } {
                                WarnWinText [= "Hexahedra Element ID: %s has %s property assigned.\n\
                                        This property is not allowed for this kind of elements" $num $propname] 
                                set error 1 
                            }
                        } else {
                            lappend elemsunassigned $num
                        } 
                    }
                    if { $elemsunassigned != "" } { 
                        WarnWinText [= "The following Hexahedra elements do not have assigned any properties:\n%s" \
                                $elemsunassigned]
                        set error 1                    
                    }
                } else {
                    WarnWinText [= "Quadratic Hexahedra elements are not supported"]
                    set error 1 
                }
            }
        }
    }     
    if { $error == 0 } { 
        WarnWinText [= "REPORT:\n\n\
                GiD Version:\t[GiD_Info GiDVersion]\n\
                Project name:\t[file tail [lindex [GiD_Info Project] 1]]\n\
                Num. Nodes:\t[GiD_Info Mesh MaxNumNodes]\n\
                Num. Elements:\t[GiD_Info Mesh MaxNumElements]\n\n\
                No problems found.\n\n\
                Both bars and beams have local axes defined\n\
                All shell elements have a property assigned\n\
                All volume elements have a property assigned\n\n\
                To write a NASTRAN input file use the following menu sequence:\n\
                \tCalculate --> Calculate"]
    } 
    .central.s waitstate 0
    return $error
}
