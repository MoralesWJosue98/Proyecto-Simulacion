proc InitGIDProject { dir } {
    set Fluent::_dir $dir
    if { [info procs ReadProblemtypeXml] != "" } {
        #this procedure exists after GiD 11.1.2b
        set data [ReadProblemtypeXml [file join $dir Fluent.xml] Infoproblemtype {Version MinimumGiDVersion MinimumAmeletPluginVersion}]                
    } else {
        #this procedure is a copy of ReadProblemtypeXml to be able to work with previous GiD's
        set data [Fluent::ReadProblemtypeXml [file join $dir Fluent.xml] Infoproblemtype {Version MinimumGiDVersion MinimumAmeletPluginVersion}]
    }    
    if { $data == "" } {
        WarnWinText [= "Configuration file %s not found" [file join $dir Fluent.xml]]
        return 1
    }
    array set problemtype_local $data
    set Fluent::VersionNumber $problemtype_local(Version)
   
      
    set GiDVersionRequired 9.1.0b
    set comp -1
    catch { set comp [GiDVersionCmp $GiDVersionRequired] }
    if { $comp < 0 } {
	WarnWin [= "This interface requires GiD %s or later" $GiDVersionRequired]
    }

    Fluent::splash $dir 1
    Fluent::modifymenus

    Fluent::MyBitmaps $dir    
}

proc EndGIDProject {} {
    Fluent::EndMyBitmaps   
}

proc ChangedLanguage { newlanguange } {
    #to force refresh some menus managed by the problemtype when the user change to newlanguage
    Fluent::modifymenus
}

proc AfterWriteCalcFileGIDProject { filename errorflag } {    
    set ret ""
    #set err [catch { Fluent::_writefile_old } string]
    set err [catch { Fluent::writefile $filename } string]    
    if { $err } { 
	WarnWin $string 
	set ret -cancel-
    } else {
	set newfilename [file rootname $filename]-Fluent.msh
	file rename -force $filename $newfilename
    }
    return $ret
}

proc LoadGIDProject { filespd } {
    if { [file join {*}[lrange [file split $filespd] end-1 end]] == "Fluent.gid/Fluent.spd" } {
        #loading the problemtype itself, not a model
    } else {
        set pt [GiD_Info project ProblemType]
        if { $pt == "Fluent" } {
            set filename [file rootname $filespd].xml
            set model_problemtype_version_number [Fluent::ReadXml $filename]            
            if { $model_problemtype_version_number != -1 && $model_problemtype_version_number < $::Fluent::VersionNumber } {            
                set must_transform 1
            } else {
                set must_transform 0
            }
            if { $must_transform } {
                after idle [list Fluent::Transform $model_problemtype_version_number $::Fluent::VersionNumber]
            }
        }
    }
}

proc SaveGIDProject { filespd } {
    set filename [file rootname $filespd].xml
    Fluent::SaveXml $filename
}

###################

namespace eval Fluent { 
    variable ProgramName Fluent
    variable VersionNumber ;#interface version, get it from xml to avoid duplication 
    variable _dir ;#path to the problemtype

    #Warning: cond_list must be -dictionary ordered, and cond_ident be on the same order!!
    variable cond_list {axis exhaust-fan fan inlet-vent intake-fan interface mass-flow-inlet \
	outflow outlet-vent parent periodic porous-jump pressure-far-field \
	pressure-inlet pressure-outlet radiator symmetry velocity-inlet wall}
    #Decimals added in order to create a bijective application
    variable cond_ident {37 5.1 14.1 4.1 4.2 24 20 5.2 36 31 12 14.2 9 4.3 5.3 14.3 7 10 3}
}

proc Fluent::SaveXml { filename } {
    variable ProgramName
    variable VersionNumber
    set fp [open $filename w]
    if { $fp != "" } {
        puts $fp {<?xml version='1.0' encoding='utf-8'?><!-- -*- coding: utf-8;-*- -->}
        puts $fp "<$ProgramName version='$VersionNumber'/>"
        close $fp
    }
}

