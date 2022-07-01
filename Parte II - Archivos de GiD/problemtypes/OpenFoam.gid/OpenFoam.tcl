proc InitGIDProject { dir } {    
    set ::OpenFoam::_dir $dir  
    if { [info procs ReadProblemtypeXml] != "" } {
    #this procedure exists after GiD 11.1.2b
        set data [ReadProblemtypeXml [file join $dir OpenFoam.xml] Infoproblemtype {Version MinimumGiDVersion MinimumAmeletPluginVersion}]                
    } else {
        #this procedure is a copy of ReadProblemtypeXml to be able to work with previous GiD's
        set data [OpenFoam::ReadProblemtypeXml [file join $dir OpenFoam.xml] Infoproblemtype {Version MinimumGiDVersion MinimumAmeletPluginVersion}]
    }    
    if { $data == "" } {
        WarnWinText [= "Configuration file %s not found" [file join $dir OpenFoam.xml]]
        return 1
    }
    array set problemtype_local $data
    set OpenFoam::VersionNumber $problemtype_local(Version)


    set GiDVersionRequired 9.1.0b
    set comp -1
    catch { set comp [GiDVersionCmp $GiDVersionRequired] }
    if { $comp < 0 } {
        WarnWin [= "This interface requires GiD %s or later" $GiDVersionRequired]
    }

    OpenFoam::Splash 1
    OpenFoam::ChangeMenus

    OpenFoam::AddToolbar    
}

proc EndGIDProject {} {
    OpenFoam::RemoveToolbar    
}

proc ChangedLanguage { newlanguange } {
    #to force refresh some menus managed by the problemtype when the user change to newlanguage
    OpenFoam::ChangeMenus
}

proc AfterWriteCalcFileGIDProject { filename errorflag } {    
    set ret ""
    #set err [catch { OpenFoam::_writefile_old } string]
    set err [catch { OpenFoam::writefile $filename } string]    
    if { $err } { 
        WarnWin $string 
        set ret -cancel-
    }
    return $ret
}

proc LoadGIDProject { filespd } {        
    if { [file join {*}[lrange [file split $filespd] end-1 end]] == "OpenFoam.gid/OpenFoam.spd" } {
        #loading the problemtype itself, not a model
    } else {
        set pt [GiD_Info project ProblemType]
        if { $pt == "OpenFoam" } {
            set filename [file rootname $filespd].xml
            set model_problemtype_version_number [OpenFoam::ReadXml $filename]            
            if { $model_problemtype_version_number != -1 && $model_problemtype_version_number < $::OpenFoam::VersionNumber } {            
                set must_transform 1
            } else {
                set must_transform 0
            }
            if { $must_transform } {
                after idle [list OpenFoam::Transform $model_problemtype_version_number $::OpenFoam::VersionNumber]
            }
        }
    }
}

proc SaveGIDProject { filespd } {
    set filename [file rootname $filespd].xml
    OpenFoam::SaveXml $filename
}

namespace eval OpenFoam { 
    variable ProgramName OpenFoam
    variable VersionNumber ;#interface version, get it from xml to avoid duplication 
    variable _dir ;#path to the problemtype


    #Warning: cond_list must be -dictionary ordered, and cond_ident be on the same order!!
    variable cond_list {cyclic empty patch symmetryPlane wall wedge }
    #Decimals added in order to create a bijective application
    variable cond_ident {37 5.1 14.1 4.1 4.2 24}
}

proc OpenFoam::SaveXml { filename } {
    variable ProgramName
    variable VersionNumber
    set fp [open $filename w]
    if { $fp != "" } {
        puts $fp {<?xml version='1.0' encoding='utf-8'?><!-- -*- coding: utf-8;-*- -->}
        puts $fp "<$ProgramName version='$VersionNumber'/>"
        close $fp
    }
}

