proc InitNastranRead { filename } {
    global NastranPriv NastranPrivMat NastranPrivProp NastranPrivElemProp NastranPrivUnimplemented NastranPrivLC \
        ProblemTypePriv
    
    #     set ProblemTypePriv(loadcasenames) Load_case_1
    #     set ProblemTypePriv(currentloadcase) 1
    set NastranPrivMat(Names) ""
    set NastranPrivProp(Names) ""
    
    
    set NastranPrivMat(Fields,ISOTROPIC) "Table Type young  mo_shear poisson density temp_ref \
        tension compression shear damping expansion conductivity spec_heat free_conv \
        heatgen nontype plasticity harden yield_func initial friction stress-strain"
    set NastranPrivMat(Defaults,ISOTROPIC) "0 isotropic void void void void void void void void void void void void void void \
        none void void void void void void"
    
    set NastranPrivMat(Fields,ANISOTROPIC_SHELL) "Table Type G11 G12 G13 G22 G23 G33 rho A1 A2 A3 Tref Ge St Sc Ss Cs K11 K12 K13 K22 K23 K33 \
        Cp Hgen nontype plasticity harden yield_func initial friction stress-strain"
    set NastranPrivMat(Defaults,ANISOTROPIC_SHELL) "0 anisotropic_shell void void void void void void void void void void void void void \
        void void void void void void void void void void void none void void void void void void"
    
    set NastranPrivMat(Fields,ORTHOTROPIC_SHELL) "Table Type E1 E2  nu12 G12 G1Z G2Z rho  A1 A2 Tref Xt Xc Yc Yt S Ge F12 Strn Cs \
        K11 K12 K13 K22 K23 K33 Cp Hgen nontype plasticity harden yield_func initial friction stress-strain"
    set NastranPrivMat(Defaults,ORTHOTROPIC_SHELL) "0 orthotropic_shell void void void void void void void void void void void void void void \
        void void void void void void void void void void void void void none void void void void void void"
    
    set NastranPrivProp(Fields,PROD) "Table PROPERTY Area_Cross_Section Torsional_Constant \
        Coeff._Torsional_Stress Nonstructural_mass/length Composition_Material"
    set NastranPrivProp(Defaults,PROD) [list 0 ROD 0.0 0.0 0.0 0.0 AISI_4340_STEEL]
    
    set NastranPrivProp(Fields,PBAR) "Table PROPERTY win_info Area Moments_of_Inertia I1 I2 I12 Torsional_Constant \
        Y_Shear_Area Z_Shear_Area Nonstructural_mass/lentgh Stress_Recovery Values:(Y,Z) Composition_Material"
    set NastranPrivProp(Defaults,PBAR) [list 0 BAR MA== 0.0 I 0.0 0.0 0.0 0.0 0.0 0.0 0.0 "2_to_4_Blank=Square" \
            "#N# 8 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0" Isotropic]
    
    set NastranPrivProp(Fields,PBEAM) "Table PROPERTY win_info Area Moments_of_Inertia I1 I2 I12 Torsional_Constant \
        Y_Shear_Area Z_Shear_Area Nonstructural_mass/lentgh Y_Neutral_Axis_Offset Stress_Recovery  \
        Z_Neutral_Axis_Offset Values:(Y,Z) Composition_Material"
    set NastranPrivProp(Defaults,PBEAM) [list 0 BEAM MA== 0.0 I 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 "2_to_4_Blank=Square" \
            "#N# 8 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0" Isotropic]   
    
    set NastranPrivProp(Fields,PTUBE) "Table PROPERTY Outside_diameter_of_tube Solid_Circular_Rod Thickness_of_tube \
        Nonstructural_mass/length Composition_Material"
    set NastranPrivProp(Defaults,PTUBE) "0 TUBE 0.0 0 0.0 0.0 Isotropic"
    
    set NastranPrivProp(Fields,PPIPE) "Table PROPERTY Outside_diameter_of_pipe Pipe_wall_thickness Internal_pressure \
        End_condition Nonstructural_mass/length Composition_Material"
    set NastranPrivProp(Defaults,PPIPE) "0 PIPE 0.0 0.0 0.0 CLOSED 0.0 Isotropic"
    
    set NastranPrivProp(Fields,PCABLE) "Table PROPERTY Initial_conditions Slack_U0 Tension_T0 Area_cross_section \
        Moment_of_Inertia Allowable_tensile_stress Composition_Material"
    set NastranPrivProp(Defaults,PCABLE) "0 CABLE cable_slack 0.0 0.0 0.0 0.0 0.0 Isotropic"
    
    set NastranPrivProp(Fields,PSHELL) "Table PROPERTY thick matid  bend trans nomass stress nastran Composition_Material"
    set NastranPrivProp(Defaults,PSHELL) "0 PLATE void SXNvdHJvcGljIFBsYXRlLU1hdGVyaWFsIFBsYXRlLU1hdGVyaWFsIE5vbmUtSWdub3Jl \
        void void void dm9pZCB2b2lk SXNvdHJvcGljIHt9IFBsYXRlLU1hdGVyaWFsIHt9IFBsYXRlLU1hdGVyaWFsIHt9IHt9IHt9IHt9IE5vbmUtSWdub3Jl \
        -ANY-"
    
    set NastranPrivProp(Fields,PSHEAR) "Table PROPERTY Thickness Nonstructural_mass/area Effectiveness_Factors F1 F2 Composition_Material"
    set NastranPrivProp(Defaults,PSHEAR) "0 SHEAR_PANEL 0.0 0.0 : 0.0 0.0 Isotropic"
    
    set NastranPrivProp(Fields,PVISC) "Table PROPERTY Viscous_coefficient_extension Viscous_coefficient_rotation Composition_Material"
    set NastranPrivProp(Defaults,PVISC) "0 VISCOUS_DAMPER 0.0 0.0 -ANY-"
    
    set NastranPrivProp(Fields,PSOLID) "Table PROPERTY Coord_System Composition_Material"
    set NastranPrivProp(Defaults,PSOLID) "0 TETRAHEDRON ELEMENT Isotropic"
    
    
    
    set fin [open $filename r]
    set fail [NastranReadExecutiveControl $fin]
    if { $fail } {
        close $fin
        set fin [open $filename r]
    }
    set fail [NastranReadCaseControl $fin]
    close $fin
    
    #to create conditions inside the first interval data
    set ProblemTypePriv(loadcasenames) Load_case_1
    set ProblemTypePriv(currentloadcase) 1
    set NastranPrivLC(1) 2
    GiD_IntervalData set 1
    #set NastranPriv(NotProcessEntitiesInGiD) 0
    #to create also nodes and elements from tcl
    
    
}

