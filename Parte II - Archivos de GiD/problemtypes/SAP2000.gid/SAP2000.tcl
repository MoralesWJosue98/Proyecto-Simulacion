#######################################################################################
#GiD Raised events
#######################################################################################

proc InitGIDProject { dir } {    
    set SAP2000::_dir $dir   

    if { [info procs ReadProblemtypeXml] != "" } {
	#this procedure exists after GiD 11.1.2b
	set data [ReadProblemtypeXml [file join $dir SAP2000.xml] Infoproblemtype {Version MinimumGiDVersion}]		
    } else {
	#SAP2000::ReadProblemtypeXml is a copy of ReadProblemtypeXml to be able to work with previous GiD's
	set data [SAP2000::ReadProblemtypeXml [file join $dir SAP2000.xml] Infoproblemtype {Version MinimumGiDVersion}]
    }
    if { $data == "" } {
	WarnWinText [= "Configuration file %s not found" [file join $dir SAP2000.xml]]
	return 1
    }
    array set problemtype_local $data
    set SAP2000::VersionNumber $problemtype_local(Version)

    if { [GidUtils::VersionCmp $problemtype_local(MinimumGiDVersion)] < 0 } {  
	WarnWinText [= "This problemtype requires GiD %s or later" $problemtype_local(MinimumGiDVersion)]
    }

    GiD_DataBehaviour materials Isotropic geomlist {surfaces}     
    SAP2000::Splash
    SAP2000::ChangeMenus
}

proc EndGIDProject {} {
    SAP2000::RestoreMenus
}

proc ChangedLanguage { newlan } {
    SAP2000::ChangeMenus
}

proc LoadGIDProject { filespd } {        
    if { [file join {*}[lrange [file split $filespd] end-1 end]] == "SAP2000.gid/SAP2000.spd" } {
        #loading the problemtype itself, not a model
    } else {
        set pt [GiD_Info project ProblemType]
        if { $pt == "SAP2000" } {
            set filename [file rootname $filespd].xml
            set model_problemtype_version_number [SAP2000::ReadXml $filename]            
            if { $model_problemtype_version_number != -1 && $model_problemtype_version_number < $::SAP2000::VersionNumber } {            
                set must_transform 1
            } else {
                set must_transform 0
            }
            if { $must_transform } {
                after idle [list SAP2000::Transform $model_problemtype_version_number $::SAP2000::VersionNumber]
            }
        }
    }
}

proc SaveGIDProject { filespd } {
    set filename [file rootname $filespd].xml
    SAP2000::SaveXml $filename
}

#to automatically convert the file _res.s2k to .post.res if it was exported from SAP2000 with this name
proc AfterRunCalculation { basename dir problemtypedir where error errorfilename } {
    if { $error == 0 } {
        set filename [file join [lindex $dir 0] $basename]_res.s2k
        if { [file exists $filename] } {
            SAP2000::ConvertSAP2000ResultsToGiD $filename
        }
    }
    return 0
}


#######################################################################################
#SAP2000 namespace procedures
#######################################################################################

namespace eval SAP2000 {
    variable ProgramName SAP2000
    variable VersionNumber ;#interface version, get it from xml to avoid duplication
    variable _dir ;#path to the problemtype
}

proc SAP2000::SaveXml { filename } {
    variable ProgramName
    variable VersionNumber
    set fp [open $filename w]
    if { $fp != "" } {
        puts $fp {<?xml version='1.0' encoding='utf-8'?><!-- -*- coding: utf-8;-*- -->}
        puts $fp "<$ProgramName version='$VersionNumber'/>"
        close $fp
    }
}

#return -1 if the xml is not an SAP2000 one or if the xml not exists
#        the SAP2000 version of the model of the xml file
proc SAP2000::ReadXml { filename } {
    variable ProgramName
    set model_problemtype_version_number -1
    if { [file exists $filename] } {
        set fp [open $filename r]
        if { $fp != "" } {
            set line ""
            gets $fp header
            gets $fp line ;#something like: <SAP2000 version='1.0'/>
            close $fp
            set line [string range $line 1 end-2]
            set model_problemtype [lindex $line 0]
            if { $model_problemtype == $ProgramName } {
                set model_version [lindex $line 1]
                if { [lindex [split $model_version =] 0] == "version" } {
                    set model_problemtype_version_number [string range [lindex [split $model_version =] 1] 1 end-1]
                }
            } else {
                set model_problemtype_version_number -1
            }
        }
    }
    return $model_problemtype_version_number
}

proc SAP2000::Transform { from_version to_version } {    
    variable ProgramName
    GiD_Process escape escape escape escape Data Defaults TransfProblem $ProgramName escape    
}