#return -1 if the xml is not an OpenFoam one or if the xml not exists
#        the OpenFoam version of the model of the xml file
proc OpenFoam::ReadXml { filename } {
    variable ProgramName
    set model_problemtype_version_number -1
    if { [file exists $filename] } {
        set fp [open $filename r]
        if { $fp != "" } {
            set line ""
            gets $fp header
            gets $fp line ;#something like: <OpenFoam version='1.0'/>
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

proc OpenFoam::Transform { from_version to_version } {    
    variable ProgramName
    GiD_Process escape escape escape escape Data Defaults TransfProblem $ProgramName escape    
}

#this procedure is a copy of ReadProblemtypeXml to be able to work with previous GiD's
proc OpenFoam::ReadProblemtypeXml { xmlfile root_name fields } {
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

proc OpenFoam::Splash { {self_close 1} } {    
    variable _dir
    variable VersionNumber
    set text "Version $VersionNumber"
    GidUtils::Splash [file join $_dir images OpenFoam_about.gif] .splash $self_close [list $text 70 300]   
}


proc OpenFoam::About { } {
    set self_close 0
    OpenFoam::Splash $self_close
} 

proc OpenFoam::ChangeMenus { } {
    variable _dir
    foreach where {PRE POST} {
        GiDMenu::InsertOption "Help#C#menu" [list [= "OpenFoam interface help"]] 0 $where \
            [list GiDCustomHelp -dir [file join $_dir info] \
                 -title [= "OpenFoam interface help"] -report 0] \
            "" "" "insert" =
        GiDMenu::InsertOption "Help#C#menu" [list [= "About OpenFoam interface"]] end $where \
            OpenFoam::About "" "" "insertafter" =        
    }
    
    #InsertMenuOption [_ Calculate] [_ Calculate] 0 "GiD_Process Mescape Files WriteCalcFile" PRE replace
   
    GidChangeDataLabel "Problem Data" ""
    GidAddUserDataOptions [= "Problem Dimension"] "GidOpenProblemData" 2
    
    #We hide one of the conditions set    
    
    
    
    GidChangeDataLabel "Conditions" [= "Zones Definition"]
    if { 1 } {
        #because now there is only implemented 3D, not 2D
    } else {
        set problem_dimension [string index [GiD_AccessValue get gendata Problem_dimension] 0] 
        
        switch $problem_dimension {
            2 {
                set normal_book "2D"
                set hidden_book "3D"
            }
            3 {
                set normal_book "3D"
                set hidden_book "2D"
            }     
        }    
        GiD_ShowBook conditions $hidden_book 0   
        GiD_ShowBook conditions $normal_book 1   
    }
    GiDMenu::UpdateMenus
}

proc OpenFoam::AddToolbar { { type "DEFAULT INSIDELEFT"} } {
    variable _dir

    global OpenFoamBitmapsNames OpenFoamBitmapsCommands OpenFoamBitmapsHelp ProblemTypePriv

    set OpenFoamBitmapsNames(0) "images/dimension.gif images/section.gif images/calc.gif"    
    
    if { 1 } {
        #because now there is only implemented 3D, not 2D
        set normal_book "3D"
    } else {
        set problem_dimension [string index [GiD_AccessValue get gendata Problem_dimension] 0]     
        switch $problem_dimension {
            2 {
                set normal_book "2D"
            }
            3 {
                set normal_book "3D"
            }     
        }      
    } 
    
    set OpenFoamBitmapsCommands(0) [list [list -np- GidOpenProblemData] [list -np- GidOpenConditions $normal_book] \
            "Utilities Calculate"]

    set OpenFoamBitmapsHelp(0) [list [= "Choose the dimension of the Problem"] [= "Define Boundary Conditions and Continuum zones"] [= "Output file"]]

    # prefix values:
    #          Pre        Only active in the preprocessor
    #          Post       Only active in the postprocessor
    #          PrePost    Active Always

    set prefix Pre

    set ProblemTypePriv(toolbarwin) [CreateOtherBitmaps OpenFoamBar [= "OpenFoam bar"] \
            OpenFoamBitmapsNames OpenFoamBitmapsCommands \
            OpenFoamBitmapsHelp $_dir OpenFoam::AddToolbar $type $prefix]
    AddNewToolbar "OpenFoam bar" ${prefix}OpenFoamBarWindowGeom OpenFoam::AddToolbar [= "OpenFoam bar"]
}

proc OpenFoam::RemoveToolbar {} {
    global ProblemTypePriv
    
#     global BitMapsNames BitMapsCommands BitmapsHelp
#     set BitMapsNames(0) [lreplace $BitMapsNames(0) 0 2]
#     set BitMapsCommands(0) [lreplace $BitMapsCommands(0) 0 2]
#     set BitmapsHelp(0) [lreplace $BitmapsHelp(0) 0 2]
#     return

    ReleaseToolbar "OpenFoam bar"
    #rename AddToolbar ""
    catch { destroy $ProblemTypePriv(toolbarwin) }
}

proc OpenFoam::writefile_old {} {
    set err [catch { OpenFoam::_writefile_old } string]
    if { $err } { WarnWin $string }
    return $string
}


proc OpenFoam::_writefile_old {} {  
    set t(0) [clock milliseconds]

    if {[GiD_Info Project Quadratic]!=0} {error [= "This interface does not support quadratic elements"]}  

    set num_zones 0
    set dict_zones ""
    
    #Writing General Data++++++++++++++++++++++++++++++++++++++++
    
    set _ ""
    append _ "(1 \"Created by GiD on [clock format [clock seconds] -format %d-%h-%y]"
    append _ " at [clock format [clock seconds] -format %H:%M:%S]\")"
   
    set problem_dimension [string index [GiD_AccessValue get gendata Problem_dimension] 0] 
    append _ "\n(0 \"Dimension:\")"  
    append _ "\n(2 $problem_dimension)" 
    
    #Writing nodes(ZONE=1)++++++++++++++++++++++++++++++++++++++++
    
    append _ "\n(0 \"Nodes:\")"
    incr num_zones    
    
    #We save enough space for all the nodes 
    
    set maxnodes [GiD_Info Mesh MaxNumNodes]
    append _ "\n(10 (0 1 [format %x $maxnodes] 0 $problem_dimension))"
    
    set nnodes [GiD_Info Mesh NumNodes]
    #If there is no skipped node, we print them all in a single caption
    
    if {$maxnodes == $nnodes} {
        append _ "\n(10 ([format %x $num_zones] 1 [format %x $maxnodes] 1 $problem_dimension)("
        #We enter the information for each node
        if { $problem_dimension == 3 } {
            foreach "n x y z" [GiD_Info Mesh Nodes] {
                append _ "\n[format "%16e %16e %16e" $x $y $z]"
            }
        } else {
            foreach {n x y z} [GiD_Info Mesh Nodes] {
                append _ "\n[format "%16e %16e" $x $y]"
            }
        }        
        append _ "\n))" 

        set t(1) [clock milliseconds]
    } else {
        #We enter the information for each node
        if { $problem_dimension == 3 } {
            foreach "n x y z" [GiD_Info Mesh Nodes] {
                append _ "\n(10 ([format %x $num_zones] [format %x $n] [format %x $n] 1 $problem_dimension)("
                append _ "\n[format "%16e %16e %16e" $x $y $z]\n))"
            }
        } else {
            foreach {n x y z} [GiD_Info Mesh Nodes] {
                append _ "\n(10 ([format %x $num_zones] [format %x $n] [format %x $n] 1 $problem_dimension)("
                append _ "\n[format "%16e %16e" $x $y]\n))"
            }
        }
        
        set t(1) [clock milliseconds]
        
        # We write as virtual nodes the undefined nodes
        
        foreach n [lindex [GiD_Info Mesh Nodes -array] 0] {
            set existnode($n) 1
        }
        set prefix "\n(10 ([format %x $num_zones]"
        if { $problem_dimension == 3 } {
            set suffix "0 $problem_dimension)(\n 0.00000000e+00  0.00000000e+00  0.00000000e+00\n))"
        } else {
            set suffix "0 $problem_dimension)(\n 0.00000000e+00  0.00000000e+00\n))"
        }
        for {set i 1} {$i<=$maxnodes} {incr i} {
            if {![info exists existnode($i)]} {
                set texti [format %x $i]
                append _ "$prefix $texti $texti $suffix" 
            }
        }
        unset existnode      
    }
      
    set t(2) [clock milliseconds]   
    #Writing Cells+++++++++++++++++++++++++++++++
    
    append _ "\n(0 \"Cells:\")" 
    
    #We save enough space for all the cells
    
    append _ "\n(12 (0 1 [format %x [GiD_Info Mesh NumElements]] 0))" 
    
    #It's not possible to skip elements keeping the proper zone as done with the nodes.
    #That's why a dict_elements with the real element number is created. This simplification is very important in terms of zone spliting for OpenFoam    
       
    array unset contset     
    set dict_elements ""
    
    switch $problem_dimension {
        2 {
            set elemtype_list {Triangle Quadrilateral}
            set cnd_type Surface_Continuum   
            set max_faces_list [list 3 4]  
            set cnd_type_boundary Line_Boundary_conditions 
            set types_list {1 3}
            set local_types [list Linear]
        }
        3 {
            set elemtype_list {Tetrahedra Hexahedra Prism Pyramid}
            set cnd_type Volume_Continuum
            set max_faces_list [list 4 6 5 5]
            set cnd_type_boundary Surface_Boundary_conditions
            set types_list {2 4 6 5}
            set local_types [list Triangle Quadrilateral]
        }      
    }
        
    #We construct conset array with the contiuum conditions info
    
    foreach cnd [GiD_Info conditions $cnd_type mesh] {
        lappend contset([lindex $cnd 4]) [list [lindex $cnd 1] [lindex $cnd 3]]
    }   
    
    set t(3) [clock milliseconds]    
    #We construct the default array
    #By default, we consider a fluid cell
    set nelem_local 0 
    foreach local_type $local_types {        
        set nelem_local [expr ($nelem_local+[GiD_Info Mesh NumElements $local_type])]   
    }       
    set maxelem [GiD_Info Mesh MaxNumElements]
    set nelem [GiD_Info Mesh NumElements]
    
    if { $nelem == $maxelem && $nelem_local == 0 } {
        #avoid check if element exists and use an array
        for {set i 1} {$i<=$maxelem} {incr i} {
            set defaultfluid($i) 1
        }
        foreach item [GiD_Info Conditions $cnd_type mesh] {
            set i [lindex $item 1]
            unset defaultfluid($i)
        }
        foreach i [lsort -integer [array names defaultfluid]] {
            lappend contset(Default_continuum) [list $i fluid]
        }
        unset defaultfluid
    } else {
        for {set i 1} {$i<=$maxelem} {incr i} {   
            foreach valid_element $elemtype_list {
                if {[GiD_Info Mesh Elements $valid_element $i] ne "" } {  
                    if {[GiD_Info Conditions $cnd_type mesh $i] eq "{0 -}"} {
                        lappend contset(Default_continuum) [list $i fluid]
                    }                            
                }    
            }
        }
    }  
    
    set t(4) [clock milliseconds]      
    #And now we print all continuum zones
    
    foreach i $elemtype_list j $types_list {
        set element_ident($i) $j
    }

    set num_elems 0
    
    foreach cont_group [array names contset] {
        
        set cont_info [lsort -unique $contset($cont_group)]  
        set printed_caption 0
        
        foreach cell $cont_info {        
            
            incr num_elems
            
            foreach {real_elementid type} $cell break
            
            dict set dict_elements $real_elementid $num_elems
            
            if {$printed_caption eq "0"} {
                set original_type $type                
                set translated_type 0
                switch $original_type {
                    solid {
                        set translated_type 11
                    }
                    fluid {
                        set translated_type 1
                    }   
                }
                #Caption printing
                incr num_zones
                dict set dict_zones $cont_group ZONE_ID $num_zones 
                dict set dict_zones $cont_group ZONE_TYPE $original_type                   
                append _ "\n(0 \"Continuum $num_zones : $cont_group\")"
                append _ "\n(12 ([format %x $num_zones] [format %x $num_elems]" 
                set final_elementid [expr ($num_elems+[llength $cont_info]-1)]                
                append _ " [format %x $final_elementid] $translated_type 0)(\n"   
                set printed_caption 1
            }
            
            if {$type ne $original_type} {
                error [= "Cell %s of continuum set %s has a continuum type not according with the rest of the elements from its condition. Please correct this" $real_elementid $cont_group]
            }
            append _ "$element_ident([lindex [GiD_Mesh get Element $real_elementid] 1]) "
        }
        append _ "\n))"   
    }
    
    array unset contset
    set t(5) [clock milliseconds]      
    #Writing faces++++++++++++++++++++++++++++++++++++++++ 
    
    set faces_distribution ""
    
    dict set faces_distribution Triangle  [list [list 1 2] [list 2 3] [list 3 1]]
    dict set faces_distribution Quadrilateral [list [list 1 2] [list 2 3] [list 3 4] [list 4 1]]
    dict set faces_distribution Tetrahedra [list [list 1 2 3] [list 2 4 3] [list 3 4 1] [list 4 2 1]]
    dict set faces_distribution Hexahedra [list [list 1 2 3 4] [list 1 4 8 5] [list 1 5 6 2] [list 2 6 7 3] [list 3 7 8 4] [list 5 8 7 6]]
    dict set faces_distribution Prism [list [list 1 2 3] [list 1 4 5 2] [list 2 5 6 3] [list 3 6 4 1] [list 4 6 5]]
    dict set faces_distribution Pyramid [list [list 1 2 3 4] [list 1 5 2] [list 2 5 3] [list 3 5 4] [list 4 5 1]]
    
    foreach cnd [GiD_Info conditions $cnd_type_boundary mesh] {
        lappend faceset([lindex $cnd 4]) [list [lindex $cnd 0] [lindex $cnd 1] [OpenFoam_cond_number [lindex $cnd 3]]]
    }  
    
    set t(6) [clock milliseconds]         
    #First we create our array relating each face with the positive and negative element    
   
    array unset face_to_elements   
    
    foreach elemtype $elemtype_list maxfaces $max_faces_list {        
        foreach element_line [GiD_Info Mesh Elements $elemtype -sublist] {
            for {set nface 1} {$nface<=$maxfaces} {incr nface} {
                set face_connectivities [extract_connectivities_old $element_line $elemtype $nface $faces_distribution]
                set key [give_hexadecimal_name [lsort -integer $face_connectivities]]
                set face_name [give_hexadecimal_name $face_connectivities]
                if { [info exists facekeys($key)] } { 
                    set face_name $facekeys($key) ;#use as face_name the first, pointed by key
                } else {
                    set facekeys($key) $face_name
                    set face_to_elements($face_name) 0 ;#First index indicate that the position is not already printed 
                }
                lappend face_to_elements($face_name) [lindex $element_line 0]                
            }
        }
    }

    set t(7) [clock milliseconds]      
    #General face caption
    
    if {[array size face_to_elements] ne "0"} {
        append _ "\n(0 \"Faces:\")" 
        append _ "\n(13 (0 [format %x 1] [format %x [array size face_to_elements]] 0))"        
    }

    #Printing each face
    
    set num_faces 0
    
    foreach i [array names faceset] {
        set face_info [lsort -unique $faceset($i)]      
        set printed_caption 0    
        
        foreach face $face_info {
            foreach {elem face_ident type} $face break
            
            if {$printed_caption eq "0"} {
                set original_type $type
                #Caption printing
                incr num_zones
                dict set dict_zones $i ZONE_ID $num_zones 
                dict set dict_zones $i ZONE_TYPE [OpenFoam_cond_name $original_type] 
                append _ "\n(0 \"Face $num_zones : $i\")"
                incr num_faces
                append _ "\n(13 ([format %x $num_zones] [format %x $num_faces]" 
                incr num_faces [expr ([llength $face_info]-1)]
                append _ " [format %x $num_faces] [format %x [expr (int($original_type))]] 0)("  
                set printed_caption 1
            }
            
            if {$type ne $original_type} {
                error [= "Element %s of face set $i has a boundary type not according with the rest of the elements from its condition. Please correct this" $elem]
            }
            
            set connectivities ""
            foreach elemtype $elemtype_list  {
                set element_line [GiD_Info mesh Elements $elemtype $elem]
                if {$element_line ne ""} {
                    set connectivities [extract_connectivities_old $element_line $elemtype $face_ident $faces_distribution]
                    break
                }
            }
            
            #Printing each face line
            append _ "\n[llength $connectivities]"            
             
            foreach connectivity_node $connectivities {
                append _ " [format %x $connectivity_node]"
            }  
                
            #We always append the right element, which is the studied element. We use the elements dict to find the real value
            set real_elem [dict get $dict_elements $elem]
            append _ " [format %x $real_elem]"
            
            #We found the element in our array
            
            set face_name [give_hexadecimal_name $connectivities]
            set found_left 0
            
            if {[info exists face_to_elements($face_name)]} {
                #We mark as printed this face in the array
                lset face_to_elements($face_name) 0 "1"
                #Then we write the left cell if needed 
                if {[llength $face_to_elements($face_name)] eq "3"} {                 
                    if {[lindex $face_to_elements($face_name) 2] eq $elem} {
                        set real_elem [dict get $dict_elements [lindex $face_to_elements($face_name) 1]]
                    } else {
                        set real_elem [dict get $dict_elements [lindex $face_to_elements($face_name) 2]]
                    }
                    append _ " [format %x $real_elem]"
                    set found_left 1
                } 
            } else {
                set key [give_hexadecimal_name [lsort -integer $connectivities]]
                if { [info exists facekeys($key)] } { 
                    set face_name $facekeys($key)
                    #We mark as printed this face in the array
                    lset face_to_elements($face_name) 0 "1"
                    #Then we write the left cell if needed  
                    if {[llength $face_to_elements($face_name)] eq "3"} {
                        if {[lindex $face_to_elements($face_name) 2] eq $elem} {
                            set real_elem [dict get $dict_elements [lindex $face_to_elements($face_name) 1]]
                        } else {
                            set real_elem [dict get $dict_elements [lindex $face_to_elements($face_name) 2]]
                        } 
                        append _ " [format %x $real_elem]"
                        set found_left 1                                               
                    } 
                }
            }
            
            #If we don't find a left cell we just print 0
            
            if {$found_left eq "0"} {append _ " 0"}  
        }
        
        append _ "\n))" 
    }
    set t(8) [clock milliseconds]      
    #Non printed faces will be printed as interior faces or walls:
    
    set interior_faces 0
    set wall_faces 0
    
    foreach face [array names face_to_elements] {
        if {([lindex $face_to_elements($face) 0] eq "0")} {
            switch [llength $face_to_elements($face)] {
                3 {
                    incr interior_faces
                }
                2 {
                    incr wall_faces
                }
                default {}
            }
        }
    }
    set t(9) [clock milliseconds]      
    #Default interior zone
    
    if {$interior_faces > "0"} {
        incr num_zones
        dict set dict_zones Default_interior_zone ZONE_ID $num_zones 
        dict set dict_zones Default_interior_zone ZONE_TYPE interior
        append _ "\n(0 \"Face [format %x $num_zones] : Default_interior_zone\")"
        append _ "\n(13 ([format %x $num_zones] [format %x [expr ($num_faces+1)]] [format %x [expr ($num_faces+$interior_faces)]] 2 0)("
        
        foreach face [array names face_to_elements] {
            if {([lindex $face_to_elements($face) 0] eq "0") && ([llength $face_to_elements($face)] eq "3")} {
                set connectivities [split $face ":"]
                append _ "\n[llength $connectivities]"   
                foreach node $connectivities { append _ " $node" }                
                set real_elem1 [dict get $dict_elements [lindex $face_to_elements($face) 1]]
                set real_elem2 [dict get $dict_elements [lindex $face_to_elements($face) 2]]
                append _ " [format %x $real_elem1] [format %x $real_elem2]"
            }
        }
        
        append _ "))" 
    }
    set t(10) [clock milliseconds]      
    #Default Wall zone    
    
    if {$wall_faces > "0"} {
        incr num_zones
        dict set dict_zones Default_wall_zone ZONE_ID $num_zones 
        dict set dict_zones Default_wall_zone ZONE_TYPE wall 
        append _ "\n(0 \"Face [format %x $num_zones] : Default_wall_zone\")"
        append _ "\n(13 ([format %x $num_zones] [format %x [expr ($num_faces+$interior_faces+1)]] [format %x [expr ($num_faces+$interior_faces+$wall_faces)]] 3 0)("
        
        foreach face [array names face_to_elements] {
            if {([lindex $face_to_elements($face) 0] eq "0") && ([llength $face_to_elements($face)] eq "2")} {
                set connectivities [split $face ":"]
                append _ "\n[llength $connectivities]"  
                foreach node $connectivities { append _ " $node" }
                set real_elem [dict get $dict_elements [lindex $face_to_elements($face) 1]]
                append _ " [format %x $real_elem] 0"
            }
        }
        
        append _ "))" 
    }
    set t(11) [clock milliseconds]      
    #ZONES DEFINITION++++++++++
    
    append _ "\n(0 \"Zones definition:\")"
    
    dict for {id info} $dict_zones {      
        dict with info {
            append _ "\n(45 ($ZONE_ID $ZONE_TYPE $id)())"
        }
    }
    
    array unset face_to_elements
    set dict_elements ""
    set dict_zones ""
    
    set t(12) [clock milliseconds]  
    for {set i 0} {$i<12} {incr i} {
        WarnWinText "$i   [expr ($t([expr $i+1])-$t($i))*0.001]"
    }
    return $_
}

proc OpenFoam::FillCondnameComboboxValues { condname } {
    set values ""      
    if { [string match *Boundary* $condname] } {
        set initial_list {Condition1 Condition2 Condition3 Condition4}
    } elseif { [string match *Continuum* $condname] } {
        set initial_list {Continuum1 Continuum2 Continuum3 Continuum4}
    } else {
        set initial_list ""
    }    
    foreach domain [list geometry mesh] {
        foreach cnd [GiD_Info conditions $condname $domain] {
            set name [lindex $cnd 4]
            if { [lsearch $values $name] == -1 && [lsearch $initial_list $name] == -1 } { 
                lappend values $name 
            }
        }
    }    
    if { [llength $values] } { lappend values --- }            
    lappend values {*}$initial_list
    return $values
}

proc OpenFoam::TkwidgetCondnameCombobox { event args } {
    variable tkwidgedpriv
    switch $event {
        INIT {
            lassign $args PARENT current_row_variable GDN STRUCT QUESTION    
            upvar $current_row_variable ROW    
            #set entry $PARENT.e$ROW
            set entry ""
            foreach item [grid slaves $PARENT -row [expr $ROW-1]] {
                if { [winfo class $item] == "Entry"  || [winfo class $item] == "TEntry" } {
                    #assumed that it is the only entry of this row
                    set entry $item
                    break
                }
            }    
            #initialize variable to current field value            
            if { [DWLocalGetValue $GDN $STRUCT $QUESTION] != "" } {
                set tkwidgedpriv($QUESTION,name) [DWLocalGetValue $GDN $STRUCT $QUESTION]                 
            } else {
                set condname [lindex [split $STRUCT ","] 1]
                set tkwidgedpriv($QUESTION,name) [lindex [OpenFoam::FillCondnameComboboxValues $condname] 0]
            }
            #trick to fill in the values pressing transfer from an applied condition
            if { [lindex [info level 2] 0] == "DWUpdateConds" } {
                set values [lrange [lindex [info level 2] 2] 3 end]
                set index_field [LabelField $GDN $STRUCT $QUESTION]
                set value [lindex $values $index_field-1]
                set tkwidgedprivfilenamebutton($QUESTION,name) $value
            }
            #replace the entry by a frame with my own widgets
            if { $entry != "" } {                
                #set width [$entry cget -width]
                set width 15                
                set condname [lindex [split $STRUCT ","] 1]               
                set w [ttk::frame $PARENT.frame$QUESTION] ;#use a name depending on $QUESTION to allow more than one row changed
                ttk::combobox $w.combo$QUESTION -textvariable OpenFoam::tkwidgedpriv($QUESTION,name) \
                    -values [OpenFoam::FillCondnameComboboxValues $condname] -width $width                
                set tkwidgedprivfilenamebutton($QUESTION,widget) $w
                grid $w.combo$QUESTION -sticky ew
                grid columnconfigure $w {0} -weight 1
                grid $w -row [expr $ROW-1] -column 1 -sticky ew -columnspan 2
                GidHelpRecursive $w [= "Enter the name for the condition"]
                if { $entry != "" } {
                    grid remove $entry
                } else {
                    #assumed that entry is hidden and then hide the usurpating frame
                    grid remove $w
                }
            }
        }
        SYNC {         
            lassign $args GDN STRUCT QUESTION            
            if { [info exists tkwidgedpriv($QUESTION,name)] } {        
                DWLocalSetValue $GDN $STRUCT $QUESTION $tkwidgedpriv($QUESTION,name)
            }
        }
        DEPEND {
            lassign $args GDN STRUCT QUESTION ACTION VALUE            
            if { [info exists tkwidgedpriv($QUESTION,widget)] && [winfo exists $tkwidgedpriv($QUESTION,widget)] } {
                if { $ACTION == "HIDE" } {
                    grid remove $tkwidgedpriv($QUESTION,widget)
                } else {
                    #RESTORE
                    grid $tkwidgedpriv($QUESTION,widget)
                }
            } else {
                
            }
        }
        CLOSE {
            array unset tkwidgedpriv
        }
        default {
            return [list ERROR [_ "Unexpected tkwidget event"]]
        }
    }
    #a tkwidget procedure must return "" if Ok or [list ERROR $description] or [list WARNING $description]
    return ""  
}

proc OpenFoam::Update_conditions { op args } {    
    switch $op {        
        "SYNC" {   
            if { 1 } {
                #because now there is only implemented 3D, not 2D
            } else {
                set problem_dimension [string index [GiD_AccessValue get gendata Problem_dimension] 0]             
                switch $problem_dimension {
                    2 {
                        set normal_book "2D"
                        set hidden_book "3D"
                    }
                    3 {
                        set normal_book "3D"
                        set hidden_book "2D"
                    }     
                }    
                
                GiD_ShowBook conditions $normal_book 1    
                GiD_ShowBook conditions $hidden_book 0 
                OpenFoam::AddToolbar
                GiDMenu::UpdateMenus
            }                        
        }          
    } 
}

proc OpenFoam::OpenFoam_cond_number { real_name } {
    variable cond_list
    variable cond_ident
    set position [lsearch -dictionary -sorted $cond_list $real_name]
    if { $position ne "-1"} {
        return [lindex $cond_ident $position]        
    }
    return -1;
}

proc OpenFoam::OpenFoam_cond_name { ident } {
    variable cond_list
    variable cond_ident
    set position [lsearch $cond_ident $ident]
    if { $position ne "-1"} {
        return [string tolower [lindex $cond_list $position]]
    }
    return -1;
}

# GiD Triangle faces:        12   23   31
# GiD Quadrilateral faces:   12   23   34   41
# GiD Tetra faces: 123  243  341  421
# GiD Hexa faces: 1234  1485  1562  2673  3784  5876
# GiD Prism faces: 123 1452 2563 3641  465      
# GiD Pyramid faces: 1234 152 253 354 451   

#face_ident from 1
proc OpenFoam::extract_connectivities_old { element_line elemtype face_ident faces_distribution} { 
    set faces_list [lindex [dict get $faces_distribution $elemtype] [expr ($face_ident-1)]]

    set nodes_list ""
    foreach position $faces_list {
        lappend nodes_list [lindex $element_line $position]          
    }
    return $nodes_list
}

#face_ident from 0  
proc OpenFoam::extract_connectivities { element_line face_localnodes} {    
    foreach i $face_localnodes {
        lappend nodes_list [lindex $element_line $i]          
    }
    return $nodes_list
}

proc OpenFoam::give_hexadecimal_name { face } {
    set facehex ""
    foreach item $face {
        lappend facehex [format %d $item]
    }
    return [join $facehex :]
}

proc OpenFoam::writefile { filename } {  
    
    if {[GiD_Info Project Quadratic]!=0} {error [= "This interface does not support quadratic elements"]}  
    
    set problem_dimension [string index [GiD_AccessValue get gendata Problem_dimension] 0] 
    set element_types [lrange [GiD_Info Mesh] 1 end]
    if { $element_types == "" } {error [= "Must generate a mesh"]}  
    if { $problem_dimension == 2 } {
        foreach element_type $element_types {
            if { [lsearch {Triangle Quadrilateral} $element_type] == -1 } {
                error [= "Wrong element type '%s', for 2D must be Triangle or Quadrilateral" $element_type]
            }
        }        
    } elseif { $problem_dimension == 3 } {
        foreach element_type $element_types {
            if { [lsearch {Tetrahedra Hexahedra Prism Pyramid} $element_type] == -1 } {
                error [= "Wrong element type '%s', for 3D must be Tetrahedra Hexahedra Prism or Pyramid" $element_type]
            }
        }
    } else {
        error [= "wrong dimension, must be 2 or 3"]
    }

    #It's not possible to skip elements keeping the proper zone as done with the nodes.
    #That's why a dict_elements with the real element number is created. 
    #This simplification is very important in terms of zone spliting for OpenFoam    

    switch $problem_dimension {
        2 {
            set elemtype_list {Triangle Quadrilateral}
            set cnd_type Surface_Continuum              
            set cnd_type_boundary Line_Boundary_conditions 
            set types_list {1 3}
            set local_types [list Linear]
        }
        3 {
            set elemtype_list {Tetrahedra Hexahedra Prism Pyramid}
            set cnd_type Volume_Continuum           
            set cnd_type_boundary Surface_Boundary_conditions
            set types_list {2 4 6 5}
            set local_types [list Triangle Quadrilateral]
        }      
    }

    #We construct conset array with the contiuum conditions info

    array unset contset
    foreach cnd [GiD_Info conditions $cnd_type mesh] {
        lappend contset([lindex $cnd 4]) [list [lindex $cnd 1] [lindex $cnd 3]]
    }   

    #We construct the default array
    #By default, we consider a fluid cell

    set nelem_local 0 
    foreach local_type $local_types {        
        set nelem_local [expr ($nelem_local+[GiD_Info Mesh NumElements $local_type])]   
    }       
    set maxelem [GiD_Info Mesh MaxNumElements]
    set nelem [GiD_Info Mesh NumElements]

    if { $nelem == $maxelem && $nelem_local == 0 } {
        #avoid check if element exists and use an array
        for {set i 1} {$i<=$maxelem} {incr i} {
            set defaultfluid($i) 1
        }
        foreach item [GiD_Info Conditions $cnd_type mesh] {
            set i [lindex $item 1]
            unset defaultfluid($i)
        }
        foreach i [lsort -integer [array names defaultfluid]] {
            lappend contset(Default_continuum) [list $i fluid]
        }
        unset defaultfluid
    } else {
        for {set i 1} {$i<=$maxelem} {incr i} {   
            foreach valid_element $elemtype_list {
                if {[GiD_Info Mesh Elements $valid_element $i] ne "" } {  
                    if {[GiD_Info Conditions $cnd_type mesh $i] eq "{0 -}"} {
                        lappend contset(Default_continuum) [list $i fluid]
                    }                            
                }    
            }
        }
    }  
 
    #And now we print all continuum zones

    set num_elems 0

    foreach cont_group [array names contset] {
        
        set cont_info [lsort -unique $contset($cont_group)]  
        set printed_caption 0

        foreach cell $cont_info {        

            incr num_elems
            
            foreach {real_elementid type} $cell break
            
            set dict_elements($real_elementid) $num_elems
        }
    }

    array unset contset

    #Writing OpenFOAM file header++++++++++++++++++++++++++++++++++++++++

    set newfilename "[file dirname $filename]/points"
    set fp [open $newfilename "w"]
    if { $fp == "" } {
        return 1
    }

    set _ ""
    append _ "// ***Created by GiD on [clock format [clock seconds] -format %d-%h-%y]"
    append _ " at [clock format [clock seconds] -format %H:%M:%S] ***//\n"
        
    append _ "FoamFile\n"  
    append _ "\{\n" 
    append _ "version     2.0;\n"
    append _ "format      ascii;\n"
    append _ "location    \"constant/polyMesh\";\n"
    append _ "class       vectorField;\n"
    append _ "object      points;\n"
    append _ "\}\n\n" 
    append _ "// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //\n\n"
    
    #Writing nodes++++++++++++++++++++++++++++++++++++++++

    #We save enough space for all the nodes 
    
    set maxnodes [GiD_Info Mesh MaxNumNodes]
    set nnodes [GiD_Info Mesh NumNodes]
    
    #If there is no skipped node, we print them all in a single caption
    
    if {$maxnodes == $nnodes} {
        append _ "[format %d $maxnodes]\n"
        append _ "(\n"
        puts -nonewline $fp $_ ; set _ ""
        #We enter the information for each node
        if { $problem_dimension == 3 } {
            foreach "n x y z" [GiD_Info Mesh Nodes] {
                puts $fp "([format {%18e %18e %18e} $x $y $z])"
            }
        } else {
            foreach {n x y z} [GiD_Info Mesh Nodes] {
                puts $fp "([format {%18e %18e} $x $y])"
            }
        }
        puts $fp ")\n"
        puts $fp "\n"
        puts $fp "// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //"
    } else {
        #We enter the information for each node
        if { $problem_dimension == 3 } {
            foreach "n x y z" [GiD_Info Mesh Nodes] {
                puts $fp "(10 ([format %x $num_zones] [format %d $n] [format %d $n] 1 $problem_dimension)("
                puts $fp  "[format "%18e %18e %18e" $x $y $z]))"
            }
        } else {
            foreach {n x y z} [GiD_Info Mesh Nodes] {
                puts $fp "(10 ([format %d $num_zones] [format %d $n] [format %d $n] 1 $problem_dimension)("
                puts $fp "[format "%18e %18e" $x $y]))"
            }
        }

        # We write as virtual nodes the undefined nodes

        foreach n [lindex [GiD_Info Mesh Nodes -array] 0] {
            set existnode($n) 1
        }
        set prefix "(10 ([format %x $num_zones]"
        if { $problem_dimension == 3 } {
            set suffix "0 $problem_dimension)(\n 0.00000000e+00  0.00000000e+00  0.00000000e+00\n))"
        } else {
            set suffix "0 $problem_dimension)(\n 0.00000000e+00  0.00000000e+00\n))"
        }
        for {set i 1} {$i<=$maxnodes} {incr i} {
            if {![info exists existnode($i)]} {
                set texti [format %d $i]
                puts $fp "$prefix $texti $texti $suffix" 
            }
        }
        unset existnode
    }

    close $fp



    #Writing OpenFOAM file header++++++++++++++++++++++++++++++++++++++++

    set newfilename "[file dirname $filename]/faces"
    set fp [open $newfilename "w"]
    if { $fp == "" } {
        return 1
    }

    set _ ""
    append _ "// ***Created by GiD on [clock format [clock seconds] -format %d-%h-%y]"
    append _ " at [clock format [clock seconds] -format %H:%M:%S] ***//\n"

    append _ "FoamFile\n"  
    append _ "\{\n" 
    append _ "version     2.0;\n"
    append _ "format      ascii;\n"
    append _ "location    \"constant/polyMesh\";\n"
    append _ "class       faceList;\n"
    append _ "object      faces;\n"
    append _ "\}\n\n"
    append _ "// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //\n\n"

    #Writing faces+++++++++++++++++++++++++++++++

    set faces_distribution(Triangle)  [list [list 1 2] [list 2 3] [list 3 1]]
    set faces_distribution(Quadrilateral) [list [list 1 2] [list 2 3] [list 3 4] [list 4 1]]
    set faces_distribution(Tetrahedra) [list [list 1 2 3] [list 2 4 3] [list 3 4 1] [list 4 2 1]]
    set faces_distribution(Hexahedra) [list [list 1 2 3 4] [list 1 4 8 5] [list 1 5 6 2] [list 2 6 7 3] [list 3 7 8 4] [list 5 8 7 6]]
    set faces_distribution(Prism) [list [list 1 2 3] [list 1 4 5 2] [list 2 5 6 3] [list 3 6 4 1] [list 4 6 5]]
    set faces_distribution(Pyramid) [list [list 1 2 3 4] [list 1 5 2] [list 2 5 3] [list 3 5 4] [list 4 5 1]]
    
    array unset bndry_name_to_type

    # Note: In OpenFOAM, face number start from 0 (inside GiD start from 1)
    
    foreach cnd [GiD_Info conditions $cnd_type_boundary mesh] {        
        lassign $cnd c0 c1 c2 c3 c4
        incr c1 -1
        lappend faceset($c4) [list $c0 $c1 [OpenFoam_cond_number $c3]]
        set bndry_name_to_type($c4) $c3
    }

    # First we create our array relating each face with the positive and negative element    

    array unset face_to_elements   

    foreach elemtype $elemtype_list {
        foreach element_line [GiD_Info Mesh Elements $elemtype -sublist] {
            foreach face_localnodes $faces_distribution($elemtype) {           
                set face_connectivities [extract_connectivities $element_line $face_localnodes]
                set face_key [give_hexadecimal_name [lsort -integer $face_connectivities]]                        
                if { ![info exists face_to_elements($face_key)] } { 
                    set face_to_elements($face_key) [list 0 [give_hexadecimal_name $face_connectivities]]
                    # First index indicate that the position is not already printed 
                }
                lappend face_to_elements($face_key) [lindex $element_line 0]
            }
        }
    }

    #General face caption

    if {[array size face_to_elements] ne "0"} {
        append _ "[format %d [array size face_to_elements]]\n"        
    }
    append _ "(\n"

    #Printing internal faces

    set interior_faces 0
    set wall_faces 0

    foreach face [array names face_to_elements] {
        if {([lindex $face_to_elements($face) 0] eq "0")} {
            switch [llength $face_to_elements($face)] {
                4 {
                    incr interior_faces
                }
                3 {
                    incr wall_faces
                }
                default {}
            }
        }
    }

    if {$interior_faces > 0} {
        incr num_zones
        foreach face [array names face_to_elements] {
            if {[lindex $face_to_elements($face) 0] eq "0" && [llength $face_to_elements($face)] eq "4"} {
                set connectivities [split [lindex $face_to_elements($face) 1] ":"]
                append _ [llength $connectivities]
                append _ "("

                # Note: In OpenFOAM, node number start from 0 (inside GiD start from 1)

                set arr_length [llength $connectivities]
                set iloop 0
                while {$iloop < $arr_length} {
                        append _ " [format %d [expr ([lindex $connectivities [expr ($arr_length-$iloop-1)]]-1)]]"
                        incr iloop
                 }
                #foreach node $connectivities { append _ " [format %d [expr ($node-1)]]" }
                append _ ")\n"
            }
        }
    }
    puts -nonewline $fp $_ ; set _ ""

    #Printing boundary faces:

    set bndry_faces 0
    foreach i [array names faceset] {
        set face_info [lsort -unique $faceset($i)]
        foreach face $face_info {
            lassign $face elem face_ident type
            set connectivities ""
            foreach elemtype $elemtype_list  {
                set element_line [GiD_Info mesh Elements $elemtype $elem]
                if {$element_line ne ""} {
                    set connectivities [extract_connectivities $element_line [lindex $faces_distribution($elemtype) $face_ident]]                   
                    break
                }
            }

            #Printing each face line
            append _ "[llength $connectivities]"
            append _ "("

            # Note: In OpenFOAM, all boundary faces point outwards, which is
            # opposite from the GiD convention. Turn them around on printout.
            # Note: In OpenFOAM, node number start from 0 (inside GiD start from 1)

            set arr_length [llength $connectivities]
            set iloop 0
            while {$iloop < $arr_length} {
                    append _ " [format %d [expr ([lindex $connectivities [expr ($arr_length-$iloop-1)]]-1)]]"
                incr iloop
            }

            #foreach connectivity_node $connectivities {
            #    append _ " [format %d [expr ($connectivity_node-1)]]"
            #}

            append _ ")\n"
            incr bndry_faces
        }
    }

    append _ "\n"
    append _ ")\n"
    puts -nonewline $fp $_ ; set _ ""

    #  if {[expr ($bndry_faces+$interior_faces)] ne [array size face_to_elements]} {
    #      error [= "Error in computing face numbers. Please correct this"]
    #  }
    #  this is not always true, because 
    #  bndry_faces are the faces of Surface_Boundary_conditions, not compulsory the faces with higherentity==1
    #  interior_faces ared the faces with higherentity==2
    #  face_to_elements is an array with all faces unrepeated

    #Default Wall zone

    if {$wall_faces > 0} {
    }
    append _ "\n"
    append _ "// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //"
    puts -nonewline $fp $_ ; set _ ""

    close $fp



    #Writing OpenFOAM file header++++++++++++++++++++++++++++++++++++++++

    set newfilename "[file dirname $filename]/boundary"
    set fp [open $newfilename "w"]
    if { $fp == "" } {
        return 1
    }

    set _ ""
    append _ "// ***Created by GiD on [clock format [clock seconds] -format %d-%h-%y]"
    append _ " at [clock format [clock seconds] -format %H:%M:%S] ***//\n"

    append _ "FoamFile\n"  
    append _ "\{\n" 
    append _ "version     2.0;\n"
    append _ "format      ascii;\n"
    append _ "location    \"constant/polyMesh\";\n"
    append _ "class       polyBoundaryMesh;\n"
    append _ "object      boundary;\n"
    append _ "\}\n\n"
    append _ "// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //\n\n"

    #Writing Boundary+++++++++++++++++++++++++++++++

    set num_bndry [array size faceset]
    set num_faces 0

    if {$num_bndry ne "0"} {
        append _ "[format %d $num_bndry]\n"        
    }

    append _ "(\n"

    set face_num 0
    set last_bndry_num 0
    foreach i [array names faceset] {
        append _ "    $i\n"
        append _ "    \{\n"
        set bndry_type $bndry_name_to_type($i)
        append _ "       type $bndry_type;\n"
        set face_info [lsort -unique $faceset($i)]
        set j 0
        foreach face $face_info {
            incr j
        }
        append _ "       nFaces $j;\n"
        set last_bndry_num [expr ($interior_faces+$face_num)]
        append _ "       startFace $last_bndry_num;\n"
        incr face_num $j
        append _ "    \}\n"
    }

    append _ ")\n"
    append _ "\n"
    append _ "// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //"
    puts -nonewline $fp $_ ; set _ ""

    close $fp



    #Writing OpenFOAM file header++++++++++++++++++++++++++++++++++++++++

    set newfilename "[file dirname $filename]/owner"
    set fp [open $newfilename "w"]
    if { $fp == "" } {
        return 1
    }

    set _ ""
    append _ "// ***Created by GiD on [clock format [clock seconds] -format %d-%h-%y]"
    append _ " at [clock format [clock seconds] -format %H:%M:%S] ***//\n"
        
    append _ "FoamFile\n"  
    append _ "\{\n" 
    append _ "version     2.0;\n"
    append _ "format      ascii;\n"
    append _ "location    \"constant/polyMesh\";\n"
    append _ "class       labelList;\n"
    append _ "object      owner;\n"
    append _ "\}\n\n"
    append _ "// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //\n\n"

    #Writing Owner+++++++++++++++++++++++++++++++

    # Firstly, for internal faces, two neighbouring cells are recorded in each element of the array face_to_elements, the
    # first of which is considered as the face's owner, and the other cell is its slave/neighbour.

    if {$interior_faces > 0} {
        append _ "[format %d [array size face_to_elements]]\n"
        append _ "(\n"
        set icounter 0
        foreach face [array names face_to_elements] {
            if {[lindex $face_to_elements($face) 0] eq "0" && [llength $face_to_elements($face)] eq "4"} {
                set owner [expr ([lindex $face_to_elements($face) 2]-1)]
                append _ " [format %d $owner]"
                incr icounter
                if {$icounter == 10} {
                    append _ "\n"
                    set icounter 0
                }
            }
        }
    }

    # Then boundary faces. Only one neighbouring cell is recorded in each element of the array face_to_elements, which
    # is considered as the face's owner.

    foreach i [array names faceset] {
        set face_info [lsort -unique $faceset($i)]
        foreach face $face_info {
            lassign $face elem face_ident type
            set owner [expr ($elem-1)]
            append _ " [format %d $owner]"
            incr icounter
            if {$icounter == 10} {
                append _ "\n"
                set icounter 0
            }
        }
    }
    append _ "\n"
    append _ ")\n"

    append _ "\n"
    append _ "// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //"
    puts -nonewline $fp $_ ; set _ ""

    close $fp



    #Writing OpenFOAM file header++++++++++++++++++++++++++++++++++++++++

    set newfilename "[file dirname $filename]/neighbour"
    set fp [open $newfilename "w"]
    if { $fp == "" } {
        return 1
    }

    set _ ""
    append _ "// ***Created by GiD on [clock format [clock seconds] -format %d-%h-%y]"
    append _ " at [clock format [clock seconds] -format %H:%M:%S] ***//\n"
        
    append _ "FoamFile\n"  
    append _ "\{\n" 
    append _ "version     2.0;\n"
    append _ "format      ascii;\n"
    append _ "location    \"constant/polyMesh\";\n"
    append _ "class       labelList;\n"
    append _ "object      neighbour;\n"
    append _ "\}\n\n"
    append _ "// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //\n\n"
    
    #Writing Neighbour+++++++++++++++++++++++++++++++
    
    # for internal faces, two neighbouring cells are recorded in each element of the array face_to_elements, the
    # second of which is considered as slave/neighbour.

    if {$interior_faces > 0} {
        append _ "[format %d $interior_faces]\n"
        append _ "(\n"
        set icounter 0
        foreach face [array names face_to_elements] {
            if {[lindex $face_to_elements($face) 0] eq "0" && [llength $face_to_elements($face)] eq "4"} {
                set neighbour [expr ([lindex $face_to_elements($face) 3]-1)]
                append _ " [format %d $neighbour]"
                incr icounter
                if {$icounter == 10} {
                    append _ "\n"
                    set icounter 0
                }
            }
        }
    }

    # The boundary faces have no slave/neighbour.

    append _ "\n"
    append _ ")\n"

    append _ "\n"
    append _ "// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //"
    puts -nonewline $fp $_ ; set _ ""

    close $fp

    return ""
}