#fail==0 -> Ok, fail==1 -> Error, fail==2 User stop
proc EndNastranRead { fail } {
    global NastranPrivMat NastranPrivProp NastranPrivElemProp NastranPrivUnimplemented NastranPrivLC \
        ProblemTypePriv
    
    foreach i [ array names NastranPrivUnimplemented ] {
        WarnWinText [= "Warning: Ignored  %s %s entities" $NastranPrivUnimplemented($i) $i]
    }
    
    #::GidUtils::DisableGraphics
    #::GidUtils::DisableWarnLine
    if { $fail != "2" } {
        #assign element properties
        foreach prop $NastranPrivProp(Names) {
            if { [info exists NastranPrivElemProp($prop)] } {
                #                set NastranPrivElemProp($prop) [CompactNumberList $NastranPrivElemProp($prop)]
                GiD_AssignData material $prop elements $NastranPrivElemProp($prop)
                
            }
        }
    }
    
    if { [array exists NastranPrivMat ] } {
        array unset NastranPrivMat
    }
    if { [array exists NastranPrivProp ] } {
        array unset NastranPrivProp
    }
    
    if { [array exists NastranPrivElemProp ] } {
        array unset NastranPrivElemProp
    }
    
    if { [array exists NastranPrivUnimplemented ] } {
        array unset NastranPrivUnimplemented
    }
    if { [array exists NastranPrivLC ] } {
        array unset NastranPrivLC
    }
    
    #::GidUtils::EnableWarnLin
    #::GidUtils::EnableGraphics
    update
}
proc NastranReadExecutiveControl  { fin } {
    global NastranPrivUnimplemented NastranPrivAnalysis
    
    set NastranPrivAnalysis "STATIC"
    set data ""
    while  { ([lindex $data 0] != "CEND" || ![regexp {([^=]+)\s*=\s*(.*)} $data {} key value]) && ![eof $fin] } {  
        set data [string trim [gets $fin]]        
        if { $data == "BEGIN BULK" } {
            return 1
        }
        if { [string range $data 0 1] == "$*" } {
            continue
            #NASTRAN comment line
        }
        if { [string is list $data] } {
            if { [llength $string] == 1 } {
                #NX NASTRAN VERSION 7.0 use , as separator instead spaces        
                set data [split $data ,]
            }
        } else {
            WarnWinText [= "Executive Control: %s not imported. is not a list" $data]
            continue;#to avoid errors considering as list
        }
        set data [list [lindex $data 0] [lrange $data 1 end]]
        set statment [lindex $data 0]
        switch $statment {
            ID {
                GiD_AccessValue set gendata ID [split [lrange $data 1 end]]
            }
            TIME {
                GiD_AccessValue set gendata TIME [split [lrange $data 1 end]]
            }
            SOL - SOLUTION {
                set nastrannames [list [list "STEADY STATE HEAT TRANSFER" 101] [list "LINEAR STATIC" 101]\
                        [list "STATIC" 101] [list "MODAL" 103]  [list "LINEAR BUCKLING" 105] [list  "NONLINEAR STATIC" 106] \
                        [list "FREQUENCY RESPONSE" 111] [list "LINEAR TRANSIENT RESPONSE" 112] \
                        [list "NONLINEAR BUCKLING" 180] [list  "PRESTRESS STATIC" 181] \
                        [list "LINEAR PRESTRESS MODAL" 182] [list "NONLINEAR TRANSIENT RESPONSE" 129] ]
                
                set gidnames [list STEADY_STATE_HEAT_TRANSFER STATIC  STATIC MODES BUCKLING NONLINEAR_STATIC \
                        DIRECT_FREQUENCY_RESPONSE DIRECT_TRANSIENT_RESPONSE NONLINEAR_BUCKLING \
                        PRESTRESS_STATIC  PRESTRESS_MODES NONLINEAR_TRANSIENT]
                
                #In two previous lists the order of the elements is very important
                if { [string is integer [lindex $data 1]] } {
                    for { set ii 0 } { $ii <[llength $nastrannames]} { incr ii } {
                        if { [lindex [lindex $nastrannames $ii] 1] == [lindex $data 1]} { 
                            GiD_AccessValue set gendata Analysis_Type [lindex $gidnames $ii]  
                        } 
                    }
                } else {
                    for { set ii 0 } { $ii <[llength $nastrannames]} { incr ii } {
                        if { [lindex [lindex $nastrannames $ii] 0] == "[lindex $data 1]"} { 
                            GiD_AccessValue set gendata Analysis_Type [lindex $gidnames $ii]  
                        } 
                    }
                }
                break
            }
            DIAG {
                GiD_AccessValue set gendata Diagnostics [split [lrange $data 1 end]]
            }           
            default {
                WarnWinText [= "Executive Control: %s not imported" $data]
            }
        }
    }
    return 0
}