#this procedure is a copy of ReadProblemtypeXml to be able to work with previous GiD's
proc SAP2000::ReadProblemtypeXml { xmlfile root_name fields } {
    set res {}
    if { [file exists $xmlfile] && [file isfile $xmlfile]} {
	package require tdom    
	set xml [tDOM::xmlReadFile $xmlfile]
	set doc [dom parse $xml]
	set root [$doc documentElement]  
	if { $root_name == "" || [$root nodeName] == $root_name} {
	    #set file_version [$root getAttribute version]
	    if { $fields == "" } {
		set fields ""
		foreach node [$root selectNodes Program/*] {
		    lappend fields [$node nodeName]
		}
	    } 
	    foreach field $fields {
		set node [$root select Program/$field]
		if {$node ne ""} {
		    set value [$node text]
		} else {
		    set value ""
		}     
		lappend res $field $value
	    }
	}
	$doc delete
    }
    return $res
}

proc SAP2000::ChangeMenus {} {
    variable ProgramName
    ::GiDMenu::Create SAP2000 PREPOST -1
    ::GiDMenu::InsertOption SAP2000 [list [= "Help on SAP2000"]...] 0 PREPOST {GiDCustomHelp -start "SAP_toc.html"} "" "" replace =   
#     GiDMenu::InsertOption "Files#C#menu" [list "Import#C#menu" [= "SAP2000 mesh#C#menu"]...] 9 PRE \
#                 SAP2000::ImportSAP2000Mesh_win "" "" "insert"
    ::GiDMenu::InsertOption SAP2000 [list [= "Import SAP2000 mesh"]...] 1 PRE SAP2000::ImportSAP2000Mesh_win "" "" replace =
    ::GiDMenu::InsertOption SAP2000 [list [= "Convert SAP2000 results"]...] 2 PRE SAP2000::ConvertSAP2000ResultsToGiD_win "" "" replace =
    ::GiDMenu::InsertOption SAP2000 [list [= "Export VRML file"]...] 3 POST VRML::CreateVRMLfile_win "" "" replace =
    ::GiDMenu::InsertOption SAP2000 [list [concat [= "About"] $ProgramName ...]] 4 PREPOST SAP2000::About "" "" replace =
    ::GiDMenu::UpdateMenus
}

proc SAP2000::RestoreMenus {} {
    ::GiDMenu::Delete SAP2000 PRE 
    ::GiDMenu::UpdateMenus
}

proc SAP2000::Splash { {self_close 1} } {
    variable _dir
    set prev_splash_state [GiD_Set SplashWindow]
    GiD_Set SplashWindow 1 ;#set temporary to 1 to force show splash without take care of the GiD splash preference
    set txt "$SAP2000::ProgramName Version $SAP2000::VersionNumber"
    append txt \n\n[= "Interface developed by: %s\n updated by %s" "Francisco Muñoz, Fernando Peña, Miguel Meza" "Enrique Escolano (CIMNE)"]
    ::GidUtils::Splash [file join $SAP2000::_dir images splash.png] .splash $self_close \
                [list $txt 30 250]
    GiD_Set SplashWindow $prev_splash_state
}

proc SAP2000::About { } {
    set self_close 0
    SAP2000::Splash $self_close
}    

# Import mesh from .s2k SAP2000 file
proc SAP2000::ImportSAP2000Mesh_win { } {    
    #User introduce the path of a SAP2000 file    
    set types [list [list [= "SAP2000 file"] ".s2k"]]     
    set filename [Browser-ramR file read .gid [= "SAP2000 file read"] "" $types]    
    if { $filename != "" } {
        SAP2000::ImportSAP2000Mesh $filename
        GidUtils::SetWarnLine [= "File read"]
        GiD_Process MEscape Meshing MeshView
    }
    return 1
}

proc SAP2000::ImportSAP2000Mesh { filename } {   
    #General structure of the reading process    
    if { [catch { set fileid [open $filename r] }] } {
        return 0
    }
    while { ![eof $fileid] } {
        set read_line [string trim [gets $fileid]]
        if { $read_line == "END TABLE DATA" } {
            break
        }
        if { [catch { set item [lindex $read_line 0] } ] } { continue }
        switch -- $item {
            TABLE: {
                if { [catch { set table [lindex $read_line 1] } ] } { continue }                
                if {$table == "JOINT COORDINATES"} {                 
                    SAP2000::_ReadJointCoordinates $fileid  
                } elseif {$table == "CONNECTIVITY - FRAME"} {            
                    SAP2000::_ReadConnectivityLinear $fileid Frame
                } elseif {$table == "CONNECTIVITY - CABLE"} {            
                    SAP2000::_ReadConnectivityLinear $fileid Cable
                } elseif {$table == "CONNECTIVITY - LINK"} {            
                    SAP2000::_ReadConnectivityLinear $fileid Link
                } elseif {$table == "CONNECTIVITY - TENDON"} {            
                    SAP2000::_ReadConnectivityLinear $fileid Tendon
                } elseif {$table == "CONNECTIVITY - AREA"} {          
                    SAP2000::_ReadConnectivityArea $fileid   
                } elseif {$table == "CONNECTIVITY - SOLID"} {                 
                    SAP2000::_ReadConnectivitySolid $fileid   
                } else {
                    #WarnWinText "ImportSAP2000Mesh: Unexpected case"
                }           
            }
        }
    }    
    close $fileid    
    return 1    
}

proc SAP2000::_ReadJointCoordinates { fileid } {        
    #read_line sample:
    #Joint=1   CoordSys=GLOBAL   CoordType=Cylindrical   XorR=864   T=90   Z=0   SpecialJt=No   GlobalX=5.29029944851267E-14   GlobalY=864   GlobalZ=0
    while { ![eof $fileid] } {   
        set read_line [string trim [gets $fileid]]
        if { [string index $read_line 0] == {$} } {
            continue
        }
        if { $read_line == "" } {
            break
        }
        array set V [string map "= { }" $read_line]
        if { [info exists V(GlobalX)] } {
            GiD_Mesh create node $V(Joint) "$V(GlobalX) $V(GlobalY) $V(GlobalZ)"                 
        } elseif { [info exists V(XorR)] } {
            if { $V(CoordType) == "Cartesian" && $V(CoordSys) == "GLOBAL"} {
                GiD_Mesh create node $V(Joint) "$V(XorR) $V(Y) $V(Z)"
            } else {
                WarnWinText "ReadJointCoordinates: Only implemented CoordType=Cartesian and CoordSys=GLOBAL"
                return 1
            }
        } else {
            WarnWinText "ReadJointCoordinates: Unexpected case"
            return 1           
        }
        
    }   
    return 0   
}

#type could be Frame, Cable
proc SAP2000::_ReadConnectivityLinear { fileid type} {
    #read_line sample:
    
    while { ![eof $fileid] } {   
        set read_line [string trim [gets $fileid]]
        if { [string index $read_line 0] == {$} } {
            continue
        }
        if { $read_line == "" } {
            break
        }        
        array set V [string map "= { }" $read_line]
        GiD_Mesh create element $V($type) linear 2 "$V(JointI) $V(JointJ)"
    }
    return 0;
}

proc SAP2000::_ReadConnectivityArea { fileid } {
    #read_line sample:
    
    while { ![eof $fileid] } {   
        set read_line [string trim [gets $fileid]]
        if { [string index $read_line 0] == {$} } {
            continue
        }
        if { $read_line == "" } {
            break
        }        
        array set V [string map "= { }" $read_line]
        if { ![info exists V(NumJoints)] } {
            if { [info exists V(Joint4)] } {
                set V(NumJoints) 4
            } else {
                set V(NumJoints) 3
            }
        }
        if { $V(NumJoints) == 3 } {
            GiD_Mesh create element $V(Area) triangle 3 "$V(Joint1) $V(Joint2) $V(Joint3)"
        } elseif { $V(NumJoints) == 4 } {
            GiD_Mesh create element $V(Area) quadrilateral 4 "$V(Joint1) $V(Joint2) $V(Joint3) $V(Joint4)"
        } else {
            WarnWinText "ReadConnectivityArea: Unexpected NumJoints"            
            return 1
        }
        
    }
    return 0;        
}


proc SAP2000::_ReadConnectivitySolid { fileid } {    
    #read_line sample:
    #Solid=1   Joint1=1   Joint2=2   Joint3=3   Joint4=4   Joint5=5   Joint6=6   Joint7=7   Joint8=8   Volume=9557820.93994232   CentroidX=311.161267687229   CentroidY=751.209752535714   CentroidZ=240
    while { ![eof $fileid] } {   
        set read_line [string trim [gets $fileid]]
        if { [string index $read_line 0] == {$} } {
            continue
        }
        if { $read_line == "" } {
            break
        }        
        array set V [string map "= { }" $read_line]
        GiD_Mesh create element $V(Solid) hexahedra 8 \
            "$V(Joint1) $V(Joint2) $V(Joint4) $V(Joint3) $V(Joint5) $V(Joint6) $V(Joint8) $V(Joint7)"
    }       
    return 0;
}


# Create .post.res GiD postprocess results file from .s2k SAP2000 file

proc SAP2000::ConvertSAP2000ResultsToGiD_win {} { 
    set types [list [list [= "SAP2000 file"] ".s2k"] [list [_ "All files"] ".*"]]
    set defaultextension .s2k
    set filename [Browser-ramR file read .gid [= "Read SAP2000"] "" $types $defaultextension 0]
    if { $filename != "" } {
        ::GidUtils::WaitState .gid
        SAP2000::ConvertSAP2000ResultsToGiD $filename   
        ::GidUtils::EndWaitState .gid
        ::GidUtils::SetWarnLine [= "SAP2000 file read. It is possible to postprocess now"]        
    }
}

#auxiliary procedure to read one line of the file
proc SAP2000::_ReadLine { fin } {
    set read_line [string trim [gets $fin]]
    while { [string index $read_line end] == {_} } {
        #it is a continuation line
        set read_line [string range $read_line 0 end-1]
        append read_line [string trim [gets $fin]]
    }
    if { [string index $read_line 0] == {$} } {
        #it is a commented line, try to get the next one
        set read_line [SAP2000::_ReadLine $fin]
    }
    return $read_line
}

#auxiliary procedure to read one result
proc SAP2000::_ReadResult { fin fout load_case type on result_maps } {
    if { $on == "Joint" } {
      set over OnNodes
    } elseif { $on == "Area" } {
        set over OnGaussPoints
    } elseif { $on == "Solid" } {
        set over OnGaussPoints
    } else {
        set over ""
    }
    while { ![eof $fin] } {   
        set read_line [SAP2000::_ReadLine $fin]
        if { $read_line == "" } {
            break                    
        }
        array unset -nocomplain V
        array set V [string map "= { }" $read_line]
        foreach item $result_maps {
            lassign $item letter name
            set id $V($on)
            if { $over == "OnGaussPoints" } {
                if { [info exists Res($id,$letter,$V(Joint))] } {
                    #repeated node (tetrahedron as degenerated hexahedron)
                    continue 
                } else {
                    set Res($id,$letter,$V(Joint)) 1
                }
                if { [info exists Elem($id,$letter)] } {
                    #to print only once the element id for each gauss point
                    set id ""
                } else {
                    set Elem($id,$letter) 1
                }
            }
            if { $type == "Scalar" } {
                append values($name) "$id $V(${letter})\n"
            } elseif { $type == "Vector" } {
                append values($name) "$id $V(${letter}1) $V(${letter}2) $V(${letter}3)\n"
            } elseif { $type == "Matrix" } {
                append values($name) "$id $V(${letter}11) $V(${letter}22) $V(${letter}33) $V(${letter}12) $V(${letter}23) $V(${letter}13)\n"
            } elseif { $type == "PlainDeformationMatrix" } {
                append values($name) "$id $V(S11${letter}) $V(S22${letter}) $V(S12${letter}) 0.0\n"
            } else {
            }
        }
    }  
    if { [info exists V(OutputCase)] } {
        #set analysis $V(OutputCase)
        set analysis Static
    } else {
        set analysis Static
    }
    foreach item $result_maps {
        lassign $item letter name
        puts $fout ""
        if { $over == "OnGaussPoints" } {
            puts $fout "Result $name $analysis $load_case $type $over GP"
        } else {
            puts $fout "Result $name $analysis $load_case $type $over"
        }
        puts $fout Values 
        puts -nonewline $fout $values($name)
        puts $fout "End values"
    }
    unset -nocomplain values
}

proc SAP2000::ConvertSAP2000ResultsToGiD { filename } {    
    if { $filename == "" } { 
        return 
    }
    if { ![file exists $filename] }  {
        return
    }
    
    set ProjectName [GiD_Info Project ModelName]
    if { [file extension $ProjectName] == ".gid" } {
        set ProjectName [file root $ProjectName]
    }    
    set basename [file tail $ProjectName]
    if { $ProjectName == "UNNAMED" } {
        WarnWin [= "Before Reading SAP2000, a project title is needed. Save project to get it"]
        return
    }
    
    set directory $ProjectName.gid
    if { [file pathtype $directory] == "relative" } {
        set directory [file join [pwd] $directory]
    }
    
    set postfile [file join $directory $basename.post.res]
    
    set fin [open $filename r]
    set fout [open $postfile w]
    
    puts $fout "GiD Post Results File 1.0"
    puts $fout " "    
    if { [GiD_Info mesh NumElements Triangle] > 0 } {
        set element_type "Triangle"
    } elseif { [GiD_Info mesh NumElements Quadrilateral] > 0 } { 
        set element_type "Quadrilateral"
    } elseif { [GiD_Info mesh NumElements Hexahedra] > 0 } { 
        set element_type "Hexahedra"
    } elseif { [GiD_Info mesh NumElements Tetrahedra] > 0 } { 
        set element_type "Tetrahedra"
    } else {
        set element_type ""
    }
    if { [string compare $element_type "Quadrilateral"] == 0 } {
        puts $fout {GaussPoints GP ElemType Quadrilateral}
        puts $fout " Number Of Gauss Points: 4"
        puts $fout " Natural Coordinates: given"
        puts $fout "-1.0 -1.0"
        puts $fout " 1.0 -1.0"
        puts $fout " 1.0  1.0"
        puts $fout "-1.0  1.0"
        puts $fout "End gausspoints"
    } elseif { [string compare $element_type "Triangle"] == 0 } {
        puts $fout {GaussPoints GP ElemType Triangle}
        puts $fout " Number Of Gauss Points: 3"
        puts $fout " Natural Coordinates: given"
        puts $fout "0.0 0.0"
        puts $fout "1.0 0.0"
        puts $fout "0.0 1.0"
        puts $fout "End gausspoints"
    } elseif { [string compare $element_type "Hexahedra"] == 0 } {
        puts $fout {GaussPoints GP ElemType Hexahedra}
        puts $fout " Number Of Gauss Points: 8"
        puts $fout " Natural Coordinates: given"
        puts $fout "-1.0 -1.0 -1.0"
        puts $fout " 1.0 -1.0 -1.0"
        puts $fout " 1.0  1.0 -1.0"
        puts $fout "-1.0  1.0 -1.0"
        puts $fout "-1.0 -1.0  1.0"
        puts $fout " 1.0 -1.0  1.0"
        puts $fout " 1.0  1.0  1.0"
        puts $fout "-1.0  1.0  1.0"
        puts $fout "End gausspoints"
    } elseif { [string compare $element_type "Tetrahedra"] == 0 } {
        puts $fout {GaussPoints GP ElemType Tetrahedra}
        puts $fout " Number Of Gauss Points: 4"
        puts $fout " Natural Coordinates: given"
        puts $fout "0.0 0.0 0.0"
        puts $fout "1.0 0.0 0.0"
        puts $fout "0.0 1.0 0.0"
        puts $fout "0.0 0.0 1.0"
        puts $fout "End gausspoints"
    } else {
    }
    
    set load_case 1
    
    while { ![eof $fin] } {
        set read_line [string trim [gets $fin]]
        if { $read_line == "END TABLE DATA" } {
            break
        }
        if { [catch { set item [lindex $read_line 0] } ] } { 
            continue 
        }
        if { [string toupper $item] != "TABLE:" } {
            continue
        }
        if { [catch { set table [lindex $read_line 1] } ] } { 
            continue 
        } 
        if { $table == "JOINT DISPLACEMENTS" } {
            SAP2000::_ReadResult $fin $fout $load_case Vector Joint {{U Displacements} {R Rotations}}
        } elseif { $table == "JOINT REACTIONS" } {            
            SAP2000::_ReadResult $fin $fout $load_case Vector Joint {{F Reaction_forces} {M Reaction_moments}}
        } elseif { $table == "ASSEMBLED JOINT MASSES" } {            
            SAP2000::_ReadResult $fin $fout $load_case Vector Joint {{U Assembled_masses}}
        } elseif { $table == "ELEMENT FORCES - AREA SHELLS" } {
            set result_maps ""
            lappend result_maps {F11 Axial_force//Fx'} {F22 Axial_force//Fy'} {F12 Axial_force//Fxy'}
            lappend result_maps {M11 Momentus//Mx'} {M22 Momentus//My'} {M12 Momentus//Mxy'}
            lappend result_maps {V13 Shear//Qx'} {V23 Shear//Qy'}
            SAP2000::_ReadResult $fin $fout $load_case Scalar Area $result_maps
        } elseif { $table == "ELEMENT STRESSES - AREA SHELLS" } {
            # can't use PlainDeformationMatrix because plane stresses are in local coordinates
            # set result_maps {{Top Stresses_Top} {Bot Stresses_Bottom}}
            # SAP2000::_ReadResult $fin $fout $load_case PlainDeformationMatrix Area $result_maps
            set result_maps ""
            lappend result_maps {S11Top Stresses_Top//Sx'} {S22Top Stresses_Top//Sy'} {S12Top Stresses_Top//Sxy'}
            lappend result_maps {SMaxTop Stresses_Top//Smax} {SMinTop Stresses_Top//Smin}
            lappend result_maps {S11Bot Stresses_Bottom//Sx'} {S22Bot Stresses_Bottom//Sy'} {S12Bot Stresses_Bottom//Sxy'}
            lappend result_maps {SMaxBot Stresses_Bottom//Smax} {SMinBot Stresses_Bottom//Smin}
            SAP2000::_ReadResult $fin $fout $load_case Scalar Area $result_maps
        } elseif { $table == "ELEMENT STRESSES - SOLIDS" } {
            SAP2000::_ReadResult $fin $fout $load_case Matrix Solid {{S Stresses}}
        } elseif { $table == "ELEMENT JOINT FORCES - AREAS" } {
            #ignore this result            
            #SAP2000::_ReadResult $fin $fout $load_case Vector Area {{F Joint_forces} {M Joint_moments}}
        } elseif { $table == "ELEMENT JOINT FORCES - SOLIDS" } {
            #ignore this result            
            #SAP2000::_ReadResult $fin $fout $load_case Vector Solid {{F Joint_forces} {M Joint_moments}}
        } elseif { $table == "OBJECTS AND ELEMENTS - JOINTS" } {
            #ignore this result, are the node coordinates            
        } elseif { $table == "OBJECTS AND ELEMENTS - AREAS" } {
            #ignore this result, are the element connectivities            
        } elseif { $table == "OBJECTS AND ELEMENTS - SOLIDS" } {
            #ignore this result, are the element connectivities                        
        } elseif { $table == "BASE REACTIONS" } {
            #this are two global vectors of integrated reaction forces and moments
        } else {
        }
    }
    
    close $fin
    close $fout    
}

#######################################################################################
#  VRML namespace (use other namespace because it is really independent of SAP2000)
#######################################################################################

namespace eval VRML {
    variable VRMLOptions
}

proc VRML::CreateVRMLfile_win {} {
    variable VRMLOptions
    
    set w .gid.vrml_results
    InitWindow $w [= "VRML results export"] VRMLResultsExportWindowGeom VRML::CreateVRMLfile_win
    if { ![winfo exists $w] } return ;# windows disabled || usemorewindows == 0

    set f [ttk::frame $w.f]
    
    
    set values ""
    set labels ""        
    set result_analysis [GiD_Info postprocess get cur_analysis]
    set step_value [GiD_Info postprocess get cur_step] 
    set results [GiD_Info postprocess get cur_results_list contour_fill]
    foreach result_name $results {
        set result_id [list $result_name $result_analysis $step_value] 
        set header [GiD_Result get -info $result_id]
        if { [lindex [lindex $header 0] 5] == "OnNodes" } {
            set over nodes
        } else {
            set over elements
        }
        set type [lindex [lindex $header 0] 4]
        set count 0
        if { $type == "Scalar" } {
            lappend values [list $result_name 0]
            lappend labels [= $result_name]            
        } elseif { $type == "Vector" } {
            foreach i [GiD_Info postprocess get cur_components_list $result_name] {
                lappend values [list $result_name $count]
                lappend labels [= $i]
                incr count
            }
        } elseif { $type == "Matrix" } {
            foreach i [GiD_Info postprocess get cur_components_list $result_name] {
                lappend values [list $result_name $count]
                lappend labels [= $i]
                incr count
            }
        } else {
        }
    }    
    
    set item Result_to_export
    set text [= "Result to export"]
    set default [lindex $values 0]
    set widget combobox
    if { ![info exists ::VRML::VRMLOptions($item)] } {
        set ::VRML::VRMLOptions($item) $default
    }
    ttk::label $f.l$item -text $text
    TTKComboBox $f.e$item -textvariable ::VRML::VRMLOptions($item) -labels $labels -values $values -state readonly
    grid $f.l$item $f.e$item -sticky ew -padx 2
    
    set item Lower_limit
    set text [= "Lower limit"]
    set default -10
    set widget entry
    if { ![info exists ::VRML::VRMLOptions($item)] } {
        set ::VRML::VRMLOptions($item) $default
    }
    ttk::label $f.l$item -text $text
    ttk::$widget $f.e$item -textvariable ::VRML::VRMLOptions($item)    
    grid $f.l$item $f.e$item -sticky ew -padx 2
    
    set item Upper_limit
    set text [= "Upper limit"]
    set default 10
    set widget entry
    if { ![info exists ::VRML::VRMLOptions($item)] } {
        set ::VRML::VRMLOptions($item) $default
    }
    ttk::label $f.l$item -text $text
    ttk::$widget $f.e$item -textvariable ::VRML::VRMLOptions($item)    
    grid $f.l$item $f.e$item -sticky ew -padx 2
    
    set item Base_Model
    set text [= "Base Model"]
    set values {X-Y X-Z}
    set labels $values
    set default X-Z
    set widget combobox
    if { ![info exists ::VRML::VRMLOptions($item)] } {
        set ::VRML::VRMLOptions($item) $default
    }
    ttk::label $f.l$item -text $text
    TTKComboBox $f.e$item -textvariable ::VRML::VRMLOptions($item) -labels $labels -values $values -state readonly
    grid $f.l$item $f.e$item -sticky ew -padx 2
    
    set item Coord_centre_base_model
    set text [= "Coord centre base model"]
    set default 0,0,0
    set widget entry
    if { ![info exists ::VRML::VRMLOptions($item)] } {
        set ::VRML::VRMLOptions($item) $default
    }
    ttk::label $f.l$item -text $text
    ttk::$widget $f.e$item -textvariable ::VRML::VRMLOptions($item)    
    grid $f.l$item $f.e$item -sticky ew -padx 2

    set item Factor_scale_Model
    set text [= "Factor scale Model"]
    set default 1
    set widget entry
    if { ![info exists ::VRML::VRMLOptions($item)] } {
        set ::VRML::VRMLOptions($item) $default
    }
    ttk::label $f.l$item -text $text
    ttk::$widget $f.e$item -textvariable ::VRML::VRMLOptions($item)    
    grid $f.l$item $f.e$item -sticky ew -padx 2
    
    set item Scale_color_number
    set text [= "Scale color number"]
    set default 11
    set widget entry
    if { ![info exists ::VRML::VRMLOptions($item)] } {
        set ::VRML::VRMLOptions($item) $default
    }
    ttk::label $f.l$item -text $text
    ttk::$widget $f.e$item -textvariable ::VRML::VRMLOptions($item)    
    grid $f.l$item $f.e$item -sticky ew -padx 2
    
    
    ttk::frame $w.buts -style BottomFrame.TFrame    
    ttk::button $w.buts.ok -text [= "Export"] -command VRML::CreateVRMLfile -underline 0 -style BottomFrame.TButton
    ttk::button $w.buts.cn -text [= "Close"] -command [list  destroy $w] -underline 0 -style BottomFrame.TButton
    grid $w.buts.ok $w.buts.cn -padx 5 -pady 5    
    focus $w.buts.ok            
    
    grid $f -sticky nsew
    grid $w.buts -sticky sew
    if { $::tcl_version >= 8.5 } { grid anchor $w.buts center }

    grid rowconfigure $w 0 -weight 1
    grid columnconfigure $w 0 -weight 1
    bind $w <Escape> "$w.buts.cn invoke"
    
    VRML::ChangeResultToExport ;#to fill values

    trace add variable ::VRML::VRMLOptions(Result_to_export) write "::VRML::ChangeResultToExport"
    bind $w <Destroy> [list +VRML::DestroyVRMLResultsExportWindow %W $w]
}

proc VRML::DestroyVRMLResultsExportWindow { W w } {
    if { $W != $w } return
    variable VRMLOptions
    trace remove variable ::VRML::VRMLOptions(Result_to_export) write "::VRML::ChangeResultToExport"
}


proc VRML::ChangeResultToExport { args } {
    variable VRMLOptions
    
    set result_analysis [GiD_Info postprocess get cur_analysis]
    set step_value [GiD_Info postprocess get cur_step]
   
    lassign $VRMLOptions(Result_to_export) result_name result_component_index
    set result_id [list $result_name $result_analysis $step_value] 
    set min [lindex [GiD_Result get -min $result_id] $result_component_index]
    set max [lindex [GiD_Result get -max $result_id] $result_component_index]
    set ::VRML::VRMLOptions(Lower_limit) $min
    set ::VRML::VRMLOptions(Upper_limit) $max    
}

# export VRML file from current select result
proc VRML::CreateVRMLfile { } {
    variable VRMLOptions    
    
    set ProjectName [GiD_Info Project ModelName]
    set basename [file tail $ProjectName]
    set postfile2 [file join ${ProjectName}.gid $basename.wrl]
        
                   
    lassign $VRMLOptions(Result_to_export) result_name result_component_index
    set lower_limit $VRMLOptions(Lower_limit)
    set upper_limit $VRMLOptions(Upper_limit)
    set basem $VRMLOptions(Base_Model)
    lassign [split $VRMLOptions(Coord_centre_base_model) ,] cxcm cycm czcm
    set fscm $VRMLOptions(Factor_scale_Model)
    set scl $VRMLOptions(Scale_color_number)
    
    set result_analysis [GiD_Info postprocess get cur_analysis]
    set step_value [GiD_Info postprocess get cur_step] 
    set result_id [list $result_name $result_analysis $step_value]    

    set ii $result_name
    
    #Results_for_VRML
    
    if { $scl < 2 } { set scl 2 }
    set upper_limit [expr {$upper_limit*1.0}]
    set lower_limit [expr {$lower_limit*1.0}]
    set itvlo [expr {($upper_limit-$lower_limit)/$scl}]
    set scl2 [expr {11./$scl}]
    
    set cxcm [ expr { (-1)*$cxcm } ]
    set cycm [ expr { (-1)*$cycm } ]
    set czcm [ expr { (-1)*$czcm } ]
    set rtcn -3.14
    if { [string compare $basem "X-Y"] == 0 } { 
        set rtcn 1.57
        set bas4 $cycm
        set cycm $czcm
        set czcm $bas4 
    }
        
    set fout2 [open $postfile2 w]    
    if { $fout2 != "" } {    
        set crc1 "{"
        set crc2 "}"
        set crc3 {[}
        set crc4 {]}
        set crc5 {"END"}
        
        puts $fout2 "#VRML V2.0 utf8"
        puts $fout2 ""
        puts $fout2 "Collision $crc1"
        puts $fout2 "children"
        puts $fout2 "Group $crc1"
        puts $fout2 "children $crc3"
        puts $fout2 "DEF top_view Viewpoint $crc1"
        puts $fout2 "position 0 0 -20.00"
        puts $fout2 "orientation 1.0 0.0 0.0 3.14  # tenia un 3.14 al final"
        puts $fout2 "fieldOfView 0.387763"
        puts $fout2 {description "Lateral"}
        puts $fout2 "$crc2,"
        puts $fout2 "DEF back_view Viewpoint $crc1"
        puts $fout2 "position 0 -25.0 0"
        puts $fout2 "orientation -1.0 0.0 0.0 4.71"
        puts $fout2 "fieldOfView 0.387763"
        puts $fout2 {description "Arriba"}
        puts $fout2 "$crc2,"
        puts $fout2 "DEF front_light DirectionalLight $crc1"
        puts $fout2 "ambientIntensity  .1            #   exposedField SFFloat"
        puts $fout2 "color             1 1 1         #   exposedField SFColor"
        puts $fout2 "direction         0 0 -1        #   exposedField SFVec3f"
        puts $fout2 "intensity         .5        #   exposedField SFFloat"
        puts $fout2 "on                TRUE          #   exposedField SFBool"
        puts $fout2 "$crc2,"
        puts $fout2 "DEF side_light DirectionalLight $crc1"
        puts $fout2 "ambientIntensity  .1            #   exposedField SFFloat"
        puts $fout2 "color             1 1 1         #   exposedField SFColor"
        puts $fout2 "direction         -1 0 0        #   exposedField SFVec3f"
        puts $fout2 "intensity         .5        #   exposedField SFFloat"
        puts $fout2 "on                TRUE          #   exposedField SFBool"
        puts $fout2 "$crc2,"
        puts $fout2 "DEF top_light DirectionalLight $crc1"
        puts $fout2 "ambientIntensity  .1            #   exposedField SFFloat"
        puts $fout2 "color             1 1 1         #   exposedField SFColor"
        puts $fout2 "direction         0 -1 0        #   exposedField SFVec3f"
        puts $fout2 "intensity         .5        #   exposedField SFFloat"
        puts $fout2 "on                TRUE          #   exposedField SFBool"
        puts $fout2 "$crc2,"
        puts $fout2 "NavigationInfo $crc1"
        puts $fout2 "headlight TRUE"
        puts $fout2 {type [ "WALK", "ANY" ]}
        puts $fout2 {avatarSize [ 0.25, 1.6, 0.75 ]}
        puts $fout2 "$crc2,"
        puts $fout2 "WorldInfo $crc1"
        puts $fout2 "$crc2,"
        puts $fout2 "Group $crc1 children $crc3"
        puts $fout2 "Background $crc1"
        puts $fout2 {groundAngle  [1.57]         #   exposedField MFFloat}
        puts $fout2 {groundColor  [0.67 1.00 1.00, 0.67 1.00 1.00]        #   exposedField MFColor}
        puts $fout2 {skyAngle     [1.57]         #   exposedField MFFloat}
        puts $fout2 {skyColor     [0.67 1.00 1.00, 0.67 1.00 1.00 ]    #   exposedField MFColor}
        puts $fout2 "$crc2,"
        puts $fout2 "Group $crc1 #GROUP DE EJES"
        puts $fout2 "children $crc3"
        puts $fout2 "Transform $crc1     # Plano base"
        puts $fout2 "translation     0.0 0.1 0     # exposedField SFVec3f"
        puts $fout2 "children"
        puts $fout2 "$crc3"
        puts $fout2 "Shape $crc1"
        puts $fout2 "appearance Appearance $crc1 material Material $crc1 diffuseColor 0.2 0.2 0.2 $crc2 $crc2 #appearance"
        puts $fout2 "geometry Box $crc1 size 8 0.1 8$crc2"
        puts $fout2 "$crc2"
        puts $fout2 "$crc4"
        puts $fout2 "$crc2 # EJE X"
        puts $fout2 "$crc4 #CHILDREN DEL GROUP EJES"
        puts $fout2 "$crc2"
        puts $fout2 "$crc4 #children"
        puts $fout2 "$crc2 # Group DE EJES"
        puts $fout2 ","
        puts $fout2 "Group $crc1 #texto"
        puts $fout2 "children $crc3"
        puts $fout2 "Transform $crc1     #"
        puts $fout2 "rotation    1 0 0 3.14"
        puts $fout2 "translation     5.5 2 5     # exposedField SFVec3f"
        puts $fout2 "children"
        puts $fout2 "  $crc3 Shape $crc1"
        puts $fout2 "    geometry Text $crc1"
        puts $fout2 "        \string \[ \" $upper_limit \" \]"
        puts $fout2 "        fontStyle FontStyle $crc1 justify $crc5 $crc2"
        puts $fout2 "    $crc2 $crc2"
        puts $fout2 "  $crc4"
        puts $fout2 "$crc2, # transform"
        puts $fout2 "Transform $crc1     #"
        puts $fout2 "rotation    1 0 0 3.14"
        puts $fout2 "translation     -5.5 2 5     # exposedField SFVec3f"
        puts $fout2 "children"
        puts $fout2 "  $crc3 Shape $crc1"
        puts $fout2 "    geometry Text $crc1"
        puts $fout2 "        \string \[ \"$lower_limit \" \]"
        puts $fout2 "    $crc2 $crc2"
        puts $fout2 "  $crc4"
        puts $fout2 "$crc2, # transform"
        puts $fout2 "Transform $crc1     # barra de color"
        puts $fout2 "rotation    1 0 0 3.14"
        puts $fout2 "translation     -5.5 3 5     # exposedField SFVec3f"
        puts $fout2 "children"
        puts $fout2 "  $crc3 Shape $crc1"
        puts $fout2 "    geometry IndexedFaceSet $crc1"
        puts $fout2 "        coord Coordinate $crc1 point $crc3 0 0 0 , 0 1 0,"
        
        for {set k 1} {$k <= $scl } {incr k} {
            set ss [ expr {$k*$scl2}] 
            puts $fout2 "$ss 0 0, $ss 1 0,"
        }
        
        puts $fout2 "        $crc4$crc2"
        puts $fout2 "        color Color $crc1 color $crc3 0.000 0.000 0.500," 
        
        set ss 0.500
        set scl2 [ expr { $scl - 1 }]
        set ss1 [ expr { 5./$scl2 }]
        for {set k 1} {$k <= $scl2 } {incr k} {
            set ss [ format "%0.3f" [ expr { $ss + $ss1 }]]
            if { $ss > 5.0 } {
                set ss2 [ format "%0.3f" [expr { 6.0-$ss }]]
                puts $fout2 " $ss2 0.000 0.000,"
            } elseif { $ss > 4.0 } {
                set ss2 [ format "%0.3f" [expr { 5.0-$ss }]]
                puts $fout2 " 1.000 $ss2 0.000,"
            } elseif { $ss > 3.0 } { 
                set ss2 [ format "%0.3f" [expr { $ss-3.0 }]]
                puts $fout2 " $ss2 1.000 0.000,"
            } elseif { $ss > 2.0 } { 
                set ss2 [ format "%0.3f" [expr { 3.0-$ss }]]
                puts $fout2 " 0.000 1.000 $ss2,"
            } elseif { $ss > 1.0 } { 
                set ss2 [ format "%0.3f" [expr { $ss-1.0  }]]
                puts $fout2 " 0.000 $ss2 1.000,"
            } else {
                puts $fout2 "0.000 0.000 $ss"
            }
        }
        
        puts $fout2 "     $crc4 $crc2"
        puts $fout2 "        colorPerVertex TRUE"
        puts $fout2 "        coordIndex $crc3 0 1 3 2 -1"
        
        for {set k 1} {$k < $scl } {incr k} {
            set ss1 [expr {$k*2}] 
            set ss2 [expr {$k*2+1}]
            set ss3 [expr {$k*2+2}]
            set ss4 [expr {$k*2+3}]
            puts $fout2 " $ss1 $ss2 $ss4 $ss3 -1"
        }
        
        puts $fout2 "        $crc4"
        puts $fout2 "       colorIndex $crc3 0 0 0 0 -1"
        
        for {set k 1} {$k < $scl } {incr k} {
            puts $fout2 " $k $k $k $k -1"
        }
        
        puts $fout2 "        $crc4"
        puts $fout2 "        ccw FALSE  #tenia valor true"
        puts $fout2 "        solid FALSE"
        puts $fout2 "        convex FALSE"
        puts $fout2 "        creaseAngle 0"
        puts $fout2 "    $crc2 $crc2"
        puts $fout2 "  $crc4"
        puts $fout2 "$crc2 # transform"
        puts $fout2 ""
        puts $fout2 "$crc4 #CHILDREN DEL GROUP EJES"
        puts $fout2 "$crc2"
        puts $fout2 ","
        puts $fout2 "Transform $crc1"
        puts $fout2 "scale $fscm $fscm $fscm # escala para llevar el sistema de coordenadas a numeros entre 0 y 8"
        puts $fout2 "children $crc3 # estructuras"
        puts $fout2 "Transform $crc1 # transformaciones"
        puts $fout2 "rotation 1 0 0 $rtcn"
        puts $fout2 "translation $cxcm $cycm $czcm # poner objeto en el centro"
        puts $fout2 "children"
        puts $fout2 "Group $crc1"
        puts $fout2 "children"
        puts $fout2 "Group $crc1"
        puts $fout2 "children"
        puts $fout2 "Shape $crc1 # Superfie"
        puts $fout2 "appearance Appearance $crc1"
        puts $fout2 "material DEF estrucMat Material $crc1"
        puts $fout2 "shininess 0.2"
        puts $fout2 "$crc2"
        puts $fout2 "$crc2 # apariencia"
        puts $fout2 "geometry"
        puts $fout2 "IndexedFaceSet $crc1"
        puts $fout2 "coord Coordinate $crc1 point $crc3 "        
        set cont 0
        foreach item [GiD_Result get_nodes] {
            set new_node_num([lindex $item 0]) $cont
            puts $fout2 [lrange $item 1 end]
            incr cont
        }        
        puts $fout2 "$crc4 $crc2 #end coordinates"
        puts $fout2 ""
        puts $fout2 "color Color $crc1 color $crc3 0.000 0.000 0.500,"
        
        set ss 0.500
        set scl2 [ expr { $scl - 1 }]
        set ss1 [ expr { 5./$scl2 }]
        for {set k 1} {$k <= $scl2 } {incr k} {
            set ss [ format "%0.3f" [ expr { $ss + $ss1 }]]
            if { $ss > 5.0 } {
                set ss2 [ format "%0.3f" [expr { 6.0-$ss }]]
                puts $fout2 " $ss2 0.000 0.000,"
            } elseif { $ss > 4.0 } {
                set ss2 [ format "%0.3f" [expr { 5.0-$ss }]]
                puts $fout2 " 1.000 $ss2 0.000,"
            } elseif { $ss > 3.0 } { 
                set ss2 [ format "%0.3f" [expr { $ss-3.0 }]]
                puts $fout2 " $ss2 1.000 0.000,"
            } elseif { $ss > 2.0 } { 
                set ss2 [ format "%0.3f" [expr { 3.0-$ss }]]
                puts $fout2 " 0.000 1.000 $ss2,"
            } elseif { $ss > 1.0 } { 
                set ss2 [ format "%0.3f" [expr { $ss-1.0  }]]
                puts $fout2 " 0.000 $ss2 1.000,"
            } else {
                puts $fout2 "0.000 0.000 $ss"
            }
        }
        
        puts $fout2 " $crc4 $crc2"
        
        
        puts $fout2 "colorPerVertex TRUE"
        puts $fout2 "coordIndex $crc3"
                        
        if { [GiD_Info mesh -post NumElements Triangle] > 0 } {
            set element_type Triangle
        } elseif { [GiD_Info mesh -post NumElements Quadrilateral] > 0 } {
            set element_type Quadrilateral
        } elseif { [GiD_Info mesh -post NumElements Hexahedra] > 0 } {
            set element_type Hexahedra
        } elseif { [GiD_Info mesh -post NumElements Tetrahedra] > 0 } {
            set element_type Tetrahedra
        } else {
            set element_type ""
        }                      
        if { $element_type == "Quadrilateral"  } {
            foreach element [lindex [GiD_Info mesh -post Elements $element_type -sublist] 0] {
                set cont 1
                foreach node_id [lrange $element 1 end-1] {
                    set n($cont) $new_node_num($node_id)                    
                    incr cont
                }
                puts $fout2 "$n(1) $n(2) $n(3) $n(4) -1"
            }
        } elseif { $element_type == "Triangle"  } {
            foreach element [lindex [GiD_Info mesh -post Elements $element_type -sublist] 0] {
                set cont 1
                foreach node_id [lrange $element 1 end-1] {
                    set n($cont) $new_node_num($node_id)
                    incr cont
                }
                puts $fout2 "$n(1) $n(2) $n(3) -1"
            }
        } elseif { $element_type == "Hexahedra"} {      
            foreach element [lindex [GiD_Info mesh -post Elements $element_type -sublist] 0] {
                set cont 1
                foreach node_id [lrange $element 1 end-1] {
                    set n($cont) $new_node_num($node_id)
                    incr cont
                }
                puts $fout2 "$n(1) $n(2) $n(3) $n(4) -1"
                puts $fout2 "$n(1) $n(4) $n(8) $n(5) -1"
                puts $fout2 "$n(1) $n(5) $n(6) $n(2) -1"
                puts $fout2 "$n(2) $n(6) $n(7) $n(3) -1"
                puts $fout2 "$n(3) $n(7) $n(8) $n(4) -1"
                puts $fout2 "$n(5) $n(8) $n(7) $n(6) -1"    
            }
        } elseif { $element_type == "Tetrahedra" } {
            foreach element [lindex [GiD_Info mesh -post Elements $element_type -sublist] 0] {
                set cont 1
                foreach node_id [lrange $element 1 end-1] {
                    set n($cont) $new_node_num($node_id)
                    incr cont
                } 
                puts $fout2 "$n(1) $n(2) $n(3) -1"
                puts $fout2 "$n(2) $n(4) $n(3) -1"
                puts $fout2 "$n(3) $n(4) $n(1) -1"
                puts $fout2 "$n(4) $n(2) $n(1) -1"
            }
        } else {
        }             
        
        puts $fout2 "$crc4 #end faces"
        puts $fout2 "colorIndex $crc3"
                        
        set result_data [lindex [lindex [lindex [GiD_Result get -array $result_id] end] 1] $result_component_index]
        #map value to index color
        set index_data ""
        foreach value $result_data {
            set index [expr { int(($value-$lower_limit)/$itvlo) }]  
            if { $index < 0 } {
                set index 0
            } elseif { $index > $scl2 } {
                set index $scl2
            }
            lappend index_data $index                 
        }
        unset result_data
        set header [GiD_Result get -info $result_id]
        set over [lindex [lindex $header 0] 5]         
        if { $over == "OnNodes" } {  
            #vrml not accept shared values enumerated by nodes must be enumerated by face vertex
            set new_index_data ""
            foreach element [lindex [GiD_Info mesh -post Elements $element_type -sublist] 0] {
                foreach node_id [lrange $element 1 end-1] {                    
                    lappend new_index_data [lindex $index_data [expr {$node_id-1}]]
                }              
            }
            set index_data $new_index_data
            unset new_index_data
        }
        if { $element_type == "Triangle" } {                
            set sublist ""
            foreach {v1 v2 v3} $index_data {
                lappend sublist [list $v1 $v2 $v3]
            }
            foreach values $sublist {
                set cont 1
                foreach index $values {
                    set n($cont) $index
                    incr cont
                }
                puts $fout2 "$n(1) $n(2) $n(3) -1"
            }
        } elseif { $element_type == "Quadrilateral" } {
            set sublist ""
            foreach {v1 v2 v3 v4} $index_data {
                lappend sublist [list $v1 $v2 $v3 $v4]
            }
            foreach values $sublist {
                set cont 1
                foreach index $values {
                    set n($cont) $index
                    incr cont
                }
                puts $fout2 "$n(1) $n(2) $n(3) $n(4) -1"
            }
        } elseif { $element_type == "Hexahedra" } {
            set sublist ""
            foreach {v1 v2 v3 v4 v5 v6 v7 v8} $index_data {
                lappend sublist [list $v1 $v2 $v3 $v4 $v5 $v6 $v7 $v8]
            }                
            foreach values $sublist {
                set cont 1
                foreach index $values {                        
                    set n($cont) $index
                    incr cont
                }
                puts $fout2 "$n(1) $n(2) $n(3) $n(4) -1"
                puts $fout2 "$n(1) $n(4) $n(8) $n(5) -1"
                puts $fout2 "$n(1) $n(5) $n(6) $n(2) -1"
                puts $fout2 "$n(2) $n(6) $n(7) $n(3) -1"
                puts $fout2 "$n(3) $n(7) $n(8) $n(4) -1"
                puts $fout2 "$n(5) $n(8) $n(7) $n(6) -1"        
            }
        } elseif { $element_type == "Tetrahedra" } {
            set sublist ""
            foreach {v1 v2 v3 v4} $index_data {
                lappend sublist [list $v1 $v2 $v3 $v4]
            }                
            foreach values $sublist {
                set cont 1
                foreach index $values {
                    set n($cont) $index
                    incr cont
                }
                puts $fout2 "$n(1) $n(2) $n(3) -1"
                puts $fout2 "$n(2) $n(4) $n(3) -1"
                puts $fout2 "$n(3) $n(4) $n(1) -1"
                puts $fout2 "$n(4) $n(2) $n(1) -1"       
            }
        }         
        unset index_data        
                        
        puts $fout2 "$crc4 #termina definicion de indices de color"
        puts $fout2 "ccw FALSE  #tenia valor true"
        puts $fout2 "solid FALSE"
        puts $fout2 "convex FALSE"
        puts $fout2 "creaseAngle 0"
        puts $fout2 "$crc2 # termina indexedFaceSet"
        puts $fout2 "$crc2 # termina shape Estructuras"
        puts $fout2 "$crc2 # termina GRUPO"
        puts $fout2 "$crc2 #termina GRUPO"
        puts $fout2 "$crc2 # termina traslacion y rotacion de Estructuras"
        puts $fout2 "$crc4 # terminan los children de estructuras"
        puts $fout2 "$crc2 #, termina transformacion de escala"
        puts $fout2 "#DEF TOUCH TouchSensor $crc1"
        puts $fout2 "#$crc2"
        puts $fout2 "$crc4 # termina el children del grupo de colisiones"
        puts $fout2 "$crc2 # termina GRUPO"
        puts $fout2 "collide FALSE"
        puts $fout2 "$crc2  # termina COLLISION"        
        close $fout2
    
        WarnWin [= "VRML file %s created." $postfile2]        
    } else {
        WarnWin [= "can't open file %s" $postfile2]                
    }
}