#return -1 if the xml is not an problemtype one or if the xml not exists
#        the problemtype version of the model of the xml file
proc Fluent::ReadXml { filename } {
    variable ProgramName
    set model_problemtype_version_number -1
    if { [file exists $filename] } {
        set fp [open $filename r]
        if { $fp != "" } {
            set line ""
            gets $fp header
            gets $fp line ;#something like: <Fluent version='1.0'/>
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

proc Fluent::Transform { from_version to_version } {    
    variable ProgramName
    GiD_Process escape escape escape escape Data Defaults TransfProblem $ProgramName escape    
}

#this procedure is a copy of ReadProblemtypeXml to be able to work with previous GiD's
proc Fluent::ReadProblemtypeXml { xmlfile root_name fields } {
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



proc Fluent::splash { dir autodestroy } {
    variable VersionNumber
    if { [GidUtils::IsTkDisabled] } {
	return
    }    
    if { [::GidUtils::VersionCmp 9.1.0b] >= 0 } {
	set text "Version $VersionNumber"
	GidUtils::Splash [file join $dir images fluent_about.gif] \
	    .splash $autodestroy [list $text 70 300]
    } else {
	#code unnecesary form GiD 9.1.0b, GidUtils::Splash can be used
	variable splashshown
	
	if { [.gid.central.s disable windows] } { return }
	
	if { [info exists splashshown] && $autodestroy } { return }
	if { [ winfo exist .splash]} {
	    destroy .splash
	    update
	}
	set splashshown 1
	
	toplevel .splash
	wm withdraw .splash
	
	set im [image create photo -file [file join $dir images fluent_about.gif]]
	set x [expr [winfo screenwidth .splash]/2-[image width $im]/2]
	set y [expr [winfo screenheight .splash]/2-[image height $im]/2]

	wm geometry .splash +$x+$y
	wm transient .splash .gid
	wm overrideredirect .splash 1
	pack [label .splash.l -image $im -relief ridge -bd 2]
	
	label .splash.lv -text "Version $VersionNumber" -font "times 32"
	place .splash.lv -x 70 -y 300
	bind .splash <1> "destroy .splash"
	bind .splash <KeyPress> "destroy .splash"
	grab .splash
	focus .splash
	update
	wm deiconify .splash
	raise .splash .gid
	update
	if { $autodestroy } {
	    after 2000 "if { [ winfo exist .splash] } { 
	    destroy .splash
	}"
	}
    }
}

proc Fluent::modifymenus { } {
    if { [GidUtils::IsTkDisabled] } {
	return
    }
    set dir $Fluent::_dir
    foreach where {PRE POST} {
	GiDMenu::InsertOption "Help#C#menu" [list [= "FLUENT interface help"]] 0 $where \
	    [list GiDCustomHelp -dir [file join $dir info] \
		 -title [= "FLUENT interface help"] -report 0] \
	    "" "" "insert" =
	GiDMenu::InsertOption "Help#C#menu" [list [= "About FLUENT interface"]] end $where \
	    [list Fluent::splash $dir 0] "" "" "insertafter" =        
    }
    
    #InsertMenuOption [_ Calculate] [_ Calculate] 0 "GiD_Process Mescape Files WriteCalcFile" PRE replace
   
    GidChangeDataLabel "Problem Data" ""
    GidAddUserDataOptions [= "Problem Dimension"] "GidOpenProblemData" 2
    
    #We hide one of the conditions set    
    
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
    
    GidChangeDataLabel "Conditions" [= "Zones Definition"]
    GiD_ShowBook conditions $hidden_book 0   
    GiD_ShowBook conditions $normal_book 1   
    GiDMenu::UpdateMenus
}

proc Fluent::MyBitmaps { dir { type "DEFAULT INSIDELEFT"} } {
    if { [GidUtils::IsTkDisabled] } {
	return
    }

    global FluentBitmapsNames FluentBitmapsCommands FluentBitmapsHelp ProblemTypePriv

    set FluentBitmapsNames(0) "images/dimension.gif images/section.gif images/calc.gif"    
    
    set problem_dimension [string index [GiD_AccessValue get gendata Problem_dimension] 0] 
    
    switch $problem_dimension {
	2 {
	    set normal_book "2D"
	}
	3 {
	    set normal_book "3D"
	}     
    }      
    
    set FluentBitmapsCommands(0) [list [list -np- GidOpenProblemData] [list -np- GidOpenConditions $normal_book] \
	    "Utilities Calculate"]

    set FluentBitmapsHelp(0) [list [= "Choose the dimension of the Problem"] [= "Define Boundary Conditions and Continuum zones"] [= "Output file"]]

    # prefix values:
    #          Pre        Only active in the preprocessor
    #          Post       Only active in the postprocessor
    #          PrePost    Active Always

    set prefix Pre

    set ProblemTypePriv(toolbarwin) [CreateOtherBitmaps FluentBar [= "FLUENT bar"] \
	    FluentBitmapsNames FluentBitmapsCommands \
	    FluentBitmapsHelp $dir "Fluent::MyBitmaps [list $dir]" $type $prefix]
    AddNewToolbar "FLUENT bar" ${prefix}FluentBarWindowGeom \
	"Fluent::MyBitmaps [list $dir]" [= "FLUENT bar"]
}

proc Fluent::EndMyBitmaps {} {
    if { [GidUtils::IsTkDisabled] } {
	return
    }

    global ProblemTypePriv
    
#     global BitMapsNames BitMapsCommands BitmapsHelp
#     set BitMapsNames(0) [lreplace $BitMapsNames(0) 0 2]
#     set BitMapsCommands(0) [lreplace $BitMapsCommands(0) 0 2]
#     set BitmapsHelp(0) [lreplace $BitmapsHelp(0) 0 2]
#     return

    ReleaseToolbar "FLUENT bar"
    #rename MyBitmaps ""
    catch { destroy $ProblemTypePriv(toolbarwin) }
}

proc Fluent::writefile_old {} {
    set err [catch { Fluent::_writefile_old } string]
    if { $err } { WarnWin $string }
    return $string
}


proc Fluent::_writefile_old {} {  
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
    #That's why a dict_elements with the real element number is created. This simplification is very important in terms of zone spliting for FLUENT    
       
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
	lappend faceset([lindex $cnd 4]) [list [lindex $cnd 0] [lindex $cnd 1] [Fluent_cond_number [lindex $cnd 3]]]
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
		dict set dict_zones $i ZONE_TYPE [Fluent_cond_name $original_type] 
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

proc Fluent::ComunicateWithGiD { op args } {
    
    variable SetName
    
    switch $op {
	"INIT" {
	    set PARENT [lindex $args 0]
	    upvar      [lindex $args 1] ROW
	    set GDN [lindex $args 2]
	    set STRUCT [lindex $args 3]
	    
	    set f [frame $PARENT.f]
	    
	    set values ""
	    
	    set condname [lindex [split $STRUCT ","] 1] 
	    
	    
	    if { [string match *Boundary $condname] } {
		set initial_list {Cond1 Cond2 Cond3 Cond4}
	    } elseif { [string match *Continuum $condname] } {
		set initial_list {Cont1 Cont2 Cont3 Cont4}
	    } else {
		set initial_list {Cond1 Cond2 Cond3 Cond4}
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
	    append values " $initial_list"
	    
	    label $f.l1 -text [= "Name"]
	    if { ![info exists SetName] || [string trim $SetName] eq "" } {
		set SetName [lindex $values 0]
	    }
	    ComboBox $f.cb1 -textvariable Fluent::SetName -values $values
	    #$f.cb1 setvalue first
	    after 100 Widget::traverseTo $f.cb1
	    
	    grid $f.l1 $f.cb1 -sticky nw
	    grid configure $f.cb1 -sticky new -padx "1 5"
	    grid rowconfigure $f 1 -weight 1
	    grid columnconfigure $f 1 -weight 1
	    
	    GidHelpRecursive $f [= "Enter the name for the condition"]
	    grid $f -row $ROW -column 0 -sticky nsew -columnspan 2 -pady 3 -padx 2
	    grid rowconf $PARENT $ROW -weight 1
	    grid columnconf $PARENT 1 -weight 1
	    return ""
	}
	"SYNC" {           
	    set GDN [lindex $args 0]
	    set STRUCT [lindex $args 1]
	    
	    set SetName [string trim $SetName]
	    if { $SetName eq "" } {
		return [list ERROR [= "Name is not valid"]]
	    } elseif {[string length $SetName]>"80"} {
		return [list ERROR [= "Name is too long"]]
	    } else {                
		DWLocalSetValue $GDN $STRUCT Name $SetName
	    }
	    return ""
	}
    }
}

proc Fluent::Update_conditions { op args } {    
    switch $op {        
	"SYNC" {   
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
	    
	    Fluent::MyBitmaps [GiD_Info problemtypepath]
	    GiDMenu::UpdateMenus
	}          
    } 
}

proc Fluent::Fluent_cond_number { real_name } {
    variable cond_list
    variable cond_ident
    set position [lsearch -dictionary -sorted $cond_list $real_name]
    if { $position ne "-1"} {
	return [lindex $cond_ident $position]        
    }
    return -1;
}

proc Fluent::Fluent_cond_name { ident } {
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
proc Fluent::extract_connectivities_old { element_line elemtype face_ident faces_distribution} { 
    set faces_list [lindex [dict get $faces_distribution $elemtype] [expr ($face_ident-1)]]

    set nodes_list ""
    foreach position $faces_list {
	lappend nodes_list [lindex $element_line $position]          
    }
    return $nodes_list
}

#face_ident from 0  
proc Fluent::extract_connectivities { element_line face_localnodes} {    
    foreach i $face_localnodes {
	lappend nodes_list [lindex $element_line $i]          
    }
    return $nodes_list
}

proc Fluent::give_hexadecimal_name { face } {
    set facehex ""
    foreach item $face {
	lappend facehex [format %x $item]
    }
    return [join $facehex :]
}

proc Fluent::writefile { filename } {  
    
    if {[GiD_Info Project Quadratic]!=0} {error [= "This interface does not support quadratic elements"]}  
    
    set problem_dimension [string index [GiD_AccessValue get gendata Problem_dimension] 0] 
    if { 0 } {
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
    }
    
    set fp [open $filename "w"]
    if { $fp == "" } {
	return 1
    }
    
    #set t(0) [clock milliseconds]
    
    
    set num_zones 0   
    
    #Writing General Data++++++++++++++++++++++++++++++++++++++++
    
    set _ ""
    append _ "(1 \"Created by GiD on [clock format [clock seconds] -format %d-%h-%y]"
    append _ " at [clock format [clock seconds] -format %H:%M:%S]\")\n"
	
    append _ "(0 \"Dimension:\")\n"  
    append _ "(2 $problem_dimension)\n" 
    
    #Writing nodes(ZONE=1)++++++++++++++++++++++++++++++++++++++++
    
    append _ "(0 \"Nodes:\")\n"
    incr num_zones    
    
    #We save enough space for all the nodes 
    
    set maxnodes [GiD_Info Mesh MaxNumNodes]
    append _ "(10 (0 1 [format %x $maxnodes] 0 $problem_dimension))\n"
    
    set nnodes [GiD_Info Mesh NumNodes]
    #If there is no skipped node, we print them all in a single caption
    
    
    if {$maxnodes == $nnodes} {
	append _ "(10 ([format %x $num_zones] 1 [format %x $maxnodes] 1 $problem_dimension)(\n"
	puts -nonewline $fp $_ ; set _ ""
	#We enter the information for each node
	if { $problem_dimension == 3 } {
	    foreach "n x y z" [GiD_Info Mesh Nodes] {
		puts $fp [format {%16e %16e %16e} $x $y $z]
	    }
	} else {
	    foreach {n x y z} [GiD_Info Mesh Nodes] {
		puts $fp [format {%16e %16e} $x $y]
	    }
	}
	puts $fp "))"
	#set t(1) [clock milliseconds]
    } else {
	#We enter the information for each node
	if { $problem_dimension == 3 } {
	    foreach "n x y z" [GiD_Info Mesh Nodes] {
		puts $fp "(10 ([format %x $num_zones] [format %x $n] [format %x $n] 1 $problem_dimension)("
		puts $fp  "[format "%16e %16e %16e" $x $y $z]))"
	    }
	} else {
	    foreach {n x y z} [GiD_Info Mesh Nodes] {
		puts $fp "(10 ([format %x $num_zones] [format %x $n] [format %x $n] 1 $problem_dimension)("
		puts $fp "[format "%16e %16e" $x $y]))"
	    }
	}
	
	#set t(1) [clock milliseconds]
	
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
		set texti [format %x $i]
		puts $fp "$prefix $texti $texti $suffix" 
	    }
	}
	unset existnode
    }
    
    #set t(2) [clock milliseconds]
    #Writing Cells+++++++++++++++++++++++++++++++
    
    set _ ""
    append _ "(0 \"Cells:\")\n" 
    
    #We save enough space for all the cells
    
    append _ "(12 (0 1 [format %x [GiD_Info Mesh NumElements]] 0))\n" 
    puts  -nonewline $fp $_ ; set _ ""
    
    #It's not possible to skip elements keeping the proper zone as done with the nodes.
    #That's why a dict_elements with the real element number is created. 
    #This simplification is very important in terms of zone spliting for FLUENT    
    
    array unset contset    
    
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
    
    foreach cnd [GiD_Info conditions $cnd_type mesh] {
	lassign $cnd over i sep c1 c2 
	lappend contset($c2) [list $i $c1]
    }
    
    #set t(3) [clock milliseconds]    
    #We construct the default array
    #By default, we consider a fluid cell
    set nelem_local 0 
    foreach local_type $local_types {        
	incr nelem_local [GiD_Info Mesh NumElements $local_type]
    }       
    set maxelem [GiD_Info Mesh MaxNumElements]
    set nelem [GiD_Info Mesh NumElements]
    
    if { $nelem == $maxelem && $nelem_local == 0 } {
	#avoid check if element exists and use an array
	for {set i 1} {$i<=$maxelem} {incr i} {
	    set defaultfluid($i) 1
	}
    } else {
	#add only existing volume elements in 3D /surfaces in 2D
	foreach valid_element $elemtype_list {
	    foreach i [lindex [lindex [GiD_Info Mesh Elements $valid_element -array] 0] 1] {
		set defaultfluid($i) 1
	    }
	}        
    }
    foreach item [GiD_Info Conditions $cnd_type mesh] {
	unset defaultfluid([lindex $item 1])
    }
    foreach i [lsort -integer [array names defaultfluid]] {
	lappend contset(Default_continuum) [list $i fluid]
    }
    unset defaultfluid
    
    #set t(4) [clock milliseconds]      
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
	    set dict_elements($real_elementid) $num_elems            
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
		set dict_zones($num_zones) [list $cont_group $original_type]                   
		append _ "(0 \"Continuum $num_zones : $cont_group\")\n"
		append _ "(12 ([format %x $num_zones] [format %x $num_elems] [format %x [expr ($num_elems+[llength $cont_info]-1)]] $translated_type 0)(\n"   
		set printed_caption 1
	    }
	    
	    if {$type ne $original_type} {
		error [= "Cell %s of continuum set %s has a continuum type not according with the rest of the elements from its condition. Please correct this" $real_elementid $cont_group]
	    }
	    append _ "$element_ident([lindex [GiD_Mesh get Element $real_elementid] 1]) "
	}
	append _ "\n))\n"
    }
    
    array unset contset
    puts -nonewline $fp $_ ; set _ ""

    #set t(5) [clock milliseconds]      
    #Writing faces++++++++++++++++++++++++++++++++++++++++ 
    
    
    set faces_distribution(Triangle)  [list [list 1 2] [list 2 3] [list 3 1]]
    set faces_distribution(Quadrilateral) [list [list 1 2] [list 2 3] [list 3 4] [list 4 1]]
    set faces_distribution(Tetrahedra) [list [list 1 2 3] [list 2 4 3] [list 3 4 1] [list 4 2 1]]
    set faces_distribution(Hexahedra) [list [list 1 2 3 4] [list 1 4 8 5] [list 1 5 6 2] [list 2 6 7 3] [list 3 7 8 4] [list 5 8 7 6]]
    set faces_distribution(Prism) [list [list 1 2 3] [list 1 4 5 2] [list 2 5 6 3] [list 3 6 4 1] [list 4 6 5]]
    set faces_distribution(Pyramid) [list [list 1 2 3 4] [list 1 5 2] [list 2 5 3] [list 3 5 4] [list 4 5 1]]
    
    #face number start from 0 (inside GiD start from 1)
    foreach cnd [GiD_Info conditions $cnd_type_boundary mesh] {        
	lassign $cnd c0 c1 c2 c3 c4
	incr c1 -1
	lappend faceset($c4) [list $c0 $c1 [Fluent_cond_number $c3]]
    }
    

    #set t(6) [clock milliseconds]         
    #First we create our array relating each face with the positive and negative element    
   
    array unset face_to_elements   
    
    foreach elemtype $elemtype_list {        
	foreach element_line [GiD_Info Mesh Elements $elemtype -sublist] {
	    foreach face_localnodes $faces_distribution($elemtype) {           
		set face_connectivities [extract_connectivities $element_line $face_localnodes]
		set face_key [give_hexadecimal_name [lsort -integer $face_connectivities]]                           
		if { ![info exists face_to_elements($face_key)] } { 
		    set face_to_elements($face_key) [list 0 [give_hexadecimal_name $face_connectivities]];
		    #First index indicate that the position is not already printed 
		}
		lappend face_to_elements($face_key) [lindex $element_line 0]
	    }
	}
    }

    #set t(7) [clock milliseconds]      
    #General face caption
    
    if {[array size face_to_elements] ne "0"} {
	append _ "(0 \"Faces:\")\n" 
	append _ "(13 (0 [format %x 1] [format %x [array size face_to_elements]] 0))\n"        
    }

    #Printing each face
    
    set num_faces 0
    
    foreach i [array names faceset] {
	set face_info [lsort -unique $faceset($i)]      

	#get the first item to know the type to print caption
	set face [lindex $face_info 0]
	if { $face != "" } {
	    lassign $face elem face_ident type
	    set original_type $type            
	    incr num_zones
	    set dict_zones($num_zones) [list $i [Fluent_cond_name $original_type]] 
	    append _ "(0 \"Face $num_zones : $i\")\n"
	    incr num_faces
	    append _ "(13 ([format %x $num_zones] [format %x $num_faces]" 
	    incr num_faces [expr ([llength $face_info]-1)]
	    append _ " [format %x $num_faces] [format %x [expr (int($original_type))]] 0)(\n"  
	}
	foreach face $face_info {
	    lassign $face elem face_ident type                                    
	    if {$type ne $original_type} {
		error [= "Element %s of face set $i has a boundary type not according with the rest of the elements from its condition. Please correct this" $elem]
	    }            
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
	     
	    foreach connectivity_node $connectivities {
		append _ " [format %x $connectivity_node]"
	    }  
		
	    #We always append the right element, which is the studied element. We use the elements dict to find the real value
	    set real_elem $dict_elements($elem)
	    append _ " [format %x $real_elem]"
	    
	    #We found the element in our array
	    
	    
	    set face_key [give_hexadecimal_name [lsort -integer $connectivities]]
	    set found_left 0            
	    if {[info exists face_to_elements($face_key)]} {
		#We mark as printed this face in the array
		lset face_to_elements($face_key) 0 1
		#Then we write the left cell if needed 
		if {[llength $face_to_elements($face_key)] eq "4"} {                 
		    if {[lindex $face_to_elements($face_key) 3] eq $elem} {
		        set real_elem $dict_elements([lindex $face_to_elements($face_key) 2])
		    } else {
		        set real_elem $dict_elements([lindex $face_to_elements($face_key) 3])
		    }
		    append _ " [format %x $real_elem]\n"
		    set found_left 1
		} 
	    }
		        
	    
	    #If we don't find a left cell we just print 0            
	    if {$found_left eq "0"} {append _ " 0\n"}  
	}
	
	append _ "))\n" 
    }

    puts -nonewline $fp $_ ; set _ ""

    #set t(8) [clock milliseconds]      
    #Non printed faces will be printed as interior faces or walls:
    
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
    #set t(9) [clock milliseconds]      
    #Default interior zone
    
    if {$interior_faces > 0} {
	incr num_zones
	set dict_zones($num_zones) [list Default_interior_zone interior]
	append _ "(0 \"Face [format %x $num_zones] : Default_interior_zone\")\n"
	append _ "(13 ([format %x $num_zones] [format %x [expr ($num_faces+1)]] [format %x [expr ($num_faces+$interior_faces)]] 2 0)(\n"
	
	foreach face [array names face_to_elements] {
	    if {[lindex $face_to_elements($face) 0] eq "0" && [llength $face_to_elements($face)] eq "4"} {
		set connectivities [split [lindex $face_to_elements($face) 1] ":"]
		append _ [llength $connectivities]
		foreach node $connectivities { append _ " $node" }            
		set real_elem1 $dict_elements([lindex $face_to_elements($face) 2])
		set real_elem2 $dict_elements([lindex $face_to_elements($face) 3])
		append _ " [format %x $real_elem1] [format %x $real_elem2]\n"
	    }
	}        
	append _ "))\n" 
    }
    puts -nonewline $fp $_ ; set _ ""

    #set t(10) [clock milliseconds]      
    #Default Wall zone    
    
    if {$wall_faces > 0} {
	incr num_zones
	set dict_zones($num_zones) [list Default_wall_zone  wall] 
	append _ "(0 \"Face [format %x $num_zones] : Default_wall_zone\")\n"
	append _ "(13 ([format %x $num_zones] [format %x [expr ($num_faces+$interior_faces+1)]] [format %x [expr ($num_faces+$interior_faces+$wall_faces)]] 3 0)(\n"        
	foreach face [array names face_to_elements] {
	    if {([lindex $face_to_elements($face) 0] eq "0") && ([llength $face_to_elements($face)] eq "3")} {
		set connectivities [split [lindex $face_to_elements($face) 1] ":"]
		append _ [llength $connectivities]
		foreach node $connectivities { append _ " $node" }
		set real_elem $dict_elements([lindex $face_to_elements($face) 2])
		append _ " [format %x $real_elem] 0\n"
	    }
	}        
	append _ "))\n" 
    }
    puts -nonewline $fp $_ ; set _ ""
    #set t(11) [clock milliseconds]      
    #ZONES DEFINITION++++++++++
    
    append _ "(0 \"Zones definition:\")\n"
    
    foreach ZONE_ID [lsort -integer [array names dict_zones]] {
	lassign $dict_zones($ZONE_ID) name ZONE_TYPE
	append _ "(45 ($ZONE_ID $ZONE_TYPE $name)())\n"        
    }
    
    puts -nonewline $fp $_ ; set _ ""
    close $fp
       
    #set t(12) [clock milliseconds]  
    #for {set i 0} {$i<12} {incr i} {
    #    WarnWinText "$i   [expr ($t([expr $i+1])-$t($i))*0.001]"
    #}
    #WarnWinText "Total [expr ($t(12)-$t(0))*0.001]"

    return ""
}