proc NastranReadCaseControl { fin } {
    global NastranPrivAnalysis
    
    set GiDoutputrequests [list Displacement Applied_Load Constraint_Force Velocity \
            Acceleration Element_Stress Element_Force Element_Strain Strain_Energy \
            Temperature Flux]
    set NASTRANoutputrequests [list DISPLACEMENT LOAD SPCFORCES VELOCITY \
            ACCELERATION STRESS FORCE ESE STRAIN THERMAL FLUX]
    set GiDcasecontrol [list Title Subtitle Label Lines_per_printed_page Maximum_number_of_output_lines ECHO \
            Rigid_Format_approach]
    set NASTRANcasecontrol [list TITLE SUBTITLE LABEL LINE MAXLINES ECHO ANALYSIS]
    set data ""
    while {$data != "BEGIN BULK" && ![eof $fin] } {
        set data [gets $fin] 
        if { [regexp {([^=]+)\s*=\s*(.*)} $data {} key value] } {
            if { [regexp {([^=]+)\s*\(\s*(.*)} $key {} key value] } {
                set key [string trim $key]
                set index [lsearch $NASTRANoutputrequests $key]
                if {  $index != -1 } {
                    GiD_AccessValue set gendata [lindex $GiDoutputrequests $index] 1
                } else {
                    WarnWinText [= "Case control: Output %s is not supported" $key]
                }
            } else { 
                set key [string trim $key]
                set index [lsearch $NASTRANcasecontrol $key]
                if {  $index !=-1} {
                    lappend NastranPrivAnalysis $value
                    GiD_AccessValue set gendata [lindex $GiDcasecontrol $index] [DWSpace2Under $value]
                }
            }
        }
    }
}
proc SetMatFieldValue { mat field value mattemplate} {   
    global NastranPrivMat
    set i [lsearch $NastranPrivMat(Fields,$mattemplate) $field]
    if { $i != "-1" } {
        if { [string trim $value] == "" ||  [string trim $value] == "Table_"} {
            lset NastranPrivMat($mat) $i "void"
        } else {
            lset NastranPrivMat($mat) $i "$value"
        }
    } else {
        WarnWinText [= "Error, field %s not exists in material %s" $field $mat]
    }
}

proc SetPropFieldValue { prop type field value } {   
    global NastranPrivProp
    set i [lsearch $NastranPrivProp(Fields,$type) $field]
    if { $i != "-1" } {
        if { [string trim $value] != "" } {
            lset NastranPrivProp($prop) $i $value
        }
    } else {
        WarnWinText [= "Error, field %s not exists in property %s" $field $prop]
    }
}

#instead "4 8 9 10 11 15" compact list --> "4 8 : 11 15" 
proc AddNumberToNastranPrivElemProp { prop n } {
    global NastranPrivElemProp
    if { ![info exists NastranPrivElemProp($prop)] || [llength $NastranPrivElemProp($prop)] < 2 } {
        lappend NastranPrivElemProp($prop) $n
    } else {
        if { [expr [lindex $NastranPrivElemProp($prop) end]+1] == $n } {
            if { [lindex $NastranPrivElemProp($prop) end-1] == ":" } {
                lset NastranPrivElemProp($prop) end $n
            } elseif { [expr [lindex $NastranPrivElemProp($prop) end-1]+1] == [lindex $NastranPrivElemProp($prop) end]} {
                lset NastranPrivElemProp($prop) end :
                lappend NastranPrivElemProp($prop) $n
            } else {
                lappend NastranPrivElemProp($prop) $n
            }
        } else {
            lappend NastranPrivElemProp($prop) $n
        }
    }
}

#items must be positive integer numbers (not 0)
proc CompactNumberList { a } {    
    set ret ""
    set istart 0
    foreach i [lsort -integer $a] {  
        if { !$istart} {
            set istart $i
        } else {
            if {$i != [expr $iprev+1]} {
                if { $istart != $iprev } {
                    if { [expr $istart +1] == $iprev } {
                        append ret "$istart $iprev "
                    } else { 
                        append ret "$istart:$iprev "
                    }
                } else {
                    append ret "$istart "
                }            
                set istart $i
            }        
        }
        set iprev $i
    }
    if { $istart } {
        if { $istart != $iprev } {
            if { [expr $istart +1] == $iprev } {
                append ret "$istart $iprev"
            } else { 
                append ret "$istart:$iprev"
            }
        } else {
            append ret "$istart"
        }   
    }
    return $ret
}

proc NastranEntity { type data } {
    global NastranPrivMat NastranPrivProp NastranPrivElemProp NastranPrivUnimplemented NastranPrivLC \
        ProblemTypePriv NastranPrivAnalysis
    
    set data [split $data ,]
    switch $type {
        CBAR {
            set EID [lindex $data 0]
            set PID [lindex $data 1]
            set GA [lindex $data 2]
            set GB [lindex $data 3]
            set X1 [lindex $data 4] ;#can be X1 or G0
            set X2 [lindex $data 5]
            set X3 [lindex $data 6]
            
            set PA [lindex $data 8]
            set PB [lindex $data 9]
            set W1A [lindex $data 10]
            set W2A [lindex $data 11]
            set W2A [lindex $data 12]
            set W1B [lindex $data 13]
            set W2B [lindex $data 14]
            set W2B [lindex $data 15]
            
            set prop "PBAR_$PID"
            append NastranPrivElemProp($prop) "$EID "
            
            foreach {Num A1 A2 A3} [GiD_Info Mesh Nodes $GA] break
            foreach {Num B1 B2 B3} [GiD_Info Mesh Nodes $GB] break
            if { [string is integer $X1] } {
                set G0 $X1
                foreach {Num X1 X2 X3} [GiD_Info Mesh Nodes $G0] break
            }
            
            set exists [GiD_LocalAxes exists "" rectangular C_XY_X "$A1 $A2 $A3" "$X1 $X2 $X3" "$B1 $B2 $B3"]
            if { $exists == -1 } {
                set values "GLOBAL"
            } elseif { $exists == -2 } {
                set values "Auto"
            } elseif { $exists == -3 } {
                set values "Auto_alt"
            } elseif { $exists == 0 } {
                GiD_LocalAxes create "LA_$EID" rectangular C_XY_X "$A1 $A2 $A3" "$X1 $X2 $X3" "$B1 $B2 $B3"
            } else {
                set values [lindex [GiD_Info localaxes] [expr $exists-1]]
            }
            set cond "Line-Local-Axes"
            GiD_AssignData condition $cond body_elements $values $EID
        }
        CBEAM {
            set EID [lindex $data 0]
            set PID [lindex $data 1]
            set GA [lindex $data 2]
            set GB [lindex $data 3]
            set X1 [lindex $data 4] ;#can be X1 or G0
            set X2 [lindex $data 5]
            set X3 [lindex $data 6]
            
            set PA [lindex $data 8]
            set PB [lindex $data 9]
            set W1A [lindex $data 10]
            set W2A [lindex $data 11]
            set W2A [lindex $data 12]
            set W1B [lindex $data 13]
            set W2B [lindex $data 14]
            set W2B [lindex $data 15]
            
            set prop "PBEAM_$PID"
            append NastranPrivElemProp($prop) "$EID "
            
            foreach {Num A1 A2 A3} [GiD_Info Mesh Nodes $GA] break
            foreach {Num B1 B2 B3} [GiD_Info Mesh Nodes $GB] break
            if { [string is integer $X1] } {
                set G0 $X1
                foreach {Num X1 X2 X3} [GiD_Info Mesh Nodes $G0] break
            }
            
            set exists [GiD_LocalAxes exists "" rectangular C_XY_X "$A1 $A2 $A3" "$X1 $X2 $X3" "$B1 $B2 $B3"]
            if { $exists == -1 } {
                set values "GLOBAL"
            } elseif { $exists == -2 } {
                set values "Auto"
            } elseif { $exists == -3 } {
                set values "Auto_alt"
            } elseif { $exists == 0 } {
                GiD_LocalAxes create "LA_$EID" rectangular C_XY_X "$A1 $A2 $A3" "$X1 $X2 $X3" "$B1 $B2 $B3"
            } else {
                set values [lindex [GiD_Info localaxes] [expr $exists-1]]
            }
            set cond "Line-Local-Axes"
            GiD_AssignData condition $cond body_elements $values $EID
        }
        CROD {
            set EID [lindex $data 0]
            set PID [lindex $data 1]
            set prop "ROD_$PID" ;#PROD
            append NastranPrivElemProp($prop) "$EID "
            #too slow assign to each element the material, store it an assign only once at end
        }
        CPIPE {
            set EID [lindex $data 0]
            set PID [lindex $data 1]
            set prop "PIPE_$PID" ;#PPIPE
            append NastranPrivElemProp($prop) "$EID "
            #too slow assign to each element the material, store it an assign only once at end
        }
        CTUBE {
            set EID [lindex $data 0]
            set PID [lindex $data 1]
            set prop "TUBE_$PID" ;#PTUBE
            append NastranPrivElemProp($prop) "$EID "
            #too slow assign to each element the material, store it an assign only once at end
        }
        CCABLE {
            set EID [lindex $data 0]
            set PID [lindex $data 1]
            set prop "CABLE_$PID" ;#PCABLE
            append NastranPrivElemProp($prop) "$EID "
            #too slow assign to each element the material, store it an assign only once at end
        }
        
        CQUADR - CQUAD4 {
            set EID [lindex $data 0]
            set PID [lindex $data 1]
            #set G1 [lindex $data 2]
            #set G2 [lindex $data 3]
            #set G3 [lindex $data 4]
            #set G4 [lindex $data 5]
            #...
            set prop "PSHELL_$PID" ;#PSHELL_OR_PCOMP
            append NastranPrivElemProp($prop) "$EID "
            #too slow assign to each element the material, store it an assign only once at end
        }
        CTETRA {
            set EID [lindex $data 0]
            set PID [lindex $data 1]
            # ...conectivities
            set prop "PSOLID_$PID"
            append NastranPrivElemProp($prop) "$EID "
            #lappend NastranPrivElemProp($prop) $EID ;#this is too slow!!!
            #too slow assign to each element the material, store it an assign only once at end
        }
        CHEXA {
            set EID [lindex $data 0]
            set PID [lindex $data 1]
            set prop "PSOLID_$PID"
            append NastranPrivElemProp($prop) "$EID "
            #lappend NastranPrivElemProp($prop) $EID ;#this is too slow!!!
            #too slow assign to each element the material, store it an assign only once at end
        }
        CTRIAR - CTRIA3 {
            set EID [lindex $data 0]
            set PID [lindex $data 1]
            #set G1 [lindex $data 2]
            #set G2 [lindex $data 3]
            #set G3 [lindex $data 4]
            #...
            set prop "PSHELL_$PID" ;#PSHELL_OR_PCOMP
            append NastranPrivElemProp($prop) "$EID "
            #too slow assign to each element the material, store it an assign only once at end
        }
        TEMPD { 
            GiD_AccessValue set gendata Model_Initial_Temperature [lindex $data 1]
        } 
        TEMP {
            set SID [lindex $data 0]
            if { [info exists NastranPrivLC($SID) ] } {
                LoadCaseManagment set $NastranPrivLC($SID)
            } else {
                set NastranPrivLC($SID) [LoadCaseManagment create -1]
                LoadCaseManagment set $NastranPrivLC($SID)
            }      
            set cond Point_Initial_Temperature
            foreach {node temp} [lrange $data 1 end] { 
                set nassigned  [GiD_AssignData condition $cond nodes $temp $node]
                if { $nassigned <= 0 } {
                    WarnWinText [= "WARNING: condition %s can not be assigned to entity %s" $cond $node]
                }
            }
            LoadCaseManagment set 1
        }
        FORCE {
            set SID [lindex $data 0]
            set G [lindex $data 1]
            set CID [lindex $data 2]
            set F [lindex $data 3]
            set N1 [lindex $data 4]
            set N2 [lindex $data 5]
            set N3 [lindex $data 6]
            set cond "Point-Force-Load"
            if { $CID } {
                #must calculate the global normal components ...
                WarnWinText [= "%s not implemented for non global coordinate sytems" $type].
            }
            set values "[expr $F*$N1] [expr $F*$N2] [expr $F*$N3]"
            if { $SID < 1 } {
                WarnWinText [= "WARNING: %s unexpected value of SID='%s'" $type $SID]
            }
            if { [info exists NastranPrivLC($SID) ] } {
                LoadCaseManagment set $NastranPrivLC($SID)
            } else {
                set NastranPrivLC($SID) [LoadCaseManagment create -1]
                LoadCaseManagment set $NastranPrivLC($SID)
            }      
            set nassigned  [GiD_AssignData condition $cond nodes $values $G]
            if { $nassigned <= 0 } {
                WarnWinText [= "WARNING: condition %s can not be assigned to entity %s" $cond $G]
            }
            LoadCaseManagment set 1
        }
        MOMENT {
            set SID [lindex $data 0]
            set G [lindex $data 1]
            set CID [lindex $data 2]
            set M [lindex $data 3]
            set N1 [lindex $data 4]
            set N2 [lindex $data 5]
            set N3 [lindex $data 6]
            set cond "Moment"
            if { $CID } {
                #must calculate the global normal components ...
                WarnWinText [= "%s not implemented for non global coordinate sytems" $type].
            }
            set values "[expr $M*$N1] [expr $M*$N2] [expr $M*$N3]"
            
            if { $SID < 1 } {
                WarnWinText [= "WARNING: %s unexpected value of SID='%s'" $type $SID]
            }
            if { [info exists NastranPrivLC($SID) ] } {
                GiD_IntervalData set $NastranPrivLC($SID)
            } else {
                set NastranPrivLC($SID) [GiD_IntervalData create]
                GiD_IntervalData set $NastranPrivLC($SID)
            }
            set nassigned  [GiD_AssignData condition $cond nodes $values $G]
            if { $nassigned <= 0 } {
                WarnWinText [= "WARNING: condition %s can not be assigned to entity %s" $cond $G]
            }
            LoadCaseManagment set 1
        }
        GRAV {
            set SID [lindex $data 0]
            set CID [lindex $data 1]
            set G [lindex $data 2]
            set N1 [lindex $data 3]
            set N2 [lindex $data 4]
            set N3 [lindex $data 5]
            #set TID1 [lindex $data 8]
            #set TID2 [lindex $data 9]
            #set TID3 [lindex $data 10]
            
            #ignored SID, gravity equal foreach interval at this moment...
            #not implemented CID !=0 at this moment...
            GiD_AccessValue set gendata :Consider_Acceleration YES
            GiD_AccessValue set gendata Modul_Acceleration $G
            GiD_AccessValue set gendata X-Acceleration_Vector $N1
            GiD_AccessValue set gendata Y-Acceleration_Vector $N2
            GiD_AccessValue set gendata Z-Acceleration_Vector $N3
        }
        GRID {
            #set ID [lindex $data 0]
            #set CP [lindex $data 1]
            #set X1 [lindex $data 2]
            #set Y1 [lindex $data 3]
            #set Z1 [lindex $data 4]
            #set CD [lindex $data 5]
            #set PS [lindex $data 6]
        }
        MAT1 {
            set MID [lindex $data 0]
            #use NastranPrivMat($mat) to store materials.
            set mat "MAT_$MID"
            if { [lsearch $NastranPrivMat(Names) $mat] != "-1"} {
                set newmat 0
            } else {
                set newmat 1
                set mattemplate ISOTROPIC
                lappend NastranPrivMat(Names) $mat
                set NastranPrivMat($mat) $NastranPrivMat(Defaults,ISOTROPIC)
            }
            
            SetMatFieldValue $mat young [lindex $data 1] $mattemplate ;#E
            SetMatFieldValue $mat  mo_shear [lindex $data 2] $mattemplate ;#G
            SetMatFieldValue $mat poisson [lindex $data 3] $mattemplate ;#NU
            SetMatFieldValue $mat density [lindex $data 4] $mattemplate ;#RHO
            SetMatFieldValue $mat expansion [lindex $data 5] $mattemplate ;#A
            SetMatFieldValue $mat temp_ref [lindex $data 6] $mattemplate;#TREF
            SetMatFieldValue $mat damping [lindex $data 7] $mattemplate ;#GE
            SetMatFieldValue $mat tension [lindex $data 8] $mattemplate ;#ST 
            SetMatFieldValue $mat compression [lindex $data 9] $mattemplate ;#SC
            SetMatFieldValue $mat shear [lindex $data 10] $mattemplate ;#SS
            #SetMatFieldValue $mat ?? [lindex $data 12] $mattemplate;#CS
            
            if { $newmat } {
                GiD_CreateData create material Isotropic $mat $NastranPrivMat($mat)
            } else {
                GiD_ModifyData materials $mat $NastranPrivMat($mat)
            }
        }
        MATT1 {
            set MID [lindex $data 0]
            #use NastranPrivMat($mat) to store materials.
            set mat "MAT_$MID"
            if { [lsearch $NastranPrivMat(Names) $mat] != "-1"} {
                set newmat 0
            } else {
                set newmat 1
                set mattemplate ISOTROPIC
                lappend NastranPrivMat(Names) $mat
                set NastranPrivMat($mat) $NastranPrivMat(Defaults,ISOTROPIC)
            }
            
            SetMatFieldValue $mat young "Table_[lindex $data 1]" $mattemplate ;#E
            SetMatFieldValue $mat  mo_shear "Table_[lindex $data 2]" $mattemplate ;#G
            SetMatFieldValue $mat poisson "Table_[lindex $data 3]" $mattemplate ;#NU
            SetMatFieldValue $mat density "Table_[lindex $data 4]" $mattemplate ;#RHO
            SetMatFieldValue $mat expansion "Table_[lindex $data 5]" $mattemplate ;#A
            SetMatFieldValue $mat temp_ref "Table_[lindex $data 6]" $mattemplate ;#TREF
            SetMatFieldValue $mat damping "Table_[lindex $data 7]" $mattemplate ;#GE
            SetMatFieldValue $mat tension "Table_[lindex $data 8]" $mattemplate;#ST 
            SetMatFieldValue $mat compression "Table_[lindex $data 9]" $mattemplate;#SC
            SetMatFieldValue $mat shear "Table_[lindex $data 10]" $mattemplate;#SS
            if { $newmat } {
                GiD_CreateData create material Isotropic $mat $NastranPrivMat($mat)
            } else {
                GiD_ModifyData materials $mat $NastranPrivMat($mat)
            }
        }
        MAT4 {
            set MID [lindex $data 0]
            #use NastranPrivMat($mat) to store materials.
            set mat "MAT_$MID"
            if { [lsearch $NastranPrivMat(Names) $mat] != "-1"} {
                set newmat 0
            } else {
                set newmat 1
                set mattemplate ISOTROPIC
                lappend NastranPrivMat(Names) $mat
                set NastranPrivMat($mat) $NastranPrivMat(Defaults,ISOTROPIC)
            }
            
            SetMatFieldValue $mat conductivity [lindex $data 1] $mattemplate;#K
            SetMatFieldValue $mat spec_heat [lindex $data 2] $mattemplate;#CP
            SetMatFieldValue $mat density [lindex $data 3] $mattemplate ;#RHO
            SetMatFieldValue $mat free_conv [lindex $data 4] $mattemplate ;#H
            #SetMatFieldValue $mat ?? [lindex $data 5] $mattemplate ;#MU
            SetMatFieldValue $mat heatgen [lindex $data 6] $mattemplate ;#HGEN
            if { $newmat } {
                GiD_CreateData create material Isotropic $mat $NastranPrivMat($mat)
            } else {
                GiD_ModifyData materials $mat $NastranPrivMat($mat)
            }
        }
        MATT4 {
            set  MID [lindex $data 0]
            #use NastranPrivMat($mat) to store materials.
            set mat "MAT_$MID"
            if { [lsearch $NastranPrivMat(Names) $mat] != "-1"} {
                set newmat 0
            } else {
                set newmat 1
                set mattemplate ISOTROPIC
                lappend NastranPrivMat(Names) $mat
                set NastranPrivMat($mat) $NastranPrivMat(Defaults,ISOTROPIC)
            }
            SetMatFieldValue $mat conductivity "Table_[lindex $data 1]" $mattemplate ;#K
            SetMatFieldValue $mat spec_heat "Table_[lindex $data 2]" $mattemplate ;#CP
            SetMatFieldValue $mat density "Table_[lindex $data 3]" $mattemplate ;#RHO
            SetMatFieldValue $mat free_conv "Table_[lindex $data 4]" $mattemplate ;#H
            #SetMatFieldValue $mat ?? [lindex $data 5] $mattemplate;#MU
            SetMatFieldValue $mat heatgen "Table_[lindex $data 6]" $mattemplate ;#HGEN
            if { $newmat } {
                GiD_CreateData create material Isotropic $mat $NastranPrivMat($mat)
            } else {
                GiD_ModifyData materials $mat $NastranPrivMat($mat)
            }
        }
        MAT2 {
            set MID [lindex $data 0]
            #use NastranPrivMat($mat) to store materials.
            set mat "MAT_$MID"
            if { [lsearch $NastranPrivMat(Names) $mat] != "-1"} {
                set newmat 0
            } else {
                set newmat 1
                set mattemplate ANISOTROPIC_SHELL
                lappend NastranPrivMat(Names) $mat
                set NastranPrivMat($mat) $NastranPrivMat(Defaults,ANISOTROPIC_SHELL)
            }
            
            SetMatFieldValue $mat G11 [lindex $data 1] $mattemplate ;#G11
            SetMatFieldValue $mat G12 [lindex $data 2] $mattemplate ;#G12
            SetMatFieldValue $mat G13 [lindex $data 3] $mattemplate ;#G13
            SetMatFieldValue $mat G22 [lindex $data 4] $mattemplate ;#G22
            SetMatFieldValue $mat G23 [lindex $data 5] $mattemplate ;#G23
            SetMatFieldValue $mat G33 [lindex $data 6] $mattemplate;#G33
            SetMatFieldValue $mat rho [lindex $data 7] $mattemplate ;#RHO
            SetMatFieldValue $mat A1 [lindex $data 8] $mattemplate ;#A1
            SetMatFieldValue $mat A2 [lindex $data 9] $mattemplate ;#A2
            SetMatFieldValue $mat A3 [lindex $data 10] $mattemplate ;#A3
            SetMatFieldValue $mat Tref [lindex $data 11] $mattemplate ;#Tref
            SetMatFieldValue $mat Ge [lindex $data 12] $mattemplate ;#GE
            SetMatFieldValue $mat St [lindex $data 13] $mattemplate ;#ST 
            SetMatFieldValue $mat Sc [lindex $data 14] $mattemplate ;#SC
            SetMatFieldValue $mat Ss [lindex $data 15] $mattemplate ;#SS
            SetMatFieldValue $mat Cs [lindex $data 17] $mattemplate;#CS
            if { $newmat } {
                GiD_CreateData create material Anisotropic_Shell $mat $NastranPrivMat($mat)
            } else {
                GiD_ModifyData materials $mat $NastranPrivMat($mat)
            }
        }
        MATT2 {
            set MID [lindex $data 0]
            #use NastranPrivMat($mat) to store materials.
            set mat "MAT_$MID"
            if { [lsearch $NastranPrivMat(Names) $mat] != "-1"} {
                set newmat 0
            } else {
                set newmat 1
                set mattemplate ANISOTROPIC_SHELL
                lappend NastranPrivMat(Names) $mat
                set NastranPrivMat($mat) $NastranPrivMat(Defaults,ANISOTROPIC_SHELL)
            }
            
            SetMatFieldValue $mat G11 "Table_[lindex $data 1]" $mattemplate ;#G11
            SetMatFieldValue $mat G12 "Table_[lindex $data 2]" $mattemplate ;#G12
            SetMatFieldValue $mat G13 "Table_[lindex $data 3]" $mattemplate ;#G13
            SetMatFieldValue $mat G22 "Table_[lindex $data 4]" $mattemplate ;#G22
            SetMatFieldValue $mat G23 "Table_[lindex $data 5]" $mattemplate ;#G23
            SetMatFieldValue $mat G33 "Table_[lindex $data 6]" $mattemplate;#G33
            SetMatFieldValue $mat rho "Table_[lindex $data 7]" $mattemplate ;#RHO
            SetMatFieldValue $mat A1 "Table_[lindex $data 8]" $mattemplate ;#A1
            SetMatFieldValue $mat A2 "Table_[lindex $data 9]" $mattemplate ;#A2
            SetMatFieldValue $mat A3 "Table_[lindex $data 10]" $mattemplate ;#A3
            SetMatFieldValue $mat Ge "Table_[lindex $data 12]" $mattemplate ;#GE
            SetMatFieldValue $mat St "Table_[lindex $data 13]" $mattemplate ;#ST 
            SetMatFieldValue $mat Sc "Table_[lindex $data 14]" $mattemplate ;#SC
            SetMatFieldValue $mat Ss "Table_[lindex $data 15]" $mattemplate ;#SS
            
            if { $newmat } {
                GiD_CreateData create material Anisotropic_Shell $mat $NastranPrivMat($mat)
            } else {
                GiD_ModifyData materials $mat $NastranPrivMat($mat)
            }
        }
        MAT5 {
            set MID [lindex $data 0]
            #use NastranPrivMat($mat) to store materials.
            set mat "MAT_$MID"
            if { [lsearch $NastranPrivMat(Names) $mat] != "-1"} {
                set newmat 0
            } else {
                set newmat 1
                set mattemplate ANISOTROPIC_SHELL
                lappend NastranPrivMat(Names) $mat
                set NastranPrivMat($mat) $NastranPrivMat(Defaults,ANISOTROPIC_SHELL)
            }
            SetMatFieldValue $mat K11 [lindex $data 1] $mattemplate ;#K11
            SetMatFieldValue $mat K12 [lindex $data 2] $mattemplate ;#K12
            SetMatFieldValue $mat K13 [lindex $data 3] $mattemplate ;#K13
            SetMatFieldValue $mat K22 [lindex $data 4] $mattemplate ;#K22
            SetMatFieldValue $mat K23 [lindex $data 5] $mattemplate ;#K23
            SetMatFieldValue $mat K33 [lindex $data 6] $mattemplate;#K33
            SetMatFieldValue $mat Cp [lindex $data 7] $mattemplate ;#Cp
            SetMatFieldValue $mat  rho [lindex $data 8] $mattemplate ;#RHO
            SetMatFieldValue $mat Hgen [lindex $data 9] $mattemplate ;#Hgen
            
            if { $newmat } {
                GiD_CreateData create material Anisotropic_Shell $mat $NastranPrivMat($mat)
            } else {
                GiD_ModifyData materials $mat $NastranPrivMat($mat)
            }
        }
        MATT5 { 
            set MID [lindex $data 0]
            #use NastranPrivMat($mat) to store materials.
            set mat "MAT_$MID"
            if { [lsearch $NastranPrivMat(Names) $mat] != "-1"} {
                set newmat 0
            } else {
                set newmat 1
                set mattemplate ANISOTROPIC_SHELL
                lappend NastranPrivMat(Names) $mat
                set NastranPrivMat($mat) $NastranPrivMat(Defaults,ANISOTROPIC_SHELL)
            }
            SetMatFieldValue $mat K11 "Table_[lindex $data 1]" $mattemplate ;#K11
            SetMatFieldValue $mat K12 "Table_[lindex $data 2]" $mattemplate ;#K12
            SetMatFieldValue $mat K13 "Table_[lindex $data 3]" $mattemplate ;#K13
            SetMatFieldValue $mat K22 "Table_[lindex $data 4]" $mattemplate ;#K22
            SetMatFieldValue $mat K23 "Table_[lindex $data 5]" $mattemplate ;#K23
            SetMatFieldValue $mat K33 "Table_[lindex $data 6]" $mattemplate;#K33
            SetMatFieldValue $mat Cp "Table_[lindex $data 7]" $mattemplate ;#Cp
            SetMatFieldValue $mat  rho "Table_[lindex $data 8]" $mattemplate ;#RHO
            SetMatFieldValue $mat Hgen "Table_[lindex $data 9]" $mattemplate ;#Hgen
            
            if { $newmat } {
                GiD_CreateData create material Anisotropic_Shell $mat $NastranPrivMat($mat)
            } else {
                GiD_ModifyData materials $mat $NastranPrivMat($mat)
            }
        }
        MAT8 {
            set MID [lindex $data 0]
            #use NastranPrivMat($mat) to store materials.
            set mat "MAT_$MID"
            if { [lsearch $NastranPrivMat(Names) $mat] != "-1"} {
                set newmat 0
            } else {
                set newmat 1
                set mattemplate ORTHOTROPIC_SHELL
                lappend NastranPrivMat(Names) $mat
                set NastranPrivMat($mat) $NastranPrivMat(Defaults,ORTHOTROPIC_SHELL)
            }
            
            SetMatFieldValue $mat E1 [lindex $data 1] $mattemplate ;#E1
            SetMatFieldValue $mat E2 [lindex $data 2] $mattemplate ;#E2
            SetMatFieldValue $mat nu12 [lindex $data 3] $mattemplate ;#nu12
            SetMatFieldValue $mat G12 [lindex $data 4] $mattemplate ;#G12
            SetMatFieldValue $mat G1Z [lindex $data 5] $mattemplate ;#G1Z
            SetMatFieldValue $mat G2Z [lindex $data 6] $mattemplate;#G2Z
            SetMatFieldValue $mat rho [lindex $data 7] $mattemplate ;#RHO
            SetMatFieldValue $mat A1 [lindex $data 8] $mattemplate ;#A1
            SetMatFieldValue $mat A2 [lindex $data 9] $mattemplate ;#A2
            SetMatFieldValue $mat Tref [lindex $data 10] $mattemplate ;#Tref
            SetMatFieldValue $mat Xt [lindex $data 11] $mattemplate ;#Xt
            SetMatFieldValue $mat Xc [lindex $data 12] $mattemplate ;#Xc 
            SetMatFieldValue $mat Yc [lindex $data 14] $mattemplate ;#Yc
            SetMatFieldValue $mat Yt [lindex $data 13] $mattemplate ;#Yt
            SetMatFieldValue $mat S [lindex $data 15] $mattemplate ;#S
            SetMatFieldValue $mat Ge [lindex $data 16] $mattemplate ;#Ge
            SetMatFieldValue $mat F12 [lindex $data 17] $mattemplate;#F12
            SetMatFieldValue $mat Strn [lindex $data 18] $mattemplate ;#Strn
            SetMatFieldValue $mat Cs [lindex $data 19] $mattemplate ;#Cs
            if { $newmat } {
                GiD_CreateData create material Orthotropic_Shell $mat $NastranPrivMat($mat)
            } else {
                GiD_ModifyData materials $mat $NastranPrivMat($mat)
            }
        }
        MATT8 {
            set MID [lindex $data 0]
            #use NastranPrivMat($mat) to store materials.
            set mat "MAT_$MID"
            if { [lsearch $NastranPrivMat(Names) $mat] != "-1"} {
                set newmat 0
            } else {
                set newmat 1
                set mattemplate ORTHOTROPIC_SHELL
                lappend NastranPrivMat(Names) $mat
                set NastranPrivMat($mat) $NastranPrivMat(Defaults,ORTHOTROPIC_SHELL)
            }
            
            SetMatFieldValue $mat E1 "Table_[lindex $data 1]" $mattemplate ;#E1
            SetMatFieldValue $mat E2 "Table_[lindex $data 2]" $mattemplate ;#E2
            SetMatFieldValue $mat nu12 "Table_[lindex $data 3]" $mattemplate ;#nu12
            SetMatFieldValue $mat G12 "Table_[lindex $data 4]" $mattemplate ;#G12
            SetMatFieldValue $mat G1Z "Table_[lindex $data 5]" $mattemplate ;#G1Z
            SetMatFieldValue $mat G2Z "Table_[lindex $data 6]" $mattemplate;#G2Z
            SetMatFieldValue $mat rho "Table_[lindex $data 7]" $mattemplate ;#RHO
            SetMatFieldValue $mat A1 "Table_[lindex $data 8]" $mattemplate ;#A1
            SetMatFieldValue $mat A2 "Table_[lindex $data 9]" $mattemplate ;#A2
            SetMatFieldValue $mat Xt "Table_[lindex $data 11]" $mattemplate ;#Xt
            SetMatFieldValue $mat Xc "Table_[lindex $data 12]" $mattemplate ;#Xc 
            SetMatFieldValue $mat Yc "Table_[lindex $data 14]" $mattemplate ;#Yc
            SetMatFieldValue $mat Yt "Table_[lindex $data 13]" $mattemplate ;#Yt
            SetMatFieldValue $mat S "Table_[lindex $data 15]" $mattemplate ;#S
            SetMatFieldValue $mat Ge "Table_[lindex $data 16]" $mattemplate ;#Ge
            SetMatFieldValue $mat F12 "Table_[lindex $data 17]" $mattemplate;#F12
            
            if { $newmat } {
                GiD_CreateData create material Orthotropic_Shell $mat $NastranPrivMat($mat)
            } else {
                GiD_ModifyData materials $mat $NastranPrivMat($mat)
            }
        }
        TABLEM2 { 
            set TID [lindex $data 0]
        }
        PARAM {
            set N [lindex $data 0]
            set V [lindex $data 1]
            switch $N {
                MULTBC - BODYLOAD - GPFORCE - MPCFORCE - INRELF - PELMCHK - PRGPST - 
                AUTOSPC - PRTGPST - BISECT  {
                    if { $V == "YES" ||  $V == "ON" || $V == "1" } {
                        GiD_AccessValue set gendata $N 1
                    } elseif { $V == "NO" || $V == "OFF" || $V == "0" } {
                        GiD_AccessValue set gendata $N 0
                    }
                }
                K6ROT - MAXRATIO - GRDPNT - WTMASS - IRES - SINGOPT - LGDISP {
                    GiD_AccessValue set gendata $N $V
                }
                G {
                    GiD_AccessValue set gendata Overall_Structural_Damping $V
                }
                COUPMASS {
                    GiD_AccessValue set gendata Mass_formulation $V
                }
                W3 {
                    GiD_AccessValue set gendat Frequency_for_System_Damping $V
                }
                W4 {
                    GiD_AccessValue set gendata Frequency_for_Element_Damping $V
                }
                LFREQ {
                    GiD_AccessValue set gendata First_frequency_(Hz) $V
                }
                HFREQ {
                    GiD_AccessValue set gendata Last_frequency_(Hz) $V
                }
                MODACC {
                    GiD_AccessValue set gendata IRES $V
                    
                }
                LANGLE {
                    if { $V == "1" } {
                        GiD_AccessValue set gendata $N GIMBAL
                    } elseif { $V == "2" } {
                        GiD_AccessValue set gendata $N ROTATION
                    }
                }
                NLINSOLACCEL {
                    if { $V == "4" } {
                        GiD_AccessValue set gendata $N 1
                    }
                }
                default {
                    WarnWinText [= "Warning: Ignored PARAM %s %s" $N $V]
                }
            }
        }
        PLOAD4 {
            set SID [lindex $data 0]
            set EID [lindex $data 1]
            set P1 [lindex $data 2]
            set P2 [lindex $data 3]
            set P3 [lindex $data 4]
            set P4 [lindex $data 5]
            set G1 [lindex $data 6]
            set G34 [lindex $data 7]
            #set CID [lindex $data 8]
            set N1 [lindex $data 9]
            set N2 [lindex $data 10]
            set N3 [lindex $data 11]
            
            if { $N1=="" } { 
                set cond Normal-Surface-Load
                set values $P1 ;#in GiD must be Normal_Inward pressure!!
            } else {
                set cond Surface-Pressure-Load
                set values [list [expr $P1*$N1] [expr $P1*$N2] [expr $P1*$N3]]
            }
            
            if { $P2 != "" && $P2 != $P1 || $P3 != "" && $P3 != $P1 || \
                $P4 != "" && $P4 != $P1 } {
                WarnWinText [= "Warning: PLOAD4 with different nodal pressure values. \
                Translated as %s condition with equal noded pressure in element %s" $cond $EID]
            }
            
            if { $SID < 1 } {
                WarnWinText [= "WARNING: %s unexpected value of SID='%s'" $type $SID]
            }
            if { [info exists NastranPrivLC($SID) ] } {
                GiD_IntervalData set $NastranPrivLC($SID)
            } else {
                set NastranPrivLC($SID) [GiD_IntervalData create]
                GiD_IntervalData set $NastranPrivLC($SID)
            }
            
            #GiD element implicit faces
            #Triangle: 12 23 31
            #Quadrilateral: 12 23 34 41
            #Tetrahedra: 123 243 341 421
            #Hexahedra: 1234 1562 2673 3784 1485 5876
            set iface 0
            set a [GiD_Info list_entities -more Elements $EID]
            regexp {Type=([^ ]*)[ ]*Nnode=([^ ]*)} $a dummy elemtype nnode
            switch $elemtype {
                Triangle {
                    set nassigned  [GiD_AssignData condition $cond body_elements $values $EID]
                    if { $nassigned <= 0 } {
                        WarnWinText [= "WARNING: condition %s can not be assigned to entity %s" $cond $values]
                    }
                }
                Quadrilateral {
                    set nassigned  [GiD_AssignData condition $cond body_elements $values $EID]
                    if { $nassigned <= 0 } {
                        WarnWinText [= "WARNING: condition %s can not be assigned to entity %s" $cond $values]
                    }
                }
                Tetrahedra {
                    set globalnodes [lrange $a 12 15]
                    set i [lsearch $globalnodes $G34]
                    if { $i == 0 } {
                        set iface 2
                    } elseif { $i == 1 } {
                        set iface 3
                    } elseif { $i == 2 } {
                        set iface 4
                    } elseif { $i == 3 } {
                        set iface 1
                    } else {
                        WarnWinText [= "Warning. $s: node %s not found in element %s" $type $G34 $EID]
                    }
                    if { $iface != "0" } {
                        set nassigned  [GiD_AssignData condition $cond face_elements $values "$EID $iface"]
                        if { $nassigned <= 0 } {
                            WarnWinText [= "WARNING: condition %s can not be assigned to entity %s" $cond $values]
                        }
                    }
                } 
                Hexahedra {
                    set globalnodes [lrange $a 12 17]
                    set i [lsearch $globalnodes $G34]
                    if { $i == 0 } {
                        set iface 2
                    } elseif { $i == 1 } {
                        set iface 3
                    } elseif { $i == 2 } {
                        set iface 4
                    } elseif { $i == 3 } {
                        set iface 5
                    }  elseif { $i == 4 } {
                        set iface 6
                    } elseif { $i == 5 } {
                        set iface 1
                    }
                    else {
                        WarnWinText [= "Warning. $s: node %s not found in element %s" $type $G34 $EID]
                    }
                    if { $iface != "0" } {
                        set nassigned  [GiD_AssignData condition $cond face_elements $values "$EID $iface"]
                        if { $nassigned <= 0 } {
                            WarnWinText [= "WARNING: condition %s can not be assigned to entity %s" $cond $values]
                        }
                    }
                }
            }
            default {
                WarnWinText [= "Warning. $s: Unexpected GiD element type %s" $type $elemtype]
            }
            LoadCaseManagment set 1
        }
        PROD {
            set NastranPrivProp(Fields,PROD) "Table PROPERTY Area_Cross_Section Torsional_Constant \
                Coeff._Torsional_Stress Nonstructural_mass/length Composition_Material"
            set NastranPrivProp(Defaults,PROD) [list 0 ROD 0.0 0.0 0.0 0.0 AISI_4340_STEEL]
            
            
            set PID [lindex $data 0]
            set MID [lindex $data 1]
            set  prop  "ROD_$PID"
            if { [lsearch $NastranPrivProp(Names) $prop] != "-1"} {
                set newprop 0
            } else {
                set newprop 1
                lappend NastranPrivProp(Names) $prop
                set mattemplate Rod
                set NastranPrivProp($prop) $NastranPrivProp(Defaults,PROD)
            }
            SetPropFieldValue $prop PROD Composition_Material "MAT_$MID"
            SetPropFieldValue $prop PROD Area_Cross_Section [lindex $data 2]
            SetPropFieldValue $prop PROD Torsional_Constant [lindex $data 3]
            SetPropFieldValue $prop PROD Coeff._Torsional_Stress [lindex $data 4]
            SetPropFieldValue $prop PROD Nonstructural_mass/length [lindex $data 5]
            if { $newprop } {
                GiD_CreateData create material $mattemplate $prop $NastranPrivProp($prop)
            } else {
                GiD_ModifyData materials $prop $NastranPrivProp($prop)
            }
        }
        PBAR - PBEAM {
            set PID [lindex $data 0]
            set MID [lindex $data 1]
            
            set prop "BAR_$PID"
            if { [lsearch $NastranPrivProp(Names) $prop] != "-1"} {
                set newprop 0
            } else {
                set newprop 1
                lappend NastranPrivProp(Names) $prop
                set mattemplate Bar
                set NastranPrivProp($prop) $NastranPrivProp(Defaults,PBAR)
            }
            SetPropFieldValue $prop PBAR Composition_Material "MAT_$MID"
            SetPropFieldValue $prop PBAR Area [lindex $data 2]
            SetPropFieldValue $prop PBAR I1 [lindex $data 3]
            SetPropFieldValue $prop PBAR I2 [lindex $data 4]
            SetPropFieldValue $prop PBAR Torsional_Constant [lindex $data 5]
            SetPropFieldValue $prop PBAR "Nonstructural_mass/lentgh" [lindex $data 6]
            SetPropFieldValue $prop PBAR "Values:(Y,Z)" "#N# 8 [lrange $data 8 15]"
            SetPropFieldValue $prop PBAR Y_Shear_Area [lindex $data 16]
            SetPropFieldValue $prop PBAR Z_Shear_Area [lindex $data 17] 
            SetPropFieldValue $prop PBAR I12 [lindex $data 18]
            if { $newprop } {
                GiD_CreateData create material $mattemplate $prop $NastranPrivProp($prop)
            } else {
                GiD_ModifyData materials $prop $NastranPrivProp($prop)
            }
        }
        PTUBE {
            set PID [lindex $data 0]
            set MID [lindex $data 1]
            set prop "PTUBE_$PID"
            if { [lsearch $NastranPrivProp(Names) $prop] != "-1"} {
                set newprop 0
            } else {
                set newprop 1
                lappend NastranPrivProp(Names) $prop
                set mattemplate Tube
                set NastranPrivProp($prop) $NastranPrivProp(Defaults,PTUBE)
            }
            SetPropFieldValue $prop PTUBE Composition_Material "MAT_$MID"
            SetPropFieldValue $prop PTUBE Outside_diameter_of_tube [lindex $data 2]
            if { [lindex $data 3] == 0.0 } {
                SetPropFieldValue $prop PTUBE Solid_Circular_Rod 1
            } else {
                SetPropFieldValue $prop PTUBE Solid_Circular_Rod 0
            }
            SetPropFieldValue $prop PTUBE Thickness_of_tube [lindex $data 3]
            SetPropFieldValue $prop PTUBE Nonstructural_mass/length [lindex $data 4]
            if { $newprop } {
                GiD_CreateData create material $mattemplate $prop $NastranPrivProp($prop)
            } else {
                GiD_ModifyData materials $prop $NastranPrivProp($prop)
            }
        }
        PPIPE {
            set PID [lindex $data 0]
            set MID [lindex $data 1]
            set prop "PPIPE_$PID"
            if { [lsearch $NastranPrivProp(Names) $prop] != "-1"} {
                set newprop 0
            } else {
                set newprop 1
                lappend NastranPrivProp(Names) $prop
                set mattemplate Pipe
                set NastranPrivProp($prop) $NastranPrivProp(Defaults,PPIPE)
            }
            SetPropFieldValue $prop PPIPE Outside_diameter_of_pipe [lindex $data 2]
            SetPropFieldValue $prop PPIPE Pipe_wall_thickness [lindex $data 3]
            SetPropFieldValue $prop PPIPE Internal_pressure [lindex $data 4]
            SetPropFieldValue $prop PPIPE End_condition [lindex $data 5]
            SetPropFieldValue $prop PPIPE Nonstructural_mass/length [lindex $data 6]
            SetPropFieldValue $prop PPIPE Composition_Material "MAT_$MID"
            if { $newprop } {
                GiD_CreateData create material $mattemplate $prop $NastranPrivProp($prop)
            } else {
                GiD_ModifyData materials $prop $NastranPrivProp($prop)
            }
        }
        PCABLE {
            set NastranPrivProp(Fields,PCABLE) "Table PROPERTY Initial_conditions Slack_U0 Tension_T0 Area_cross_section \
                Moment_of_Inertia Allowable_tensile_stress Composition_Material"
            set NastranPrivProp(Defaults,PCABLE) "0 CABLE cable_slack 0.0 0.0 0.0 0.0 0.0 AISI_4340_STEEL"
            
            set PID [lindex $data 0]
            set MID [lindex $data 1]
            set prop "PCABLE_$PID"
            if { [lsearch $NastranPrivProp(Names) $prop] != "-1"} {
                set newprop 0
            } else {
                set newprop 1
                lappend NastranPrivProp(Names) $prop
                set mattemplate Cable
                set NastranPrivProp($prop) $NastranPrivProp(Defaults,PCABLE)
            }
            if { [lindex $data 2] == "" } {
                SetPropFieldValue $prop PCABLE Initial_conditions "cable_tension"
            } else {
                SetPropFieldValue $prop PCABLE Initial_conditions "cable_slack"
            }
            SetPropFieldValue $prop PCABLE Slack_U0 [lindex $data 2]
            SetPropFieldValue $prop PCABLE Tension_T0 [lindex $data 3]
            SetPropFieldValue $prop PCABLE Area_cross_section [lindex $data 4]
            SetPropFieldValue $prop PCABLE Moment_of_Inertia [lindex $data 5]
            SetPropFieldValue $prop PCABLE Allowable_tensile_stress [lindex $data 6]
            SetPropFieldValue $prop PCABLE Composition_Material "MAT_$MID"
            if { $newprop } {
                GiD_CreateData create material $mattemplate $prop $NastranPrivProp($prop)
            } else {
                GiD_ModifyData materials $prop $NastranPrivProp($prop)
            }
        }
        PSHELL {
            set PID [lindex $data 0]
            set MID1 [lindex $data 1]
            set MID2 [lindex $data 3]
            set MID3 [lindex $data 5]
            set MID4 [lindex $data 10]
            set prop "PSHELL_$PID"
            if { [lsearch $NastranPrivProp(Names) $prop] != "-1"} {
                set newprop 0
            } else {
                set newprop 1
                lappend NastranPrivProp(Names) $prop
                set mattemplate Plate
                set NastranPrivProp($prop) $NastranPrivProp(Defaults,PSHELL)
            }
            if {$MID1!=0 && $MID1!=""} {set matnames MAT_$MID1} else { set matnames None-Ignore}
            if {$MID2!=0 && $MID2!=""} {lappend matnames MAT_$MID2} else { lappend matnames None-Ignore}
            if {$MID3!=0 && $MID3!=""} {lappend matnames MAT_$MID3} else { lappend matnames None-Ignore}
            if {$MID4!=0 && $MID4!=""} {lappend matnames MAT_$MID4} else { lappend matnames None-Ignore}
            SetPropFieldValue $prop PSHELL matid [base64::encode $matnames]
            if { [lindex $data 2] !=""} {SetPropFieldValue $prop PSHELL thick [lindex $data 2]}
            if { [lindex $data 4] !=""} {SetPropFieldValue $prop PSHELL bend [lindex $data 4]}
            if { [lindex $data 6] !=""} {SetPropFieldValue $prop PSHELL trans [lindex $data 6]}
            if { [lindex $data 7] !=""} {SetPropFieldValue $prop PSHELL nomass [lindex $data 7]}
            if {[lindex $data 8]!=""} {
                set stress [lindex $data 8]
            } else {
                set stress void
            }
            if {[lindex $data 9]!=""} {
                lappend stress [lindex $data 9]
            } else {
                lappend stress void
            }
            SetPropFieldValue $prop PSHELL stress [base64::encode $stress]
            set nastran [list [lindex $matnames 0] [lindex $data 2] [lindex $matnames 1] [lindex $data 4] [lindex $matnames 2] [lindex $data 6] \
                    [lindex $data 7] [lindex $data 8] [lindex $data 9] [lindex $matnames 3]]
            SetPropFieldValue $prop PSHELL nastran [base64::encode $nastran]
            if { $newprop } {
                GiD_CreateData create material $mattemplate $prop $NastranPrivProp($prop)
            } else {
                GiD_ModifyData materials $prop $NastranPrivProp($prop)
            }
        }
        PSOLID {
            set PID [lindex $data 0]
            set prop "PSOLID_$PID"
            if { [lsearch $NastranPrivProp(Names) $prop] != "-1"} {
                set newprop 0
            } else {
                set newprop 1
                set mattemplate Tetrahedron
                lappend NastranPrivProp(Names) $prop
                set NastranPrivProp($prop) $NastranPrivProp(Defaults,PSOLID)
            }
            
            SetPropFieldValue $prop PSOLID Composition_Material "MAT_[lindex $data 1]";#MID
            if { [lindex $data 2] == "0" } {  
                ;#MCID
                SetPropFieldValue $prop PSOLID Coord_System BASIC
            } else {
                SetPropFieldValue $prop PSOLID Coord_System ELEMENT
            }
            
            if { $newprop } {
                GiD_CreateData create material $mattemplate $prop $NastranPrivProp($prop)
            } else {
                GiD_ModifyData materials $prop $NastranPrivProp($prop)
            }
        }
        SPC1 {
            set SID [lindex $data 0]
            set C [lindex $data 1]
            
            regexp {(1)?(2)?(3)?(4)?(5)?(6)?} $C dummy g1 g2 g3 g4 g5 g6   
            set cond Point-Constraints
            set values ""
            foreach i {g1 g2 g3 g4 g5 g6} {
                if { [set $i] == "" } {
                    lappend values 0 
                } else {
                    lappend values 1
                }
            }
            if { $SID < 1 } {
                WarnWinText [= "WARNING: %s unexpected value of SID='%s'" $type $SID]
            }
            if { [info exists NastranPrivLC($SID) ] } {
                LoadCaseManagment set $NastranPrivLC($SID)
            } else {
                set NastranPrivLC($SID) [LoadCaseManagment create -1]
                LoadCaseManagment set $NastranPrivLC($SID)
            }           
            foreach node [lrange $data 2 end] {
                set nassigned [GiD_AssignData condition $cond nodes $values $node]
                if { $nassigned <= 0 } {
                    WarnWinText [= "WARNING: condition %s not assigned to entity %s" $cond $node]
                }
            }
            LoadCaseManagment set 1
            
        }
        SPC - SPCD {
            set SID [lindex $data 0]
            set G1 [lindex $data 1]
            set C1 [lindex $data 2]
            set D1 [lindex $data 3]
            
            regexp {(1)?(2)?(3)?(4)?(5)?(6)?} $C1 dummy g1 g2 g3 g4 g5 g6   
            if { $D1 != "" && $D1 != "0" } {        
                if { [lsearch $NastranPrivAnalysis "HEAT"] >= 0 }  {
                    set cond Point_Fixed_Temperature
                    set values $D1
                } else {
                    set cond Point-Enforced-Displacement
                    set values ""
                    foreach i {g1 g2 g3 g4 g5 g6} {
                        if { [set $i] == "" } {
                            lappend values 0 
                        } else {
                            lappend values $D1
                        }
                    }
                }
            } else {
                set cond Point-Constraints
                set values ""
                foreach i {g1 g2 g3 g4 g5 g6} {
                    if { [set $i] == "" } {
                        lappend values 0 
                    } else {
                        lappend values 1
                    }
                }
            }
            
            if { $SID < 1 } {
                WarnWinText [= "WARNING: %s unexpected value of SID='%s'" $type $SID]
            }
            if { [info exists NastranPrivLC($SID) ] } {
                LoadCaseManagment set $NastranPrivLC($SID)
            } else {
                set NastranPrivLC($SID) [LoadCaseManagment create -1]
                LoadCaseManagment set $NastranPrivLC($SID)
            }           
            set nassigned [GiD_AssignData condition $cond nodes $values $G1]
            if { $nassigned <= 0 } {
                WarnWinText [= "WARNING: condition %s not assigned to entity %s" $cond $G1]
            }
            LoadCaseManagment set 1
        }
        ENDDATA {
        }
        default {   
            if { ![info exists NastranPrivUnimplemented($type)] } {
                set NastranPrivUnimplemented($type) 1
            } else {
                incr NastranPrivUnimplemented($type)
            }
        }
    }
}

proc LoadCaseManagment { action SID } {
    global ProblemTypePriv NastranPrivLC
    switch $action {
        set {
            GiD_IntervalData set $SID
            set ProblemTypePriv(currentloadcase) [expr $SID]
            return $SID
        }
        create { 
            set loadcase [GiD_IntervalData create]
            lappend ProblemTypePriv(loadcasenames) "Load_case_[expr $loadcase-1]"
            #            lappend ProblemTypePriv(loadcasescombotext) ",Load Case [expr $loadcase-1]"
            return $loadcase
        }
        default {
            WarnWinText [= "procedure call with invalid action %s" $action].
        }
    }
}
